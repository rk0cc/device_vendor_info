import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'vmchecker_bindings_generated.dart';

/// The bindings to the native functions in [_dylib].
final VmcheckerBindings _bindings = VmcheckerBindings(_dylib);

const String _libName = 'vmchecker';

/// The dynamic library in which the symbols for [VmcheckerBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// Check the platform where this program executed is under virtualized environment.
Future<bool> isHypervisor() => Isolate.run(_bindings.is_hypervisor);
