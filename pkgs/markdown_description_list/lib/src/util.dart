import 'package:meta/meta.dart';

/// Returns the specified [line] with the expected indentation from
/// a description continuation line removed.
///
/// Strips two spaces or one tab from the beginning of [line].
@internal
String removeIndentation(String line) {
  if (line.startsWith('  ')) {
    return line.substring(2);
  } else if (line.startsWith('\t')) {
    return line.substring(1);
  }
  return line;
}

/// Provides the [withoutTrailingEmptyStrings] extension to
/// remove trailing empty strings from a list of strings.
@internal
extension WithoutTrailingEmptyStrings on List<String> {
  /// Returns a new list with any trailing empty strings
  /// removed from the end of this list.
  @internal
  List<String> get withoutTrailingEmptyStrings {
    // Find the index of the last element that is not an empty string.
    final lastNonEmptyIndex = lastIndexWhere((s) => s.isNotEmpty);

    // If no non-empty string is found, lastIndexWhere returns -1.
    // In that case, we should return an empty list.
    if (lastNonEmptyIndex == -1) {
      return const [];
    }

    // Otherwise, create a new list containing elements from the start
    // up to and including the last non-empty string.
    return sublist(0, lastNonEmptyIndex + 1);
  }
}
