enum NodeStatus {
  disabled,
  disconnected,
  connecting,
  challenging,
  pairing,
  paired,
  error,
}

class NodeState {
  final NodeStatus status;
  final List<String> logs;
  final String? errorMessage;
  final String? pairingCode;
  final String? gatewayHost;
  final int? gatewayPort;
  final String? deviceId;
  final DateTime? connectedAt;

  const NodeState({
    this.status = NodeStatus.disabled,
    this.logs = const [],
    this.errorMessage,
    this.pairingCode,
    this.gatewayHost,
    this.gatewayPort,
    this.deviceId,
    this.connectedAt,
  });

  NodeState copyWith({
    NodeStatus? status,
    List<String>? logs,
    String? errorMessage,
    bool clearError = false,
    String? pairingCode,
    bool clearPairingCode = false,
    String? gatewayHost,
    int? gatewayPort,
    String? deviceId,
    DateTime? connectedAt,
    bool clearConnectedAt = false,
  }) {
    return NodeState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pairingCode: clearPairingCode ? null : (pairingCode ?? this.pairingCode),
      gatewayHost: gatewayHost ?? this.gatewayHost,
      gatewayPort: gatewayPort ?? this.gatewayPort,
      deviceId: deviceId ?? this.deviceId,
      connectedAt: clearConnectedAt ? null : (connectedAt ?? this.connectedAt),
    );
  }

  bool get isPaired => status == NodeStatus.paired;
  bool get isDisabled => status == NodeStatus.disabled;
  bool get isConnecting =>
      status == NodeStatus.connecting || status == NodeStatus.challenging;

  String get statusText {
    switch (status) {
      case NodeStatus.disabled:
        return '已禁用';
      case NodeStatus.disconnected:
        return '已断开';
      case NodeStatus.connecting:
        return '正在连接...';
      case NodeStatus.challenging:
        return '正在验证...';
      case NodeStatus.pairing:
        return '正在配对...';
      case NodeStatus.paired:
        return '已配对';
      case NodeStatus.error:
        return '错误';
    }
  }
}
