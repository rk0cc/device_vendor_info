import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device_vendor_info_interface/release.dart'
    show
        DeviceVendorInfoDictionary,
        EntryBasedDeviceVendorInfoDictionary,
        UnsupportedDictionaryPlatformException;
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:win32_registry/win32_registry.dart';

/// Windows implementation of [DeviceVendorInfoDictionary].
@internal
final class WindowsDeviceVendorInfoDictionary
    extends EntryBasedDeviceVendorInfoDictionary {
  /// Constructor of [WindowsDeviceVendorInfoDictionary].
  ///
  /// It only valid when running in Windows. Otherwise, throws
  ///
  WindowsDeviceVendorInfoDictionary() {
    if (!Platform.isWindows) {
      throw UnsupportedDictionaryPlatformException(defaultTargetPlatform,
          windows: true);
    }
  }

  Future<RegistryKey> _openRegistry() =>
      Isolate.run(() => Registry.openPath(RegistryHive.localMachine,
          path: r"HARDWARE\DESCRIPTION\System\BIOS",
          desiredAccessRights: AccessRights.readOnly));

  @override
  Stream<MapEntry<String, Object>> get entries async* {
    RegistryKey k = await _openRegistry();

    try {
      for (var value in k.values) {
        yield MapEntry(
            value.name,
            switch (value.type) {
              RegistryValueType.int32 ||
              RegistryValueType.int64 =>
                value.data as int,
              RegistryValueType.string ||
              RegistryValueType.unexpandedString ||
              RegistryValueType.link =>
                value.data as String,
              RegistryValueType.stringArray =>
                List.unmodifiable(value.data as List<String>) as List<String>,
              RegistryValueType.binary => UnmodifiableUint8ListView(
                  Uint8List.fromList(value.data as List<int>)),
              _ => ""
            });
      }
    } finally {
      k.close();
    }
  }
}
