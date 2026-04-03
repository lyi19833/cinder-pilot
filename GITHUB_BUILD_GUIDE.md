# GitHub云构建指南

你的Android项目已经成功推送到GitHub：https://github.com/lyi19833/cinder-pilot

## 如何获取构建好的APK文件

### 步骤1：访问GitHub仓库
1. 打开 https://github.com/lyi19833/cinder-pilot
2. 点击顶部的 **Actions** 标签页

### 步骤2：触发构建
每次你向仓库推送代码时，GitHub Actions会自动开始构建。如果你想手动触发：
1. 在Actions页面，点击 **Android CI** 工作流
2. 点击 **Run workflow** 按钮
3. 选择要构建的分支（默认是main）
4. 点击绿色的 **Run workflow** 按钮

### 步骤3：下载APK
构建完成后：
1. 点击已完成的工作流运行
2. 向下滚动到 **Artifacts** 部分
3. 你会看到 **app-debug-apk** 文件
4. 点击文件名下载APK到本地

## 项目配置详情

### 当前稳定配置
- **Android Gradle Plugin**: 8.0.2
- **Gradle**: 8.2
- **Kotlin**: 1.8.20
- **Java**: 1.8
- **Compile SDK**: 34
- **Min SDK**: 24

### GitHub Actions配置
构建过程包括：
1. 设置Java 11环境
2. 安装Android SDK
3. 构建debug版本的APK
4. 将APK作为构建产物上传

## 本地构建命令（可选）

如果你需要在本地测试构建，可以使用以下命令：

```bash
# 在项目目录下执行
.\gradlew assembleDebug
```

构建完成后，APK文件位于：
```
app/build/outputs/apk/debug/app-debug.apk
```

## 常见问题

### 构建失败怎么办？
1. 检查Actions页面的错误日志
2. 确保所有配置文件正确
3. 如果需要帮助，可以分享错误截图

### APK无法安装？
1. 确保手机开启了"未知来源应用"安装权限
2. 如果是覆盖安装，先卸载旧版本
3. 检查Android版本是否兼容（最低支持Android 7.0）

## 注意事项
- GitHub Actions构建的APK有效期为7天
- 每次推送新代码都会自动触发新构建
- 构建日志会保留90天

---

**项目状态**: ✅ 已配置完成，可以开始使用GitHub云构建！

**下一步**: 
1. 访问 https://github.com/lyi19833/cinder-pilot/actions
2. 等待第一次自动构建完成
3. 下载APK文件安装测试