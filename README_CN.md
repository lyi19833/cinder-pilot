# 远程控制 APP - 快速开始指南

## 📱 项目概述

两部安卓手机互相远程控制的 APP。一部手机可以看到另一部手机的屏幕，并通过点击、滑动来控制。

**核心特性：**
- ✅ 屏幕镜像（实时显示被控端屏幕）
- ✅ 触摸控制（点击、滑动）
- ✅ 二维码配对（一次配对，永久保存）
- ✅ 账号密码认证
- ✅ 云服务器中转

---

## ⚙️ 环境设置

### 必需软件

1. **Java JDK 11+**
   - 下载：[Adoptium Temurin](https://adoptium.net/temurin/releases/) 或 [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
   - 安装后设置环境变量 `JAVA_HOME`

2. **Android Studio**
   - 下载：[Android Studio](https://developer.android.com/studio)
   - 安装时会自动安装 Android SDK

3. **Node.js** (服务器端)
   - 下载：[Node.js](https://nodejs.org/)

### 自动环境检查

运行环境设置脚本：

**Windows (命令提示符)**
```cmd
setup-environment.bat
```

**Windows (PowerShell)**
```powershell
.\setup-environment.ps1
```

脚本会自动检测并配置 Java 和 Android SDK 路径。

> ⚠️ **重要提示：** 如果Java只在Administrator用户下安装，请使用管理员权限构建：
> ```cmd
> build-as-admin.bat
> ```

> 💡 **遇到问题？** 查看 [故障排除指南](TROUBLESHOOTING.md)

---

## 🚀 快速开始（5分钟）

### 第一步：启动服务器

**本地测试（同一 WiFi）**

```bash
cd server
npm install
npm start
```

输出：`Server running on port 8080`

查看你的电脑 IP：
```bash
# Mac/Linux
ifconfig | grep "inet "

# Windows
ipconfig
```

假设 IP 是 `192.168.1.100`，记住这个地址。

### 第二步：编译 Android APP

1. 用 Android Studio 打开 `app` 文件夹
2. 等待 Gradle 同步完成
3. 连接两部安卓手机（或模拟器）
4. 点击 Run → Run 'app'

### 第三步：配置服务器地址

APP 启动后，在输入框中填入：
```
ws://192.168.1.100:8080
```

（把 `192.168.1.100` 改成你的电脑 IP）

### 第四步：配对

**被控端（Phone B）**
1. 点击"作为被控端连接"
2. 等待连接成功
3. 点击"二维码配对"
4. 屏幕显示二维码

**控制端（Phone A）**
1. 点击"二维码配对"
2. 用摄像头扫描 Phone B 的二维码
3. 配对成功

### 第五步：开始控制

**被控端**
1. 点击"作为被控端连接"
2. 连接成功后，点击"开始屏幕捕获"
3. 授权屏幕捕获权限（点击"立即开始"）
4. 等待控制端连接

**控制端**
1. 点击"作为控制端连接"
2. 连接成功后，看到 Phone B 的屏幕
3. 点击或滑动屏幕来控制 Phone B

---

## 🔧 服务器配置

### 本地测试（开发环境）

```bash
cd server
npm install
npm start
```

### 云服务器部署（生产环境）

假设你的云服务器 IP 是 `123.45.67.89`

**1. 上传代码**
```bash
scp -r server/ root@123.45.67.89:/opt/remote-control/
```

**2. SSH 连接**
```bash
ssh root@123.45.67.89
```

**3. 安装并启动**
```bash
cd /opt/remote-control/server
npm install
npm start
```

**4. 使用 PM2 保活（可选）**
```bash
npm install -g pm2
pm2 start src/index.js --name "remote-control"
pm2 startup
pm2 save
```

**5. 防火墙配置**

在云服务器控制台（阿里云/腾讯云/AWS）中：
- 安全组规则 → 入站规则
- 允许 TCP 8080 端口

**6. APP 中填入服务器地址**
```
ws://123.45.67.89:8080
```

---

## 📋 权限配置

### Android 权限

APP 会自动请求以下权限：

| 权限 | 用途 | 何时授予 |
|------|------|--------|
| 网络 | 连接服务器 | 自动 |
| 屏幕捕获 | 被控端捕获屏幕 | 启动屏幕捕获时 |
| 无障碍服务 | 被控端注入触摸 | 手动启用 |

### 启用无障碍服务

**被控端需要手动启用：**

1. 打开手机"设置"
2. 进入"无障碍"或"Accessibility"
3. 找到"无障碍服务"
4. 找到"远程控制"或"Remote Control"
5. 打开开关

---

## 🔐 二维码配对详解

### 配对流程

```
被控端 (Phone B)
  ↓
生成二维码（包含 deviceId + 临时 token）
  ↓
显示二维码
  ↓
控制端 (Phone A) 扫描
  ↓
发送配对请求到服务器
  ↓
服务器验证 token
  ↓
建立配对关系
  ↓
双端存储配对信息
```

### 二维码内容

二维码包含 JSON 数据：
```json
{
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "tempToken": "temp-1711900000000"
}
```

### 配对后

配对信息存储在手机本地，下次启动时：
1. 自动读取配对信息
2. 直接连接到对端
3. 无需重新扫描二维码

---

## 🎮 使用场景

### 场景 1：同一 WiFi 网络

```
家里 WiFi：192.168.1.0/24
├─ 电脑（服务器）：192.168.1.100:8080
├─ Phone A（控制端）：192.168.1.101
└─ Phone B（被控端）：192.168.1.102
```

所有设备填：`ws://192.168.1.100:8080`

### 场景 2：云服务器（任意网络）

```
云服务器：123.45.67.89:8080
├─ Phone A（控制端）：4G/WiFi
└─ Phone B（被控端）：4G/WiFi
```

所有设备填：`ws://123.45.67.89:8080`

### 场景 3：远程协助

```
你的电脑（服务器）：公网 IP
├─ 你的 Phone A（控制端）：任意地点
└─ 朋友的 Phone B（被控端）：任意地点
```

---

## 🐛 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|--------|
| 连接超时 | 服务器未启动或 IP 错误 | 检查服务器是否运行，IP 是否正确 |
| 认证失败 | Token 过期或无效 | 清除 APP 数据，重新登录 |
| 屏幕不显示 | 被控端未启动屏幕捕获 | 点击"开始屏幕捕获"并授权 |
| 触摸无反应 | 无障碍服务未启用 | 在设置中启用无障碍服务 |
| 配对失败 | 二维码过期或网络问题 | 重新生成二维码，检查网络 |
| 屏幕卡顿 | 网络延迟或分辨率过高 | 检查网络，APP 已自动降低分辨率 |

---

## 📊 性能指标

| 指标 | 值 |
|------|-----|
| 屏幕分辨率 | 原分辨率的 50%（降低带宽） |
| JPEG 质量 | 60%（平衡清晰度和速度） |
| 帧率 | 根据网络自动调整 |
| 延迟 | 100-500ms（取决于网络） |
| 支持设备数 | 100+ 并发连接 |

---

## 🔒 安全建议

### 开发环境
- 本地 WiFi 测试，无需加密

### 生产环境
- 使用 WSS（加密 WebSocket）
- 定期更换 JWT_SECRET
- 限制 IP 访问（可选）
- 定期备份配对信息

### 配置 HTTPS/WSS

编辑 `server/.env`：
```
PORT=443
JWT_SECRET=your-very-long-random-secret-key
```

使用 Nginx 反向代理（可选）：
```nginx
upstream remote_control {
    server localhost:8080;
}

server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://remote_control;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

APP 中填：`wss://your-domain.com`

---

## 📝 文件结构

```
remote-control/
├── server/                          # Node.js 后端
│   ├── src/
│   │   ├── index.js                # 服务器入口
│   │   ├── auth.js                 # 认证逻辑
│   │   ├── messageRouter.js        # 消息路由
│   │   └── store.js                # 数据存储
│   ├── package.json
│   └── .env
│
└── app/                             # Android APP
    ├── src/main/
    │   ├── java/com/remotectrl/
    │   │   ├── MainActivity.kt      # 主界面
    │   │   ├── auth/                # 认证模块
    │   │   ├── network/             # 网络通信
    │   │   ├── controller/          # 控制端
    │   │   ├── controlled/          # 被控端
    │   │   └── storage/             # 本地存储
    │   ├── res/
    │   │   ├── layout/              # UI 布局
    │   │   └── values/              # 字符串资源
    │   └── AndroidManifest.xml
    └── build.gradle
```

---

## 🎯 下一步

1. ✅ 启动服务器
2. ✅ 编译 APP
3. ✅ 配对两部手机
4. ✅ 开始控制

有问题？检查日志：
```bash
# 服务器日志
npm start

# APP 日志（Android Studio）
Logcat → 搜索 "RemoteControl"
```

祝你使用愉快！🎉
