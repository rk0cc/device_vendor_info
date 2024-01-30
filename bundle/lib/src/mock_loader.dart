import 'dart:math';

import 'package:device_vendor_info_interface/interface.dart';
import 'package:meta/meta.dart';

/// A replicated [DeviceVendorInfoLoader] which allows to assign [BiosInfo],
/// [BoardInfo] and [SystemInfo] for testing purpose.
@immutable
base class MockDeviceVendorInfoLoader implements DeviceVendorInfoLoader {
  @override
  final Future<BiosInfo> biosInfo;

  @override
  final Future<BoardInfo> boardInfo;

  @override
  final Future<SystemInfo> systemInfo;

  MockDeviceVendorInfoLoader._(this.biosInfo, this.boardInfo, this.systemInfo);

  /// Create a mock loader which obtained immediately.
  MockDeviceVendorInfoLoader(
      BiosInfo biosInfo, BoardInfo boardInfo, SystemInfo systemInfo)
      : biosInfo = Future.value(biosInfo),
        boardInfo = Future.value(boardInfo),
        systemInfo = Future.value(systemInfo);

  /// Simulate a loader with delay to mock duration of fetching data
  /// from system.
  factory MockDeviceVendorInfoLoader.simulateDelay(
      BiosInfo biosInfo, BoardInfo boardInfo, SystemInfo systemInfo,
      {int minimumDelay = 10, int maximumDelay = 250, int? seed}) {
    late Random r;

    if (seed != null) {
      r = Random(seed);
    } else {
      try {
        r = Random.secure();
      } on UnsupportedError {
        r = Random();
      }
    }

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
