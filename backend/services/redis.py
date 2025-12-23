"""Redis 连接池管理"""
import os
from redis.asyncio import ConnectionPool, Redis

# Redis 配置
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
REDIS_URL = f"redis://{REDIS_HOST}:{REDIS_PORT}"

# 连接池配置
POOL_SETTINGS = {
    "encoding": "utf8",
    "decode_responses": True,
    "max_connections": 20,
}

# 创建连接池
_pools: list[ConnectionPool] = []


def _create_pool(db: int = 0) -> Redis:
    """创建 Redis 连接池"""
    pool = ConnectionPool.from_url(f"{REDIS_URL}/{db}", **POOL_SETTINGS)
    _pools.append(pool)
    return Redis(connection_pool=pool)


# Redis 实例 (不同 db 用于不同业务)
redis = _create_pool(db=0)           # 通用缓存
ac_bangumi_redis = _create_pool(db=1)  # AcFun 番剧
bili_cid_redis = _create_pool(db=2)    # B站 CID
haokan_redis = _create_pool(db=3)      # 好看视频


async def close_redis_pools():
    """关闭所有连接池"""
    for pool in _pools:
        await pool.disconnect()
