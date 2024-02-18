import 'package:intl/intl.dart' show DateFormat;

DateFormat _biosDateFormat = DateFormat("MM/dd/yyyy");

/// Apply [newDateFormat] that for parsing BIOS date into [DateTime].
///
/// The eligable [newDateFormat] must be [DateFormat.dateOnly]. If it
/// returns `false`, it throws [FormatException].
set biosDateFormat(DateFormat newDateFormat) {
  if (!newDateFormat.dateOnly) {
    throw FormatException(
        "The date format can only exist year, month and date only.",
        newDateFormat);
  }

  // Parse deep copied DateFormat to ensure no state changes after applied.
  _biosDateFormat = DateFormat(newDateFormat.pattern);
}

/// Definition of [DateFormat] that indicate release date
/// of BIOS.
DateFormat get biosDateFormat => _biosDateFormat;
