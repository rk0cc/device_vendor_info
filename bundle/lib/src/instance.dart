import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_unix/device_vendor_info_unix.dart';
import 'package:device_vendor_info_windows/device_vendor_info_windows.dart';
import 'package:flutter/foundation.dart';

/// Entry class for fetching device information.
///
/// It only serves for instance managment of [DeviceVendorInfoLoader] which is
/// a handler for extracting hardware information.
final class DeviceVendorInfo {
  static DeviceVendorInfoLoader? _instance;

  const DeviceVendorInfo._();

  static DeviceVendorInfoLoader get _releaseLoader =>
      switch (defaultTargetPlatform) {
        TargetPlatform.linux ||
        TargetPlatform.macOS =>
          UnixDeviceVendorInfoLoader(),
        TargetPlatform.windows => WindowsDeviceVendorInfoLoader(),
        _ =>
          throw UnsupportedError("Unable to get loader for unsupported system")
      };

  /// Get current instance for fetching hardware information.
  ///
  /// If the [instance] getter called directly, it will aggigned real
  /// [DeviceVendorInfoLoader] which disallowed for running testes.
  ///
  /// Moreover, this library only supported Windows, macOS and Linux.
  /// Running unsupported platform will lead to throws [UnsupportedError].
  static DeviceVendorInfoLoader get instance {
    _instance ??= _releaseLoader;

    return _instance!;
  }

  /// Change [DeviceVendorInfoLoader] instance for future uses.
  ///
  /// If [newInstance] assigned as [Null], it will assign
  /// productive version of [DeviceVendorInfoLoader] or
  /// throwning [UnsupportedError] if using under
  /// unsupported platform.
  static set instance(DeviceVendorInfoLoader? newInstance) {
    _instance = newInstance ?? _releaseLoader;
  }
}
