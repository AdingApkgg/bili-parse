/*
 * @Author: your name
 * @Date: 2021-02-21 20:01:15
 * @LastEditTime: 2021-02-25 10:59:53
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \html\src\networker\server.js
 */
// 解析服务器地址
// 容器模式: nginx 代理 /api -> backend:8888
// Windows 模式: 直接访问 /api
export default {
    server: "/api"
}