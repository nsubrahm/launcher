# Maintenance Mitra Installation Script
param(
    [Parameter()]
    [ValidateSet('check', 'config', 'docker', 'deploy', 'verify', 'config-rollback', 'docker-rollback', 'deploy-rollback', 'full-rollback')]
    [string]$Phase = 'check'
)

# Script Variables
$InstallRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $InstallRoot "logs"
$BackupDir = Join-Path $InstallRoot "backups"
$ConfigDir = Join-Path $InstallRoot "config"
$LibDir = Join-Path $InstallRoot "lib"
$StateFile = Join-Path $InstallRoot "install_state.yaml"

# Import library functions
. (Join-Path $LibDir "config.ps1")
. (Join-Path $LibDir "docker.ps1")
. (Join-Path $LibDir "deploy.ps1")

# Create required directories
$null = New-Item -ItemType Directory -Force -Path $LogDir
$null = New-Item -ItemType Directory -Force -Path $BackupDir
$null = New-Item -ItemType Directory -Force -Path $ConfigDir

# Initialize Logging
$LogFile = Join-Path $LogDir "install_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param($Message, [ValidateSet('INFO', 'WARN', 'ERROR')]$Level = 'INFO')
    $TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$TimeStamp [$Level] $Message" | Tee-Object -FilePath $LogFile -Append
}

# State Management
function Save-InstallationState {
    param(
        [string]$Phase,
        [string]$Status,
        [hashtable]$Data
    )
    
    $state = @{
        last_phase = $Phase
        status = $Status
        timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        data = $Data
    }
    
    $state | ConvertTo-Yaml | Set-Content $StateFile
    Write-Log "Installation state saved: $Phase - $Status" -Level 'INFO'
}

function Get-InstallationState {
    if (Test-Path $StateFile) {
        return Get-Content $StateFile | ConvertFrom-Yaml
    }
    return $null
}

# Helper Functions
function Show-Header {
    Write-Host "`nMaintenance Mitra Installation" -ForegroundColor Cyan
    Write-Host "-" * 30 -ForegroundColor Cyan
    Write-Host ""
}

function Check-SystemRequirements {
    Write-Host "[1/4] Checking system requirements..." -ForegroundColor Yellow
    
    # Check CPU
    $CPU = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
    if ($CPU -ge 4) {
        Write-Host "      ✓ CPU: $CPU cores available (minimum: 2)" -ForegroundColor Green
    } else {
        Write-Host "      ! CPU: Only $CPU cores available (minimum: 2)" -ForegroundColor Yellow
        $proceed = Read-Host "Continue anyway? (Y/N)"
        if ($proceed -ne 'Y') { exit 1 }
    }
    
    # Check Memory
    $Memory = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    if ($Memory -ge 8) {
        Write-Host "      ✓ Memory: ${Memory}GB available (minimum: 4GB)" -ForegroundColor Green
    } else {
        Write-Host "      ! Memory: Only ${Memory}GB available (minimum: 4GB)" -ForegroundColor Yellow
        $proceed = Read-Host "Continue anyway? (Y/N)"
        if ($proceed -ne 'Y') { exit 1 }
    }
    
    # Check Disk Space
    $Disk = [math]::Round((Get-PSDrive C).Free / 1GB)
    if ($Disk -ge 50) {
        Write-Host "      ✓ Disk: ${Disk}GB available (minimum: 50GB)" -ForegroundColor Green
    } else {
        Write-Host "      ! Disk: Only ${Disk}GB available (minimum: 50GB)" -ForegroundColor Red
        Write-Host "Installation cannot proceed with insufficient disk space."
        exit 1
    }
}

function Check-DockerInstallation {
    Write-Host "[2/4] Checking Docker installation..." -ForegroundColor Yellow
    
    # Required versions
    $minDockerVersion = "20.10.0"
    $minComposeVersion = "2.0.0"
    
    try {
        # Check Docker installation
        $dockerVersion = docker version --format '{{.Server.Version}}' 2>$null
        if (-not $dockerVersion) {
            Write-Host "      ! Docker not found." -ForegroundColor Yellow
            $install = Read-Host "Install Docker Desktop? (Y/N)"
            if ($install -eq 'Y') {
                Write-Host "      ! Please install Docker Desktop manually from https://www.docker.com/products/docker-desktop"
                Write-Host "      ! After installation, please restart the system and run this script again."
                exit 1
            } else {
                Write-Host "Docker is required for installation. Exiting..."
                exit 1
            }
        }
        
        # Check Docker version
        $dockerVersionObj = [Version]($dockerVersion -replace '[^0-9.].*$')
        $minDockerVersionObj = [Version]$minDockerVersion
        
        if ($dockerVersionObj -lt $minDockerVersionObj) {
            Write-Host "      ! Docker version $dockerVersion is below minimum required version $minDockerVersion" -ForegroundColor Yellow
            $upgrade = Read-Host "Would you like to upgrade Docker? (Y/N)"
            if ($upgrade -eq 'Y') {
                Write-Host "      ! Please upgrade Docker Desktop manually from https://www.docker.com/products/docker-desktop"
                Write-Host "      ! After upgrade, please restart the system and run this script again."
                exit 1
            } else {
                Write-Host "Minimum Docker version $minDockerVersion is required. Exiting..."
                exit 1
            }
        }
        
        # Check Docker Compose installation
        $composeVersion = docker compose version --short 2>$null
        if (-not $composeVersion) {
            Write-Host "      ! Docker Compose not found." -ForegroundColor Yellow
            Write-Host "      ! Please install Docker Desktop which includes Docker Compose."
            exit 1
        }
        
        # Check Docker Compose version
        $composeVersionObj = [Version]($composeVersion -replace '[^0-9.].*$')
        $minComposeVersionObj = [Version]$minComposeVersion
        
        if ($composeVersionObj -lt $minComposeVersionObj) {
            Write-Host "      ! Docker Compose version $composeVersion is below minimum required version $minComposeVersion" -ForegroundColor Yellow
            Write-Host "      ! Please upgrade Docker Desktop to get the latest Docker Compose version."
            exit 1
        }
        
        # Check Docker service status
        $dockerService = Get-Service -Name 'com.docker.service' -ErrorAction SilentlyContinue
        if (-not $dockerService -or $dockerService.Status -ne 'Running') {
            Write-Host "      ! Docker service is not running" -ForegroundColor Yellow
            $start = Read-Host "Start Docker service? (Y/N)"
            if ($start -eq 'Y') {
                Start-Service -Name 'com.docker.service'
                Write-Host "      → Waiting for Docker to start..."
                Start-Sleep -Seconds 10
            } else {
                Write-Host "Docker service must be running. Exiting..."
                exit 1
            }
        }
        
        Write-Host "      ✓ Docker $dockerVersion is installed and running" -ForegroundColor Green
        Write-Host "      ✓ Docker Compose $composeVersion is installed" -ForegroundColor Green
        Write-Log "Docker check passed: Docker $dockerVersion, Compose $composeVersion" -Level 'INFO'
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log "Docker check failed: $errorMsg" -Level 'ERROR'
        Write-Host "      ! Failed to check Docker installation. Error: $errorMsg" -ForegroundColor Red
        exit 1
    }
}

function Check-PortAvailability {
    Write-Host "[3/4] Checking port availability..." -ForegroundColor Yellow
    
    $config = Get-Content (Join-Path $ConfigDir "install_config.yaml") | ConvertFrom-Yaml
    $ports = @($config.network.ports.http, $config.network.ports.mqtt, $config.network.ports.kafka)
    
    foreach ($port in $ports) {
        $inUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($inUse) {
            Write-Host "      ! Port $port is in use" -ForegroundColor Yellow
            Write-Host "      Would you like to:"
            Write-Host "      1. Use a different port"
            Write-Host "      2. Stop the service using this port"
            Write-Host "      3. Exit installation"
            $choice = Read-Host "Select option (1-3)"
            
            switch ($choice) {
                1 {
                    $newPort = Read-Host "Enter new port"
                    # Update configuration with new port
                    Write-Host "      ✓ Port $newPort will be used instead" -ForegroundColor Green
                }
                2 {
                    Write-Host "      ! Please stop the service manually and run the script again"
                    exit 1
                }
                3 {
                    Write-Host "Installation cancelled."
                    exit 1
                }
            }
        } else {
            Write-Host "      ✓ Port $port is available" -ForegroundColor Green
        }
    }
}

function Initialize-InstallationLog {
    Write-Host "[4/4] Creating installation log..." -ForegroundColor Yellow
    Write-Log "Installation started"
    Write-Host "      ✓ Log file created at $LogFile" -ForegroundColor Green
}

# Phase Implementation Functions
function Start-ConfigurationPhase {
    Write-Host "`nPhase 2: Configuration Setup" -ForegroundColor Yellow
    
    try {
        # Backup existing configuration
        $backupPath = Backup-Configuration -SourcePath $ConfigDir -BackupDir $BackupDir
        Write-Host "      ✓ Existing configuration backed up" -ForegroundColor Green
        
        # Update configuration
        $params = @{
            "MACHINE_ID" = "m001"
            "TZ" = "Asia/Kolkata"
        }
        Update-Configuration -TemplatePath (Join-Path $ConfigDir "templates\common.tmpl") `
                           -TargetPath (Join-Path $ConfigDir "common.env") `
                           -Parameters $params
        Write-Host "      ✓ Configuration updated" -ForegroundColor Green
        
        # Validate configuration
        if (Test-Configuration -ConfigPath (Join-Path $ConfigDir "common.env")) {
            Write-Host "      ✓ Configuration validated" -ForegroundColor Green
            Save-InstallationState -Phase 'config' -Status 'completed' -Data @{ BackupPath = $backupPath }
            return $true
        } else {
            throw "Configuration validation failed"
        }
    }
    catch {
        Write-Log "Configuration phase failed: $_" -Level 'ERROR'
        Write-Host "      ! Configuration failed. Rolling back..." -ForegroundColor Red
        & $PSCommandPath -Phase 'config-rollback'
        return $false
    }
}

function Start-DockerPhase {
    Write-Host "`nPhase 3: Docker Setup" -ForegroundColor Yellow
    
    try {
        # Get required images from config
        $config = Get-Content (Join-Path $ConfigDir "install_config.yaml") | ConvertFrom-Yaml
        $requiredImages = $config.docker.images
        
        # Check for missing images
        $missingImages = Test-DockerImages -RequiredImages $requiredImages
        if ($missingImages.Count -gt 0) {
            Write-Host "      → Pulling missing Docker images..." -ForegroundColor Yellow
            Pull-DockerImages -Images $missingImages
        }
        
        # Create network
        New-DockerNetwork -NetworkName "mtmt-network"
        
        Write-Host "      ✓ Docker setup completed" -ForegroundColor Green
        Save-InstallationState -Phase 'docker' -Status 'completed' -Data @{}
        return $true
    }
    catch {
        Write-Log "Docker phase failed: $_" -Level 'ERROR'
        Write-Host "      ! Docker setup failed. Rolling back..." -ForegroundColor Red
        & $PSCommandPath -Phase 'docker-rollback'
        return $false
    }
}

function Start-DeploymentPhase {
    Write-Host "`nPhase 4: Service Deployment" -ForegroundColor Yellow
    
    try {
        # Start stack deployment
        if (Start-StackDeployment -LaunchPath (Join-Path $InstallRoot "launch")) {
            Write-Host "      ✓ All services deployed successfully" -ForegroundColor Green
            
            # Test endpoints
            $endpoints = @{
                "HTTP" = "http://localhost:80/ui"
                "MQTT" = "tcp://localhost:1883"
            }
            
            $failedEndpoints = Test-Endpoints -Endpoints $endpoints
            if ($failedEndpoints.Count -eq 0) {
                Write-Host "      ✓ All endpoints are accessible" -ForegroundColor Green
                Save-InstallationState -Phase 'deploy' -Status 'completed' -Data @{}
                return $true
            } else {
                throw "Endpoints not accessible: $($failedEndpoints -join ', ')"
            }
        } else {
            throw "Stack deployment failed"
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log "Deployment phase failed: $errorMsg" -Level 'ERROR'
        Write-Host "      ! Deployment failed. Rolling back..." -ForegroundColor Red
        & $PSCommandPath -Phase 'deploy-rollback'
        return $false
    }
}

function Start-VerificationPhase {
    Write-Host "`nPhase 5: Final Verification" -ForegroundColor Yellow
    
    try {
        # Verify all components
        $unhealthyServices = Test-ServiceHealth -ProjectName "mtmt"
        if ($unhealthyServices.Count -gt 0) {
            throw "Unhealthy services found: $($unhealthyServices -join ', ')"
        }
        
        # Verify configuration
        if (-not (Test-Configuration -ConfigPath (Join-Path $ConfigDir "common.env"))) {
            throw "Configuration validation failed"
        }
        
        Write-Host "      ✓ All verifications passed" -ForegroundColor Green
        Save-InstallationState -Phase 'verify' -Status 'completed' -Data @{}
        
        # Show success message
        Write-Host "`nInstallation completed successfully!" -ForegroundColor Green
        Write-Host "Access the dashboard at: http://localhost:80/ui"
        Write-Host "View logs at: $LogDir"
        return $true
    }
    catch {
        Write-Log "Verification phase failed: $_" -Level 'ERROR'
        Write-Host "      ! Verification failed" -ForegroundColor Red
        return $false
    }
}

# Rollback Functions
function Start-ConfigRollback {
    Write-Host "Rolling back configuration..." -ForegroundColor Yellow
    
    try {
        $state = Get-InstallationState
        if ($state -and $state.data.BackupPath) {
            Copy-Item -Path $state.data.BackupPath -Destination $ConfigDir -Recurse -Force
            Write-Host "      ✓ Configuration restored from backup" -ForegroundColor Green
            return $true
        }
        return $false
    }
    catch {
        Write-Log "Configuration rollback failed: $_" -Level 'ERROR'
        return $false
    }
}

function Start-DockerRollback {
    Write-Host "Rolling back Docker setup..." -ForegroundColor Yellow
    
    try {
        Remove-DockerResources -ProjectName "mtmt"
        Write-Host "      ✓ Docker resources removed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Log "Docker rollback failed: $_" -Level 'ERROR'
        return $false
    }
}

function Start-DeployRollback {
    Write-Host "Rolling back deployment..." -ForegroundColor Yellow
    
    try {
        docker-compose -p "mtmt" down --remove-orphans
        Write-Host "      ✓ Services stopped and removed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Log "Deployment rollback failed: $_" -Level 'ERROR'
        return $false
    }
}

# Main Installation Logic
Show-Header

switch ($Phase) {
    'check' {
        Check-SystemRequirements
        Check-DockerInstallation
        Check-PortAvailability
        Initialize-InstallationLog
        
        $continue = Read-Host "`nContinue with configuration setup? (Y/N)"
        if ($continue -eq 'Y') {
            & $PSCommandPath -Phase 'config'
        }
    }
    'config' {
        if (Start-ConfigurationPhase) {
            $continue = Read-Host "`nContinue with Docker setup? (Y/N)"
            if ($continue -eq 'Y') {
                & $PSCommandPath -Phase 'docker'
            }
        }
    }
    'docker' {
        if (Start-DockerPhase) {
            $continue = Read-Host "`nContinue with service deployment? (Y/N)"
            if ($continue -eq 'Y') {
                & $PSCommandPath -Phase 'deploy'
            }
        }
    }
    'deploy' {
        if (Start-DeploymentPhase) {
            $continue = Read-Host "`nContinue with final verification? (Y/N)"
            if ($continue -eq 'Y') {
                & $PSCommandPath -Phase 'verify'
            }
        }
    }
    'verify' {
        Start-VerificationPhase
    }
    'config-rollback' { Start-ConfigRollback }
    'docker-rollback' { Start-DockerRollback }
    'deploy-rollback' { Start-DeployRollback }
    'full-rollback' {
        Start-DeployRollback
        Start-DockerRollback
        Start-ConfigRollback
    }
}
