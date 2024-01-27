import 'dart:math';

import 'package:device_vendor_info_interface/interface.dart';

base class MockDeviceVendorInfoLoader implements DeviceVendorInfoLoader {
  @override
  final Future<BiosInfo> biosInfo;

  @override
  final Future<BoardInfo> boardInfo;

  @override
  final Future<SystemInfo> systemInfo;

  MockDeviceVendorInfoLoader._(this.biosInfo, this.boardInfo, this.systemInfo);

  MockDeviceVendorInfoLoader(
      BiosInfo biosInfo, BoardInfo boardInfo, SystemInfo systemInfo)
      : biosInfo = Future.value(biosInfo),
        boardInfo = Future.value(boardInfo),
        systemInfo = Future.value(systemInfo);

  factory MockDeviceVendorInfoLoader.simulateDelay(
      BiosInfo biosInfo, BoardInfo boardInfo, SystemInfo systemInfo,
      {int minimumDelay = 10, int maximumDelay = 250, int? seed}) {
    Random r = Random(seed);

    try {
      r = Random.secure();
    } on UnsupportedError {}

    Duration getSimDelay() {
      return Duration(
          milliseconds: r.nextInt(maximumDelay - minimumDelay) + minimumDelay);
    }

    return MockDeviceVendorInfoLoader._(
        Future.delayed(getSimDelay(), () => biosInfo),
        Future.delayed(getSimDelay(), () => boardInfo),
        Future.delayed(getSimDelay(), () => systemInfo));
  }
}
