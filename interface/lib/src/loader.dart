import 'dart:async';
import 'dart:io';
import 'dart:math' show Random;

import 'package:async/async.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:meta/meta.dart';

import 'info/bios.dart';
import 'info/board.dart';
import 'info/system.dart';
import 'dictionary.dart' hide DeviceVendorInfoDictionaryMapConversion;

/// A barebone loader for finding [BiosInfo] and [SystemInfo]
/// in specific system.
///
/// All information ideally should be run once only, and
/// return the same result for the next getter called from
/// current instance of [DeviceVendorInfoLoader] since
/// these data is rarely changes during execution process
/// that it does not worth to uses computing power for
/// fetching information for each request.
///
/// Since this package is designed for Windows, macOS and Linux
/// [TargetPlatform], invoking [DeviceVendorInfoLoader.new] on
/// unsupport platform always throw [UnsupportedError].
abstract final class DeviceVendorInfoLoader {
  /// Create loader for accessing hardware information.
  ///
  /// The deployed [defaultTargetPlatform] should be Windows, macOS and
  /// Linux only. Invoke other platform result to throw
  /// [UnsupportedError].
  DeviceVendorInfoLoader() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
      default:
        throw UnsupportedError(
            "Current target platform may not offeres hardware information data");
    }
  }

  /// Extract BIOS information.
  Future<BiosInfo> get biosInfo;

  /// Extract motherborad information.
  Future<BoardInfo> get boardInfo;

  /// Extract system information.
  Future<SystemInfo> get systemInfo;
}

/// Productive (or release) version of [DeviceVendorInfoLoader] which
/// report [BiosInfo], [BoardInfo] and [SystemInfo] based on real
/// information found in local machine. Once these data obtained
/// already, it memorizes the result and reuse for incoming
/// calls.
///
/// Any [ProductiveDeviceVendorInfoLoader.new] called during
/// test will throw [UnsupportedError]. To uses [DeviceVendorInfoLoader]
/// when performing test, uses [MockDeviceVendorInfoLoader] instead.
abstract base class ProductiveDeviceVendorInfoLoader
    extends DeviceVendorInfoLoader {
  final AsyncMemoizer<BiosInfo> _biosMemoizer = AsyncMemoizer();
  final AsyncMemoizer<BoardInfo> _boardMemoizer = AsyncMemoizer();
  final AsyncMemoizer<SystemInfo> _systemMemoizer = AsyncMemoizer();

  /// Create instance of [ProductiveDeviceVendorInfoLoader].
  ///
  /// Any instances created during test will lead to throwing
  /// [UnsupportedError] to avoid using real hardware information
  /// to perform testes.
  ProductiveDeviceVendorInfoLoader() {
    if (Platform.environment.containsKey("FLUTTER_TEST")) {
      throw UnsupportedError("Productive loader cannot be applied during test");
    }
  }

  /// Grab informations found in [dictionary] to construct
  /// [BiosInfo] when calling [biosInfo].
  @protected
  Future<BiosInfo> fetchBiosInfo(DeviceVendorInfoDictionary dictionary);

  /// Grab informations found in [dictionary] to construct
  /// [BoardInfo] when calling [boardInfo].
  @protected
  Future<BoardInfo> fetchBoardInfo(DeviceVendorInfoDictionary dictionary);

  /// Grab informations found in [dictionary] to construct
  /// [SystemInfo] when calling [systemInfo].
  @protected
  Future<SystemInfo> fetchSystemInfo(DeviceVendorInfoDictionary dictionary);

  /// Obtain [DeviceVendorInfoDictionary] for finding entity of
  /// hardware information.
  ///
  /// All extended classes **must define** it as `final` property scope
  /// rather than a getter:
  ///
  /// ```dart
  /// // Correct example
  /// base class SampleLoader extends ProductiveDeviceVendorLoader {
  ///   @override
  ///   final DeviceVendorInfoDictionary dictionary = SampleDictionary();
  ///
  ///   // Other implementations
  /// }
  ///
  /// // Incorrect example
  /// base class InvalidLoader extends ProductiveDeviceVendorLoader {
  ///   @override
  ///   DeviceVendorInfoDictionary get dictionary => SampleDictionary();
  /// }
  /// ```
  DeviceVendorInfoDictionary get dictionary;

  @override
  @nonVirtual
  Future<BiosInfo> get biosInfo =>
      _biosMemoizer.runOnce(() => fetchBiosInfo(dictionary));

  @override
  @nonVirtual
  Future<BoardInfo> get boardInfo =>
      _boardMemoizer.runOnce(() => fetchBoardInfo(dictionary));

  @override
  @nonVirtual
  Future<SystemInfo> get systemInfo =>
      _systemMemoizer.runOnce(() => fetchSystemInfo(dictionary));
}

/// Another [DeviceVendorInfoLoader] that all data are defined already
/// in [MockDeviceVendorInfoLoader.new] and [MockDeviceVendorInfoLoader.simulateDelay].
///
/// Since the sources of data no longer come from hardwares, it is preferred
/// to deploy under testing environment. Any implementations done
/// in packages library is discouraged.
@visibleForTesting
base class MockDeviceVendorInfoLoader extends DeviceVendorInfoLoader {
  final BiosInfo _biosInfo;
  final BoardInfo _boardInfo;
  final SystemInfo _systemInfo;

  /// Assign [biosInfo], [boardInfo] and [systemInfo] that it
  /// returns [identical] result to simulate workflow of
  /// [DeviceVendorInfoLoader].
  MockDeviceVendorInfoLoader(
      BiosInfo biosInfo, BoardInfo boardInfo, SystemInfo systemInfo)
      : _biosInfo = biosInfo,
        _boardInfo = boardInfo,
        _systemInfo = systemInfo;

  /// Assign [biosInfo], [boardInfo] and [systemInfo] with random
  /// generated delay for more realistic emulation on fetching
  /// data.
  ///
  /// The [Duration] of random generated delay is based on a range from [initialDelay]
  /// to [latestResponse] and pick a [Duration] value between the range in
  /// milliseconds. Hence, applying negative [Duration] or [initialDelay] is greater than
  /// [latestResponse] will throw [ArgumentError].
  factory MockDeviceVendorInfoLoader.simulateDelay(
      BiosInfo biosInfo, BoardInfo boardInfo, SystemInfo systemInfo,
      {Duration initialDelay,
      Duration latestResponse}) = _DelayedMockDeviceVendorInfoLoader;

  @mustCallSuper
  @override
  Future<BiosInfo> get biosInfo => Future.value(_biosInfo);

  @mustCallSuper
  @override
  Future<BoardInfo> get boardInfo => Future.value(_boardInfo);

  @mustCallSuper
  @override
  Future<SystemInfo> get systemInfo => Future.value(_systemInfo);
}

final class _DelayedMockDeviceVendorInfoLoader
    extends MockDeviceVendorInfoLoader {
  late final Duration Function() _generateDelayDuration;

  _DelayedMockDeviceVendorInfoLoader(
      super.biosInfo, super.boardInfo, super.systemInfo,
      {Duration initialDelay = const Duration(milliseconds: 250),
      Duration latestResponse = const Duration(seconds: 1),
      int? seed}) {
    if ([initialDelay, latestResponse].any((element) => element.isNegative)) {
      throw ArgumentError(
          "Initial delay or latest response cannot be negative duration");
    }

    if (initialDelay > latestResponse) {
      throw ArgumentError("Initial delay should not exceed latest response");
    }

    _generateDelayDuration = () {
      late Random r;

      if (seed == null) {
        try {
          r = Random.secure();
        } on UnsupportedError {
          r = Random();
        }
      } else {
        r = Random(seed);
      }

      final int start = initialDelay.inMilliseconds;
      final int range = latestResponse.inMilliseconds - start;

      return Duration(milliseconds: r.nextInt(range) + start);
    };
  }

  @override
  Future<BiosInfo> get biosInfo =>
      Future.delayed(_generateDelayDuration(), () => super.biosInfo);

  @override
  Future<BoardInfo> get boardInfo =>
      Future.delayed(_generateDelayDuration(), () => super.boardInfo);

  @override
  Future<SystemInfo> get systemInfo =>
      Future.delayed(_generateDelayDuration(), () => super.systemInfo);
}
