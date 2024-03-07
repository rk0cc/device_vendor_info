import 'dart:io';

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:meta/meta.dart';

import 'async/dictionary.dart' show VendorDictionary;
import 'sync/dictionary.dart' show SyncedVendorDictionary;

/// Indicate [VendorDictionary] has been constructed under
/// unsupport platform.
final class UnsupportDictionaryPlatformException implements IOException {
  /// Eligable [TargetPlatform] for [VendorDictionary].
  final Iterable<TargetPlatform> supportedPlatform;

  /// Create exception with expected platform.
  ///
  /// Specifying [linux], [macOS] and [windows] to indicate the
  /// supported platform when using [VendorDictionary].
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
/// invalid opertation in [VendorDictionary] and [SyncedVendorDictionary].
abstract final class InvalidDictionaryOperationError extends Error {
  InvalidDictionaryOperationError._();

  /// Message of invalid opetaion.
  String get message;
}

/// Extended from [TypeError] when applying invalid key types
/// in [SyncedVendorDictionary].
final class DictionaryKeyTypeMismatchError extends TypeError
    implements InvalidDictionaryOperationError {
  @override
  final String message;

  /// A collection of accepted [Type] for [SyncedVendorDictionary.keys]
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

    if (message.isNotEmpty) {
      buf
        ..write("DictionaryKeyTypeMismatchedError: ")
        ..writeln(message);
    }

    buf.write("Only these types of key are eligable to applied: ");

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

/// Error when the provided key does not existed in [VendorDictionary]
/// and [SyncedVendorDictionary].
///
/// The origin implementation of [Map] will return `null` when no corresponded
/// [MapEntry] found in [Map.entries]. However, [VendorDictionary] and
/// [SyncedVendorDictionary] expected the  null type should be returned if
/// and only if the key existed in their entries. Otherwise, this exception
/// thrown instead.
final class UndefinedDictionaryKeyError extends InvalidDictionaryOperationError
    implements ArgumentError, StateError {
  /// The invalid value based on when [Map] returns unexisted key,
  /// which is [Null].
  @override
  @nonVirtual
  final Null invalidValue = null;

  /// Parameter name.
  /// 
  /// If thrown from [VendorDictionary] and [SyncedVendorDictionary],
  /// it should be `key`.
  @override
  final String name;

  /// Applied key that causing this error thrown.
  final Object? key;

  @override
  final String message;

  /// Consturct [UndefinedDictionaryKeyError] with parameter [name]
  /// and [message].
  UndefinedDictionaryKeyError(this.key, {this.name = "key", this.message = ""}) : super._();

  @override
  String toString() {
    final StringBuffer buf = StringBuffer();

    buf
      ..write("UndefinedDictionaryKeyError: ")
      ..writeln(message.isNotEmpty
          ? message
          : "No entries found with corresponded keys.")
      ..writeln()
      ..writeCharCode(9)
      ..write("Applied key: ")
      ..writeln(key);

    return buf.toString();
  }
}
