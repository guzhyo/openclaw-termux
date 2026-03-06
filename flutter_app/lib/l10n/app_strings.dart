/// 应用程序中文字符串常量
class AppStrings {
  // 通用
  static const String ok = '确定';
  static const String cancel = '取消';
  static const String confirm = '确认';
  static const String close = '关闭';
  static const String save = '保存';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String add = '添加';
  static const String remove = '移除';
  static const String install = '安装';
  static const String uninstall = '卸载';
  static const String update = '更新';
  static const String refresh = '刷新';
  static const String retry = '重试';
  static const String loading = '加载中...';
  static const String pleaseWait = '请稍候...';
  static const String error = '错误';
  static const String success = '成功';
  static const String warning = '警告';
  static const String info = '信息';
  static const String unknown = '未知';
  static const String notSet = '未设置';
  static const String enabled = '已启用';
  static const String disabled = '已禁用';
  static const String yes = '是';
  static const String no = '否';

  // 应用信息
  static const String appName = 'OpenClaw';
  static const String appDescription = 'AI 网关节点';
  static const String author = '作者';
  static const String version = '版本';
  static const String license = '许可证';

  // 设置向导
  static const String setupTitle = '设置 OpenClaw';
  static const String setupDescription = '这将下载 Ubuntu、Node.js 和 OpenClaw 到独立的环境中。';
  static const String setupInProgress = '正在设置环境，可能需要几分钟时间。';
  static const String beginSetup = '开始设置';
  static const String retrySetup = '重试设置';
  static const String setupComplete = '设置完成';
  static const String configureApiKeys = '配置 API 密钥';
  static const String storageRequirement = '需要约 500MB 存储空间和网络连接';

  // 设置步骤
  static const String stepDownloadUbuntu = '下载 Ubuntu 根文件系统';
  static const String stepExtractRootfs = '解压根文件系统';
  static const String stepInstallNode = '安装 Node.js';
  static const String stepInstallOpenClaw = '安装 OpenClaw';
  static const String stepConfigureBypass = '配置 Bionic Bypass';

  // 下载状态
  static const String downloading = '正在下载...';
  static const String downloadingRootfs = '正在下载 Ubuntu 根文件系统...';
  static const String extractingRootfs = '正在解压根文件系统（可能需要一段时间）...';
  static const String rootfsExtracted = '根文件系统已解压';
  static const String installingNode = '正在安装 Node.js...';
  static const String nodeInstalled = 'Node.js 已安装';
  static const String installingOpenClaw = '正在安装 OpenClaw（可能需要几分钟）...';
  static const String openClawInstalled = 'OpenClaw 已安装';
  static const String creatingBinWrappers = '正在创建二进制包装器...';
  static const String verifyingOpenClaw = '正在验证 OpenClaw...';
  static const String bionicBypassConfigured = 'Bionic Bypass 已配置';
  static const String settingUpDirectories = '正在设置目录...';
  static const String configuringAptMirror = '正在配置软件源镜像...';
  static const String updatingPackageLists = '正在更新软件包列表...';
  static const String installingBasePackages = '正在安装基础软件包...';
  static const String fixingPermissions = '正在修复权限...';

  // 错误信息
  static const String downloadFailed = '下载失败';
  static const String setupFailed = '设置失败';
  static const String checkInternetConnection = '请检查网络连接';
  static const String unknownError = '未知错误';

  // 节点页面
  static const String nodeStatus = '节点状态';
  static const String gatewayConnection = '网关连接';
  static const String nodeConfiguration = '节点配置';
  static const String startNode = '启动节点';
  static const String stopNode = '停止节点';
  static const String restartNode = '重启节点';
  static const String nodeRunning = '节点运行中';
  static const String nodeStopped = '节点已停止';
  static const String nodeStarting = '正在启动...';
  static const String nodeStopping = '正在停止...';
  static const String nodeError = '节点错误';
  static const String notPaired = '未配对';
  static const String paired = '已配对';
  static const String pairing = '配对中...';
  static const String deviceToken = '设备令牌';
  static const String copyToken = '复制令牌';
  static const String tokenCopied = '令牌已复制到剪贴板';
  static const String dashboardUrl = '仪表板地址';
  static const String openDashboard = '打开仪表板';
  static const String capabilities = '功能';
  static const String autoRestart = '自动重启';
  static const String autoRestartEnabled = '已启用自动重启';
  static const String autoRestartDisabled = '已禁用自动重启';

  // 终端页面
  static const String terminal = '终端';
  static const String terminalHint = '输入命令...';
  static const String send = '发送';
  static const String clear = '清空';
  static const String keyboard = '键盘';

  // SSH 页面
  static const String sshServer = 'SSH 服务器';
  static const String sshStatus = 'SSH 状态';
  static const String sshRunning = 'SSH 运行中';
  static const String sshStopped = 'SSH 已停止';
  static const String startSsh = '启动 SSH';
  static const String stopSsh = '停止 SSH';
  static const String setPassword = '设置密码';
  static const String password = '密码';
  static const String confirmPassword = '确认密码';
  static const String passwordSet = '密码已设置';
  static const String connectionInfo = '连接信息';
  static const String ipAddress = 'IP 地址';
  static const String port = '端口';
  static const String username = '用户名';
  static const String root = 'root';

  // 设置页面
  static const String settings = '设置';
  static const String general = '通用';
  static const String about = '关于';
  static const String openSourceLicenses = '开源许可证';
  static const String privacyPolicy = '隐私政策';
  static const String termsOfService = '服务条款';
  static const String checkForUpdates = '检查更新';
  static const String currentVersion = '当前版本';
  static const String noUpdatesAvailable = '没有可用更新';
  static const String updateAvailable = '有可用更新';

  // 网关页面
  static const String gateway = '网关';
  static const String gatewayStatus = '网关状态';
  static const String gatewayRunning = '网关运行中';
  static const String gatewayStopped = '网关已停止';
  static const String startGateway = '启动网关';
  static const String stopGateway = '停止网关';
  static const String gatewayLogs = '网关日志';
  static const String viewLogs = '查看日志';
  static const String clearLogs = '清空日志';

  // 可选包
  static const String optionalPackages = '可选软件包';
  static const String installed = '已安装';
  static const String notInstalled = '未安装';
  static const String installPackage = '安装软件包';
  static const String uninstallPackage = '卸载软件包';
  static const String installingPackage = '正在安装...';
  static const String goDescription = 'Go 编程语言编译器和工具';
  static const String homebrewDescription = 'Linux 缺失的软件包管理器';
  static const String sshDescription = '用于安全远程访问的 SSH 客户端和服务器';

  // 提供商页面
  static const String providers = '提供商';
  static const String addProvider = '添加提供商';
  static const String editProvider = '编辑提供商';
  static const String deleteProvider = '删除提供商';
  static const String providerName = '提供商名称';
  static const String apiKey = 'API 密钥';
  static const String apiUrl = 'API 地址';
  static const String model = '模型';
  static const String testConnection = '测试连接';
  static const String connectionSuccessful = '连接成功';
  static const String connectionFailed = '连接失败';
  static const String noProviders = '没有配置提供商';
  static const String addFirstProvider = '添加第一个提供商';

  // 日志页面
  static const String logs = '日志';
  static const String systemLogs = '系统日志';
  static const String noLogs = '没有日志';
  static const String clearAllLogs = '清空所有日志';
  static const String exportLogs = '导出日志';

  // 引导页面
  static const String welcome = '欢迎使用 OpenClaw';
  static const String onboardingTitle1 = 'AI 网关';
  static const String onboardingDesc1 = '将您的设备转变为 AI 能力网关';
  static const String onboardingTitle2 = '本地处理';
  static const String onboardingDesc2 = '在本地处理 AI 请求，保护隐私';
  static const String onboardingTitle3 = '多功能';
  static const String onboardingDesc3 = '支持摄像头、传感器、位置等多种功能';
  static const String getStarted = '开始使用';
  static const String skip = '跳过';
  static const String next = '下一步';
  static const String previous = '上一步';

  // 杂项
  static const String by = '作者';
  static const String and = '和';
  static const String poweredBy = '技术支持';
}
