import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:device_vendor_info_interface/interface.dart';
import 'package:intl/intl.dart';
import 'package:win32_registry/win32_registry.dart';

/// Windows base [DeviceVendorInfoLoader] that to obtain hardware information
/// by reading Windows [Registry].
final class WindowsDeviceVendorInfoLoader implements DeviceVendorInfoLoader {
  static const String _infoKeyPath = r"HARDWARE\DESCRIPTION\System\BIOS";
  static final DateFormat _usDateFormat = DateFormat("MM/dd/yyyy");

  final AsyncMemoizer<BiosInfo> _biosInfo = AsyncMemoizer();
  final AsyncMemoizer<BoardInfo> _boardInfo = AsyncMemoizer();
  final AsyncMemoizer<SystemInfo> _systemInfo = AsyncMemoizer();

  /// Create new instance for fetching hardward information.
  ///
  /// [biosInfo], [boardInfo] and [systemInfo] will be fetch once
  /// after this loader constructed.
  WindowsDeviceVendorInfoLoader() : assert(Platform.isWindows) {
    if (Platform.environment.containsKey("FLUTTER_TEST")) {
      throw UnsupportedError(
          "Using real information to perform test is forbidden.");
    }
  }

  Future<T> _operateRegistryTask<T extends Object>(
          T Function(RegistryKey k) task) =>
      Isolate.run(() {
        RegistryKey k = Registry.openPath(RegistryHive.localMachine,
            path: _infoKeyPath, desiredAccessRights: AccessRights.readOnly);

        try {
          T result = task(k);
          return result;
        } finally {
          k.close();
        }
      });

  @override
  Future<BiosInfo> get biosInfo =>
      _biosInfo.runOnce(() => _operateRegistryTask((k) {
            String? releaseDate = k.getValueAsString("BIOSReleaseDate");

            return BiosInfo(
                vendor: k.getValueAsString("BIOSVendor"),
                version: k.getValueAsString("BIOSVersion"),
                releaseDate: releaseDate == null
                    ? null
                    : _usDateFormat.parse(releaseDate));
          }));

  @override
  Future<BoardInfo> get boardInfo =>
      _boardInfo.runOnce(() => _operateRegistryTask((k) {
            return BoardInfo(
                manufacturer: k.getValueAsString("BaseBoardManufacturer"),
                productName: k.getValueAsString("BaseBoardProduct"),
                version: k.getValueAsString("BaseBoardVersion"));
          }));

  @override
  Future<SystemInfo> get systemInfo =>
      _systemInfo.runOnce(() => _operateRegistryTask((k) {
            return SystemInfo(
                family: k.getValueAsString("SystemFamily"),
                manufacturer: k.getValueAsString("SystemManufacturer"),
                productName: k.getValueAsString("SystemProductName"),
                version: k.getValueAsString("SystemVersion"));
          }));
}
