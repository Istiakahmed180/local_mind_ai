import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DeviceInfo {
  const DeviceInfo({
    required this.manufacturer,
    required this.model,
    required this.sdkInt,
    required this.socModel,
    required this.abis,
    required this.cpuCores,
    required this.totalRamBytes,
    required this.availRamBytes,
    required this.isLowRamDevice,
    required this.memoryClassMb,
    required this.largeMemoryClassMb,
    required this.freeStorageBytes,
    required this.totalStorageBytes,
    required this.isEmulator,
  });

  final String manufacturer;
  final String model;
  final int sdkInt;
  final String? socModel;
  final List<String> abis;
  final int cpuCores;

  /// From ActivityManager.MemoryInfo. Total is reliable; available is a
  /// snapshot that changes constantly and is shown as approximate.
  final int totalRamBytes;
  final int availRamBytes;
  final bool isLowRamDevice;
  final int memoryClassMb;
  final int largeMemoryClassMb;
  final int freeStorageBytes;
  final int totalStorageBytes;
  final bool isEmulator;

  bool get supportsArm64 => abis.contains('arm64-v8a');

  factory DeviceInfo.fromMap(Map<Object?, Object?> m) => DeviceInfo(
    manufacturer: m['manufacturer'] as String? ?? '',
    model: m['model'] as String? ?? '',
    sdkInt: m['sdkInt'] as int? ?? 0,
    socModel: m['socModel'] as String?,
    abis: (m['abis'] as List?)?.cast<String>() ?? const [],
    cpuCores: m['cpuCores'] as int? ?? 1,
    totalRamBytes: (m['totalRamBytes'] as num?)?.toInt() ?? 0,
    availRamBytes: (m['availRamBytes'] as num?)?.toInt() ?? 0,
    isLowRamDevice: m['isLowRamDevice'] as bool? ?? false,
    memoryClassMb: m['memoryClassMb'] as int? ?? 0,
    largeMemoryClassMb: m['largeMemoryClassMb'] as int? ?? 0,
    freeStorageBytes: (m['freeStorageBytes'] as num?)?.toInt() ?? 0,
    totalStorageBytes: (m['totalStorageBytes'] as num?)?.toInt() ?? 0,
    isEmulator: m['isEmulator'] as bool? ?? false,
  );
}

class DeviceInfoService extends GetxService {
  static const _channel = MethodChannel('localmind/device');
  static const _network = EventChannel('localmind/network');

  final info = Rxn<DeviceInfo>();
  final online = false.obs;
  StreamSubscription<dynamic>? _networkSub;

  @override
  void onInit() {
    super.onInit();
    refreshInfo();
    _networkSub = _network.receiveBroadcastStream().listen(
      (value) => online.value = value == true,
      onError: (_) => online.value = false,
    );
  }

  Future<DeviceInfo?> refreshInfo() async {
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>('info');
      if (map != null) info.value = DeviceInfo.fromMap(map);
    } on MissingPluginException {
      // Not running on Android (tests); leave info empty.
    }
    return info.value;
  }

  Future<int> freeStorageBytes() async =>
      (await refreshInfo())?.freeStorageBytes ?? 0;

  @override
  void onClose() {
    _networkSub?.cancel();
    super.onClose();
  }
}
