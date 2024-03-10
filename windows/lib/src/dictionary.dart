import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device_vendor_info_interface/collections.dart';
import 'package:meta/meta.dart';
import 'package:win32_registry/win32_registry.dart';

final class _WindowsVendorDictionaryEntriesStream
    extends VendorDictionaryEntriesStreamBase<Object?> {
  const _WindowsVendorDictionaryEntriesStream();

  Future<RegistryKey> _openRegistry() =>
      Isolate.run(() => Registry.openPath(RegistryHive.localMachine,
          path: r"HARDWARE\DESCRIPTION\System\BIOS",
          desiredAccessRights: AccessRights.readOnly));

  @override
  Future<void> generateContent(DictionaryEntryStreamAdder<Object?> add,
      DictionaryEntryStreamThrower addError) async {
    RegistryKey k = await _openRegistry();

    try {
      for (var value in k.values) {
        add(
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
              RegistryValueType.none => null,
              _ => throw TypeError()
            });
      }
    } finally {
      k.close();
    }
  }
}

/// Windows implementation of [VendorDictionary].
@internal
final class WindowsVendorDictionary extends VendorDictionaryBase<Object?> {
  /// Constructor of [WindowsDeviceVendorInfoDictionary].
  ///
  /// It only valid when running in Windows. Otherwise, throws
  ///
  WindowsVendorDictionary() {
    if (!Platform.isWindows) {
      throw UnsupportedError("This dictionary only designed for Windows.");
    }
  }

  @override
  VendorDictionaryEntriesStream<Object?> get entries =>
      const _WindowsVendorDictionaryEntriesStream();
}
