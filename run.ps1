# 视频外链解析服务管理脚本
# 用法: .\run.ps1 [命令]
# 命令: start, stop, restart, status, logs, build, clean

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "build", "clean", "help")]
    [string]$Command = "help"
)

$ErrorActionPreference = "Stop"

# 检查 podman 或 docker
function Get-ContainerRuntime {
    if (Get-Command podman -ErrorAction SilentlyContinue) {
        return "podman"
    }
    elseif (Get-Command docker -ErrorAction SilentlyContinue) {
        return "docker"
    }
    else {
        Write-Error "未找到 podman 或 docker，请先安装容器运行时"
        exit 1
    }
}

$Runtime = Get-ContainerRuntime
Write-Host "使用容器运行时: $Runtime" -ForegroundColor Cyan

function Start-Services {
    Write-Host "启动服务..." -ForegroundColor Green
    & $Runtime compose up -d
    Write-Host ""
    Write-Host "服务已启动，访问地址: http://localhost:7891" -ForegroundColor Yellow
}

function Stop-Services {
    Write-Host "停止服务..." -ForegroundColor Yellow
    & $Runtime compose down
    Write-Host "服务已停止" -ForegroundColor Green
}

function Restart-Services {
    Write-Host "重启服务..." -ForegroundColor Yellow
    & $Runtime compose down
    & $Runtime compose up -d
    Write-Host ""
    Write-Host "服务已重启，访问地址: http://localhost:7891" -ForegroundColor Green
}

function Get-ServiceStatus {
    Write-Host "服务状态:" -ForegroundColor Cyan
    & $Runtime compose ps
}

function Get-ServiceLogs {
    Write-Host "查看日志 (Ctrl+C 退出):" -ForegroundColor Cyan
    & $Runtime compose logs -f
}

function Build-Services {
    Write-Host "构建镜像..." -ForegroundColor Yellow
    & $Runtime compose build --no-cache
    Write-Host "构建完成" -ForegroundColor Green
}

function Clean-All {
    Write-Host "清理所有容器和镜像..." -ForegroundColor Red
    & $Runtime compose down -v --rmi all
    Write-Host "清理完成" -ForegroundColor Green
}

function Show-Help {
    Write-Host ""
    Write-Host "视频外链解析服务管理脚本" -ForegroundColor White
    Write-Host "========================" -ForegroundColor White
    Write-Host ""
    Write-Host "用法: .\run.ps1 [命令]" -ForegroundColor White
    Write-Host ""
    Write-Host "命令:" -ForegroundColor White
    Write-Host "  start     启动所有服务" -ForegroundColor White
    Write-Host "  stop      停止所有服务" -ForegroundColor White
    Write-Host "  restart   重启所有服务" -ForegroundColor White
    Write-Host "  status    查看服务状态" -ForegroundColor White
    Write-Host "  logs      查看实时日志" -ForegroundColor White
    Write-Host "  build     重新构建镜像" -ForegroundColor White
    Write-Host "  clean     清理所有容器和镜像" -ForegroundColor White
    Write-Host "  help      显示此帮助" -ForegroundColor White
    Write-Host ""
    Write-Host "示例:" -ForegroundColor White
    Write-Host "  .\run.ps1 start     # 启动服务" -ForegroundColor White
    Write-Host "  .\run.ps1 logs      # 查看日志" -ForegroundColor White
    Write-Host "  .\run.ps1 restart   # 重启服务" -ForegroundColor White
    Write-Host ""
    Write-Host "访问地址: http://localhost:7891" -ForegroundColor Yellow
    Write-Host ""
}

# 切换到脚本所在目录
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
