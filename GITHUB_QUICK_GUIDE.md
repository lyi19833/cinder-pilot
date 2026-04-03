# GitHub云构建快速指南

## 一、准备工作

### 1. 安装Git
- 下载: https://git-scm.com/download/win
- 安装时选择"Use Git from the Windows Command Prompt"

### 2. 注册GitHub账号
- 访问: https://github.com/signup
- 如果没有账号，请先注册

### 3. 登录GitHub
- 登录你的GitHub账号

## 二、一键设置（推荐）

### 最简单的方法：
1. **运行设置脚本**：
   ```cmd
   cd c:\Users\nora\cinder-pilot
   SETUP_GITHUB_BUILD.bat
   ```

2. **按照脚本提示操作**

## 三、手动设置步骤

### 步骤1: 初始化Git仓库
```cmd
cd c:\Users\nora\cinder-pilot
git init
```

### 步骤2: 配置Git用户
```cmd
git config user.name "你的GitHub用户名"
git config user.email "你的GitHub邮箱"
```

### 步骤3: 添加文件
```cmd
git add .
git commit -m "Initial commit"
```

### 步骤4: 在GitHub创建仓库
1. 访问: https://github.com/new
2. 仓库名: `cinder-pilot`
3. **不要**勾选"Initialize with README"
4. 点击"Create repository"

### 步骤5: 推送代码
```cmd
git remote add origin https://github.com/你的用户名/cinder-pilot.git
git branch -M main
git push -u origin main
```

## 四、查看构建结果

### 1. 访问你的仓库
```
https://github.com/你的用户名/cinder-pilot
```

### 2. 点击"Actions"标签页
- 会看到正在运行或已完成的构建

### 3. 下载APK
构建成功后：
1. 点击完成的构建
2. 在"Artifacts"部分下载 `app-debug-apk`
3. 解压得到 `app-debug.apk`

## 五、常见问题

### Q1: 推送时要求输入用户名密码
- 使用GitHub Personal Access Token
- 生成Token: https://github.com/settings/tokens
- 选择权限: `repo` (全选)
- 推送时用Token代替密码

### Q2: 构建失败
常见原因：
1. **Gradle版本不兼容** - 已配置为8.2（稳定）
2. **缺少依赖** - GitHub会下载所有依赖
3. **Android SDK问题** - 使用 `actions/setup-android`

### Q3: 如何重新构建
- 修改代码后提交
- 或手动触发：Actions → "Build" → "Run workflow"

## 六、高级功能

### 1. 自动构建分支
每次推送到 `main` 分支都会自动构建。

### 2. 构建历史
保留7天的构建记录和APK。

### 3. 多环境构建
可以配置不同环境（debug/release）。

## 七、优点

1. **无需本地环境** - 云端完成所有构建
2. **环境干净** - 每次都是全新环境
3. **自动化** - 代码推送后自动构建
4. **免费** - GitHub Actions有免费额度
5. **跨平台** - 在Linux环境构建，更稳定

## 八、备用方案

如果GitHub构建失败，还可以使用：
1. **GitLab CI** - 类似GitHub Actions
2. **Bitrise** - 专业移动应用CI/CD
3. **App Center** - 微软的移动应用平台

## 九、技术支持

如果遇到问题：
1. 查看构建日志
2. 检查`.github/workflows/android.yml`配置
3. 搜索GitHub Actions文档