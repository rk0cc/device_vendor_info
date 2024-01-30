import 'dart:io';

import 'package:async/async.dart';
import 'package:device_vendor_info_interface/interface.dart';
import 'package:intl/intl.dart';

import 'dmi.dart';

/// UNIX based [DeviceVendorInfoLoader] for getting hardware information.
final class UnixDeviceVendorInfoLoader implements DeviceVendorInfoLoader {
  static final DateFormat _usDateFormat = DateFormat("MM/dd/yyyy");

  final AsyncMemoizer<BiosInfo> _biosInfo = AsyncMemoizer();
  final AsyncMemoizer<BoardInfo> _boardInfo = AsyncMemoizer();
  final AsyncMemoizer<SystemInfo> _systemInfo = AsyncMemoizer();
  late final DmiDirectoryReader _dmiDir;

  /// Construct new instance for fetching hardward information.
  UnixDeviceVendorInfoLoader() : assert(Platform.isLinux || Platform.isMacOS) {
    if (Platform.environment.containsKey("FLUTTER_TEST")) {
      throw UnsupportedError(
          "Using real information to perform test is forbidden.");
    }
    _dmiDir = DmiDirectoryReader();
  }

  @override
  Future<BiosInfo> get biosInfo => _biosInfo.runOnce(() async {
        String? releaseDate = await _dmiDir[(DmiCategory.bios, "date")];

        return BiosInfo(
            vendor: await _dmiDir[(DmiCategory.bios, "vendor")],
            version: await _dmiDir[(DmiCategory.bios, "version")],
            releaseDate:
                releaseDate == null ? null : _usDateFormat.parse(releaseDate));
      });

  @override
  Future<BoardInfo> get boardInfo => _boardInfo.runOnce(() async => BoardInfo(
      manufacturer: await _dmiDir[(DmiCategory.board, "vendor")],
      productName: await _dmiDir[(DmiCategory.board, "name")],
      version: await _dmiDir[(DmiCategory.board, "version")]));

  @override
  Future<SystemInfo> get systemInfo =>
      _systemInfo.runOnce(() async => SystemInfo(
          family: await _dmiDir[(DmiCategory.product, "family")],
          manufacturer: await _dmiDir["sys_vendor"],
          productName: await _dmiDir[(DmiCategory.product, "name")],
          version: await _dmiDir[(DmiCategory.product, "version")]));
}