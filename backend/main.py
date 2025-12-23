"""视频外链解析 API 服务"""
import os
from contextlib import asynccontextmanager
from pathlib import Path

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

from router import router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    # 启动时
    yield
    # 关闭时 - 清理资源
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

# 注册路由
app.include_router(router.router)

# 首页文件路径
INDEX_FILE = Path("index.html") if Path("index.html").exists() else Path("backend/index.html")


@app.get("/")
async def index():
    """首页"""
    return FileResponse(INDEX_FILE)


@app.get("/health")
async def health():
    """健康检查"""
    return {"status": "ok"}


if __name__ == "__main__":
    host = os.getenv("HOST", "127.0.0.1")
    port = int(os.getenv("PORT", "8888"))
    reload = os.getenv("RELOAD", "true").lower() == "true"
    uvicorn.run("main:app", host=host, port=port, reload=reload)
