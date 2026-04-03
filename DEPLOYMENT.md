# 服务器部署指南

## 📍 目录

1. [本地开发](#本地开发)
2. [云服务器部署](#云服务器部署)
3. [Docker 部署](#docker-部署)
4. [监控和维护](#监控和维护)

---

## 本地开发

### 快速启动

**Mac/Linux：**
```bash
chmod +x start-server.sh
./start-server.sh
```

**Windows：**
```cmd
start-server.bat
```

### 手动启动

```bash
cd server
npm install
npm start
```

输出：
```
Server running on port 8080
```

### 测试连接

```bash
# 检查服务器是否在线
curl http://localhost:8080/health

# 输出：OK
```

---

## 云服务器部署

### 支持的云平台

- ✅ 阿里云 ECS
- ✅ 腾讯云 CVM
- ✅ AWS EC2
- ✅ DigitalOcean
- ✅ Linode
- ✅ 其他 Linux 服务器

### 部署步骤

#### 1. 购买云服务器

**推荐配置：**
- CPU：1 核
- 内存：1GB
- 带宽：1Mbps
- 系统：Ubuntu 20.04 LTS

#### 2. 连接到服务器

```bash
ssh root@your-server-ip
```

#### 3. 安装 Node.js

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证
node -v
npm -v
```

#### 4. 上传代码

**方式 1：使用 SCP**
```bash
scp -r server/ root@your-server-ip:/opt/remote-control/
```

**方式 2：使用 Git**
```bash
ssh root@your-server-ip
cd /opt
git clone https://github.com/your-repo/remote-control.git
```

#### 5. 安装依赖

```bash
cd /opt/remote-control/server
npm install
```

#### 6. 配置环境变量

编辑 `.env` 文件：
```bash
nano .env
```

内容：
```
PORT=8080
JWT_SECRET=your-very-long-random-secret-key-12345678
```

#### 7. 启动服务

**方式 1：直接启动（测试）**
```bash
npm start
```

**方式 2：使用 PM2（推荐）**

```bash
# 全局安装 PM2
npm install -g pm2

# 启动服务
pm2 start src/index.js --name "remote-control"

# 设置开机自启
pm2 startup
pm2 save

# 查看状态
pm2 status
pm2 logs remote-control
```

#### 8. 配置防火墙

**阿里云/腾讯云：**
1. 进入云服务器控制台
2. 找到"安全组"
3. 添加入站规则：
   - 协议：TCP
   - 端口：8080
   - 来源：0.0.0.0/0（允许所有）

**Linux 防火墙：**
```bash
# UFW（Ubuntu）
sudo ufw allow 8080/tcp
sudo ufw enable

# Firewalld（CentOS）
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

#### 9. 测试连接

```bash
# 在本地测试
curl http://your-server-ip:8080/health

# 输出：OK
```

#### 10. APP 中配置

在 Android APP 中填入：
```
ws://your-server-ip:8080
```

---

## Docker 部署

### 创建 Dockerfile

在 `server/` 目录下创建 `Dockerfile`：

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY src ./src

EXPOSE 8080

CMD ["node", "src/index.js"]
```

### 构建镜像

```bash
cd server
docker build -t remote-control:latest .
```

### 运行容器

```bash
docker run -d \
  --name remote-control \
  -p 8080:8080 \
  -e JWT_SECRET="your-secret-key" \
  remote-control:latest
```

### 查看日志

```bash
docker logs -f remote-control
```

### 停止容器

```bash
docker stop remote-control
docker rm remote-control
```

---

## 监控和维护

### 查看服务状态

**PM2：**
```bash
pm2 status
pm2 monit
```

**Docker：**
```bash
docker ps
docker stats remote-control
```

### 查看日志

**PM2：**
```bash
pm2 logs remote-control
pm2 logs remote-control --lines 100
```

**Docker：**
```bash
docker logs remote-control
docker logs -f remote-control
```

### 重启服务

**PM2：**
```bash
pm2 restart remote-control
```

**Docker：**
```bash
docker restart remote-control
```

### 更新代码

**PM2：**
```bash
cd /opt/remote-control/server
git pull
npm install
pm2 restart remote-control
```

**Docker：**
```bash
docker stop remote-control
docker rm remote-control
git pull
docker build -t remote-control:latest .
docker run -d --name remote-control -p 8080:8080 remote-control:latest
```

### 性能监控

**查看内存使用：**
```bash
# PM2
pm2 monit

# Docker
docker stats remote-control

# Linux
top
```

**查看连接数：**
```bash
netstat -an | grep 8080 | wc -l
```

### 日志轮转

**PM2 自动轮转：**
```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

---

## 故障排查

### 服务无法启动

```bash
# 检查端口是否被占用
lsof -i :8080

# 杀死占用进程
kill -9 <PID>

# 重新启动
npm start
```

### 连接超时

```bash
# 检查防火墙
sudo ufw status

# 检查服务是否运行
curl http://localhost:8080/health

# 检查 IP 和端口
netstat -tlnp | grep 8080
```

### 内存泄漏

```bash
# 查看内存使用
pm2 monit

# 重启服务
pm2 restart remote-control

# 查看日志
pm2 logs remote-control
```

### 连接断开

检查 `.env` 中的 `JWT_SECRET` 是否正确。

---

## 性能优化

### 增加并发连接数

编辑 `src/index.js`，增加 WebSocket 服务器配置：

```javascript
const wss = new WebSocket.Server({ 
    server,
    perMessageDeflate: false,  // 禁用压缩，提高速度
    maxPayload: 100 * 1024 * 1024  // 最大消息大小
});
```

### 使用 Nginx 反向代理

```nginx
upstream remote_control {
    server localhost:8080;
    keepalive 64;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://remote_control;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }
}
```

### 使用 HTTPS/WSS

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://remote_control;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 备份和恢复

### 备份配对信息

配对信息存储在 APP 本地，无需备份服务器。

### 备份服务器配置

```bash
# 备份 .env 文件
cp server/.env server/.env.backup

# 备份整个项目
tar -czf remote-control-backup.tar.gz server/
```

---

## 安全建议

1. **定期更换 JWT_SECRET**
   ```bash
   # 编辑 .env
   JWT_SECRET=new-random-secret-key
   
   # 重启服务
   pm2 restart remote-control
   ```

2. **限制 IP 访问**
   ```nginx
   location / {
       allow 192.168.1.0/24;
       deny all;
   }
   ```

3. **启用 HTTPS/WSS**
   - 使用 Let's Encrypt 免费证书
   - 配置 Nginx 反向代理

4. **定期更新依赖**
   ```bash
   npm update
   npm audit fix
   ```

5. **监控日志**
   ```bash
   pm2 logs remote-control | grep error
   ```

---

## 常见问题

| 问题 | 解决方案 |
|------|--------|
| 服务无法启动 | 检查端口是否被占用，检查 Node.js 版本 |
| 连接超时 | 检查防火墙规则，检查服务器 IP 和端口 |
| 内存占用过高 | 重启服务，检查是否有内存泄漏 |
| 连接断开 | 检查网络，检查 JWT_SECRET 配置 |
| 屏幕卡顿 | 检查网络延迟，降低屏幕分辨率 |

---

## 获取帮助

- 查看日志：`pm2 logs remote-control`
- 测试连接：`curl http://your-server-ip:8080/health`
- 检查端口：`netstat -tlnp | grep 8080`
