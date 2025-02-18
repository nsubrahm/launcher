# Docker Management Functions

function Test-DockerImages {
    param(
        [array]$RequiredImages
    )
    
    $missingImages = @()
    foreach ($image in $RequiredImages) {
        $imageTag = "$($image.name):$($image.tag)"
        try {
            $null = docker image inspect $imageTag 2>&1
        }
        catch {
            $missingImages += $imageTag
        }
    }
    return $missingImages
}

function Pull-DockerImages {
    param(
        [array]$Images
    )
    
    foreach ($image in $Images) {
        $imageTag = "$($image.name):$($image.tag)"
        try {
            Write-Host "Pulling $imageTag..."
            docker pull $imageTag
            Write-Log "Successfully pulled $imageTag" -Level 'INFO'
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Log "Failed to pull $imageTag : $errorMsg" -Level 'ERROR'
            throw
        }
    }
}

function Test-DockerNetwork {
    param(
        [string]$NetworkName
    )
    
    try {
        $network = docker network inspect $NetworkName 2>&1
        return $true
    }
    catch {
        return $false
    }
}

function New-DockerNetwork {
    param(
        [string]$NetworkName
    )
    
    if (-not (Test-DockerNetwork $NetworkName)) {
        try {
            docker network create $NetworkName
            Write-Log "Created Docker network: $NetworkName" -Level 'INFO'
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Log "Failed to create Docker network : $errorMsg" -Level 'ERROR'
            throw
        }
    }
}

function Remove-DockerResources {
    param(
        [string]$ProjectName
    )
    
    try {
        # Stop and remove containers
        docker-compose -p $ProjectName down --remove-orphans
        
        # Remove networks
        docker network prune -f
        
        # Remove volumes
        docker volume prune -f
        
        Write-Log "Docker resources cleaned up successfully" -Level 'INFO'
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log "Failed to clean up Docker resources : $errorMsg" -Level 'ERROR'
        throw
    }
}
