<#
.SYNOPSIS
    Video Parse Service - Windows Native Runner
.DESCRIPTION
    Usage: .\run.ps1 [command]
    Commands: install, start, stop, build-frontend, help
#>

param(
    [Parameter(Position=0)]
    [ValidateSet("install", "start", "stop", "build-frontend", "status", "help")]
    [string]$Command = "help"
)

$ErrorActionPreference = "Stop"
$BackendDir = Join-Path $PSScriptRoot "backend"
$FrontendDir = Join-Path $PSScriptRoot "frontend"
$VenvDir = Join-Path $BackendDir ".venv"
$PidFile = Join-Path $PSScriptRoot "backend.pid"

function Install-Dependencies {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    
    # Check Python
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Host "Python not found. Please install Python 3.10+ first." -ForegroundColor Red
        Write-Host "Download: https://www.python.org/downloads/" -ForegroundColor Cyan
        exit 1
    }
    
    # Create venv
    Write-Host "Creating Python virtual environment..." -ForegroundColor Cyan
    Push-Location $BackendDir
    python -m venv .venv
    
    # Activate and install
    & "$VenvDir\Scripts\pip.exe" install -r requirements.txt
    Pop-Location
    
    Write-Host ""
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Install Redis: https://github.com/tporadowski/redis/releases" -ForegroundColor White
    Write-Host "  2. Run: .\run.ps1 start" -ForegroundColor White
    Write-Host ""
}

function Start-Backend {
    Write-Host "Starting backend service..." -ForegroundColor Green
    
    if (-not (Test-Path $VenvDir)) {
        Write-Host "Virtual environment not found. Run '.\run.ps1 install' first." -ForegroundColor Red
        exit 1
    }
    
    # Check if already running
    if (Test-Path $PidFile) {
        $existingPid = Get-Content $PidFile
        $proc = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Host "Backend already running (PID: $existingPid)" -ForegroundColor Yellow
            return
        }
    }
    
    # Start backend
    Push-Location $BackendDir
    $env:REDIS_HOST = "localhost"
    $env:REDIS_PORT = "6379"
    
    $process = Start-Process -FilePath "$VenvDir\Scripts\python.exe" `
        -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7891" `
        -PassThru -WindowStyle Hidden
    
    $process.Id | Out-File $PidFile
    Pop-Location
    
    Write-Host ""
    Write-Host "Backend started (PID: $($process.Id))" -ForegroundColor Green
    Write-Host "Access URL: http://localhost:7891" -ForegroundColor Yellow
    Write-Host "API Health: http://localhost:7891/health" -ForegroundColor Yellow
    Write-Host ""
}

function Stop-Backend {
    Write-Host "Stopping backend service..." -ForegroundColor Yellow
    
    if (Test-Path $PidFile) {
        $pid = Get-Content $PidFile
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Id $pid -Force
            Write-Host "Backend stopped (PID: $pid)" -ForegroundColor Green
        }
        Remove-Item $PidFile -Force
    }
    else {
        Write-Host "Backend is not running." -ForegroundColor Yellow
    }
}

function Get-Status {
    Write-Host "Service Status:" -ForegroundColor Cyan
    Write-Host ""
    
    # Check Redis
    $redis = Get-Process redis-server -ErrorAction SilentlyContinue
    if ($redis) {
        Write-Host "  Redis:   Running (PID: $($redis.Id))" -ForegroundColor Green
    }
    else {
        Write-Host "  Redis:   Not running" -ForegroundColor Red
    }
    
    # Check Backend
    if (Test-Path $PidFile) {
        $pid = Get-Content $PidFile
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Host "  Backend: Running (PID: $pid)" -ForegroundColor Green
        }
        else {
            Write-Host "  Backend: Not running (stale PID file)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  Backend: Not running" -ForegroundColor Yellow
    }
    Write-Host ""
}

function Build-Frontend {
    Write-Host "Building frontend..." -ForegroundColor Yellow
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm not found. Please install Node.js first." -ForegroundColor Red
        Write-Host "Download: https://nodejs.org/" -ForegroundColor Cyan
        exit 1
    }
    
    Push-Location $FrontendDir
    npm install
    npm run build
    Pop-Location
    
    # Copy dist to backend static folder
    $distDir = Join-Path $FrontendDir "dist"
    $staticDir = Join-Path $BackendDir "static"
    
    if (Test-Path $staticDir) {
        Remove-Item $staticDir -Recurse -Force
    }
    Copy-Item $distDir $staticDir -Recurse
    
    Write-Host "Frontend built and copied to backend/static" -ForegroundColor Green
}

function Show-Help {
    Write-Host ""
    Write-Host "Video Parse Service - Windows Native Runner" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage: .\run.ps1 [command]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor White
    Write-Host "  install         Install Python dependencies" -ForegroundColor White
    Write-Host "  start           Start backend service" -ForegroundColor White
    Write-Host "  stop            Stop backend service" -ForegroundColor White
    Write-Host "  status          Show service status" -ForegroundColor White
    Write-Host "  build-frontend  Build and deploy frontend" -ForegroundColor White
    Write-Host "  help            Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor Yellow
    Write-Host "  - Python 3.10+  https://www.python.org/downloads/" -ForegroundColor White
    Write-Host "  - Redis         https://github.com/tporadowski/redis/releases" -ForegroundColor White
    Write-Host "  - Node.js       https://nodejs.org/ (for frontend build)" -ForegroundColor White
    Write-Host ""
    Write-Host "Quick Start:" -ForegroundColor Yellow
    Write-Host "  1. .\run.ps1 install" -ForegroundColor White
    Write-Host "  2. Start Redis (redis-server.exe)" -ForegroundColor White
    Write-Host "  3. .\run.ps1 start" -ForegroundColor White
    Write-Host ""
    Write-Host "Access URL: http://localhost:7891" -ForegroundColor Cyan
    Write-Host ""
}

switch ($Command) {
    "install"        { Install-Dependencies }
    "start"          { Start-Backend }
    "stop"           { Stop-Backend }
    "status"         { Get-Status }
    "build-frontend" { Build-Frontend }
    "help"           { Show-Help }
    default          { Show-Help }
}
