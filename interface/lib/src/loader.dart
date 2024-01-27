import 'info/bios.dart';
import 'info/board.dart';
import 'info/system.dart';

/// A barebone loader for finding [BiosInfo] and [SystemInfo]
/// in specific system.
///
/// All information ideally should be run once only, and
/// return the same result for the next getter called from
/// current instance of [DeviceVendorInfoLoader] since
/// these data is rarely changes during execution process
/// that it does not worth to uses computing power for
/// fetching information for each request.
abstract interface class DeviceVendorInfoLoader {
  /// Extract BIOS information.
  Future<BiosInfo> get biosInfo;

  /// Extract motherborad information.
  Future<BoardInfo> get boardInfo;

  /// Extract system information.
  Future<SystemInfo> get systemInfo;
}
