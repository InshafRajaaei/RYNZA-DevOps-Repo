# MongoDB Restore Script for Windows
param(
    [string]$BackupFolder,
    [string]$ConnectionString = "mongodb://ecommerce_user:ecommerce_pass@localhost:27017/e-commerce"
)

if (!$BackupFolder) {
    Write-Host "Usage: .\restore.ps1 <BackupFolder>" -ForegroundColor Yellow
    Write-Host "`nAvailable backups:" -ForegroundColor Cyan
    
    if (Test-Path ".\backups") {
        Get-ChildItem ".\backups" -Directory | Sort-Object LastWriteTime -Descending | Format-Table Name, LastWriteTime -AutoSize
    } else {
        Write-Host "No backups directory found" -ForegroundColor Red
    }
    exit 1
}

$BackupPath = ".\backups\$BackupFolder"

if (!(Test-Path $BackupPath)) {
    Write-Host "❌ Backup folder not found: $BackupPath" -ForegroundColor Red
    Write-Host "💡 Available backups:" -ForegroundColor Yellow
    Get-ChildItem ".\backups" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 5 Name
    exit 1
}

Write-Host "Restoring MongoDB from backup..." -ForegroundColor Green
Write-Host "Backup: $BackupPath" -ForegroundColor Yellow
Write-Host "Database: e-commerce" -ForegroundColor Yellow

try {
    # Confirm restoration
    $confirmation = Read-Host "This will overwrite existing data. Continue? (y/N)"
    if ($confirmation -ne 'y') {
        Write-Host "Restore cancelled" -ForegroundColor Yellow
        exit 0
    }

    # Execute mongorestore
    mongorestore --uri="$ConnectionString" --drop "$BackupPath"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Restore completed successfully!" -ForegroundColor Green
        Write-Host "📊 Database has been restored from: $BackupFolder" -ForegroundColor Cyan
    } else {
        throw "mongorestore failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Restore failed: $($_.Exception.Message)" -ForegroundColor Red
}