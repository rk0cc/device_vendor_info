import 'dart:io';

import 'package:device_vendor_info_interface/definitions.dart';
import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_interface/release.dart';

import 'dictionary.dart' hide UnixDeviceVendorInfoDictionaryExtension;

/// UNIX based [DeviceVendorInfoLoader] for getting hardware information.
final class UnixDeviceVendorInfoLoader
    extends ProductiveDeviceVendorInfoLoader {
  /// Get all value if supported Desktop Management Interface (DMI).
  ///
  /// The corresponded entities will be stored  `/sys/class/dmi/id/`
  /// and extract them (not include subdirectories).
  @override
  late final DeviceVendorInfoDictionary dictionary;

  /// Construct new instance for fetching hardward information.
  UnixDeviceVendorInfoLoader() {
    if (!Platform.isLinux && !Platform.isMacOS) {
      throw UnsupportedError(
          "This loader is for UNIX platform (e.g. macOS, Linux) only");
    }

    dictionary = UnixDeviceVendorInfoDictionary();
  }

  @override
  Future<BiosInfo> fetchBiosInfo(DeviceVendorInfoDictionary dictionary) async {
    String? releaseDate = await dictionary["bios_date"] as String?;

    return BiosInfo(
        vendor: await dictionary["bios_vendor"] as String?,
        version: await dictionary["bios_version"] as String?,
        releaseDate:
            releaseDate == null ? null : biosDateFormat.parse(releaseDate));
  }

  @override
  Future<BoardInfo> fetchBoardInfo(
      DeviceVendorInfoDictionary dictionary) async {
    return BoardInfo(
        manufacturer: await dictionary["board_vendor"] as String?,
        productName: await dictionary["board_name"] as String?,
        version: await dictionary["board_version"] as String?);
  }

  @override
  Future<SystemInfo> fetchSystemInfo(
      DeviceVendorInfoDictionary dictionary) async {
    return SystemInfo(
        family: await dictionary["product_family"] as String?,
        manufacturer: await dictionary["sys_vendor"] as String?,
        productName: await dictionary["product_name"] as String?,
        version: await dictionary["product_version"] as String?);
  }
}
