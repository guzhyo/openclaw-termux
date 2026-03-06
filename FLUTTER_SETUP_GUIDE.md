# Flutter 编译环境配置指南

## 方式一：自动配置（推荐）

### 步骤

1. **以管理员身份运行 PowerShell**
   - 右键点击开始菜单 → Windows PowerShell (管理员)

2. **执行配置脚本**
   ```powershell
   cd C:\Users\guzyo\Downloads\openclaw-termux-1.8.3
   .\setup_flutter_env.ps1
   ```

3. **等待完成**，脚本会自动：
   - 下载 Flutter SDK
   - 配置环境变量
   - 设置国内镜像
   - 检查 Android Studio 和 SDK

---

## 方式二：手动配置

### 1. 下载 Flutter SDK

```powershell
# 下载 Flutter 3.24.5 (稳定版)
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\flutter.zip"

# 解压到 C:\flutter
Expand-Archive -Path "$env:TEMP\flutter.zip" -DestinationPath "C:\"
```

### 2. 配置环境变量

**用户环境变量**（系统属性 → 高级 → 环境变量）：

| 变量名 | 值 |
|--------|-----|
| `Path` | 添加 `C:\flutter\flutter\bin` |
| `PUB_HOSTED_URL` | `https://pub.flutter-io.cn` |
| `FLUTTER_STORAGE_BASE_URL` | `https://storage.flutter-io.cn` |

**PowerShell 命令配置：**
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\flutter\bin", "User")
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")
```

### 3. 安装 Android Studio

1. 下载：https://developer.android.com/studio
2. 安装时勾选：
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device (可选)

3. **配置 Android SDK 环境变量：**
   ```powershell
   [Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", "User")
   [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "$env:LOCALAPPDATA\Android\Sdk", "User")
   ```

### 4. 验证安装

重启 PowerShell，执行：
```powershell
flutter doctor
```

应看到类似输出：
```
[✓] Flutter (Channel stable, 3.24.5, ...)
[✓] Android toolchain - develop for Android devices
[✓] Android Studio
```

如果有 `[!]` 或 `[✗]`，按提示修复。

---

## 编译 OpenClaw APK

环境配置完成后：

```powershell
# 1. 进入项目目录
cd C:\Users\guzyo\Downloads\openclaw-termux-1.8.3\flutter_app

# 2. 获取依赖
flutter pub get

# 3. 编译 Release APK
flutter build apk --release
```

**APK 输出位置：**
```
build\app\outputs\flutter-apk\app-release.apk
```

---

## 常见问题

### 1. 下载依赖很慢

已配置国内镜像，如果仍然慢，可以换其他镜像：

```powershell
# 上海交大镜像
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://mirrors.sjtug.sjtu.edu.cn/dart-pub", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://mirrors.sjtug.sjtu.edu.cn", "User")

# 清华大学镜像
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://mirrors.tuna.tsinghua.edu.cn/dart-pub", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://mirrors.tuna.tsinghua.edu.cn/flutter", "User")
```

### 2. Android licenses 未接受

```powershell
flutter doctor --android-licenses
# 全部输入 y 接受
```

### 3. 找不到 Android SDK

在 Android Studio 中：
1. File → Settings → Appearance & Behavior → System Settings → Android SDK
2. 记住 "Android SDK Location" 路径
3. 设置环境变量：
   ```powershell
   [Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\<你的用户名>\AppData\Local\Android\Sdk", "User")
   ```

### 4. 编译时出现编码错误

```powershell
# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
```

### 5. Gradle 下载失败

编辑 `android\build.gradle`，在 `buildscript` 和 `allprojects` 中添加国内镜像：

```gradle
repositories {
    google()
    mavenCentral()
    maven { url 'https://maven.aliyun.com/repository/google' }
    maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
    maven { url 'https://maven.aliyun.com/repository/public' }
}
```

---

## 需要帮助？

- Flutter 官方文档：https://docs.flutter.dev/get-started/install/windows
- 国内镜像文档：https://flutter.cn/docs/community/china
