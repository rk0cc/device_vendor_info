part of '../../dictionary.dart';

typedef _EncodingDecoder = Converter<List<int>, String>;

final class DecodedBytesValueDeviceVendorInfoDictionary
    extends EntryBasedTypedDeviceVendorInfoDictionary<String> {
  final TypedDeviceVendorInfoDictionary<List<int>> _origin;
  final _EncodingDecoder _decoder;

  DecodedBytesValueDeviceVendorInfoDictionary._(this._origin, this._decoder);

  factory DecodedBytesValueDeviceVendorInfoDictionary(
          DeviceVendorInfoDictionary dictionary,
          {Encoding encoding = const Utf8Codec(allowMalformed: true)}) =>
      DecodedBytesValueDeviceVendorInfoDictionary._(
          _DelegatedDeviceVendorInfoDictionary<List<int>>(
              dictionary.entries.where((event) {
            final v = event.value;

            return v is List<int> && v is TypedData;
          }).cast<MapEntry<String, List<int>>>()),
          encoding.decoder);

  @factory
  DecodedBytesValueDeviceVendorInfoDictionary changeEncoding(
      Encoding encoding) {
    return DecodedBytesValueDeviceVendorInfoDictionary._(
        _origin, encoding.decoder);
  }

  @override
  Stream<MapEntry<String, String>> get entries =>
      _origin.entries.asyncMap((event) async {
        Future<String> decodeBytes(List<int> context) =>
            Isolate.run(() => _decoder.convert(context));

        return MapEntry(event.key, await decodeBytes(event.value));
      });
}
