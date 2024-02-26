import 'dart:io';

import 'package:device_vendor_info_interface/release.dart'
    show DeviceVendorInfoDictionary;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// UNIX implementation of [DeviceVendorInfoDictionary].
@internal
final class UnixDeviceVendorInfoDictionary
    implements DeviceVendorInfoDictionary {
  /// Constructor of [UnixDeviceVendorInfoDictionary].
  ///
  /// It only valid when running in UNIX. Otherwise, the assertion
  /// failed.
  UnixDeviceVendorInfoDictionary() {
    if (!Platform.isMacOS && !Platform.isLinux) {}
  }

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
    final Directory dmi = Directory(r"/sys/class/dmi/id/");
    assert(dmi.isAbsolute);

    if (!await dmi.exists()) {
      return;
    }

    bool isReadable(String mode) =>
        RegExp(r"(?:r(?:w|-)(?:x|-)){3}$", caseSensitive: true, dotAll: false)
            .hasMatch(mode);

    final Stream<File> dmiFiles = dmi
        .list(followLinks: false)
        .where((entity) =>
            entity is File && isReadable(entity.statSync().modeString()))
        .cast<File>();

    await for (File f in dmiFiles) {
      yield MapEntry(p.basename(f.path), await f.readAsString());
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

/// Categorize DMI file structure found in UNIX implementation of
/// [DeviceVendorInfoDictionary].
///
/// The structure of [DeviceVendorInfoDictionary.keys] are formed as
/// `<types>_<names>` that allowing to categorize which hardware types
/// and names can be fetched.
///
/// When [types] and [names] calles in non-UNIX platform, it will returns
/// an empty [String].
extension UnixDeviceVendorInfoDictionaryExtension
    on DeviceVendorInfoDictionary {
  Stream<(String, String)> _keyStruct() {
    if (this is UnixDeviceVendorInfoDictionary) {
      return keys.map((event) {
        final splited = event.split("_");

        return (splited[0], splited.sublist(1).join("_"));
      });
    }

    return const Stream.empty(broadcast: false);
  }

  /// Get available hardware types can be found in hardware.
  Future<Set<String>> get types =>
      _keyStruct().map((event) => event.$1).toSet().then(Set.unmodifiable);

  /// Get available names of [types].
  ///
  /// The provided names may not applied as a pair with [types].
  Future<Set<String>> get names =>
      _keyStruct().map((event) => event.$2).toSet().then(Set.unmodifiable);
}
