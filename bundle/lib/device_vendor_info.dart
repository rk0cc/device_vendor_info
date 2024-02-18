/// Fetch device's hardware information info Flutter platform.
library device_vendor_info;

import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_interface/release.dart';
import 'src/instance.dart';

export 'package:device_vendor_info_interface/interface.dart'
    show BiosInfo, BoardInfo, SystemInfo;
export 'package:device_vendor_info_unix/device_vendor_info_unix.dart'
    show UnixDeviceVendorInfoDictionaryExtension;

/// Direct callback for fetching [BiosInfo] from [DeviceVendorInfo.instance].
Future<BiosInfo> getBiosInfo() => DeviceVendorInfo.instance.biosInfo;

/// Direct callback for fetching [BoardInfo] from [DeviceVendorInfo.instance].
Future<BoardInfo> getBoardInfo() => DeviceVendorInfo.instance.boardInfo;

/// Direct callback for fetching [SystemInfo] from [DeviceVendorInfo.instance].
Future<SystemInfo> getSystemInfo() => DeviceVendorInfo.instance.systemInfo;

/// Get [BiosInfo] (`bios` key in [Map]), [BoardInfo] (`mother_board` key in [Map])
/// and [SystemInfo] (`system` key in [Map]) into an unmodifiable [Map].
Future<Map<String, dynamic>> exportVendorInfoToJson() async =>
    Map.unmodifiable(<String, dynamic>{
      "bios": await getBiosInfo().then((value) => value.toJson()),
      "mother_board": await getBoardInfo().then((value) => value.toJson()),
      "system": await getSystemInfo().then((value) => value.toJson())
    });

/// Return original hardware metadata into [String]-[String] JSON
/// format.
Future<Map<String, String>> exportRawVendorInfoToJson() async {
  final DeviceVendorInfoLoader loader = DeviceVendorInfo.instance;

  if (loader is ProductiveDeviceVendorInfoLoader) {
    return loader.dictionary.toMap();
  }

  return const <String, String>{};
}
