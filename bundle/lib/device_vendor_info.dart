library device_vendor_info;

import 'package:device_vendor_info_interface/interface.dart';

import 'src/global.dart';

final class DeviceVendorInfo {
  const DeviceVendorInfo._();

  static DeviceVendorInfoLoader get loader => loaderInstance;
}
