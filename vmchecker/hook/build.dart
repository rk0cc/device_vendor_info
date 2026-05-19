import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final CodeConfig(:targetOS) = input.config.code;

    final supportedOS = [
      OS.linux,
      OS.macOS,
      OS.windows,
    ].any((os) => targetOS == os);

    if (!input.config.buildCodeAssets || !supportedOS) {
      return;
    }

    final builder = CBuilder.library(
      name: "device_vendor_info_vmchecker",
      assetName: "src/vm_checker.g.dart",
      sources: const <String>["src/device_vendor_info_vmchecker.c"],
      flags: [
        if (targetOS == OS.windows) ...["/nologo"],
      ],
    );

    await builder.run(input: input, output: output);
  });
}
