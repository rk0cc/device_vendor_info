import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final pkgRoot = Platform.script.resolve("../");
  final checkerHeaderPath = pkgRoot.resolve(
    "src/device_vendor_info_vmchecker.h",
  );

  FfiGenerator(
    output: Output(dartFile: pkgRoot.resolve("lib/src/vm_checker.g.dart")),
    headers: Headers(entryPoints: [checkerHeaderPath]),
    functions: Functions.includeSet(const <String>{"is_hypervisor"}),
  ).generate();
}
