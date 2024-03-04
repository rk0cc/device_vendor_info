import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math hide MutableRectangle, Random, Point, Rectangle;
import 'dart:typed_data';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:meta/meta.dart';

/// [MapEntry] type definition for [DeviceVendorInfoDictionary.entries]
/// that the value does not resolved yet.
@optionalTypeArgs
typedef FutureDictionaryEntry<V extends Object> = MapEntry<String, Future<V?>>;

/// [MapEntry] type definition for [SyncedDeviceVendorInfoDictionary.entries]
/// that the value is resolved from [FutureDictionaryEntry].
@optionalTypeArgs
typedef DictionaryEntry<V extends Object> = MapEntry<String, V?>;

/// Indicate [DeviceVendorInfoDictionary] has been constructed under
/// unsupport platform.
final class UnsupportDictionaryPlatformException implements IOException {
  /// Eligable [TargetPlatform] for [DeviceVendorInfoDictionary].
  final Iterable<TargetPlatform> supportedPlatform;

  /// Create exception with expected platform.
  ///
  /// Specifying [linux], [macOS] and [windows] to indicate the
  /// supported platform when using [DeviceVendorInfoDictionary].
  /// Therefore, at least one of them must be defined as `true`.
  UnsupportDictionaryPlatformException(
      {bool linux = false, bool macOS = false, bool windows = false})
      : assert(linux || macOS || windows),
        supportedPlatform = List.unmodifiable(<TargetPlatform>[
          if (linux) TargetPlatform.linux,
          if (macOS) TargetPlatform.macOS,
          if (windows) TargetPlatform.windows
        ]);

  /// Create exception that applied for all supported platform.
  ///
  /// This constructor is equivalent to this code:
  ///
  /// ```dart
  /// throw UnsupportDictionaryPlatformException(linux: true, macOS: true, windows: true);
  /// ```
  @visibleForTesting
  UnsupportDictionaryPlatformException.allPlatforms()
      : supportedPlatform = const <TargetPlatform>[
          TargetPlatform.linux,
          TargetPlatform.macOS,
          TargetPlatform.windows
        ];
}

/// An abstract, general defintion of [Error] regarding to
/// invalid opertation in [DeviceVendorInfoDictionary] and
/// [SyncedDeviceVendorInfoDictionary] exclusively.
abstract final class InvalidDictionaryOperationError implements Error {
  const InvalidDictionaryOperationError._();

  /// Message of invalid opetaion.
  String get message;
}

/// Extended from [TypeError] when applying invalid key types
/// in [DeviceVendorInfoDictionary] or [SyncedDeviceVendorInfoDictionary].
final class DictionaryKeyTypeMismatchError extends TypeError
    implements InvalidDictionaryOperationError {
  @override
  final String message;

  /// A collection of accepted [Type] for [DeviceVendorInfoDictionary.keys]
  /// or [SyncedDeviceVendorInfoDictionary.keys].
  ///
  /// Every elements of [Type]s must be public accessable. Applying
  /// private [Type]s (name with leading underscore (`_`))
  /// cannot be accepted as a member of [approvedTypes].
  final Set<Type> approvedTypes;

  /// Construct [DictionaryKeyTypeMismatchError] and indicate eligable [Type]s
  /// in [approvedTypes] as well as applied [message].
  ///
  /// [approvedTypes] must be applied with non-empty [Iterable].
  /// Including [Never] type or applying [Null] type without
  /// providing additional [Type]s is forbidden.
  DictionaryKeyTypeMismatchError(Iterable<Type> approvedTypes,
      {this.message = ""})
      : assert(approvedTypes.isNotEmpty),
        assert(approvedTypes.every(_checkIsPublicType)),
        assert(!approvedTypes.contains(Never)),
        assert(() {
          if (approvedTypes.contains(Null)) {
            return approvedTypes.length >= 2;
          }

          return true;
        }()),
        approvedTypes = Set.unmodifiable(approvedTypes);

  /// Construct [DictionaryKeyTypeMismatchError] that the dictionary
  /// only accept a single [approvedType] along with [message]
  /// of this error.
  ///
  /// Eligable [approvedType] can be accept majority of dart [Type]s
  /// except [Null] and [Never]. [Null] only can be applied when
  /// [nullable] is set as `true`.
  DictionaryKeyTypeMismatchError.singleType(Type approvedType,
      {bool nullable = false, this.message = ""})
      : assert(_checkIsPublicType(approvedType)),
        assert(!const <Type>{Null, Never}.contains(approvedType)),
        approvedTypes =
            Set.unmodifiable(<Type>{approvedType, if (nullable) Null});

  static bool _checkIsPublicType(Type type) {
    return "$type"[0] != "_";
  }

  @override
  String toString() {
    final StringBuffer buf = StringBuffer();

    buf
      ..write("DictionaryKeyTypeMismatchedError: ")
      ..writeln(message)
      ..write("Only these types of key are eligable to applied: ");

    switch (approvedTypes.length) {
      case 1:
        buf.writeln(approvedTypes.single);
        break;
      case 2:
        if (approvedTypes.contains(Null)) {
          buf
            ..write(approvedTypes.singleWhere((element) => element != Null))
            ..writeln("?");
          break;
        }
      default:
        for (Type t in approvedTypes) {
          buf
            ..writeCharCode(9)
            ..writeln(t);
        }
        break;
    }

    return buf.toString();
  }
}

/// Error when the provided key does not existed in [DeviceVendorInfoDictionary]
/// or [SyncedDeviceVendorInfoDictionary].
///
/// The origin implementation of [Map] will return `null` when no corresponded
/// [MapEntry] found in [Map.entries]. However, [DeviceVendorInfoDictionary]
/// and [SyncedDeviceVendorInfoDictionary] expected the null type should be
/// returned if and only if the key existed in their entries. Otherwise,
/// this exception thrown instead.
final class UndefinedDictionaryKeyError extends Error
    implements ArgumentError, InvalidDictionaryOperationError, StateError {
  /// The invalid value based on when [Map] returns unexisted key,
  /// which is [Null].
  @override
  @nonVirtual
  final Null invalidValue = null;

  /// Parameter name that causing this error throws.
  @override
  final String name;

  @override
  final String message;

  /// Consturct [UndefinedDictionaryKeyError] with parameter [name]
  /// and [message].
  UndefinedDictionaryKeyError(this.name, [String message = ""])
      : message = message.isEmpty
            ? "No entries found with corresponded keys."
            : message;

  @override
  String toString() {
    final StringBuffer buf = StringBuffer();

    buf
      ..write("UndefinedDictionaryKeyError: ")
      ..writeln(message)
      ..writeln()
      ..writeCharCode(9)
      ..write("Key name: ")
      ..writeln(name);

    return buf.toString();
  }
}

/// [Iterable] based class for extract all available hardware information
/// in device.
///
/// It will iterated [FutureDictionaryEntry] and can be converted to
/// [DictionaryEntry] in [Stream] by calling [toStream].
@optionalTypeArgs
abstract base class IteratedFutureDictionaryEntries<V extends Object>
    extends Iterable<FutureDictionaryEntry<V>> {
  const IteratedFutureDictionaryEntries();

  /// Resolves all [Future] values and formed as a [Stream] of
  /// [DictionaryEntry].
  Stream<DictionaryEntry<V>> toStream() async* {
    for (var MapEntry(key: k, value: v) in this) {
      yield MapEntry(k, await v);
    }
  }
}

base mixin _DeviceVendorInfoDictionaryMixin<V>
    on UnmodifiableMapBase<String, V> {
  @override
  V operator [](Object? key) {
    if (key is! String) {
      throw DictionaryKeyTypeMismatchError.singleType(String,
          message: "Invalid key type of dictionary.");
    }

    final matched = entries.where((element) => element.key == key);

    if (matched.isEmpty) {
      throw UndefinedDictionaryKeyError(key, "This key does not existed.");
    }

    return matched.single.value;
  }

  @override
  Iterable<MapEntry<String, V>> get entries;

  @override
  Iterable<String> get keys => entries.map((e) => e.key);

  @override
  Iterable<V> get values => entries.map((e) => e.value);
}

/// [UnmodifiableMapBase] object to obtains retrived
/// device information from sources.
///
/// Implementing [DeviceVendorInfoDictionary] can be done by
/// extending [entries]. Then rest of the function can be handled
/// by default implementations already.
///
/// Calling [DeviceVendorInfoDictionary.new] must be under
/// supported [TargetPlatform] (Windows, macOS and Linux) in
/// general, and can be narrowed down to specific platforms.
/// When the platform does not satisified requirement,
/// it should throw [UnsupportDictionaryPlatformException].
@optionalTypeArgs
abstract base class DeviceVendorInfoDictionary<V extends Object>
    extends UnmodifiableMapBase<String, Future<V?>>
    with _DeviceVendorInfoDictionaryMixin<Future<V?>> {
  /// Create new instance of dictionary for querying device vendor
  /// information.
  ///
  /// It expected to be called under Windows, macOS and Linux
  /// referring to [defaultTargetPlatform]. Otherwise, it
  /// throws [UnsupportDictionaryPlatformException] except during
  /// test.
  DeviceVendorInfoDictionary() {
    final onTest = Platform.environment.containsKey("FLUTTER_TEST");
    final isSupportedPlatform = const [
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows
    ].contains(defaultTargetPlatform);

    if (!onTest && !isSupportedPlatform) {
      throw UnsupportDictionaryPlatformException.allPlatforms();
    }
  }

  /// Get [values] where assigned with corresponded [key].
  ///
  /// The [key] must be a [String], parsing other types
  /// will throw [DictionaryKeyTypeMismatchError].
  ///
  /// It returns [Future] value, which presents in this
  /// dictionary.
  ///
  /// Unlike traditional [Map] that it returns `null` if
  /// no [values] assigned with the [key], it throws
  /// [UndefinedDictionaryKeyError] instead.
  @override
  Future<V?> operator [](Object? key) => super[key];

  /// The entries of this dictionary.
  @override
  @mustBeOverridden
  IteratedFutureDictionaryEntries<V> get entries;

  /// Convert to [String] notation of [Map] object.
  ///
  /// Since [values] are wrapped with [Future], which
  /// is impossible to resolve actual data synchronously
  /// that every [values] will be replaced to `<Future>`
  /// instead:
  ///
  /// ```json
  /// {"foo": "<Future>"}
  /// ```
  ///
  /// To obtain resolved [Future] values in [String],
  /// it must be converted to [SyncedDeviceVendorInfoDictionary]
  /// by calling [AsyncDeviceVendorInfoDictionaryExtension.toSyncedValuesDictionary].
  ///
  /// ### See also
  ///
  /// * [SyncedDeviceVendorInfoDictionary.toString] : Notating dictionary in [String]
  /// with resolved [values].
  @override
  String toString() {
    return "{${keys.map((e) => "$e:<Future>").join(",")}}";
  }
}

/// Asynchronous process extension on top of [DeviceVendorInfoDictionary].
extension AsyncDeviceVendorInfoDictionaryExtension<V extends Object>
    on DeviceVendorInfoDictionary<V> {
  /// Resolved all [values] and returned as [Stream].
  Stream<V?> get streamValues => Stream.fromFutures(values);

  /// Performing [forEach] asynchronously with resolved [values].
  Future<void> forEachAsync(void Function(String key, V? value) action) =>
      entries
          .toStream()
          .forEach((element) => action(element.key, element.value));

  /// Apply [DeviceVendorInfoDictionary] to [SyncedDeviceVendorInfoDictionary]
  /// which all [Future] of [values] will be resolved during
  /// construction.
  SyncedDeviceVendorInfoDictionary<V> toSyncedValuesDictionary() =>
      SyncedDeviceVendorInfoDictionary._(this);
}

/// A preference for converting bytes, which is a [List] of [int]
/// with [TypedData] implemented value.
///
/// The notation of bytes will be wrapped in angle bracket and containing
/// numerous of bytes value in [int].
///
/// ```dart
/// "<1 4 43 143 -29 86>" // Decimal
/// "<0x00F3 0x34F0 -0x0002>" // Hexadecimal
/// ```
///
/// When stringify bytes in [lowerHexadecimal] or [upperHexadecimal],
/// the notations always formed with `0x` prefix and length of hexadecimal
/// value must be `2^n` where `n` is the maximum length of hexadecimal value
/// that allowing the maximum magnitude of byte value can be displayed within
/// `2^n` standard.
///
/// ```dart
/// [256, 255] // These will be converted to <0x0100 0x00FF>
/// [0x100, 0XFF] // Same rule applied form above
/// ```
enum StringifyBytes {
  /// Stringify bytes to decimal value.
  decimal(_DecimalStringifier()),

  /// Stringify bytes to hexadecimal value and display
  /// letters in [String.toLowerCase].
  lowerHexadecimal(_HexadecimalStringifier(false)),

  /// Stringify bytes to hexadecimal value and display
  /// letters in [String.toUpperCase].
  upperHexadecimal(_HexadecimalStringifier(true));

  final _BytesStringifier _stringifier;

  const StringifyBytes(this._stringifier);
}

sealed class _BytesStringifier {
  const _BytesStringifier();

  String _byteToString(bool negative, int magnitude, int maxMag);

  @nonVirtual
  String stringify(List<int> bytes) {
    assert(bytes is TypedData, "Bytes must be implemented TypedData already.");

    final int maxMag = bytes.map((e) => e < 0 ? e * -1 : e).reduce(math.max);
    final ctx = bytes.map((e) {
      final bool negative = e < 0;

      return _byteToString(negative, negative ? e * -1 : e, maxMag);
    }).join(" ");

    return "<$ctx>";
  }
}

final class _DecimalStringifier extends _BytesStringifier {
  const _DecimalStringifier();

  @override
  String _byteToString(bool negative, int magnitude, int maxMag) {
    final StringBuffer buf = StringBuffer();

    if (negative) {
      buf.write(r"-");
    }

    buf.write(magnitude.toRadixString(10));

    return buf.toString();
  }
}

final class _HexadecimalStringifier extends _BytesStringifier {
  final bool uppercase;

  const _HexadecimalStringifier(this.uppercase);

  @override
  String _byteToString(bool negative, int magnitude, int maxMag) {
    int bytesLength = 2;
    while (maxMag >= math.pow(2, 4 * bytesLength)) {
      bytesLength *= 2;
    }

    final StringBuffer buf = StringBuffer();

    if (negative) {
      buf.write(r"-");
    }

    buf.write(r"0x");

    final String magRadixStr =
        magnitude.toRadixString(16).padLeft(bytesLength, r"0");

    buf.write(
        uppercase ? magRadixStr.toUpperCase() : magRadixStr.toLowerCase());

    return buf.toString();
  }
}

/// Resolve and store all [DeviceVendorInfoDictionary.values]
/// and obtains [values] like oridinary [Map].
final class SyncedDeviceVendorInfoDictionary<V extends Object>
    extends UnmodifiableMapBase<String, V?>
    with _DeviceVendorInfoDictionaryMixin<V?> {
  late final Map<String, V?> _synced;

  /// Preferences of representing bytes data when calling
  /// [toString].
  StringifyBytes stringifyBytes = StringifyBytes.upperHexadecimal;

  SyncedDeviceVendorInfoDictionary._(DeviceVendorInfoDictionary<V> dictionary) {
    // This should able to sync all values without marking await.
    _mapSync(dictionary);
  }

  void _mapSync(DeviceVendorInfoDictionary<V> dictionary) async {
    _synced = Map.unmodifiable(<String, V?>{
      for (var MapEntry(key: k, value: futureV) in dictionary.entries)
        k: await futureV
    });
  }

  /// Get synced [values] result originally from
  /// [DeviceVendorInfoDictionary].
  ///
  /// The [key] must be a [String], parsing other types
  /// will throw [DictionaryKeyTypeMismatchError].
  ///
  /// It returned all [Future] resolved value during
  /// construction of [SyncedDeviceVendorInfoDictionary].
  ///
  /// Unlike traditional [Map] that it returns `null` if
  /// no [values] assigned with the [key], it throws
  /// [UndefinedDictionaryKeyError] instead.
  @override
  V? operator [](Object? key) => super[key];

  @override
  Iterable<DictionaryEntry<V>> get entries => _synced.entries;

  /// Convert to [String] notation with actual [values].
  ///
  /// The result should be closed to [jsonEncode], with only
  /// difference on handling bytes data (a [List] of [int] which
  /// implemented [TypedData] at the same time, for example: [Uint8List])
  /// that it will convert as [String] depending current setting of
  /// [StringifyBytes].
  @override
  String toString() {
    String mapper(MapEntry<String, V?> entry) {
      final StringBuffer buf = StringBuffer();
      final MapEntry(key: k, value: v) = entry;

      buf
        ..write(k)
        ..write(r":");

      if (v is List<int>) {
        if (v is TypedData) {
          buf.write(stringifyBytes._stringifier.stringify(v));

          return buf.toString();
        }
      }

      buf.write(v);

      return buf.toString();
    }

    return "{${entries.map(mapper).join(",")}}";
  }
}
