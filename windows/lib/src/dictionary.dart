import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device_vendor_info_interface/collections.dart';
import 'package:meta/meta.dart';
import 'package:win32_registry/win32_registry.dart';

final class _WindowsVendorDictionaryEntriesStream
    extends VendorDictionaryEntriesStreamBase<Object?> {
  const _WindowsVendorDictionaryEntriesStream();

  Future<RegistryKey> _openRegistry() => Isolate.run(
    () => Registry.openPath(
      RegistryHive.localMachine,
      path: r"HARDWARE\DESCRIPTION\System\BIOS",
      desiredAccessRights: AccessRights.readOnly,
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
        add(regVal.name, switch (regVal) {
          Int32Value(name: String _, value: int intVal) ||
          Int64Value(name: String _, value: int intVal) => intVal,
          StringValue(name: String _, value: String strVal) ||
          UnexpandedStringValue(name: String _, value: String strVal) ||
          LinkValue(name: String _, value: String strVal) => strVal,
          StringArrayValue(name: String _, value: List<String> stAVal) =>
            List.unmodifiable(stAVal),
          BinaryValue(name: String _, value: Uint8List binVal) =>
            Uint8List.fromList(binVal as List<int>).asUnmodifiableView(),
          NoneValue(name: String _) => null,
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
