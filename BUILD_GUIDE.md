# Android APP 编译和安装指南

## 📱 环境要求

- Android Studio 2022.1+
- Android SDK 24+（API Level 24）
- Gradle 7.0+
- Java 11+

---

## 🚀 快速编译

### 方式 1：Android Studio（推荐）

#### 1. 打开项目

1. 打开 Android Studio
2. File → Open
3. 选择 `app` 文件夹
4. 等待 Gradle 同步完成

#### 2. 配置服务器地址

编辑 `app/src/main/java/com/remotectrl/MainActivity.kt`

找到这行：
```kotlin
serverUrlInput.setText("ws://192.168.1.100:8080")
```

改成你的服务器 IP：
```kotlin
// 本地测试
serverUrlInput.setText("ws://192.168.1.100:8080")

// 云服务器
serverUrlInput.setText("ws://123.45.67.89:8080")
```

#### 3. 连接设备

**连接真机：**
1. 用 USB 线连接安卓手机
2. 手机开启"开发者模式"
   - 设置 → 关于手机 → 连续点击"版本号"7 次
   - 返回设置 → 开发者选项 → 启用 USB 调试
3. Android Studio 会自动识别设备

**使用模拟器：**
1. Tools → Device Manager
2. 创建新虚拟设备
3. 选择 API Level 24+
4. 启动模拟器

#### 4. 编译和运行

1. Run → Run 'app'
2. 选择设备
3. 等待编译完成
4. APP 自动安装并启动

### 方式 2：命令行编译

```bash
cd app

# 编译 Debug 版本
./gradlew build

# 编译 Release 版本
./gradlew build -Pbuild_type=release

# 直接安装到设备
./gradlew installDebug

# 查看编译日志
./gradlew build --info
```

---

## 📦 生成 APK

### Debug APK（开发用）

```bash
cd app
./gradlew assembleDebug
```

输出：`app/build/outputs/apk/debug/app-debug.apk`

### Release APK（发布用）

#### 1. 创建签名密钥

```bash
keytool -genkey -v -keystore release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias remote-control
```

按提示输入密码和信息。

#### 2. 编辑 `app/build.gradle`

在 `android` 块中添加：

```gradle
signingConfigs {
    release {
        storeFile file('release.keystore')
        storePassword 'your-keystore-password'
        keyAlias 'remote-control'
        keyPassword 'your-key-password'
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

#### 3. 编译 Release APK

```bash
cd app
./gradlew assembleRelease
```

输出：`app/build/outputs/apk/release/app-release.apk`

---

## 📲 安装 APK

### 方式 1：Android Studio

1. Run → Run 'app'
2. 选择设备
3. 自动安装

### 方式 2：ADB 命令

```bash
# 安装 APK
adb install app/build/outputs/apk/debug/app-debug.apk

# 卸载 APP
adb uninstall com.remotectrl

# 查看已安装的 APP
adb shell pm list packages | grep remotectrl
```

### 方式 3：手动安装

1. 将 APK 文件复制到手机
2. 打开文件管理器
3. 找到 APK 文件
4. 点击安装

---

## 🔧 配置和权限

### 修改服务器地址

**方式 1：代码中修改**

编辑 `MainActivity.kt`：
```kotlin
serverUrlInput.setText("ws://your-server-ip:8080")
```

**方式 2：运行时输入**

APP 启动后，在输入框中输入服务器地址。

### 权限配置

APP 需要以下权限：

| 权限 | 用途 | 何时授予 |
|------|------|--------|
| INTERNET | 网络连接 | 自动 |
| FOREGROUND_SERVICE | 前台服务 | 自动 |
| FOREGROUND_SERVICE_MEDIA_PROJECTION | 屏幕捕获 | 自动 |
| CAMERA | 摄像头（二维码扫描） | 首次使用时 |

### 启用无障碍服务

被控端需要手动启用无障碍服务：

1. 打开手机"设置"
2. 进入"无障碍"
3. 找到"无障碍服务"
4. 找到"远程控制"
5. 打开开关

---

## 🐛 调试

### 查看日志

```bash
# 实时查看日志
adb logcat

# 过滤 APP 日志
adb logcat | grep RemoteControl

# 保存日志到文件
adb logcat > logcat.txt
```

### Android Studio 调试

1. 在代码中设置断点
2. Run → Debug 'app'
3. 使用调试工具单步执行

### 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|--------|
| Gradle 同步失败 | 网络问题或 SDK 版本不匹配 | 检查网络，更新 SDK |
| 编译失败 | 依赖版本冲突 | 运行 `./gradlew clean build` |
| 安装失败 | 设备存储不足 | 清理设备存储空间 |
| 运行时崩溃 | 权限未授予 | 检查权限配置 |

---

## 📊 编译优化

### 加快编译速度

编辑 `gradle.properties`：

```properties
# 启用并行编译
org.gradle.parallel=true

# 启用守护进程
org.gradle.daemon=true

# 增加堆内存
org.gradle.jvmargs=-Xmx2048m

# 启用构建缓存
org.gradle.caching=true
```

### 减小 APK 大小

编辑 `app/build.gradle`：

```gradle
android {
    bundle {
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

---

## 🔐 签名和发布

### 生成签名密钥

```bash
keytool -genkey -v -keystore my-release-key.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

### 查看签名信息

```bash
keytool -list -v -keystore my-release-key.keystore
```

### 签名 APK

```bash
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore my-release-key.keystore \
  app-unsigned.apk my-key-alias
```

---

## 📱 多设备测试

### 连接多个设备

```bash
# 列出所有连接的设备
adb devices

# 指定设备安装
adb -s <device-id> install app-debug.apk

# 指定设备运行日志
adb -s <device-id> logcat
```

### 模拟器和真机同时测试

1. 启动模拟器
2. 连接真机
3. 在 Android Studio 中选择设备
4. 分别运行和测试

---

## 🚀 发布到 Google Play

### 准备工作

1. 创建 Google Play 开发者账户
2. 生成签名密钥
3. 编译 Release APK

### 上传步骤

1. 打开 Google Play Console
2. 创建新应用
3. 填写应用信息
4. 上传 APK
5. 填写应用描述和截图
6. 提交审核

---

## 常见问题

| 问题 | 解决方案 |
|------|--------|
| Gradle 同步超时 | 检查网络，增加超时时间 |
| 编译内存不足 | 增加 Gradle 堆内存 |
| 设备无法识别 | 检查 USB 驱动，启用 USB 调试 |
| APK 安装失败 | 卸载旧版本，检查签名 |
| 运行时权限错误 | 在设置中手动授予权限 |

---

## 获取帮助

- Android Studio 文档：https://developer.android.com/studio
- Gradle 文档：https://gradle.org/
- Android 开发文档：https://developer.android.com/
