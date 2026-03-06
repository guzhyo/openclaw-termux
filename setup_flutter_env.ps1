# OpenClaw Flutter 编译环境配置脚本
# 以管理员身份运行 PowerShell 后执行此脚本

param(
    [string]$FlutterVersion = "3.24.5",
    [string]$InstallPath = "C:\flutter",
    [string]$AndroidStudioPath = "${env:ProgramFiles}\Android\Android Studio"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[步骤] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[成功] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[错误] $Message" -ForegroundColor Red
}

# 检查管理员权限
Write-Step "检查管理员权限..."
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "请以管理员身份运行 PowerShell！`n右键点击 PowerShell → 以管理员身份运行"
    exit 1
}
Write-Success "已获得管理员权限"

# 创建安装目录
Write-Step "创建安装目录..."
if (!(Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}
Write-Success "安装目录: $InstallPath"

# 下载 Flutter
Write-Step "下载 Flutter SDK $FlutterVersion..."
$FlutterZip = "$env:TEMP\flutter_windows_$FlutterVersion-stable.zip"
$FlutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$FlutterVersion-stable.zip"

if (Test-Path $FlutterZip) {
    Remove-Item $FlutterZip -Force
}

try {
    Invoke-WebRequest -Uri $FlutterUrl -OutFile $FlutterZip -UseBasicParsing
    Write-Success "下载完成"
} catch {
    Write-Error "下载失败: $_"
    Write-Host "尝试备用下载方式..."
    # 使用 BITS 下载
    Start-BitsTransfer -Source $FlutterUrl -Destination $FlutterZip
}

# 解压 Flutter
Write-Step "解压 Flutter SDK..."
if (Test-Path "$InstallPath\flutter") {
    Write-Host "发现已有 Flutter 安装，正在备份..."
    Rename-Item "$InstallPath\flutter" "$InstallPath\flutter_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force
}

Expand-Archive -Path $FlutterZip -DestinationPath $InstallPath -Force
Write-Success "解压完成"

# 添加环境变量
Write-Step "配置环境变量..."
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallPath\flutter\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallPath\flutter\bin", "User")
    Write-Success "已添加 Flutter 到用户 PATH"
} else {
    Write-Success "Flutter 已在 PATH 中"
}

# 设置 PUB_HOSTED_URL 和 FLUTTER_STORAGE_BASE_URL (国内镜像)
Write-Step "配置 Flutter 镜像..."
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")
Write-Success "已配置国内镜像"

# 刷新环境变量
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User")
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# 验证 Flutter 安装
Write-Step "验证 Flutter 安装..."
& "$InstallPath\flutter\bin\flutter.bat" --version

# 运行 flutter doctor
Write-Step "运行 Flutter Doctor 检查环境..."
& "$InstallPath\flutter\bin\flutter.bat" doctor

# 检查 Android Studio
Write-Step "检查 Android Studio..."
if (Test-Path $AndroidStudioPath) {
    Write-Success "找到 Android Studio: $AndroidStudioPath"
    
    # 检查 Android SDK
    $AndroidSdkPath = "${env:LOCALAPPDATA}\Android\Sdk"
    if (Test-Path $AndroidSdkPath) {
        Write-Success "找到 Android SDK: $AndroidSdkPath"
        [Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidSdkPath, "User")
        [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $AndroidSdkPath, "User")
        $env:ANDROID_HOME = $AndroidSdkPath
        $env:ANDROID_SDK_ROOT = $AndroidSdkPath
    } else {
        Write-Error "未找到 Android SDK，请在 Android Studio 中安装 SDK"
    }
} else {
    Write-Error "未找到 Android Studio"
    Write-Host "请下载安装 Android Studio: https://developer.android.com/studio"
}

# 安装 Android licenses
Write-Step "接受 Android licenses..."
& "$InstallPath\flutter\bin\flutter.bat" doctor --android-licenses

# 最终检查
Write-Step "最终环境检查..."
& "$InstallPath\flutter\bin\flutter.bat" doctor

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Flutter 环境配置完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n请重启 PowerShell 或 IDE 以应用环境变量更改"
Write-Host "`n编译 OpenClaw APK 步骤:"
Write-Host "  1. cd C:\Users\guzyo\Downloads\openclaw-termux-1.8.3\flutter_app"
Write-Host "  2. flutter pub get"
Write-Host "  3. flutter build apk --release"
Write-Host "`nAPK 将生成在: build\app\outputs\flutter-apk\app-release.apk"

# 清理临时文件
Remove-Item $FlutterZip -Force -ErrorAction SilentlyContinue

Write-Host "`n按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
