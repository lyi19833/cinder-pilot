# 远控 APP 完整使用指南

## 1. 服务器设置

### 1.1 云服务器环境要求
- Node.js 14+
- 开放 8080 端口（或自定义端口）

### 1.2 部署步骤

**本地测试（开发环境）**
```bash
cd server
npm install
npm start
```
输出：`Server running on port 8080`

**云服务器部署（生产环境）**

假设你的云服务器 IP 是 `123.45.67.89`

1. 上传代码到服务器
```bash
scp -r server/ root@123.45.67.89:/opt/remote-control/
```

2. SSH 连接到服务器
```bash
ssh root@123.45.67.89
```

3. 安装依赖并启动
```bash
cd /opt/remote-control/server
npm install
npm start
```

4. 使用 PM2 保活（可选但推荐）
```bash
npm install -g pm2
pm2 start src/index.js --name "remote-control"
pm2 startup
pm2 save
```

### 1.3 配置 JWT_SECRET

编辑 `.env` 文件，改成强密钥：
```
PORT=8080
JWT_SECRET=your-very-long-random-secret-key-12345678
```

### 1.4 防火墙配置

**阿里云/腾讯云/AWS 等**
- 安全组规则：允许 TCP 8080 入站
- 或使用 Nginx 反向代理到 443（HTTPS）

**本地测试**
- 确保手机和电脑在同一 WiFi 网络

---

## 2. Android APP 配置

### 2.1 修改服务器地址

打开 `app/src/main/java/com/remotectrl/MainActivity.kt`

找到这行：
```kotlin
serverUrlInput.setText("ws://your-server:8080")
```

改成你的服务器 IP：
```kotlin
// 本地测试
serverUrlInput.setText("ws://192.168.1.100:8080")

// 云服务器
serverUrlInput.setText("ws://123.45.67.89:8080")
```

### 2.2 编译和安装

**方式 1：Android Studio**
1. 打开 Android Studio
2. File → Open → 选择 `app` 文件夹
3. 等待 Gradle 同步完成
4. Run → Run 'app'
5. 选择设备或模拟器

**方式 2：命令行**
```bash
cd app
./gradlew build
./gradlew installDebug
```

### 2.3 权限配置

APP 首次启动会请求以下权限：
- **网络权限** — 自动授予
- **屏幕捕获权限** — 被控端启动时弹窗，点击"立即开始"
- **无障碍服务** — 手动启用：
  - 设置 → 无障碍 → 无障碍服务 → Remote Control → 打开

---

## 3. 二维码配对流程

### 3.1 生成二维码（被控端）

1. 被控端 APP 启动
2. 点击"Connect as Controlled"
3. 输入服务器地址，连接
4. 连接成功后，点击"QR Pair"
5. 屏幕显示二维码（包含 deviceId + 临时 token）

### 3.2 扫描配对（控制端）

1. 控制端 APP 启动
2. 点击"QR Pair"
3. 打开摄像头，扫描被控端的二维码
4. 自动解析 deviceId 和 tempToken
5. 发送配对请求到服务器
6. 配对成功，双端存储配对信息

### 3.3 完整配对代码（需要添加）

编辑 `app/src/main/java/com/remotectrl/auth/QrPairActivity.kt`，添加 ZXing 扫描：

```kotlin
package com.remotectrl.auth

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.journeyapps.barcodescanner.CaptureActivity
import com.remotectrl.R
import com.remotectrl.network.MessageHandler
import com.remotectrl.network.WsClient
import com.remotectrl.storage.PairStorage
import org.json.JSONObject

class QrPairActivity : AppCompatActivity(), MessageHandler {
    private val SCAN_REQUEST = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_qr_pair)

        val scanBtn = findViewById<Button>(R.id.scanBtn)
        scanBtn.setOnClickListener { startScan() }

        WsClient.instance?.let { ws ->
            ws.handler = this
        }
    }

    private fun startScan() {
        val intent = Intent(this, CaptureActivity::class.java)
        startActivityForResult(intent, SCAN_REQUEST)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == SCAN_REQUEST && resultCode == RESULT_OK) {
            val result = data?.getStringExtra("SCAN_RESULT")
            if (result != null) {
                try {
                    val qrData = JSONObject(result)
                    val peerDeviceId = qrData.getString("deviceId")
                    val tempToken = qrData.getString("tempToken")

                    WsClient.instance?.send("pair_confirm", JSONObject()
                        .put("peerDeviceId", peerDeviceId)
                        .put("tempToken", tempToken))

                    Toast.makeText(this, "Pairing...", Toast.LENGTH_SHORT).show()
                } catch (e: Exception) {
                    Toast.makeText(this, "Invalid QR code", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    override fun onConnected() {}
    override fun onDisconnected() {}
    override fun onMessage(msg: JSONObject) {
        val type = msg.getString("type")
        val payload = msg.getJSONObject("payload")

        when (type) {
            "pair_confirm" -> {
                if (payload.getBoolean("success")) {
                    val peerDeviceId = payload.getString("peerDeviceId")
                    PairStorage.savePair(this, peerDeviceId)
                    Toast.makeText(this, "Paired successfully!", Toast.LENGTH_SHORT).show()
                    finish()
                }
            }
        }
    }
}
```

更新 layout：
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp">

    <Button
        android:id="@+id/scanBtn"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Scan QR Code" />

</LinearLayout>
```

---

## 4. 使用流程

### 4.1 首次使用（配对）

**被控端（Phone B）**
1. 打开 APP
2. 输入服务器地址（如 `ws://192.168.1.100:8080`）
3. 点击"Connect as Controlled"
4. 等待连接成功
5. 点击"QR Pair"，显示二维码

**控制端（Phone A）**
1. 打开 APP
2. 输入相同的服务器地址
3. 点击"QR Pair"
4. 扫描 Phone B 的二维码
5. 配对成功，自动保存配对信息

### 4.2 后续使用（无需重新配对）

**被控端**
1. 打开 APP
2. 输入服务器地址
3. 点击"Connect as Controlled"
4. 点击"Start Screen Capture"
5. 授权屏幕捕获权限
6. 开始被控

**控制端**
1. 打开 APP
2. 输入服务器地址
3. 点击"Connect as Controller"
4. 看到 Phone B 的屏幕
5. 点击/滑动控制 Phone B

---

## 5. 服务器监控和调试

### 5.1 查看服务器日志

```bash
# 本地开发
npm start

# 云服务器（PM2）
pm2 logs remote-control

# 查看连接状态
pm2 monit
```

### 5.2 测试连接

```bash
# 测试服务器是否在线
curl http://123.45.67.89:8080/health

# 输出：OK
```

### 5.3 常见问题

| 问题 | 解决方案 |
|------|--------|
| 连接超时 | 检查防火墙、服务器 IP、端口是否正确 |
| 认证失败 | 清除 APP 数据，重新登录 |
| 屏幕不显示 | 检查被控端是否启动了屏幕捕获服务 |
| 触摸无反应 | 检查被控端是否启用了无障碍服务 |
| 配对失败 | 确保两部手机连接到同一服务器 |

---

## 6. 网络配置示例

### 6.1 本地 WiFi 测试

```
服务器：192.168.1.100:8080
Phone A：192.168.1.101（控制端）
Phone B：192.168.1.102（被控端）
```

APP 中都填：`ws://192.168.1.100:8080`

### 6.2 云服务器配置

```
服务器：阿里云 ECS 123.45.67.89:8080
Phone A：任意 4G/WiFi（控制端）
Phone B：任意 4G/WiFi（被控端）
```

APP 中都填：`ws://123.45.67.89:8080`

### 6.3 Nginx 反向代理（可选）

如果要用 HTTPS/WSS，编辑 `/etc/nginx/nginx.conf`：

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
        proxy_set_header Host $host;
    }
}
```

APP 中填：`wss://your-domain.com`

---

## 7. 性能优化建议

- **屏幕分辨率**：已自动减半（降低带宽）
- **JPEG 质量**：设为 60（平衡清晰度和速度）
- **帧率**：根据网络自动调整
- **服务器**：建议 1GB+ 内存，支持 100+ 并发连接

---

## 8. 安全建议

- 生产环境使用 WSS（加密）
- 定期更换 JWT_SECRET
- 限制 IP 访问（可选）
- 定期备份配对信息

