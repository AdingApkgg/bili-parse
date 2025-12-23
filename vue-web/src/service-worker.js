import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { StaleWhileRevalidate } from 'workbox-strategies';
import { setCacheNameDetails, skipWaiting, clientsClaim } from 'workbox-core';

// 设置相应缓存的名字的前缀和后缀
setCacheNameDetails({
    prefix: 'video-link-cache',
    suffix: 'v2022.06.30',
});

// 让我们的service worker尽快的得到更新和获取页面的控制权
skipWaiting();
clientsClaim();

/* vue-cli3.0通过workbox-webpack-plugin 来实现相关功能，我们需要加入
 * 以下语句来获取预缓存列表和预缓存他们，也就是打包项目后生产的html，js，css等
 * 静态文件
 */
precacheAndRoute(self.__WB_MANIFEST);

// 缓存web的css资源
registerRoute(
    // Cache CSS files
    /.*\.css/,
    // 使用缓存，但尽快在后台更新
    new StaleWhileRevalidate({
        // 使用自定义缓存名称
        cacheName: 'css-cache'
    })
);

// 缓存web的js资源
registerRoute(
    // 缓存JS文件
    /.*\.js/,
    // 使用缓存，但尽快在后台更新
    new StaleWhileRevalidate({
        // 使用自定义缓存名称
        cacheName: 'js-cache'
    })
);

// 缓存web的图片资源
registerRoute(
    /\.(?:png|gif|jpg|jpeg|svg)$/,
    // 使用缓存，但尽快在后台更新
    new StaleWhileRevalidate({
        // 使用自定义缓存名称
        cacheName: 'images'
    })
);
