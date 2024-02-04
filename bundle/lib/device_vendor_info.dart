/// Fetch device's hardware information info Flutter platform.
library device_vendor_info;

import 'package:device_vendor_info_interface/interface.dart';
import 'src/instance.dart';

export 'package:device_vendor_info_interface/interface.dart'
    show BiosInfo, BoardInfo, SystemInfo;

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
