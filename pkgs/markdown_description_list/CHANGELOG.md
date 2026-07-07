## 0.2.0-wip

- Treat description continuation lines as requiring either
  two spaces or one tab of indentation, matching the documented syntax.
- Parse term lines as inline content instead of reparsing them as blocks,
  so terms that look like Markdown block markers remain valid term text.
- Reduce unnecessary operations and allocations,
  particularly when handling blank lines.
- Require Dart 3.10 or later.
- Increase dependency constraint of `package:markdown` to `^7.3.1`.

## 0.1.1

- Support a single empty line after terms and before the description.

## 0.1.0

- Initial release of the package with support for description lists,
  matching the commonly used syntax for Markdown definition lists.
