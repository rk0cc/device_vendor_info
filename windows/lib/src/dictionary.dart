import 'dart:io';
import 'dart:isolate';

import 'package:device_vendor_info_interface/collections.dart';
import 'package:meta/meta.dart';
import 'package:win32_registry/win32_registry.dart';

final class _WindowsVendorDictionaryEntriesStream
    extends VendorDictionaryEntriesStreamBase<Object?> {
  const _WindowsVendorDictionaryEntriesStream();

  Future<RegistryKey> _openRegistry() => Isolate.run(
    () => LOCAL_MACHINE.open(
      r"HARDWARE\DESCRIPTION\System\BIOS",
      config: RegistryOpenConfig(access: RegistryAccess.read),
    ),
  );

  @override
  Future<void> generateContent(
    DictionaryEntryStreamAdder<Object?> add,
    DictionaryEntryStreamThrower addError,
  ) async {
    RegistryKey k = await _openRegistry();

    try {
      for (var regVal in k.values) {
        final regValName = regVal.name;

        add(regValName, switch (regVal.value.type) {
          RegistryValueType.dword ||
          RegistryValueType.qword => k.getInt(regValName),
          RegistryValueType.string => k.getString(regValName),
          RegistryValueType.unexpandedString => k.getUnexpandedString(regValName),
          RegistryValueType.multiString => k.getMultiString(regValName),
          RegistryValueType.binary => k.getBinary(regValName),
          _ => null
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
