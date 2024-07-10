import 'package:meta/meta.dart';

@internal
const Set<(String, String)> vmSysManufactureModel = {
  ("VMware, Inc.", "VMware Virtual Platform"),
  ("innotek GmbH", "VirtualBox"),
  ("Microsoft Corporation", "Virtual Machine"),
  ("", "") // Possible as container which emulated based on application
};
