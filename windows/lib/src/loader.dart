import 'package:device_vendor_info_interface/definitions.dart';
import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_interface/release.dart';
import 'package:win32_registry/win32_registry.dart';

import 'dictionary.dart';

/// Windows base [DeviceVendorInfoLoader] that to obtain hardware information
/// by reading Windows [Registry].
final class WindowsDeviceVendorInfoLoader
    extends ProductiveDeviceVendorInfoLoader {
  /// Get all raw values can be found in Windows Registry.
  ///
  /// The corresponded entities will be stored
  /// `HKEY_LOCALE_MACHINE\HARDWARE\DESCRIPTION\System\BIOS`
  /// and extract them (not include subdirectories).
  @override
  final DeviceVendorInfoDictionary dictionary;

  /// Create new instance for fetching hardward information.
  WindowsDeviceVendorInfoLoader()
      : dictionary = WindowsDeviceVendorInfoDictionary();

  @override
  Future<BiosInfo> fetchBiosInfo(DeviceVendorInfoDictionary dictionary) async {
    String? releaseDateString = await dictionary["BIOSReleaseDate"] as String?;

    return BiosInfo(
        vendor: "${await dictionary["BIOSVendor"]}",
        version: "${await dictionary["BIOSVersion"]}",
        releaseDate: releaseDateString == null
            ? null
            : biosDateFormat.parse(releaseDateString));
  }

  @override
  Future<BoardInfo> fetchBoardInfo(
      DeviceVendorInfoDictionary dictionary) async {
    return BoardInfo(
        manufacturer: "${await dictionary["BaseBoardManufacturer"]}",
        productName: "${await dictionary["BaseBoardProduct"]}",
        version: "${await dictionary["BaseBoardVersion"]}");
  }

  @override
  Future<SystemInfo> fetchSystemInfo(
      DeviceVendorInfoDictionary dictionary) async {
    return SystemInfo(
        family: "${await dictionary["SystemFamily"]}",
        manufacturer: "${await dictionary["SystemManufacturer"]}",
        productName: "${await dictionary["SystemProductName"]}",
        version: "${await dictionary["SystemVersion"]}");
  }
}
