# MongoDB Backup Script for Windows
param(
    [string]$BackupPath = ".\backups",
    [string]$ConnectionString = "mongodb://ecommerce_user:ecommerce_pass@localhost:27017/e-commerce"
)

$Date = Get-Date -Format "yyyyMMdd_%HHmmss"
$BackupDir = "$BackupPath\$Date"

Write-Host "Starting MongoDB backup..." -ForegroundColor Green
Write-Host "Backup Directory: $BackupDir" -ForegroundColor Yellow
Write-Host "Database: e-commerce" -ForegroundColor Yellow

# Create backup directory if it doesn't exist
if (!(Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force
    Write-Host "Created backup directory: $BackupPath" -ForegroundColor Green
}

try {
    # Execute mongodump
    mongodump --uri="$ConnectionString" --out="$BackupDir"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backup completed successfully!" -ForegroundColor Green
        Write-Host "📁 Backup location: $BackupDir" -ForegroundColor Cyan
        
        # Show backup size
        $Size = (Get-ChildItem $BackupDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "💾 Backup size: $([math]::Round($Size, 2)) MB" -ForegroundColor Cyan
        
        # List available backups
        Write-Host "`nAvailable backups:" -ForegroundColor Magenta
        Get-ChildItem $BackupPath -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 5 Name
    } else {
        throw "mongodump failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Backup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Make sure MongoDB is running and connection string is correct" -ForegroundColor Yellow
}