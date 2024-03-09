/// Release version for extracting real hardware information
/// during release.
library release;

export 'src/dictionary/async/stream.dart' show VendorDictionaryEntriesStream;
export 'src/dictionary/async/dictionary.dart' show VendorDictionary;
export 'src/dictionary/sync/dictionary.dart' show SyncedVendorDictionary;
export 'src/dictionary/exceptions.dart';
export 'src/loader.dart' show ProductiveDeviceVendorInfoLoader;
