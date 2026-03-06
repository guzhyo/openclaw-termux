@echo off
chcp 65001 >nul
title OpenClaw APK 编译工具
setlocal EnableDelayedExpansion

echo ==========================================
echo    OpenClaw APK 编译工具
echo ==========================================
echo.

REM 检查 Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [警告] 未找到 Flutter！
    echo.
    echo 请选择操作：
    echo  [1] 自动安装 Flutter 环境（推荐）
    echo  [2] 手动安装教程
    echo  [3] 退出
    echo.
    choice /c 123 /n /m "请选择 [1-3]: "
    
    if !errorlevel! equ 1 (
        echo.
        echo 正在启动自动安装...
        powershell -ExecutionPolicy Bypass -File "%~dp0setup_flutter_env.ps1"
        exit /b
    ) else if !errorlevel! equ 2 (
        start "" "%~dp0FLUTTER_SETUP_GUIDE.md"
        exit /b
    ) else (
        exit /b
    )
)

echo [✓] Flutter 已安装
flutter --version 2>nul | findstr "Flutter"
echo.

REM 进入项目目录
cd /d "%~dp0flutter_app"

echo [1/4] 清理旧构建...
if exist "build" rd /s /q "build" 2>nul
echo     完成
echo.

echo [2/4] 获取依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo [错误] 获取依赖失败！
    pause
    exit /b 1
)
echo     完成
echo.

echo [3/4] 编译 Release APK...
echo     这可能需要 5-15 分钟，请耐心等待...
echo.
flutter build apk --release
if %errorlevel% neq 0 (
    echo.
    echo [错误] 编译失败！
    echo 常见原因：
    echo   1. Android SDK 未配置 - 运行 flutter doctor 检查
    echo   2. Gradle 下载失败 - 检查网络连接
    echo   3. 内存不足 - 关闭其他程序后重试
    echo.
    pause
    exit /b 1
)
echo.
echo     完成
echo.

echo [4/4] 复制 APK...
set "APK_SOURCE=build\app\outputs\flutter-apk\app-release.apk"
set "APK_TARGET=%~dp0OpenClaw-v1.8.3.apk"

if exist "%APK_SOURCE%" (
    copy /y "%APK_SOURCE%" "%APK_TARGET%" >nul
    echo     完成
echo.
    echo ==========================================
    echo    编译成功！
    echo ==========================================
    echo.
    echo APK 文件：
    echo   %APK_TARGET%
    echo.
    echo 文件大小：
    for %%F in ("%APK_TARGET%") do (
        echo   %%~zF bytes ^(约 %%~zF / 1048576 MB^)
    )
    echo.
    echo 安装命令：
    echo   adb install "%APK_TARGET%"
    echo.
    
    REM 询问是否安装
    choice /c YN /n /m "是否现在安装到已连接的设备？[Y/N]: "
    if !errorlevel! equ 1 (
        echo.
        echo 正在安装...
        adb install -r "%APK_TARGET%"
        if !errorlevel! equ 0 (
            echo [✓] 安装成功！
        ) else (
            echo [✗] 安装失败，请检查设备连接
        )
    )
) else (
    echo [错误] 未找到 APK 文件！
    echo 预期路径: %APK_SOURCE%
)

echo.
pause
