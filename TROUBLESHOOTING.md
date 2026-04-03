# Android Studio 编译错误故障排除指南

## 常见错误及解决方案

### 错误：JAVA_HOME is not set and no 'java' command could be found in your PATH

**原因：** Java JDK 未安装或未正确配置

**解决方案：**

1. **下载并安装 JDK**
   - 推荐： [Adoptium Temurin JDK 17](https://adoptium.net/temurin/releases/)
   - 或者：[Oracle JDK](https://www.oracle.com/java/technologies/downloads/)

2. **设置环境变量**
   - 右键"此电脑" → "属性" → "高级系统设置" → "环境变量"
   - 新建系统变量：
     - 变量名：`JAVA_HOME`
     - 变量值：`C:\Program Files\Java\jdk-17` (根据你的安装路径)
   - 编辑 `Path` 变量，添加：`%JAVA_HOME%\bin`

3. **验证安装**
   ```cmd
   java -version
   ```
   应该显示类似：`java version "17.0.6"`

### 错误：SDK location not found / Android SDK not found

**原因：** Android SDK 路径配置错误

**解决方案：**

1. **检查 local.properties 文件**
   确保 `app/local.properties` 中的路径正确：
   ```
   sdk.dir=C:\\Users\\nora\\AppData\\Local\\Android\\Sdk
   ```

2. **通过 Android Studio 安装 SDK**
   - 打开 Android Studio
   - File → Settings → Appearance & Behavior → System Settings → Android SDK
   - 安装必要的 SDK 组件（API 34, Build Tools 等）

### 错误：Unable to find method 'org.gradle.api.artifacts.Dependency org.gradle.api.artifacts.dsl.DependencyHandler.module(java.lang.Object)'

**原因：** Gradle版本不兼容或依赖缓存损坏

**解决方案：**

1. **清除Gradle缓存：**
   ```cmd
   fix-gradle.bat
   ```

2. **下载Gradle Wrapper：**
   ```cmd
   download-gradle-wrapper.bat
   ```

3. **手动修复步骤：**
   - 删除 `%USERPROFILE%\.gradle\caches` 目录
   - 删除项目中的 `.gradle` 和 `app\.gradle` 目录
   - 重新启动Android Studio

4. **如果问题持续，禁用Gradle守护进程：**
   编辑 `gradle.properties`：
   ```
   org.gradle.daemon=false
   ```

### 错误：Gradle sync failed

**原因：** Gradle 配置问题

**解决方案：**

1. **清除 Gradle 缓存**
   ```cmd
   cd app
   .\gradlew clean
   ```

2. **重新同步项目**
   - 在 Android Studio 中：File → Invalidate Caches / Restart

3. **检查网络连接**
   - 确保可以访问 jcenter 和 google maven 仓库

### 错误：Build failed with multiple tasks

**原因：** 编译错误

**解决方案：**

1. **查看详细错误信息**
   - 在 Android Studio 的 Build 窗口查看完整错误日志

2. **常见编译错误：**
   - 检查 Kotlin 语法错误
   - 确认所有依赖版本兼容
   - 检查资源文件（layout XML, strings.xml 等）

### 权限相关错误

**屏幕捕获权限：**
- 确保 APP 有 `FOREGROUND_SERVICE_MEDIA_PROJECTION` 权限
- 在设置中允许"显示在其他应用上层"

**网络权限：**
- 确保有 `INTERNET` 权限
- 检查防火墙设置

### Administrator 权限问题

**错误：** Java 只在 Administrator 用户下可用

**解决方案：**

1. **使用管理员权限构建：**
   ```cmd
   build-as-admin.bat
   ```

2. **或者在 Android Studio 中：**
   - 右键 Android Studio 图标 → "以管理员身份运行"
   - 然后打开项目并构建

3. **设置系统级 JAVA_HOME：**
   - 以管理员身份打开命令提示符
   - 运行：`setx JAVA_HOME "C:\Path\To\Your\JDK" /M`

## 快速诊断脚本

运行项目根目录下的环境检查脚本：

```cmd
setup-environment.bat
```

或

```powershell
.\setup-environment.ps1
```

## 获取帮助

如果问题仍然存在：

1. **查看完整错误日志**
   - Android Studio → View → Tool Windows → Build
   - 复制完整错误信息

2. **检查项目结构**
   - 确保所有文件都在正确位置
   - 检查文件权限

3. **更新依赖**
   ```cmd
   cd app
   .\gradlew build --refresh-dependencies
   ```