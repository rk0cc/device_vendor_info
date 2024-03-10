import 'dart:typed_data' show Uint8List;

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
  ///
  /// The possible values stored in this dictionary are listed
  /// below:
  ///
  /// * [String] - When data types are [RegistryValueType.string]
  ///   , [RegistryValueType.unexpandedString], [RegistryValueType.link]
  ///   as well as [RegistryValueType.none] which yield an empty string.
  /// * [int] - [RegistryValueType.int32] and [RegistryValueType.int64].
  /// * [Uint8List], unmodifiable - [RegistryValueType.binary].
  /// * [List] of [String], unmodifiable - [RegistryValueType.stringArray].
  @override
  final VendorDictionary dictionary;

  /// Create new instance for fetching hardward information.
  WindowsDeviceVendorInfoLoader() : dictionary = WindowsVendorDictionary();

  @override
  Future<BiosInfo> fetchBiosInfo(VendorDictionary dictionary) async {
    String? releaseDateString = await dictionary["BIOSReleaseDate"] as String?;

    return BiosInfo(
        vendor: await dictionary["BIOSVendor"] as String?,
        version: await dictionary["BIOSVersion"] as String?,
        releaseDate: releaseDateString == null
            ? null
            : biosDateFormat.parse(releaseDateString));
  }

  @override
  Future<BoardInfo> fetchBoardInfo(VendorDictionary dictionary) async {
    return BoardInfo(
        manufacturer: await dictionary["BaseBoardManufacturer"] as String?,
        productName: await dictionary["BaseBoardProduct"] as String?,
        version: await dictionary["BaseBoardVersion"] as String?);
  }

  @override
  Future<SystemInfo> fetchSystemInfo(VendorDictionary dictionary) async {
    return SystemInfo(
        family: await dictionary["SystemFamily"] as String?,
        manufacturer: await dictionary["SystemManufacturer"] as String?,
        productName: await dictionary["SystemProductName"] as String?,
        version: await dictionary["SystemVersion"] as String?);
  }
}
