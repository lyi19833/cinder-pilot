# 替代Android Studio的APK打包方法

## 方法一：使用命令行（推荐）

### 步骤：
1. **运行构建脚本**：
   ```cmd
   cd c:\Users\nora\cinder-pilot
   BUILD_APK_MANUALLY.bat
   ```

2. **如果成功**：APK在 `app\build\outputs\apk\debug\app-debug.apk`

3. **如果失败**：查看错误日志，根据提示修复

## 方法二：使用在线构建服务

### 1. GitHub Actions（免费）
创建 `.github/workflows/android.yml`：
```yaml
name: Android CI

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 11
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        
    - name: Build with Gradle
      run: ./gradlew assembleDebug
      
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-debug-apk
        path: app/build/outputs/apk/debug/*.apk
```

### 2. GitLab CI
创建 `.gitlab-ci.yml`：
```yaml
image: openjdk:11-jdk

build:
  script:
    - chmod +x gradlew
    - ./gradlew assembleDebug
  artifacts:
    paths:
      - app/build/outputs/apk/debug/*.apk
```

## 方法三：使用云构建服务

### 1. Bitrise（有免费额度）
- 注册：https://app.bitrise.io
- 连接GitHub/GitLab仓库
- 自动构建Android应用

### 2. App Center Build（微软，有免费额度）
- 注册：https://appcenter.ms
- 支持Android/iOS自动构建
- 免费构建时间每月一定额度

## 方法四：使用Docker构建

创建 `Dockerfile`：
```dockerfile
FROM openjdk:11-jdk

WORKDIR /app
COPY . .

# 设置Android SDK
ENV ANDROID_SDK_ROOT /usr/local/android-sdk
RUN mkdir -p $ANDROID_SDK_ROOT
RUN apt-get update && apt-get install -y wget unzip

# 下载命令行工具
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
RUN unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools
RUN mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest

ENV PATH $PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# 接受许可
RUN yes | sdkmanager --licenses

# 构建
RUN ./gradlew assembleDebug

# 复制APK
RUN cp app/build/outputs/apk/debug/*.apk /app/app-debug.apk
```

构建命令：
```bash
docker build -t android-build .
docker run -v $(pwd):/output android-build cp /app/app-debug.apk /output/
```

## 方法五：使用Termux（手机端构建）

如果只有手机，可以尝试：
1. 安装Termux
2. 安装Java和Git
3. 克隆项目
4. 使用命令行构建

## 方法六：简化构建脚本

如果只想测试应用，可以创建极简版本：

创建 `simple_build.bat`：
```batch
@echo off
echo 正在下载必要依赖...
powershell -Command "Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.2-bin.zip' -OutFile 'gradle.zip'"

echo 解压...
powershell -Command "Add-Type -Assembly 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::ExtractToDirectory('gradle.zip', 'gradle')"

echo 构建...
java -cp "gradle\gradle-8.2\lib\*" org.gradle.launcher.GradleMain assembleDebug
```

## 紧急方案：直接编译Java文件

如果所有方法都失败，可以尝试：
1. 手动编译Java/Kotlin文件
2. 使用aapt打包资源
3. 使用apksigner签名

但这需要较高的技术能力。

## 推荐方案

1. **先尝试**：`BUILD_APK_MANUALLY.bat`
2. **如果失败**：使用GitHub Actions云构建
3. **长期方案**：降级Android Studio到稳定版本

## 获取帮助

如果所有方法都失败，可以：
1. 分享错误日志
2. 使用在线编译平台：https://gitpod.io
3. 寻求社区帮助：Stack Overflow