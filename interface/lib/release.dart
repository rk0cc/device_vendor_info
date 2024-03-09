/// Release version for extracting real hardware information
/// during release.
library release;

export 'src/dictionary/stream.dart' show VendorDictionaryEntriesStream;
export 'src/dictionary/dictionary.dart'
    show VendorDictionary, SyncedVendorDictionary, VendorDictionarySynchronizer;
export 'src/dictionary/exceptions.dart';
export 'src/loader.dart' show ProductiveDeviceVendorInfoLoader;
