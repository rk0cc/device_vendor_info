import 'dart:async';

import 'package:meta/meta.dart';

import '../exceptions.dart' show InvalidDictionaryKeyError;
import '../typedef.dart';

/// [Stream] based [DictionaryEntry] collection that each listeners
/// will be isolated when [listen].
///
/// The mechnism of [VendorDictionaryCollection] is offers
/// new instances of single [StreamSubscription] for listeners
/// that they can only process on their own subscription
/// without interferences. However, when it converted
/// to another stream events (e.g. [cast], [map], [where] and more),
/// it will returns original implementation of [Stream], which
/// is forbidden for subscribe more than one listeners.
///
/// Since it designed to offers unique subscription to
/// various listeners with the same instance, it does not
/// allow to convert as broadcast [Stream] by calling
/// [asBroadcastStream], which thrown [UnsupportedError] instead.
abstract final class VendorDictionaryCollection<V>
    extends Stream<DictionaryEntry<V>> {
  @override
  final bool isBroadcast = false;

  /// Determine only accept [V] if it is Dart's primitive type
  /// as well as [List] and [Map].
  final bool primitiveTypeOnly;

  const VendorDictionaryCollection._(this.primitiveTypeOnly);

  /// Create [VendorDictionaryCollection] with applied [generator]
  /// during [listen].
  ///
  /// If the generated content is excepted to be reused, consider
  /// extends [VendorDictionaryCollectionBase] instead.
  factory VendorDictionaryCollection(
      Stream<DictionaryEntry<V>> Function() generator,
      {bool primitiveTypeOnly}) = _InstantVendorDictionaryCollection;

  Stream<DictionaryEntry<V>> Function() get _generator;

  static bool _isValidType(Object? value) {
    bool isPrimitiveType(Object? value) =>
        value == null || value is num || value is String || value is bool;
    bool isContainerType(Object? value) => value is List || value is Map;

    if (value is List) {
      return value.every(
          (element) => isPrimitiveType(element) || isContainerType(element));
    }

    if (value is Map) {
      return value.entries.every((element) =>
          isPrimitiveType(element.key) &&
          (isPrimitiveType(element.value) || isContainerType(element.value)));
    }

    return isPrimitiveType(value);
  }

  /// Convert this to broadcast [Stream] is disabled. And throw [UnsupportedError]
  /// if attempted.
  @nonVirtual
  @override
  Stream<DictionaryEntry<V>> asBroadcastStream(
      {void Function(StreamSubscription<DictionaryEntry<V>> subscription)?
          onListen,
      void Function(StreamSubscription<DictionaryEntry<V>> subscription)?
          onCancel}) {
    throw UnsupportedError(
        "Convert to broadcast stream is forbidden in DeviceDictionaryCollection.");
  }

  /// Add subscription to this stream.
  ///
  /// The returned [StreamSubscription] is newly constructed
  /// single subscription, which each listeners have dedicated
  /// [StreamSubscription] such that they will only [listen]
  /// their own subscription.
  ///
  /// If duplicated key founds in [DictionaryEntry], it throws
  /// [InvalidDictionaryKeyError].
  ///
  /// It is allows to override but the implementation must be
  /// based on parent's [listen] to ensure functionality of
  /// type checking.
  @mustCallSuper
  @override
  StreamSubscription<DictionaryEntry<V>> listen(
      void Function(DictionaryEntry<V> event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    late final StreamController<DictionaryEntry<V>> controller;
    StreamSubscription<DictionaryEntry<V>>? subscription;

    void startGenerate() {
      final Set<String> appliedKeys = {};

      subscription = _generator().listen((entry) {
        if (!_isValidType(entry.value) && primitiveTypeOnly) {
          controller.addError(TypeError());
          return;
        }

        if (appliedKeys.contains(entry.key)) {
          controller.addError(InvalidDictionaryKeyError(entry.key,
              "Found duplicated key in different DictionaryEntries."));
          return;
        }

        appliedKeys.add(entry.key);
        controller.add(entry);
      }, onError: controller.addError, onDone: controller.close);
    }

    void stopGenerate() async {
      await subscription?.cancel();
      subscription = null;
    }

    controller = StreamController(
        onListen: startGenerate,
        onResume: startGenerate,
        onPause: stopGenerate,
        onCancel: stopGenerate);

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

/// Abstract implementation of custom [VendorDictionaryCollection].
///
/// The streaming events will be relys on [generator] implementations
/// rather than as a parameter in [VendorDictionaryCollection.new] that
/// it allows standarize outputs of [listen] as well as assign as
/// constant value.
abstract base class VendorDictionaryCollectionBase<V>
    extends VendorDictionaryCollection<V> {
  const VendorDictionaryCollectionBase({bool primitiveTypeOnly = false})
      : super._(primitiveTypeOnly);

  /// Implementation of [Stream] output that it relys on the same
  /// sources no matter where [listen] is called.
  ///
  /// If [DictionaryEntry] generated with duplicated key, it only
  /// yield the first entry with associated key only.
  @doNotStore
  @protected
  Stream<DictionaryEntry<V>> generator();

  @override
  Stream<DictionaryEntry<V>> Function() get _generator => generator;
}

final class _InstantVendorDictionaryCollection<V>
    extends VendorDictionaryCollection<V> {
  @override
  final Stream<DictionaryEntry<V>> Function() _generator;

  _InstantVendorDictionaryCollection(this._generator,
      {bool primitiveTypeOnly = false})
      : super._(primitiveTypeOnly);
}
