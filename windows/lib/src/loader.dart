import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:device_vendor_info_interface/definitions.dart';
import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_interface/release.dart';
import 'package:device_vendor_info_vmchecker/device_vendor_info_vmchecker.dart';
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

  static Future<void> _guardAssign(FutureOr<void> Function() assigner) async {
    try {
      await assigner();
    } on InvalidDictionaryKeyError {
      // Do nothing
    }
  }

  @override
  Future<BiosInfo> fetchBiosInfo(VendorDictionary dictionary) async {
    String? releaseDateString, vendor, version;

    await Future.wait([
      _guardAssign(() async {
        releaseDateString = await dictionary["BIOSReleaseDate"];
      }),
      _guardAssign(() async {
        vendor = await dictionary["BIOSVendor"];
      }),
      _guardAssign(() async {
        version = await dictionary["BIOSVersion"];
      })
    ]);

    return BiosInfo(
        vendor: vendor,
        version: version,
        releaseDate: releaseDateString == null
            ? null
            : biosDateFormat.parse(releaseDateString as String));
  }

  @override
  Future<BoardInfo> fetchBoardInfo(VendorDictionary dictionary) async {
    String? manufacturer, productName, version;

    await Future.wait([
      _guardAssign(() async {
        manufacturer = await dictionary["BaseBoardManufacturer"];
      }),
      _guardAssign(() async {
        productName = await dictionary["BaseBoardProduct"];
      }),
      _guardAssign(() async {
        version = await dictionary["BaseBoardVersion"];
      })
    ]);

    return BoardInfo(
        manufacturer: manufacturer, productName: productName, version: version);
  }

  @override
  Future<SystemInfo> fetchSystemInfo(VendorDictionary dictionary) async {
    String? family, manufacturer, productName, version;

    await Future.wait([
      _guardAssign(() async {
        manufacturer = await dictionary["SystemManufacturer"];
      }),
      _guardAssign(() async {
        productName = await dictionary["SystemProductName"];
      }),
      _guardAssign(() async {
        version = await dictionary["SystemVersion"];
      }),
      _guardAssign(() async {
        family = await dictionary["SystemFamily"];
      })
    ]);
    
    return SystemInfo(
        family: family,
        manufacturer: manufacturer,
        productName: productName,
        version: version);
  }

  @override
  Future<bool> fetchIsVirtualPlatform() {
    return isHypervisor();
  }
}
