# bili-parse

bilibili 非官方视频解析工具

修改自 [MfunsTool](https://github.com/ChenDoXiu/MfunsTool)

## 支持平台

- 哔哩哔哩 (B站)
- 微博视频
- AcFun
- 贴吧视频
- 好看视频
- 蓝奏云
- 123网盘

---

## POSIX 部署 (Linux / macOS)

使用 Podman Compose 容器化部署，推荐用于生产环境。

### 前置要求

- [Podman](https://podman.io/) 或 Docker
- podman-compose 或 docker-compose

### 快速开始

```bash
# 克隆项目
git clone https://github.com/your-repo/bili-parse.git
cd bili-parse

# 启动服务
podman compose up -d

# 查看状态
podman compose ps

# 查看日志
podman compose logs -f

# 停止服务
podman compose down
```

### 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| 前端+API | 7891 | 统一入口 (nginx 反代) |

### 常用命令

```bash
# 重新构建
podman compose build --no-cache

# 强制重启
podman compose up -d --force-recreate

# 清理所有
podman compose down -v --rmi all
```

---

## Windows 部署

使用 [PowerShell 7+](https://github.com/PowerShell/PowerShell) 原生运行，无需容器。

### 前置要求

| 软件 | 下载地址 |
|------|----------|
| PowerShell 7+ | https://github.com/PowerShell/PowerShell/releases |
| Python 3.10+ | https://www.python.org/downloads/ |
| Redis | https://github.com/tporadowski/redis/releases |
| Node.js (可选) | https://nodejs.org/ |

### 快速开始

```powershell
# 1. 安装 Python 依赖
.\run.ps1 install

# 2. 启动 Redis (单独窗口)
redis-server.exe

# 3. 启动后端服务
.\run.ps1 start

# 4. (可选) 构建前端
.\run.ps1 build-frontend
```

### 管理命令

```powershell
.\run.ps1 install         # 安装依赖
.\run.ps1 start           # 启动服务
.\run.ps1 stop            # 停止服务
.\run.ps1 status          # 查看状态
.\run.ps1 build-frontend  # 构建前端
.\run.ps1 help            # 显示帮助
```

### 服务端口

- 访问地址: http://localhost:7891
- 健康检查: http://localhost:7891/health

---

## API 使用示例

```bash
# B站视频
curl http://localhost:7891/api/bili/BV1xx411c7mD

# B站指定分P
curl http://localhost:7891/api/bili/BV1xx411c7mD?p=2

# 微博视频
curl http://localhost:7891/api/weibo/1034:4738314251731108

# 微博4K
curl http://localhost:7891/api/weibo/1034:4738314251731108?q=4k
```

---

## 项目结构

```
bili-parse/
├── backend/          # Python FastAPI 后端
├── frontend/         # Vue.js 前端
├── compose.yaml      # Podman/Docker Compose 配置
├── run.ps1           # Windows PowerShell 管理脚本
└── README.md
```

## License

MIT
