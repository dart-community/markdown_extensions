import 'package:meta/meta.dart';

/// Provides the [withoutTrailingEmptyStrings] extension method to
/// remove trailing empty strings from a list of strings.
@internal
extension WithoutTrailingEmptyStrings on List<String> {
  /// Returns a list of these strings without any trailing empty strings.
  ///
  /// If this list has no trailing empty strings, the original list is returned.
  @internal
  List<String> get withoutTrailingEmptyStrings {
    // Walk backwards to find the last string that should be preserved.
    for (var index = length - 1; index >= 0; index -= 1) {
      if (this[index].isNotEmpty) {
        // No trailing empty strings were found, so avoid copying the list.
        if (index == length - 1) {
          return this;
        }

        // Otherwise, return a new list containing elements from
        // the start up to and including the last non-empty string.
        return sublist(0, index + 1);
      }
    }

    // Every string was empty, or the list itself was empty.
    return const [];
  }
}
