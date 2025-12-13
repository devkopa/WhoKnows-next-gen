# Setup Windows Task Scheduler for Automated Backups
# Run this script as Administrator to create scheduled tasks

param(
    [ValidateSet("Daily", "Hourly", "Weekly")]
    [string]$Schedule = "Daily",
    [string]$Time = "02:00"
)

$ErrorActionPreference = "Stop"

# Get the current script location
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$BackupScript = Join-Path $ProjectRoot "scripts\scheduled_backup.ps1"

if (!(Test-Path $BackupScript)) {
    Write-Error "Backup script not found: $BackupScript"
    exit 1
}

Write-Host "Setting up automated database backups..." -ForegroundColor Cyan
Write-Host "Schedule: $Schedule"
Write-Host "Time: $Time (for daily/weekly)"
Write-Host ""

# Task details
$TaskName = "WhoKnows-DatabaseBackup"
$TaskDescription = "Automated database backup for WhoKnows application"
$TaskPath = "\WhoKnows\"

# Check if task already exists
$ExistingTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue

if ($ExistingTask) {
    Write-Host "Task already exists. Removing old task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
}

# Create action
$Action = New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$BackupScript`"" `
    -WorkingDirectory $ProjectRoot

# Create trigger based on schedule
switch ($Schedule) {
    "Hourly" {
        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)
        Write-Host "Trigger: Hourly backups"
    }
    "Daily" {
        $Trigger = New-ScheduledTaskTrigger -Daily -At $Time
        Write-Host "Trigger: Daily backups at $Time"
    }
    "Weekly" {
        $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At $Time
        Write-Host "Trigger: Weekly backups on Sunday at $Time"
    }
}

# Create principal (run whether user is logged on or not)
$Principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

# Create settings
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

# Register the task
try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -TaskPath $TaskPath `
        -Action $Action `
        -Trigger $Trigger `
        -Principal $Principal `
        -Settings $Settings `
        -Description $TaskDescription `
        -Force

    Write-Host "`nScheduled task created successfully!" -ForegroundColor Green
    Write-Host "Task Name: $TaskPath$TaskName"
    Write-Host ""
    Write-Host "To view the task:"
    Write-Host "  Get-ScheduledTask -TaskName '$TaskName' -TaskPath '$TaskPath'"
    Write-Host ""
    Write-Host "To run the task manually:"
    Write-Host "  Start-ScheduledTask -TaskName '$TaskName' -TaskPath '$TaskPath'"
    Write-Host ""
    Write-Host "To remove the task:"
    Write-Host "  Unregister-ScheduledTask -TaskName '$TaskName' -TaskPath '$TaskPath'"

} catch {
    Write-Error "Failed to create scheduled task: $_"
    exit 1
}
