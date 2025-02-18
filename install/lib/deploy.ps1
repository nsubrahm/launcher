# Deployment Management Functions

function Start-Services {
    param(
        [string]$EnvFile,
        [string]$ComposeFile,
        [string]$ProjectName,
        [string]$Phase
    )
    
    try {
        Write-Host "Starting $Phase services..."
        docker compose --env-file $EnvFile -f $ComposeFile up -d
        Write-Log "$Phase services started successfully" -Level 'INFO'
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log "Failed to start $Phase services: $errorMsg" -Level 'ERROR'
        throw
    }
}

function Test-ServiceHealth {
    param(
        [string]$ProjectName,
        [string]$Phase
    )
    
    try {
        $containers = docker ps --filter "name=mitra-$Phase" --format "{{.Names}}"
        $unhealthyContainers = @()
        
        foreach ($container in $containers) {
            $health = docker inspect --format='{{.State.Health.Status}}' $container
            if ($health -ne 'healthy' -and $health -ne $null) {
                $unhealthyContainers += $container
            }
        }
        
        return $unhealthyContainers
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log "Failed to check service health: $errorMsg" -Level 'ERROR'
        throw
    }
}

function Wait-ForHealthyServices {
    param(
        [string]$ProjectName,
        [string]$Phase,
        [int]$TimeoutSeconds = 300
    )
    
    $timer = [Diagnostics.Stopwatch]::StartNew()
    
    while ($timer.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
        $unhealthy = Test-ServiceHealth -ProjectName $ProjectName -Phase $Phase
        
        if ($unhealthy.Count -eq 0) {
            Write-Log "All $Phase services are healthy" -Level 'INFO'
            return $true
        }
        
        Write-Host "Waiting for $Phase services to be healthy: $($unhealthy -join ', ')"
        Start-Sleep -Seconds 10
    }
    
    Write-Log "Timeout waiting for $Phase services to be healthy" -Level 'ERROR'
    return $false
}

function Deploy-Stack {
    param(
        [string]$LaunchPath,
        [string]$Phase
    )
    
    $envFile = Join-Path $LaunchPath "conf\$Phase.env"
    $composeFile = Join-Path $LaunchPath "stacks\$Phase.yaml"
    
    try {
        # Start services
        Start-Services -EnvFile $envFile -ComposeFile $composeFile -ProjectName "mtmt" -Phase $Phase
        
        # Wait for services to be healthy (skip for init as it's meant to stop)
        if ($Phase -ne "init") {
            if (-not (Wait-ForHealthyServices -ProjectName "mtmt" -Phase $Phase -TimeoutSeconds 300)) {
                throw "Services failed to become healthy"
            }
        }
        
        Write-Host "      ✓ $Phase deployment completed" -ForegroundColor Green
        return $true
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log "Failed to deploy $Phase stack: $errorMsg" -Level 'ERROR'
        throw
    }
}

function Start-StackDeployment {
    param(
        [string]$LaunchPath
    )
    
    $deploymentOrder = @(
        "platform",
        "base",
        "init",
        "apps"
    )
    
    try {
        foreach ($phase in $deploymentOrder) {
            Write-Host "`nDeploying $phase stack..." -ForegroundColor Yellow
            Deploy-Stack -LaunchPath $LaunchPath -Phase $phase
            
            # Special handling for init phase
            if ($phase -eq "init") {
                # Wait for init containers to complete
                Write-Host "Waiting for initialization to complete..."
                Start-Sleep -Seconds 30
                
                # Verify init containers completed successfully
                $initContainers = docker ps -a --filter "name=mitra-.*-init-" --format "{{.Names}}"
                foreach ($container in $initContainers) {
                    $exitCode = docker inspect --format='{{.State.ExitCode}}' $container
                    if ($exitCode -ne 0) {
                        throw "Initialization container $container failed with exit code $exitCode"
                    }
                }
                Write-Host "      ✓ Initialization completed successfully" -ForegroundColor Green
            }
        }
        
        return $true
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log "Stack deployment failed: $errorMsg" -Level 'ERROR'
        throw
    }
}

function Test-Endpoints {
    param(
        [hashtable]$Endpoints
    )
    
    $failedEndpoints = @()
    
    foreach ($endpoint in $Endpoints.GetEnumerator()) {
        try {
            $response = Invoke-WebRequest -Uri $endpoint.Value -Method HEAD -UseBasicParsing
            if ($response.StatusCode -ne 200) {
                $failedEndpoints += $endpoint.Key
            }
        }
        catch {
            $failedEndpoints += $endpoint.Key
        }
    }
    
    return $failedEndpoints
}
