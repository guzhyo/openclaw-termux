import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../l10n/app_strings.dart';
import '../providers/node_provider.dart';
import '../services/preferences_service.dart';
import '../widgets/node_controls.dart';

class NodeScreen extends StatefulWidget {
  const NodeScreen({super.key});

  @override
  State<NodeScreen> createState() => _NodeScreenState();
}

class _NodeScreenState extends State<NodeScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLocal = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = PreferencesService();
    await prefs.init();
    final host = prefs.nodeGatewayHost ?? '127.0.0.1';
    final port = prefs.nodeGatewayPort ?? 18789;
    final token = prefs.nodeGatewayToken ?? '';
    setState(() {
      _isLocal = host == '127.0.0.1' || host == 'localhost';
      _hostController.text = _isLocal ? '' : host;
      _portController.text = _isLocal ? '' : '$port';
      _tokenController.text = _isLocal ? '' : token;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.nodeConfiguration)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<NodeProvider>(
              builder: (context, provider, _) {
                final state = provider.state;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const NodeControls(),
                    const SizedBox(height: 16),

                    // Gateway Connection
                    _sectionHeader(theme, AppStrings.gatewayConnection),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RadioListTile<bool>(
                              title: const Text('本地网关'),
                              subtitle: const Text('自动配对此设备上的网关'),
                              value: true,
                              groupValue: _isLocal,
                              onChanged: (value) {
                                setState(() => _isLocal = value!);
                              },
                            ),
                            RadioListTile<bool>(
                              title: const Text('远程网关'),
                              subtitle: const Text('连接到另一台设备上的网关'),
                              value: false,
                              groupValue: _isLocal,
                              onChanged: (value) {
                                setState(() => _isLocal = value!);
                              },
                            ),
                            if (!_isLocal) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _hostController,
                                decoration: const InputDecoration(
                                  labelText: '网关主机',
                                  hintText: '192.168.1.100',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _portController,
                                decoration: const InputDecoration(
                                  labelText: '网关端口',
                                  hintText: '18789',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _tokenController,
                                decoration: const InputDecoration(
                                  labelText: '网关令牌',
                                  hintText: '从网关仪表板URL中粘贴令牌',
                                  helperText: '在仪表板URL的 #token= 之后',
                                  prefixIcon: Icon(Icons.key),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () {
                                  final host = _hostController.text.trim();
                                  final port = int.tryParse(_portController.text.trim()) ?? 18789;
                                  final token = _tokenController.text.trim();
                                  if (host.isNotEmpty) {
                                    provider.connectRemote(host, port,
                                        token: token.isNotEmpty ? token : null);
                                  }
                                },
                                icon: const Icon(Icons.link),
                                label: const Text(AppStrings.confirm),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pairing Status
                    if (state.pairingCode != null) ...[
                      _sectionHeader(theme, '配对'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.qr_code, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                '在网关上批准此代码：',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                state.pairingCode!,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Capabilities
                    _sectionHeader(theme, AppStrings.capabilities),
                    _capabilityTile(
                      theme,
                      '摄像头',
                      '拍摄照片和视频片段',
                      Icons.camera_alt,
                    ),
                    _capabilityTile(
                      theme,
                      '画布',
                      '浏览和与网页交互',
                      Icons.web,
                    ),
                    _capabilityTile(
                      theme,
                      '位置',
                      '获取设备GPS坐标',
                      Icons.location_on,
                    ),
                    _capabilityTile(
                      theme,
                      '屏幕录制',
                      '录制设备屏幕（每次需要同意）',
                      Icons.screen_share,
                    ),
                    _capabilityTile(
                      theme,
                      '手电筒',
                      '开关设备手电筒',
                      Icons.flashlight_on,
                    ),
                    _capabilityTile(
                      theme,
                      '振动',
                      '触发触觉反馈和振动模式',
                      Icons.vibration,
                    ),
                    _capabilityTile(
                      theme,
                      '传感器',
                      '读取加速度计、陀螺仪、磁力计、气压计',
                      Icons.sensors,
                    ),
                    const SizedBox(height: 16),

                    // Device Info
                    if (state.deviceId != null) ...[
                      _sectionHeader(theme, '设备信息'),
                      ListTile(
                        title: const Text('设备ID'),
                        subtitle: SelectableText(
                          state.deviceId!,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                        leading: const Icon(Icons.fingerprint),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Logs
                    _sectionHeader(theme, '节点日志'),
                    Card(
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(12),
                        child: state.logs.isEmpty
                            ? Center(
                                child: Text(
                                  '暂无日志',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                reverse: true,
                                itemCount: state.logs.length,
                                itemBuilder: (context, index) {
                                  final log = state.logs[state.logs.length - 1 - index];
                                  return Text(
                                    log,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _capabilityTile(
      ThemeData theme, String title, String subtitle, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.check_circle,
          color: AppColors.statusGreen,
          size: 20,
        ),
      ),
    );
  }
}
