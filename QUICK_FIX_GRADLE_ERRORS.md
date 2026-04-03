# Gradle 错误快速修复指南

## 遇到的错误
```
Unable to find method 'org.gradle.api.artifacts.Dependency org.gradle.api.artifacts.dsl.DependencyHandler.module(java.lang.Object)'
```

## 问题原因
这个错误通常是由于：
1. **Gradle版本不兼容** - Gradle版本与Android Gradle插件版本不匹配
2. **依赖缓存损坏** - Gradle缓存文件损坏
3. **Gradle守护进程问题** - Gradle守护进程状态异常

## 快速修复步骤

### 方法1：运行修复脚本（推荐）
1. 关闭 Android Studio/IDE
2. 在项目根目录运行：
   ```
   fix-gradle.bat
   ```
3. 运行：
   ```
   download-gradle-wrapper.bat
   ```
4. 重新打开 Android Studio 并同步项目

### 方法2：手动修复
1. **停止所有 Gradle 进程**：
   ```cmd
   gradle --stop
   ```

2. **清除 Gradle 缓存**：
   - 删除 `%USERPROFILE%\.gradle\caches` 目录
   - 删除项目中的 `.gradle` 和 `app\.gradle` 目录

3. **清除 Java 进程**：
   - 打开任务管理器
   - 结束所有 Java(TM) Platform SE binary 进程

4. **重新下载依赖**：
   ```cmd
   cd app
   gradlew clean
   gradlew build --refresh-dependencies
   ```

### 方法3：更新版本（已自动完成）
项目已更新到：
- **Gradle**: 8.5
- **Android Gradle Plugin**: 8.1.1
- **Kotlin**: 1.9.0

## 如果问题仍然存在

### 检查网络连接
确保可以访问以下仓库：
- https://repo.maven.apache.org/maven2/
- https://dl.google.com/dl/android/maven2/
- https://plugins.gradle.org/m2/

### 使用代理或镜像
如果网络访问有问题，在 `gradle.properties` 中添加：
```properties
systemProp.http.proxyHost=proxy.example.com
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=proxy.example.com
systemProp.https.proxyPort=8080
```

### 完全重置
1. 备份项目
2. 删除以下目录：
   - `%USERPROFILE%\.gradle`
   - 项目中的 `build` 目录
   - 项目中的 `.gradle` 目录
3. 重新克隆项目或从备份恢复

## 验证修复
修复后，运行以下命令验证：
```cmd
cd app
gradlew tasks --info
```

如果看到任务列表而不是错误，说明修复成功。

## 联系支持
如果所有方法都失败，请提供：
1. 完整的错误日志
2. 操作系统和 Java 版本
3. 网络环境信息