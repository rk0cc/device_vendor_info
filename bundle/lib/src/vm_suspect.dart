import 'package:meta/meta.dart';

@internal
const Set<(String, String)> vmSysManufactureModel = {
  ("VMware, Inc.", "VMware Virtual Platform"), // VMWare
  ("innotek GmbH", "VirtualBox"), // Virtual Box
  ("Microsoft Corporation", "Virtual Machine"), // Hyper-V
  ("", "") // Possible as container which emulated based on application
};
