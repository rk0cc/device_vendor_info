import 'dart:async';

import 'package:device_vendor_info_interface/definitions.dart';
import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_interface/release.dart';

import 'dictionary.dart';

/// UNIX based [DeviceVendorInfoLoader] for getting hardware information.
final class UnixDeviceVendorInfoLoader
    extends ProductiveDeviceVendorInfoLoader {
  /// Get all value if supported Desktop Management Interface (DMI).
  ///
  /// The corresponded entities will be stored  `/sys/class/dmi/id/`
  /// and extract them (not include subdirectories).
  @override
  final VendorDictionary dictionary;

  /// Construct new instance for fetching hardward information.
  UnixDeviceVendorInfoLoader() : dictionary = UnixVendorDictionary();

  static Future<void> _guardAssign(FutureOr<void> Function() assigner) async {
    try {
      assigner();
    } on InvalidDictionaryKeyError {
      // Do nothing
    }
  }

  @override
  Future<BiosInfo> fetchBiosInfo(VendorDictionary dictionary) async {
    String? releaseDate, vendor, version;

    await Future.wait([
      _guardAssign(() async {
        releaseDate = await dictionary["bios_date"];
      }),
      _guardAssign(() async {
        vendor = await dictionary["bios_vendor"];
      }),
      _guardAssign(() async {
        version = await dictionary["bios_version"];
      })
    ]);

    return BiosInfo(
        vendor: vendor,
        version: version,
        releaseDate:
            releaseDate == null ? null : biosDateFormat.parse(releaseDate!));
  }

  @override
  Future<BoardInfo> fetchBoardInfo(VendorDictionary dictionary) async {
    String? manufacturer, productName, version;

    await Future.wait([
      _guardAssign(() async {
        manufacturer = await dictionary["board_vendor"];
      }),
      _guardAssign(() async {
        productName = await dictionary["board_name"];
      }),
      _guardAssign(() async {
        version = await dictionary["board_version"];
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
        manufacturer = await dictionary["sys_vendor"];
      }),
      _guardAssign(() async {
        productName = await dictionary["product_name"];
      }),
      _guardAssign(() async {
        version = await dictionary["product_version"];
      }),
      _guardAssign(() async {
        family = await dictionary["product_family"];
      })
    ]);

    return SystemInfo(
        family: family,
        manufacturer: manufacturer,
        productName: productName,
        version: version);
  }
}
