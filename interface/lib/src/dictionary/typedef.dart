import 'stream.dart' show VendorDictionaryEntriesStream;

/// Definitions of a [MapEntry] contains [String] based [MapEntry.key]
/// with any primitative type [V] for [MapEntry.value].
typedef DictionaryEntry<V> = MapEntry<String, V>;

/// A [Function] that appending [DictionaryEntry] into [VendorDictionaryEntriesStream].
typedef DictionaryEntryStreamAdder<V> = void Function(String key, V value);

/// Report error to [VendorDictionaryEntriesStream] when an error caught.
typedef DictionaryEntryStreamThrower = void Function(Object error,
    [StackTrace? stackTrace]);

/// A [Function] that to temprorary create [Stream] used by
/// [VendorDictionaryEntriesStream.new].
typedef EntriesStreamGenerator<V> = Stream<(String, V)> Function();
