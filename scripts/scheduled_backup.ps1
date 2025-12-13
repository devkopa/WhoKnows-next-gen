# Scheduled Database Backup (Windows Task Scheduler)
# This script should be run via Windows Task Scheduler

param(
    [string]$LogFile = ".\logs\backup_$(Get-Date -Format 'yyyyMMdd').log"
)

# Create logs directory if it doesn't exist
$LogDir = Split-Path $LogFile -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Start logging
Start-Transcript -Path $LogFile -Append

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Automated Database Backup Started" -ForegroundColor Cyan
Write-Host "Time: $(Get-Date)" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

try {
    # Change to project directory
    Set-Location $PSScriptRoot\..

    # Run backup script
    & .\scripts\backup_database.ps1

    # Verify backup was created
    $LatestBackup = Get-ChildItem -Path .\backups -Filter "whoknows_backup_*.sql.gz" | 
                    Sort-Object LastWriteTime -Descending | 
                    Select-Object -First 1

    if ($LatestBackup) {
        Write-Host "`nBackup verification:" -ForegroundColor Green
        Write-Host "Latest backup: $($LatestBackup.Name)"
        Write-Host "Size: $([math]::Round($LatestBackup.Length/1MB, 2)) MB"
        Write-Host "Created: $($LatestBackup.LastWriteTime)"

        # Test backup integrity (basic check)
        $TestFile = "$env:TEMP\backup_test_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        $CompressedStream = [System.IO.File]::OpenRead($LatestBackup.FullName)
        $GzipStream = New-Object System.IO.Compression.GZipStream($CompressedStream, [System.IO.Compression.CompressionMode]::Decompress)
        $Reader = New-Object System.IO.StreamReader($GzipStream)
        $FirstLine = $Reader.ReadLine()
        $Reader.Close()
        $GzipStream.Close()
        $CompressedStream.Close()

        if ($FirstLine) {
            Write-Host "Integrity check: PASSED" -ForegroundColor Green
        } else {
            Write-Host "Integrity check: FAILED" -ForegroundColor Red
            throw "Backup file appears to be corrupted"
        }
    } else {
        throw "No backup file was created"
    }

    Write-Host "`nAutomated backup completed successfully!" -ForegroundColor Green

} catch {
    Write-Host "`nERROR: Automated backup failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Send alert (optional - implement email notification here)
    Write-Host "`nALERT: Please check the backup system immediately!" -ForegroundColor Yellow
    
    exit 1
} finally {
    Stop-Transcript
}

# Rotate log files (keep last 30 days)
Get-ChildItem -Path $LogDir -Filter "backup_*.log" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | 
    Remove-Item -Force
