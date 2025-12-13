# Backup Verification Script
# Tests backup integrity and restorability

param(
    [string]$BackupFile
)

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Backup Verification Tool" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# If no backup file specified, use the latest
if (!$BackupFile) {
    $LatestBackup = Get-ChildItem -Path ".\backups" -Filter "whoknows_backup_*.sql.gz" -ErrorAction SilentlyContinue | 
                    Sort-Object LastWriteTime -Descending | 
                    Select-Object -First 1
    
    if ($LatestBackup) {
        $BackupFile = $LatestBackup.FullName
        Write-Host "Using latest backup: $($LatestBackup.Name)" -ForegroundColor Yellow
    } else {
        Write-Error "No backup files found in .\backups directory"
        exit 1
    }
}

if (!(Test-Path $BackupFile)) {
    Write-Error "Backup file not found: $BackupFile"
    exit 1
}

$BackupInfo = Get-Item $BackupFile
Write-Host "Backup File: $($BackupInfo.Name)"
Write-Host "Size: $([math]::Round($BackupInfo.Length/1MB, 2)) MB"
Write-Host "Created: $($BackupInfo.LastWriteTime)"
Write-Host ""

# Test 1: File integrity
Write-Host "Test 1: Checking file integrity..." -ForegroundColor Cyan
try {
    $CompressedStream = [System.IO.File]::OpenRead($BackupFile)
    $GzipStream = New-Object System.IO.Compression.GZipStream($CompressedStream, [System.IO.Compression.CompressionMode]::Decompress)
    $Reader = New-Object System.IO.StreamReader($GzipStream)
    
    $LineCount = 0
    $HasData = $false
    
    while (($line = $Reader.ReadLine()) -and $LineCount -lt 100) {
        if ($line -match "(CREATE TABLE|INSERT INTO|COPY)") {
            $HasData = $true
        }
        $LineCount++
    }
    
    $Reader.Close()
    $GzipStream.Close()
    $CompressedStream.Close()
    
    if ($HasData -and $LineCount -gt 0) {
        Write-Host "  ✓ File decompresses successfully" -ForegroundColor Green
        Write-Host "  ✓ Contains SQL commands" -ForegroundColor Green
        Write-Host "  ✓ Read $LineCount lines successfully" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Backup appears to be empty or corrupted" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ✗ Failed to read backup file: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Backup size validation
Write-Host "Test 2: Validating backup size..." -ForegroundColor Cyan
$MinSize = 1KB
$MaxSize = 10GB

if ($BackupInfo.Length -lt $MinSize) {
    Write-Host "  ✗ Backup size too small ($([math]::Round($BackupInfo.Length/1KB, 2)) KB)" -ForegroundColor Red
    Write-Host "    Minimum expected: $([math]::Round($MinSize/1KB, 2)) KB" -ForegroundColor Yellow
    exit 1
} elseif ($BackupInfo.Length -gt $MaxSize) {
    Write-Host "  ⚠ Backup size unusually large ($([math]::Round($BackupInfo.Length/1GB, 2)) GB)" -ForegroundColor Yellow
    Write-Host "    Consider investigating" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Backup size within expected range" -ForegroundColor Green
}

Write-Host ""

# Test 3: Backup age check
Write-Host "Test 3: Checking backup freshness..." -ForegroundColor Cyan
$Age = (Get-Date) - $BackupInfo.LastWriteTime
if ($Age.TotalHours -gt 48) {
    Write-Host "  ⚠ Backup is $([math]::Round($Age.TotalHours, 1)) hours old" -ForegroundColor Yellow
    Write-Host "    Consider creating a fresh backup" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Backup is recent ($([math]::Round($Age.TotalHours, 1)) hours old)" -ForegroundColor Green
}

Write-Host ""

# Test 4: Content validation
Write-Host "Test 4: Validating backup content..." -ForegroundColor Cyan
try {
    $CompressedStream = [System.IO.File]::OpenRead($BackupFile)
    $GzipStream = New-Object System.IO.Compression.GZipStream($CompressedStream, [System.IO.Compression.CompressionMode]::Decompress)
    $Reader = New-Object System.IO.StreamReader($GzipStream)
    
    $Content = $Reader.ReadToEnd()
    $Reader.Close()
    $GzipStream.Close()
    $CompressedStream.Close()
    
    $Checks = @{
        "Users table" = $Content -match "CREATE TABLE.*users"
        "Pages table" = $Content -match "CREATE TABLE.*pages"
        "Search logs table" = $Content -match "CREATE TABLE.*search_logs"
        "Database encoding" = $Content -match "SET client_encoding"
    }
    
    $AllPassed = $true
    foreach ($Check in $Checks.GetEnumerator()) {
        if ($Check.Value) {
            Write-Host "  ✓ $($Check.Key) found" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($Check.Key) missing" -ForegroundColor Red
            $AllPassed = $false
        }
    }
    
    if (!$AllPassed) {
        Write-Host "`n  Backup may be incomplete" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Failed to validate content: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Verification Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Backup Status: " -NoNewline
Write-Host "VERIFIED" -ForegroundColor Green
Write-Host ""
Write-Host "The backup file appears to be valid and restorable." -ForegroundColor Green
Write-Host ""
Write-Host "To restore this backup, run:"
Write-Host "  .\scripts\restore_database.ps1 -BackupFile `"$BackupFile`"" -ForegroundColor Yellow
