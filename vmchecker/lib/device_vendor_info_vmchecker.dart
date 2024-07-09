
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'device_vendor_info_vmchecker_bindings_generated.dart';

/// Check the platform where this program executed is under virtualized environment.
Future<bool> isHypervisor() => Isolate.run(_bindings.is_hypervisor);

const String _libName = 'device_vendor_info_vmchecker';

/// The dynamic library in which the symbols for [DeviceVendorInfoVmcheckerBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final DeviceVendorInfoVmcheckerBindings _bindings = DeviceVendorInfoVmcheckerBindings(_dylib);
