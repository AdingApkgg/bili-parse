import os
import redis.asyncio as aioredis

# 从环境变量读取 Redis 配置，支持容器化部署
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = os.getenv("REDIS_PORT", "6379")
REDIS_URL = f"redis://{REDIS_HOST}:{REDIS_PORT}"

redis = aioredis.from_url(REDIS_URL, encoding="utf8", decode_responses=True)

ac_bangumi_redis = aioredis.from_url(REDIS_URL, encoding="utf8", decode_responses=True, db=1)

bili_cid_redis = aioredis.from_url(REDIS_URL, encoding="utf8", decode_responses=True, db=2)

haokan_redis = aioredis.from_url(REDIS_URL, encoding="utf8", decode_responses=True, db=3)

# 发现这些代码写在views模块里面还好些233333

# async def query_weibo(vid: str, quality: str):
# global redis
# value = await redis.get("weibo" + f"{vid}" + f"?q={quality}")
# return value


# async def query_bili(vid: str, p: int = 1):
# global redis
# value = await redis.get("bili" + f"{vid}" + f"?p={p}")
# return value

# async def set_weibo(vid:str,quality:str,url:str):
# global redis
# await redis.set("weibo"+f"{vid}"+f"?q={quality}", url,ex = 3600)

# async def set_bili(vid:str,p:int,url:str):
# global redis
# await redis.set("bili" + f"{vid}" + f"?p={p}", url, ex=900)
