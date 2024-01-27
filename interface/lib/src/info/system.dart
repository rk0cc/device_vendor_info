/// A collection of device's system description.
///
/// It more likely available from pre-built computer
/// and for those who uses custom build may not
/// applied and all properties will be returned either
/// [Null] or empty [String] depending applied
/// operating system.
final class SystemInfo {
  /// Familly series of this system.
  ///
  /// It can be just a name of series or
  /// name of device model.
  final String? family;

  /// A company who manufactur this system.
  final String? manufacturer;

  /// Name of product.
  ///
  /// It can be a model number or
  /// name of device model.
  final String? productName;

  /// System's version.
  final String? version;

  /// Construct information of the system.
  const SystemInfo(
      {required this.family,
      required this.manufacturer,
      required this.productName,
      required this.version});
}
