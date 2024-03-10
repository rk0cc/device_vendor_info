import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'typedef.dart';

/// [Stream] based [DictionaryEntry] collection that each listeners
/// will be isolated when [listen].
///
/// The mechnism of [VendorDictionaryEntriesStream] is offers
/// new instances of single [StreamSubscription] for listeners
/// that they can only process on their own subscription
/// without interferences. However, when it converted
/// to another stream events (e.g. [cast], [map], [where] and more),
/// it will returns original implementation of [Stream], which
/// is forbidden for subscribe more than one listeners.
/// As a result, although it is identical with broadcast
/// [Stream], it cannot be categorized as broadcast stream and
/// any attempted to convert it into broadcast stream by
/// [asBroadcastStream] is forbidden.
///
/// [DictionaryEntry] will yield as the same behaviour in
/// [Map], which refers to latest assigned value with
/// associated key only. However, due to concurrency
/// process, it does not gurantte the order of entries.
abstract final class VendorDictionaryEntriesStream<V>
    implements Stream<DictionaryEntry<V>> {
  const VendorDictionaryEntriesStream._();

  /// Create an instant, ready-to-use [VendorDictionaryEntriesStream]
  /// with directly apply [generator], which stream [DictionaryEntry]
  /// in [Record] form.
  ///
  /// It only suitable for temprorary implementations, for generating
  /// [DictionaryEntry] from the same sources or allow store as constant,
  /// please extends [VendorDictionaryEntriesStreamBase] instead.
  factory VendorDictionaryEntriesStream(
          Stream<(String, V)> Function() generator) =
      _InstantVendorDictionaryEntriesStream;

  /// Converting [VendorDictionaryEntriesStream] to broadcast [Stream]
  /// is forbidden. It throws [UnsupportedError] once it called.
  @override
  Stream<DictionaryEntry<V>> asBroadcastStream(
      {void Function(StreamSubscription<DictionaryEntry<V>> subscription)?
          onListen,
      void Function(StreamSubscription<DictionaryEntry<V>> subscription)?
          onCancel});

  /// Process when [listen] called and prepare to generate content to
  /// [StreamSubscription].
  ///
  /// Normally, the content of [DictionaryEntry] will be streamed by calling
  /// [add]. When duplicated key called with various [DictionaryEntry], [add]
  /// will only accept the latest called parameter. Once this process has been
  /// completed, all applied [DictionaryEntry] will be yield without considering
  /// sequence.
  ///
  /// When error occured during generate content, attach caught object into [addError],
  /// which no longer stream any [add]ed [DictionaryEntry].
  Future<void> generateContent(
      DictionaryEntryStreamAdder<V> add, DictionaryEntryStreamThrower addError);
}

/// Abstract implementation of [VendorDictionaryEntriesStream]
/// by overriding [generateContent].
///
/// See [VendorDictionaryEntriesStream] for further explaination
/// of the workflow.
abstract base class VendorDictionaryEntriesStreamBase<V>
    extends Stream<DictionaryEntry<V>>
    implements VendorDictionaryEntriesStream<V> {
  @nonVirtual
  @override
  final bool isBroadcast = false;

  const VendorDictionaryEntriesStreamBase();

  /// Converting [VendorDictionaryEntriesStream] to broadcast [Stream]
  /// is forbidden. It throws [UnsupportedError] once it called.
  @nonVirtual
  @override
  Stream<DictionaryEntry<V>> asBroadcastStream(
      {void Function(StreamSubscription<DictionaryEntry<V>> subscription)?
          onListen,
      void Function(StreamSubscription<DictionaryEntry<V>> subscription)?
          onCancel}) {
    throw UnsupportedError("Convert to broadcast stream is not allowed.");
  }

  @nonVirtual
  @override
  StreamSubscription<DictionaryEntry<V>> listen(
      void Function(DictionaryEntry<V> event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    late final Map<String, V> applied = HashMap();

    final StreamController<DictionaryEntry<V>> controller = StreamController();
    final sink = controller.sink;

    bool hasError = false;

    generateContent((key, value) {
      applied[key] = value;
    }, (error, [stackTrace]) {
      hasError = true;
      sink.addError(error, stackTrace);
    }).then((_) async {
      if (!hasError) {
        applied.entries.forEach(sink.add);
      }
      await controller.close();
    });

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

final class _InstantVendorDictionaryEntriesStream<V>
    extends VendorDictionaryEntriesStreamBase<V> {
  final Stream<(String, V)> Function() generator;

  _InstantVendorDictionaryEntriesStream(this.generator);

  @override
  Future<void> generateContent(DictionaryEntryStreamAdder<V> add,
      DictionaryEntryStreamThrower addError) async {
    try {
      await for (var (k, v) in generator()) {
        add(k, v);
      }
    } catch (err, stackTrace) {
      addError(err, stackTrace);
    }
  }
}
