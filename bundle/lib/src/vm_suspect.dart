import 'package:meta/meta.dart';

@internal
const Set<(String, String)> vmSysManufactureModel = {
  ("VMware, Inc.", "VMware Virtual Platform"), // VMWare
  ("innotek GmbH", "VirtualBox"), // Virtual Box
  ("Microsoft Corporation", "Virtual Machine"), // Hyper-V
  ("QEMU Standard PC (Q35 + ICH9, 2009)", ""), // QEMU
  ("QEMU Standard PC (i440FX + PIIX, 1996)", ""),
  ("", ""), // Possible as container which emulated based on application
};
