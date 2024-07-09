/// Fetch device's hardware information info Flutter platform.
library device_vendor_info;

import 'package:device_vendor_info/testing.dart';
import 'package:device_vendor_info_interface/interface.dart';
import 'package:device_vendor_info_interface/release.dart';
import 'src/instance.dart';

export 'package:device_vendor_info_interface/interface.dart'
    show BiosInfo, BoardInfo, SystemInfo;

/// Direct callback for fetching [BiosInfo] from [DeviceVendorInfo.instance].
Future<BiosInfo> getBiosInfo() => DeviceVendorInfo.instance.biosInfo;

/// Direct callback for fetching [BoardInfo] from [DeviceVendorInfo.instance].
Future<BoardInfo> getBoardInfo() => DeviceVendorInfo.instance.boardInfo;

/// Direct callback for fetching [SystemInfo] from [DeviceVendorInfo.instance].
Future<SystemInfo> getSystemInfo() => DeviceVendorInfo.instance.systemInfo;

/// Determine this machine enabled hypervisor, no matter it running in guest OS, container
/// or actually physical machine.
///
/// It possible return `true` if:
///
/// * Running inside of virtual machine or a container.
/// * Enables type 1 [hypervisor](https://en.wikipedia.org/wiki/Hypervisor#Classification) service
///   (e.g. [Hyper-V](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/),
///   [KVM](https://linux-kvm.org/page/Main_Page)) in host machine.
///
/// The result always return `false` if using [MockDeviceVendorInfoLoader].
///
/// This result is not related with BIOS information that it does not appeared in
/// [exportRawVendorInfoToJson].
Future<bool> hasHypervisor() => DeviceVendorInfo.instance.isVirtualPlatform;

/// Determine this program executed under virtualized platform. (e.g. Virtual machine,
/// container).
///
/// Once [hasHypervisor] return `true`, it compare manufactor and model informations from [SystemInfo]
/// to decide this program is actually executing under virtual machine or container. However,
/// it can be easily defeated if virtual machines allows altering system properties (e.g. QEMU).
///
/// This result is not related with BIOS information that it does not appeared in
/// [exportRawVendorInfoToJson].
Future<bool> isVirtualized() async {
  if (!await hasHypervisor()) {
    return false;
  }

  const Set<(String, String)> vmSysManufactorModel = {
    ("VMware, Inc.", "VMware Virtual Platform"),
    ("innotek GmbH", "VirtualBox"),
    ("Microsoft Corporation", "Virtual Machine"),
    ("", "")
  };

  (String, String) sysInfoResult = await getSystemInfo()
      .then((sys) => (sys.manufacturer ?? "", sys.productName ?? ""));

  for (var vmSus in vmSysManufactorModel) {
    if (vmSus == sysInfoResult) {
      return true;
    }
  }

  return false;
}

/// Get [BiosInfo] (`bios` key in [Map]), [BoardInfo] (`mother_board` key in [Map])
/// and [SystemInfo] (`system` key in [Map]) into an unmodifiable [Map].
Future<Map<String, dynamic>> exportVendorInfoToJson() async =>
    Map.unmodifiable(<String, dynamic>{
      "bios": await getBiosInfo().then((value) => value.toJson()),
      "mother_board": await getBoardInfo().then((value) => value.toJson()),
      "system": await getSystemInfo().then((value) => value.toJson())
    });

/// Return original hardware metadata into [String] key JSON
/// format.
Future<Map<String, dynamic>> exportRawVendorInfoToJson() async {
  final DeviceVendorInfoLoader loader = DeviceVendorInfo.instance;

  if (loader is ProductiveDeviceVendorInfoLoader) {
    return loader.dictionary.toSynced();
  }

  return const <String, dynamic>{};
}
