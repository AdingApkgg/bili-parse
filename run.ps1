<#
.SYNOPSIS
    Video Parse Service Management Script
.DESCRIPTION
    Usage: .\run.ps1 [command]
    Commands: start, stop, restart, status, logs, build, clean, help
#>

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "build", "clean", "help")]
    [string]$Command = "help"
)

$ErrorActionPreference = "Stop"

function Get-ContainerRuntime {
    if (Get-Command podman -ErrorAction SilentlyContinue) {
        return "podman"
    }
    elseif (Get-Command docker -ErrorAction SilentlyContinue) {
        return "docker"
    }
    else {
        Write-Error "podman or docker not found. Please install container runtime first."
        exit 1
    }
}

$Runtime = Get-ContainerRuntime
Write-Host "Container runtime: $Runtime" -ForegroundColor Cyan

function Start-Services {
    Write-Host "Starting services..." -ForegroundColor Green
    & $Runtime compose up -d
    Write-Host ""
    Write-Host "Services started: http://localhost:7891" -ForegroundColor Yellow
}

function Stop-Services {
    Write-Host "Stopping services..." -ForegroundColor Yellow
    & $Runtime compose down
    Write-Host "Services stopped." -ForegroundColor Green
}

function Restart-Services {
    Write-Host "Restarting services..." -ForegroundColor Yellow
    & $Runtime compose down
    & $Runtime compose up -d
    Write-Host ""
    Write-Host "Services restarted: http://localhost:7891" -ForegroundColor Green
}

function Get-ServiceStatus {
    Write-Host "Service status:" -ForegroundColor Cyan
    & $Runtime compose ps
}

function Get-ServiceLogs {
    Write-Host "Viewing logs (Ctrl+C to exit):" -ForegroundColor Cyan
    & $Runtime compose logs -f
}

function Build-Services {
    Write-Host "Building images..." -ForegroundColor Yellow
    & $Runtime compose build --no-cache
    Write-Host "Build completed." -ForegroundColor Green
}

function Clean-All {
    Write-Host "Cleaning all containers and images..." -ForegroundColor Red
    & $Runtime compose down -v --rmi all
    Write-Host "Cleanup completed." -ForegroundColor Green
}

function Show-Help {
    Write-Host ""
    Write-Host "Video Parse Service Management Script" -ForegroundColor White
    Write-Host "======================================" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage: .\run.ps1 [command]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor White
    Write-Host "  start     Start all services" -ForegroundColor White
    Write-Host "  stop      Stop all services" -ForegroundColor White
    Write-Host "  restart   Restart all services" -ForegroundColor White
    Write-Host "  status    Show service status" -ForegroundColor White
    Write-Host "  logs      View realtime logs" -ForegroundColor White
    Write-Host "  build     Rebuild images" -ForegroundColor White
    Write-Host "  clean     Remove all containers and images" -ForegroundColor White
    Write-Host "  help      Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  .\run.ps1 start" -ForegroundColor White
    Write-Host "  .\run.ps1 logs" -ForegroundColor White
    Write-Host "  .\run.ps1 restart" -ForegroundColor White
    Write-Host ""
    Write-Host "Access URL: http://localhost:7891" -ForegroundColor Yellow
    Write-Host ""
}

Push-Location $PSScriptRoot

try {
    switch ($Command) {
        "start"   { Start-Services }
        "stop"    { Stop-Services }
        "restart" { Restart-Services }
        "status"  { Get-ServiceStatus }
        "logs"    { Get-ServiceLogs }
        "build"   { Build-Services }
        "clean"   { Clean-All }
        "help"    { Show-Help }
        default   { Show-Help }
    }
}
finally {
    Pop-Location
}
