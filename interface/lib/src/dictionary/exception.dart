part of '../dictionary.dart';

mixin _DeviceVendorInfoDictionaryThrowable<
    T extends DeviceVendorInfoDictionary> {
  String _getDictionaryType() => "Dictionary type: $T";
}

extension on TargetPlatform {
  String get _displayName => switch (this) {
        TargetPlatform.iOS || TargetPlatform.macOS => name,
        _ => "${name[0].toUpperCase()}${name.substring(1)}"
      };
}

/// Indicate the [DeviceVendorInfoDictionary] cannot be constucted
/// in [currentPlatform].
class UnsupportedDictionaryPlatformException implements IOException {
  /// Current [TargetPlatform] when this exception thrown.
  final TargetPlatform currentPlatform;

  /// The eligable [TargetPlatform]s that [DeviceVendorInfoDictionary]
  /// can be constructed.
  final Iterable<TargetPlatform> appliedPlatform;

  static Iterable<TargetPlatform> _getAppliedPlatform(
      bool linux, bool macOS, bool windows) sync* {
    if (linux) {
      yield TargetPlatform.linux;
    }

    if (macOS) {
      yield TargetPlatform.macOS;
    }

    if (windows) {
      yield TargetPlatform.windows;
    }
  }

  /// Construct [UnsupportedDictionaryPlatformException] to prevent
  /// [DeviceVendorInfoDictionary] in unsupported platform.
  UnsupportedDictionaryPlatformException(this.currentPlatform,
      {bool linux = false, bool macOS = false, bool windows = false})
      : appliedPlatform = _getAppliedPlatform(linux, macOS, windows) {
    assert(!appliedPlatform.contains(currentPlatform));
  }

  @override
  String toString() {
    final List<TargetPlatform> apL = List.of(appliedPlatform, growable: false);
    final StringBuffer buf = StringBuffer();

    buf
      ..write("UnsupportedDictionaryPlatformException: ")
      ..write("This dictionary only support in ")
      ..write(apL.getRange(0, apL.length - 1).join(", "))
      ..write(" and ")
      ..write(apL.last)
      ..write(". But it constructed in ")
      ..write(currentPlatform._displayName)
      ..writeln(".");

    return buf.toString();
  }
}

/// [TypeError] based that the same [DeviceVendorInfoDictionary] cannot be
/// accepted as nested dictionary.
final class SameNestedDictionaryTypeError<T extends DeviceVendorInfoDictionary>
    extends TypeError with _DeviceVendorInfoDictionaryThrowable<T> {
  SameNestedDictionaryTypeError._();

  @override
  String toString() {
    final StringBuffer buf = StringBuffer();

    buf
      ..write("SameNestedDictionaryTypeError: ")
      ..writeln("It does not accept exact same type as nested dictionary.")
      ..writeln(_getDictionaryType());

    return buf.toString();
  }
}
