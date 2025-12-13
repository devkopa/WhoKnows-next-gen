# Database Backup Script for WhoKnows Application (Windows)
# Usage: .\backup_database.ps1

param(
    [int]$RetentionDays = 7
)

$ErrorActionPreference = "Stop"

# Configuration
$BackupDir = ".\backups"
$Date = Get-Date -Format "yyyyMMdd_HHmmss"

# Load environment variables from .env file
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^#].+?)=(.+)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            Set-Item -Path "env:$name" -Value $value
        }
    }
} else {
    Write-Error ".env file not found"
    exit 1
}

# Create backup directory if it doesn't exist
if (!(Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

Write-Host "Starting database backup..." -ForegroundColor Green
Write-Host "Database: $env:POSTGRES_DB"
Write-Host "Timestamp: $Date"

# Create backup
$BackupFile = "$BackupDir\whoknows_backup_$Date.sql"
Write-Host "Creating backup..."

docker-compose exec -T postgres pg_dump -U $env:POSTGRES_USER $env:POSTGRES_DB | Out-File -FilePath $BackupFile -Encoding UTF8

# Compress backup using .NET
Write-Host "Compressing backup..."
$CompressedFile = "$BackupFile.gz"
$InputStream = [System.IO.File]::OpenRead($BackupFile)
$OutputStream = [System.IO.File]::Create($CompressedFile)
$GzipStream = New-Object System.IO.Compression.GZipStream($OutputStream, [System.IO.Compression.CompressionMode]::Compress)
$InputStream.CopyTo($GzipStream)
$GzipStream.Close()
$OutputStream.Close()
$InputStream.Close()

# Remove uncompressed file
Remove-Item $BackupFile

# Check if backup was successful
if (Test-Path $CompressedFile) {
    $BackupSize = (Get-Item $CompressedFile).Length / 1MB
    Write-Host "Backup completed successfully!" -ForegroundColor Green
    Write-Host "File: $CompressedFile"
    Write-Host "Size: $([math]::Round($BackupSize, 2)) MB"
} else {
    Write-Error "Backup failed"
    exit 1
}

# Remove old backups
Write-Host "`nCleaning up old backups (older than $RetentionDays days)..."
$CutoffDate = (Get-Date).AddDays(-$RetentionDays)
Get-ChildItem -Path $BackupDir -Filter "whoknows_backup_*.sql.gz" | 
    Where-Object { $_.LastWriteTime -lt $CutoffDate } | 
    Remove-Item -Force

Write-Host "Cleanup completed"

# List current backups
Write-Host "`nCurrent backups:"
Get-ChildItem -Path $BackupDir -Filter "whoknows_backup_*.sql.gz" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 5 | 
    Format-Table Name, @{Name="Size (MB)";Expression={[math]::Round($_.Length/1MB, 2)}}, LastWriteTime -AutoSize

Write-Host "`nBackup process completed successfully!" -ForegroundColor Green
