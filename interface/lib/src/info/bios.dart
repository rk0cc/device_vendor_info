/// A collection of BIOS data of the computer.
final class BiosInfo {
  /// Name of vandor who produces this BIOS chip.
  final String? vendor;

  /// BIOS version.
  ///
  /// Be note that the pattern of BIOS version
  /// is varied.
  final String? version;

  /// A [DateTime] when this BIOS [version] released at.
  final DateTime? releaseDate;

  /// Construct a BIOS information of a device.
  const BiosInfo(
      {required this.vendor, required this.version, required this.releaseDate});
}
