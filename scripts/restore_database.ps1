# Database Restore Script for WhoKnows Application (Windows)
# Usage: .\restore_database.ps1 -BackupFile ".\backups\whoknows_backup_20251213_120000.sql.gz"

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile
)

$ErrorActionPreference = "Stop"

# Check if backup file exists
if (!(Test-Path $BackupFile)) {
    Write-Error "Backup file not found: $BackupFile"
    Write-Host "`nAvailable backups:"
    Get-ChildItem -Path ".\backups" -Filter "whoknows_backup_*.sql.gz" -ErrorAction SilentlyContinue | 
        Format-Table Name, @{Name="Size (MB)";Expression={[math]::Round($_.Length/1MB, 2)}}, LastWriteTime -AutoSize
    exit 1
}

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

Write-Host "WARNING: This will overwrite the current database!" -ForegroundColor Yellow
Write-Host "Database: $env:POSTGRES_DB"
Write-Host "Backup file: $BackupFile"
Write-Host ""

$confirmation = Read-Host "Are you sure you want to continue? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Restore cancelled"
    exit 0
}

Write-Host "`nStarting database restore..." -ForegroundColor Green

# Decompress backup if needed
if ($BackupFile -match '\.gz$') {
    Write-Host "Decompressing backup..."
    $TempFile = "$env:TEMP\restore_temp_$(Get-Date -Format 'yyyyMMddHHmmss').sql"
    
    $CompressedStream = [System.IO.File]::OpenRead($BackupFile)
    $GzipStream = New-Object System.IO.Compression.GZipStream($CompressedStream, [System.IO.Compression.CompressionMode]::Decompress)
    $OutputStream = [System.IO.File]::Create($TempFile)
    $GzipStream.CopyTo($OutputStream)
    $OutputStream.Close()
    $GzipStream.Close()
    $CompressedStream.Close()
    
    $RestoreFile = $TempFile
} else {
    $RestoreFile = $BackupFile
}

# Drop and recreate database
Write-Host "Recreating database..."
@"
DROP DATABASE IF EXISTS $env:POSTGRES_DB;
CREATE DATABASE $env:POSTGRES_DB;
"@ | docker-compose exec -T postgres psql -U $env:POSTGRES_USER -d postgres

# Restore database
Write-Host "Restoring database..."
Get-Content $RestoreFile | docker-compose exec -T postgres psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB

# Clean up temporary file
if ($TempFile) {
    Remove-Item $TempFile -ErrorAction SilentlyContinue
}

Write-Host "`nDatabase restore completed successfully!" -ForegroundColor Green
Write-Host "`nNext steps:"
Write-Host "1. Restart the application: docker-compose restart web"
Write-Host "2. Verify application functionality"
Write-Host "3. Check logs: docker-compose logs web"
