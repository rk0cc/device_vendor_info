import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final supportedOS = [
      OS.linux,
      OS.macOS,
      OS.windows,
    ].any((os) => input.config.code.targetOS == os);

    if (!input.config.buildCodeAssets || !supportedOS) {
      return;
    }

    final CodeConfig(:targetOS, :targetArchitecture) = input.config.code;

    final builder = CBuilder.library(
      name: "device_vendor_info_vmchecker_${targetOS.name}_${targetArchitecture.name}",
      assetName: "device_vendor_info_vmchecker.dart",
      sources: const <String>["src/device_vendor_info_vmchecker.c"],
    );

    await builder.run(input: input, output: output);
  });
}
