import 'dart:io';
import 'dart:isolate';

import 'package:device_vendor_info_interface/release.dart'
    show DeviceVendorInfoDictionary;
import 'package:meta/meta.dart';
import 'package:win32_registry/win32_registry.dart';

/// Windows implementation of [DeviceVendorInfoDictionary].
@internal
final class WindowsDeviceVendorInfoDictionary
    implements DeviceVendorInfoDictionary {
  /// Constructor of [WindowsDeviceVendorInfoDictionary].
  ///
  /// It only valid when running in Windows. Otherwise, the assertion
  /// failed.
  WindowsDeviceVendorInfoDictionary() : assert(Platform.isWindows);

  Future<RegistryKey> _openRegistry() =>
      Isolate.run(() => Registry.openPath(RegistryHive.localMachine,
          path: r"HARDWARE\DESCRIPTION\System\BIOS",
          desiredAccessRights: AccessRights.readOnly));

  @override
  Future<String?> operator [](String key) async {
    try {
      return await entries
          .singleWhere((element) => element.key == key)
          .then((value) => value.value);
    } on StateError {
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) {
    return entries.any((element) => element.key == key);
  }

  @override
  Future<bool> containsValue(String value) {
    return entries.any((element) => element.value == value);
  }

  @override
  Stream<MapEntry<String, String>> get entries async* {
    RegistryKey k = await _openRegistry();

    try {
      for (var value in k.values) {
        yield MapEntry(value.name, "${value.data}");
      }
    } finally {
      k.close();
    }
  }

  @override
  Future<void> forEach(void Function(String key, String value) action) {
    return entries.forEach((element) => action(element.key, element.value));
  }

  @override
  Future<bool> get isEmpty => entries.isEmpty;

  @override
  Future<bool> get isNotEmpty async => !await isEmpty;

  @override
  Stream<String> get keys => entries.map((event) => event.key);

  @override
  Future<int> get length => entries.length;

  @override
  Stream<String> get values => entries.map((event) => event.value);
}
