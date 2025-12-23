"""视频外链解析 API 服务"""
import os
from contextlib import asynccontextmanager
from pathlib import Path

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from router import router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    yield
    from services.redis import close_redis_pools
    await close_redis_pools()


# 初始化 FastAPI
app = FastAPI(
    title="视频外链解析 API",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册 API 路由
app.include_router(router.router, prefix="/api")
# 兼容旧路由 (无 /api 前缀)
app.include_router(router.router)


@app.get("/health")
async def health():
    """健康检查"""
    return {"status": "ok"}


# 静态文件目录 (前端构建产物)
STATIC_DIR = Path(__file__).parent / "static"
INDEX_FILE = Path("index.html") if Path("index.html").exists() else Path("backend/index.html")

# 如果存在 static 目录，挂载静态文件
if STATIC_DIR.exists():
    app.mount("/js", StaticFiles(directory=STATIC_DIR / "js"), name="js")
    app.mount("/css", StaticFiles(directory=STATIC_DIR / "css"), name="css")
    app.mount("/img", StaticFiles(directory=STATIC_DIR / "img"), name="img")
    
    @app.get("/")
    async def index():
        return FileResponse(STATIC_DIR / "index.html")
    
    @app.get("/{path:path}")
    async def catch_all(path: str):
        """SPA 路由支持"""
        file_path = STATIC_DIR / path
        if file_path.exists() and file_path.is_file():
            return FileResponse(file_path)
        return FileResponse(STATIC_DIR / "index.html")
else:
    @app.get("/")
    async def index():
        return FileResponse(INDEX_FILE)


if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "7891"))
    reload = os.getenv("RELOAD", "false").lower() == "true"
    uvicorn.run("main:app", host=host, port=port, reload=reload)
