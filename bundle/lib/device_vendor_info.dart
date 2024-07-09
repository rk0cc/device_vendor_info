/// Fetch device's hardware information info Flutter platform.
library device_vendor_info;

import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_interface/release.dart';
import 'src/instance.dart';

export 'package:device_vendor_info_interface/interface.dart'
    show BiosInfo, BoardInfo, SystemInfo;

/// Direct callback for fetching [BiosInfo] from [DeviceVendorInfo.instance].
Future<BiosInfo> getBiosInfo() => DeviceVendorInfo.instance.biosInfo;

/// Direct callback for fetching [BoardInfo] from [DeviceVendorInfo.instance].
Future<BoardInfo> getBoardInfo() => DeviceVendorInfo.instance.boardInfo;

/// Direct callback for fetching [SystemInfo] from [DeviceVendorInfo.instance].
Future<SystemInfo> getSystemInfo() => DeviceVendorInfo.instance.systemInfo;

/// Determine this program executed under virtualized platform. (e.g. Virtual machine,
/// container).
/// 
/// This result is not related with BIOS information that it does not appeared in 
/// [exportRawVendorInfoToJson].
Future<bool> isVirtualized() => DeviceVendorInfo.instance.isVirtualPlatform; 

/// Get [BiosInfo] (`bios` key in [Map]), [BoardInfo] (`mother_board` key in [Map])
/// and [SystemInfo] (`system` key in [Map]) into an unmodifiable [Map].
Future<Map<String, dynamic>> exportVendorInfoToJson() async =>
    Map.unmodifiable(<String, dynamic>{
      "bios": await getBiosInfo().then((value) => value.toJson()),
      "mother_board": await getBoardInfo().then((value) => value.toJson()),
      "system": await getSystemInfo().then((value) => value.toJson())
    });

/// Return original hardware metadata into [String] key JSON
/// format.
Future<Map<String, dynamic>> exportRawVendorInfoToJson() async {
  final DeviceVendorInfoLoader loader = DeviceVendorInfo.instance;

  if (loader is ProductiveDeviceVendorInfoLoader) {
    return loader.dictionary.toSynced();
  }

  return const <String, dynamic>{};
}
