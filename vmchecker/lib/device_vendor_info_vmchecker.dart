import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'device_vendor_info_vmchecker_bindings_generated.dart';

const String _libName = 'device_vendor_info_vmchecker';

DynamicLibrary _openLibrary() {
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
}

/// Check the platform where this program executed is under virtualized environment.
///
/// This may becomes false positive if the machines adapted type 1 hypervisor, which allows
/// virtualization with physical hardware directly.
Future<bool> isHypervisor() => Isolate.run(() {
      final DynamicLibrary lib = _openLibrary();

      try {
        return DeviceVendorInfoVmcheckerBindings(lib).is_hypervisor();
      } finally {
        lib.close();
      }
    });
