# Admin check
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Admin rights required"
    exit 1
}

$timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$backupDir = "C:\\Temp\\AppCompat_Backup_$timestamp"
New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
Write-Host "Backup directory created: $backupDir"

function Export-RegistryKeyIfExists {
    param($hivePath, $outfile)
    try {
        reg export $hivePath $outfile /y > $null 2>&1
        if ($LASTEXITCODE -eq 0) { Write-Host "Backup: $outfile" }
    } catch {
        Write-Warning "Backup failed: $hivePath"
    }
}

$regPathsToBackup = @(
    "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Layers",
    "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Compatibility Assistant\\Store",
    "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Compatibility Assistant\\Persisted",
    "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Layers",
    "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Compatibility Assistant",
    "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat",
    "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompat"
)

Write-Host "Creating registry backups..."
foreach ($r in $regPathsToBackup) {
    $out = Join-Path $backupDir ( ($r -replace '[\\\\:]','_') + ".reg" )
    Export-RegistryKeyIfExists -hivePath $r -outfile $out
}

function Remove-RegistryPathSafe {
    param($path)
    try {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            Write-Host "Removed: $path"
        } else {
            Write-Host "Not present: $path"
        }
    } catch {
        Write-Warning "Error during removal: $path - $_"
    }
}

Write-Host "Cleaning up registry entries..."
$pathsToRemove = @(
    "HKCU:\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Layers",
    "HKCU:\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Compatibility Assistant\\Store",
    "HKCU:\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Compatibility Assistant\\Persisted",
    "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Layers",
    "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Compatibility Assistant"
)

foreach ($p in $pathsToRemove) { Remove-RegistryPathSafe -path $p }

Write-Host "Setting PCA deactivation..."
try {
    $policyPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat"
    if (-not (Test-Path $policyPath)) { 
        New-Item -Path $policyPath -Force | Out-Null
        Write-Host "Policy path created: $policyPath"
    }
    New-ItemProperty -Path $policyPath -Name "DisablePCA" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Host "Policy DisablePCA set: $policyPath\\DisablePCA = 1"

    $winPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompat"
    if (-not (Test-Path $winPath)) { 
        New-Item -Path $winPath -Force | Out-Null
        Write-Host "Registry path created: $winPath"
    }
    New-ItemProperty -Path $winPath -Name "DisablePCA" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Host "Registry DisablePCA set: $winPath\\DisablePCA = 1"
} catch {
    Write-Warning "Error setting DisablePCA: $_"
}

Write-Host "Stopping PCA Service..."
try {
    $svcName = "PcaSvc"
    if (Get-Service -Name $svcName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $svcName -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svcName -StartupType Disabled
        Write-Host "Service stopped and disabled: $svcName"
    } else {
        Write-Host "Service $svcName not found."
    }
} catch {
    Write-Warning "Error during service handling: $_"
}

Write-Host "Compatibility fix completed! Developed by fzer0x"
Write-Host "Backups are located in: $backupDir"
Write-Host "A restart is recommended"