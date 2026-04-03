#!/bin/bash

# Android APP 打包脚本（Debug APK）

echo "🚀 开始打包 Android APP..."
echo "================================"

cd app

# 清理旧的构建
echo "🧹 清理旧构建..."
./gradlew clean

# 编译 Debug APK
echo "📦 编译 Debug APK..."
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 打包成功！"
    echo ""
    echo "APK 文件位置："
    echo "app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "文件大小："
    ls -lh app/build/outputs/apk/debug/app-debug.apk
else
    echo "❌ 打包失败，请检查错误信息"
    exit 1
fi
