# Configuration Management Functions

function Backup-Configuration {
    param(
        [string]$SourcePath,
        [string]$BackupDir
    )
    
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupPath = Join-Path $BackupDir "config_$timestamp"
    
    try {
        if (Test-Path $SourcePath) {
            Copy-Item -Path $SourcePath -Destination $backupPath -Recurse -Force
            Write-Log "Configuration backed up to $backupPath" -Level 'INFO'
            return $backupPath
        }
    }
    catch {
        Write-Log "Failed to backup configuration: $_" -Level 'ERROR'
        throw
    }
}

function Update-Configuration {
    param(
        [string]$TemplatePath,
        [string]$TargetPath,
        [hashtable]$Parameters
    )
    
    try {
        $content = Get-Content $TemplatePath -Raw
        foreach ($key in $Parameters.Keys) {
            $content = $content.Replace("{{$key}}", $Parameters[$key])
        }
        Set-Content -Path $TargetPath -Value $content
        Write-Log "Configuration updated at $TargetPath" -Level 'INFO'
    }
    catch {
        Write-Log "Failed to update configuration: $_" -Level 'ERROR'
        throw
    }
}

function Test-Configuration {
    param(
        [string]$ConfigPath
    )
    
    try {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Yaml
        # Add validation logic here
        Write-Log "Configuration validation successful" -Level 'INFO'
        return $true
    }
    catch {
        Write-Log "Configuration validation failed: $_" -Level 'ERROR'
        return $false
    }
}
