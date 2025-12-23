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

function Start-Service {
    Write-Host "启动服务..." -ForegroundColor Green
    & $Runtime compose up -d
    Write-Host "`n服务已启动，访问地址: http://localhost:7891" -ForegroundColor Yellow
}

function Stop-Service {
    Write-Host "停止服务..." -ForegroundColor Yellow
    & $Runtime compose down
    Write-Host "服务已停止" -ForegroundColor Green
}

function Restart-Service {
    Write-Host "重启服务..." -ForegroundColor Yellow
    & $Runtime compose down
    & $Runtime compose up -d
    Write-Host "`n服务已重启，访问地址: http://localhost:7891" -ForegroundColor Green
}

function Get-Status {
    Write-Host "服务状态:" -ForegroundColor Cyan
    & $Runtime compose ps
}

function Get-Logs {
    Write-Host "查看日志 (Ctrl+C 退出):" -ForegroundColor Cyan
    & $Runtime compose logs -f
}

function Build-Service {
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
    Write-Host @"

视频外链解析服务管理脚本
========================

用法: .\run.ps1 [命令]

命令:
  start     启动所有服务
  stop      停止所有服务
  restart   重启所有服务
  status    查看服务状态
  logs      查看实时日志
  build     重新构建镜像
  clean     清理所有容器和镜像
  help      显示此帮助

示例:
  .\run.ps1 start     # 启动服务
  .\run.ps1 logs      # 查看日志
  .\run.ps1 restart   # 重启服务

访问地址: http://localhost:7891

"@ -ForegroundColor White
}

# 切换到脚本所在目录
Push-Location $PSScriptRoot

try {
    switch ($Command) {
        "start"   { Start-Service }
        "stop"    { Stop-Service }
        "restart" { Restart-Service }
        "status"  { Get-Status }
        "logs"    { Get-Logs }
        "build"   { Build-Service }
        "clean"   { Clean-All }
        "help"    { Show-Help }
        default   { Show-Help }
    }
}
finally {
    Pop-Location
}

