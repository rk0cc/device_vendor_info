import 'dart:async';

import 'src/vm_checker.g.dart';

/// Check the platform where this program executed is under virtualized environment.
///
/// This may becomes false positive if the machines adapted type 1 hypervisor, which allows
/// virtualization with physical hardware directly.
Future<bool> isHypervisor() => Future.microtask(is_hypervisor);
