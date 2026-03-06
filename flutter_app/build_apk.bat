@echo off
chcp 65001 >nul
echo ==========================================
echo OpenClaw APK Build Script
echo ==========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] Flutter 未找到！
    echo.
    echo 请先安装 Flutter SDK：
    echo 1. 访问 https://docs.flutter.dev/get-started/install/windows
    echo 2. 下载并解压到 C:\flutter
    echo 3. 将 C:\flutter\bin 添加到系统 PATH
    echo 4. 运行 flutter doctor 检查配置
    echo.
    pause
    exit /b 1
)

echo [1/4] 检查 Flutter 环境...
flutter doctor --android-licenses >nul 2>nul
flutter doctor

echo.
echo [2/4] 获取依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo [错误] 获取依赖失败！
    pause
    exit /b 1
)

echo.
echo [3/4] 编译 Release APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo [错误] 编译失败！
    pause
    exit /b 1
)

echo.
echo [4/4] 编译完成！
echo ==========================================
echo APK 输出路径:
echo build\app\outputs\flutter-apk\app-release.apk
echo ==========================================
echo.

REM Copy to a known location
copy build\app\outputs\flutter-apk\app-release.apk ..\openclaw-v1.8.3.apk >nul 2>nul
if %errorlevel% equ 0 (
    echo APK 已复制到: ..\openclaw-v1.8.3.apk
)

echo.
pause
