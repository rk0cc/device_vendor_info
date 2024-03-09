/// Definitions of a [MapEntry] contains [String] based [MapEntry.key]
/// with any primitative type [V] for [MapEntry.value].
typedef DictionaryEntry<V> = MapEntry<String, V>;

typedef DictionaryEntryStreamAdder<V> = void Function(String key, V value);
typedef DictionaryEntryStreamThrower = void Function(Object error,
    [StackTrace? stackTrace]);
