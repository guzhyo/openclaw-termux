import 'dart:io';
import 'package:dio/dio.dart';
import '../constants.dart';
import '../models/setup_state.dart';
import 'native_bridge.dart';
import '../l10n/app_strings.dart';

class BootstrapService {
  final Dio _dio = Dio();

  void _updateSetupNotification(String text, {int progress = -1}) {
    try {
      NativeBridge.updateSetupNotification(text, progress: progress);
    } catch (_) {}
  }

  void _stopSetupService() {
    try {
      NativeBridge.stopSetupService();
    } catch (_) {}
  }

  Future<SetupState> checkStatus() async {
    try {
      final complete = await NativeBridge.isBootstrapComplete();
      if (complete) {
        return const SetupState(
          step: SetupStep.complete,
          progress: 1.0,
          message: AppStrings.setupComplete,
        );
      }
      return const SetupState(
        step: SetupStep.checkingStatus,
        progress: 0.0,
        message: '需要设置',
      );
    } catch (e) {
      return SetupState(
        step: SetupStep.error,
        error: '检查状态失败: $e',
      );
    }
  }

  Future<void> runFullSetup({
    required void Function(SetupState) onProgress,
  }) async {
    try {
      // Start foreground service to keep app alive during setup
      try {
        await NativeBridge.startSetupService();
      } catch (_) {} // Non-fatal if service fails to start

      // Step 0: Setup directories
      onProgress(const SetupState(
        step: SetupStep.checkingStatus,
        progress: 0.0,
        message: AppStrings.settingUpDirectories,
      ));
      _updateSetupNotification(AppStrings.settingUpDirectories, progress: 2);
      try { await NativeBridge.setupDirs(); } catch (_) {}
      try { await NativeBridge.writeResolv(); } catch (_) {}

      // Step 1: Download rootfs
      final arch = await NativeBridge.getArch();
      final rootfsUrl = AppConstants.getRootfsUrl(arch);
      final filesDir = await NativeBridge.getFilesDir();

      // Direct Dart fallback: ensure config dir + resolv.conf exist (#40).
      const resolvContent = 'nameserver 8.8.8.8\nnameserver 8.8.4.4\n';
      try {
        final configDir = '$filesDir/config';
        final resolvFile = File('$configDir/resolv.conf');
        if (!resolvFile.existsSync()) {
          Directory(configDir).createSync(recursive: true);
          resolvFile.writeAsStringSync(resolvContent);
        }
        // Also write into rootfs /etc/ so DNS works even if bind-mount fails
        final rootfsResolv = File('$filesDir/rootfs/ubuntu/etc/resolv.conf');
        if (!rootfsResolv.existsSync()) {
          rootfsResolv.parent.createSync(recursive: true);
          rootfsResolv.writeAsStringSync(resolvContent);
        }
      } catch (_) {}
      final tarPath = '$filesDir/tmp/ubuntu-rootfs.tar.gz';

      _updateSetupNotification(AppStrings.downloadingRootfs, progress: 5);
      onProgress(const SetupState(
        step: SetupStep.downloadingRootfs,
        progress: 0.0,
        message: AppStrings.downloadingRootfs,
      ));

      // Clean up any partial download from previous attempt
      final tarFile = File(tarPath);
      if (tarFile.existsSync()) {
        tarFile.deleteSync();
      }

      await _dio.download(
        rootfsUrl,
        tarPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            final mb = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
            // Map download to 5-30% of overall progress
            final notifProgress = 5 + (progress * 25).round();
            _updateSetupNotification('正在下载: $mb / $totalMb MB', progress: notifProgress);
            onProgress(SetupState(
              step: SetupStep.downloadingRootfs,
              progress: progress,
              message: '正在下载: $mb MB / $totalMb MB',
            ));
          }
        },
      );

      // Step 2: Extract rootfs (30-45%)
      _updateSetupNotification(AppStrings.extractingRootfs, progress: 30);
      onProgress(SetupState(
        step: SetupStep.extractingRootfs,
        progress: 0.0,
        message: AppStrings.extractingRootfs,
      ));
      await NativeBridge.extractRootfs(tarPath);
      onProgress(const SetupState(
        step: SetupStep.extractingRootfs,
        progress: 1.0,
        message: AppStrings.rootfsExtracted,
      ));

      // Install bionic bypass + cwd-fix + node-wrapper BEFORE using node.
      // The wrapper patches process.cwd() which returns ENOSYS in proot.
      await NativeBridge.installBionicBypass();

      // Step 3: Install Node.js (45-80%)
      // Fix permissions inside proot (Java extraction may miss execute bits)
      _updateSetupNotification(AppStrings.fixingPermissions, progress: 45);
      onProgress(SetupState(
        step: SetupStep.installingNode,
        progress: 0.0,
        message: AppStrings.fixingPermissions,
      ));
      // Blanket recursive chmod on all bin/lib directories.
      // Java tar extraction loses execute bits; dpkg needs tar, xz,
      // gzip, rm, mv, etc. — easier to fix everything than enumerate.
      await NativeBridge.runInProot(
        'chmod -R 755 /usr/bin /usr/sbin /bin /sbin '
        '/usr/local/bin /usr/local/sbin 2>/dev/null; '
        'chmod -R +x /usr/lib/apt/ /usr/lib/dpkg/ /usr/libexec/ '
        '/var/lib/dpkg/info/ /usr/share/debconf/ 2>/dev/null; '
        'chmod 755 /lib/*/ld-linux-*.so* /usr/lib/*/ld-linux-*.so* 2>/dev/null; '
        'mkdir -p /var/lib/dpkg/updates /var/lib/dpkg/triggers; '
        'echo permissions_fixed',
      );

      // --- Install base packages via apt-get (like Termux proot-distro) ---
      // Now that our proot matches Termux exactly (env -i, clean host env,
      // proper flags), dpkg works normally. No need for Java-side deb
      // extraction — let dpkg+tar handle it inside proot like Termux does.
      _updateSetupNotification(AppStrings.configuringAptMirror, progress: 48);
      onProgress(SetupState(
        step: SetupStep.installingNode,
        progress: 0.1,
        message: AppStrings.configuringAptMirror,
      ));

      // Replace Ubuntu sources with China mirror for faster download
      await NativeBridge.runInProot(
        'cp /etc/apt/sources.list /etc/apt/sources.list.bak && '
        'sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && '
        'sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && '
        'sed -i "s/ports.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && '
        'echo "Mirror configured"',
      );

      _updateSetupNotification(AppStrings.updatingPackageLists, progress: 49);
      onProgress(SetupState(
        step: SetupStep.installingNode,
        progress: 0.1,
        message: AppStrings.updatingPackageLists,
      ));
      await NativeBridge.runInProot('apt-get update -y');

      // Pre-configure tzdata to avoid interactive prompt
      await NativeBridge.runInProot(
        'ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && '
        'echo "Etc/UTC" > /etc/timezone',
      );

      // Install base packages one by one with progress updates
      final packages = [
        ('ca-certificates', 'HTTPS 证书', 0.15),
        ('git', 'Git 版本控制', 0.17),
        ('python3', 'Python 3', 0.20),
        ('make', 'Make 构建工具', 0.22),
        ('g++', 'C++ 编译器', 0.25),
      ];

      for (final (pkg, desc, prog) in packages) {
        _updateSetupNotification('正在安装 $desc...', progress: 52 + (prog * 100).toInt());
        onProgress(SetupState(
          step: SetupStep.installingNode,
          progress: prog,
          message: '正在安装 $desc ($pkg)...',
        ));
        await NativeBridge.runInProot(
          'apt-get install -y --no-install-recommends $pkg',
        );
      }

      // Git config (.gitconfig) is written by installBionicBypass() on the
      // Java side — directly to $rootfsDir/root/.gitconfig — rewrites
      // SSH→HTTPS for npm git deps (no SSH keys in proot).

      // --- Install Node.js via binary tarball ---
      // Download directly from nodejs.org (bypasses curl/gpg/NodeSource
      // which fail inside proot). Includes node + npm + corepack.
      final nodeTarUrl = AppConstants.getNodeTarballUrl(arch);
      final nodeTarPath = '$filesDir/tmp/nodejs.tar.xz';

      onProgress(SetupState(
        step: SetupStep.installingNode,
        progress: 0.3,
        message: '正在下载 Node.js ${AppConstants.nodeVersion}...',
      ));
      _updateSetupNotification('正在下载 Node.js...', progress: 55);

      // Clean up any partial download from previous attempt
      final nodeTarFile = File(nodeTarPath);
      if (nodeTarFile.existsSync()) {
        nodeTarFile.deleteSync();
      }

      await _dio.download(
        nodeTarUrl,
        nodeTarPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = 0.3 + (received / total) * 0.4;
            final mb = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
            // Map Node download to 55-70% of overall
            final notifProgress = 55 + ((received / total) * 15).round();
            _updateSetupNotification('正在下载 Node.js: $mb / $totalMb MB', progress: notifProgress);
            onProgress(SetupState(
              step: SetupStep.installingNode,
              progress: progress,
              message: '正在下载 Node.js: $mb MB / $totalMb MB',
            ));
          }
        },
      );

      _updateSetupNotification('正在解压 Node.js...', progress: 72);
      onProgress(SetupState(
        step: SetupStep.installingNode,
        progress: 0.75,
        message: '正在解压 Node.js...',
      ));
      await NativeBridge.extractNodeTarball(nodeTarPath);

      _updateSetupNotification('正在验证 Node.js...', progress: 78);
      onProgress(SetupState(
        step: SetupStep.installingNode,
        progress: 0.9,
        message: '正在验证 Node.js...',
      ));
      // node-wrapper.js patches broken proot syscalls before loading npm.
      // /usr/local/bin is on PATH, so node finds the tarball's npm.
      const wrapper = '/root/.openclaw/node-wrapper.js';
      const nodeRun = 'node $wrapper';
      // npm from nodejs.org tarball is at /usr/local/lib/node_modules/npm
      const npmCli = '/usr/local/lib/node_modules/npm/bin/npm-cli.js';
      await NativeBridge.runInProot(
        'node --version && $nodeRun $npmCli --version',
      );
      onProgress(const SetupState(
        step: SetupStep.installingNode,
        progress: 1.0,
        message: 'Node.js 已安装',
      ));

      // Step 4: Install OpenClaw (80-98%)
      _updateSetupNotification(AppStrings.installingOpenClaw, progress: 82);
      onProgress(SetupState(
        step: SetupStep.installingOpenClaw,
        progress: 0.0,
        message: AppStrings.installingOpenClaw,
      ));
      // Install openclaw — fork/exec works now with our Termux-matching proot.
      await NativeBridge.runInProot(
        '$nodeRun $npmCli install -g openclaw',
        timeout: 1800,
      );

      _updateSetupNotification(AppStrings.creatingBinWrappers, progress: 92);
      onProgress(SetupState(
        step: SetupStep.installingOpenClaw,
        progress: 0.7,
        message: AppStrings.creatingBinWrappers,
      ));
      // npm global install creates symlinks for bin entries, but symlinks
      // can fail silently in proot. Create shell wrappers from Java side
      // (reads package.json directly from rootfs filesystem — no escaping).
      await NativeBridge.createBinWrappers('openclaw');

      _updateSetupNotification(AppStrings.verifyingOpenClaw, progress: 96);
      onProgress(SetupState(
        step: SetupStep.installingOpenClaw,
        progress: 0.9,
        message: AppStrings.verifyingOpenClaw,
      ));
      await NativeBridge.runInProot('openclaw --version || echo openclaw_installed');
      onProgress(const SetupState(
        step: SetupStep.installingOpenClaw,
        progress: 1.0,
        message: 'OpenClaw 已安装',
      ));

      // Step 5: Bionic Bypass already installed (before node verification)
      _updateSetupNotification('设置完成!', progress: 100);
      onProgress(const SetupState(
        step: SetupStep.configuringBypass,
        progress: 1.0,
        message: AppStrings.bionicBypassConfigured,
      ));

      // Done
      _stopSetupService();
      onProgress(const SetupState(
        step: SetupStep.complete,
        progress: 1.0,
        message: '设置完成! 准备启动网关。',
      ));
    } on DioException catch (e) {
      _stopSetupService();
      onProgress(SetupState(
        step: SetupStep.error,
        error: '下载失败: ${e.message}。请检查网络连接。',
      ));
    } catch (e) {
      _stopSetupService();
      onProgress(SetupState(
        step: SetupStep.error,
        error: '设置失败: $e',
      ));
    }
  }
}
