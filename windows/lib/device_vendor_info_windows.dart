/// Windows base implementation for getting hardware information.
///
/// All information is get from registry of local machine
/// and this library **ONLY** grant for **READ** access.
library device_vendor_info_windows;

export 'src/loader.dart';
