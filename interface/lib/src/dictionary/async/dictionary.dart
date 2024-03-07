import '../exceptions.dart';
import '../typedef.dart';
import 'cast.dart';
import 'collections.dart';
import 'map.dart';
import 'selector.dart';

@Deprecated("Please uses simplified name instead")
typedef DeviceVendorInfoDictionary<V> = VendorDictionary<V>;

abstract interface class VendorDictionary<V> {
  VendorDictionaryCollection<V> get entries;

  Stream<String> get keys;

  Stream<V> get values;

  Future<int> get length;

  Future<bool> get isEmpty;

  Future<bool> get isNotEmpty;

  Future<bool> any(bool Function(String key, V value) condition);

  VendorDictionary<RV> cast<RV>();

  Future<bool> containsKey(String key);

  Future<bool> containsValue(V value);

  Future<bool> every(bool Function(String key, V value) condition);

  Future<void> forEach(void Function(String key, V value) action);

  VendorDictionary<RV> map<RV>(
      DictionaryEntry<RV> Function(String key, V value) convert);

  VendorDictionary<V> where(bool Function(String key, V value) condition);

  VendorDictionary<RV> whereValueType<RV>();

  Future<V> operator [](String key);
}

abstract base class VendorDictionaryBase<V> implements VendorDictionary<V> {
  const VendorDictionaryBase();

  @override
  Stream<String> get keys => entries.map((event) => event.key);

  @override
  Stream<V> get values => entries.map((event) => event.value);

  @override
  Future<bool> get isEmpty async => await length == 0;

  @override
  Future<bool> get isNotEmpty async => await length != 0;

  @override
  Future<int> get length => entries.length;

  @override
  Future<bool> any(bool Function(String key, V value) condition) {
    return entries.any((element) => condition(element.key, element.value));
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      await entries.singleWhere((element) => element.key == key);
      return true;
    } on StateError {
      return false;
    }
  }

  @override
  Future<bool> containsValue(V value) {
    return any((k, v) => v == value);
  }

  @override
  Future<bool> every(bool Function(String key, V value) condition) {
    return entries.every((element) => condition(element.key, element.value));
  }

  @override
  Future<void> forEach(void Function(String key, V value) action) async {
    await for (var DictionaryEntry(key: k, value: v) in entries) {
      action(k, v);
    }
  }

  @override
  VendorDictionary<RV> cast<RV>() {
    return CastVendorDictionary(this);
  }

  @override
  VendorDictionary<RV> map<RV>(
      DictionaryEntry<RV> Function(String key, V value) convert) {
    return MapVendorDictionaryCollection<V, RV>(this, convert);
  }

  @override
  VendorDictionary<V> where(bool Function(String key, V value) condition) {
    return VendorDictionarySelector(this, condition);
  }

  @override
  VendorDictionary<RV> whereValueType<RV>() {
    return VendorDictionaryTypedSelector<RV>(this);
  }

  @override
  Future<V> operator [](String key) async {
    try {
      return await entries
          .singleWhere((element) => element.key == key)
          .then((e) => e.value);
    } on StateError {
      throw UndefinedDictionaryKeyError(key);
    }
  }
}
