import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_unix/device_vendor_info_unix.dart';
import 'package:device_vendor_info_windows/device_vendor_info_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'mock_loader.dart';

DeviceVendorInfoLoader? _loader;

DeviceVendorInfoLoader get _releaseLoader => switch (defaultTargetPlatform) {
      TargetPlatform.linux ||
      TargetPlatform.macOS =>
        UnixDeviceVendorInfoLoader(),
      TargetPlatform.windows => WindowsDeviceVendorInfoLoader(),
      _ => throw UnsupportedError("Unable to get loader for unsupported system")
    };

@internal
DeviceVendorInfoLoader get loaderInstance {
  if (_loader == null) {
    useMockLoaderInstance();
  }

  return _loader!;
}

void useMockLoaderInstance([MockDeviceVendorInfoLoader? mockLoaderInstance]) {
  _loader = mockLoaderInstance ?? _releaseLoader;
}
