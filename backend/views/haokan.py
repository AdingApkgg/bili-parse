from httpx import AsyncClient
from urllib.parse import urlsplit
from random import randint
from router.router import router
from services.redis import haokan_redis
from fastapi import Response

client = AsyncClient(http2=True, follow_redirects=True)

async def getvideolink(vid: int):
    url = 'https://sv.baidu.com/appui/api'
    headers = {
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.8,*/*;q=0.8',
        'cache-control': 'no-cache',
        'Connection': 'keep-alive',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36'
    }
    html = await client.get(url=url, params={'cmd':'video/relate','vid':vid}, headers=headers, timeout=5)
    html = html.json()
    try:
        video_json = html['video/relate']['data']['cur_video']['video_list']
    except:
        raise Exception('此视频不存在！')
    qualitys = ['1080p','sc','hd','sd']

    for k in qualitys:
        if k in video_json:
            url = video_json[k]

    return url

async def set_cache(vid: int, value: str):
    try:
        await haokan_redis.set(f'haokan{vid}',value)
    except:
        print('设置缓存出错！')

@router.get('/haokan/{vid}')
async def haokan_main(vid: int):
    cache = await haokan_redis.get(f'haokan{vid}')
    if cache is not None:
        url = f'https://vd{randint(1,4)}.bdstatic.com{cache}'
        return Response(status_code=307,
                            headers={
                                "Location": url,
                                "Content-Type": "video/mp4",
                                "Cache-Control": "no-cache",
                                "Referrer-Policy": "no-referrer",
                                "X-Cache-used": "Yes"})
    
    if cache is None:
        try:
            url = await getvideolink(vid)
            return Response(status_code=307,
                            headers={
                                "Location": url,
                                "Content-Type": "video/mp4",
                                "Cache-Control": "no-cache",
                                "Referrer-Policy": "no-referrer",
                                "X-Cache-used": "Yes"})
        except:
            return '获取链接出错！'
        finally:
            value = urlsplit(url)[2]
            print(value)
            await set_cache(vid,value)

