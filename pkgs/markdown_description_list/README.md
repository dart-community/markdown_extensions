Dart package that extends [`package:markdown`][] with support for
description lists, sometimes known as definition lists.

[`package:markdown`]: https://pub.dev/packages/markdown

## Installation

To use `package:markdown_description_list` and its provided syntax extension,
first add it and `package:markdown` as dependencies in your `pubspec.yaml` file:

```shell
dart pub add markdown markdown_description_list
```

## Usage

The package contains one library:

- `package:markdown_description_list/markdown_description_list.dart`

  Provides the `DescriptionListSyntax` class which can be included in
  the list of block syntaxes provided to `package:markdown` to
  add support for parsing description lists in Markdown.

### Parse description lists from Markdown

To add support for parsing description lists in Markdown,
add a `DescriptionListSyntax` in list of block syntaxes
provided to `package:markdown`.

When creating a `Document`:

```dart
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_description_list/markdown_description_list.dart';

void main() {
  final document = md.Document(
    blockSyntaxes: [const DescriptionListSyntax()],
  );

  final exampleMarkdown = '''
Markdown
: A plain-text markup language for writing structured documents.
''';

  // Parse the Markdown string into a list of nodes.
  final nodes = document.parse(exampleMarkdown);

  // Render the resulting nodes into an HTML string.
  final html = md.renderToHtml(nodes);
}
```

When parsing and rendering a single string:

```dart
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_description_list/markdown_description_list.dart';

void main() {
  final document = md.Document(
    blockSyntaxes: [const DescriptionListSyntax()],
  );

  final exampleMarkdown = '''
Markdown
: A plain-text markup language for writing structured documents.
''';

  // Directly parse the Markdown string and render into an HTML string.
  final html = md.markdownToHtml(
    exampleMarkdown,
    blockSyntaxes: [const DescriptionListSyntax()],
  );
}
```

### Write description lists in Markdown

The supported syntax for description lists allows
grouping one or more descriptions to one or more terms.
To write description lists in this syntax, follow this procedure:

1.  Write one or more terms on consecutive lines.
2.  On a new line after the terms, add a colon and a space (`: `).
3.  After the colon and space, write a description.
4.  To continue the description on to the next line,
    indent the line's contents by two spaces.
5.  To add an additional description for the preceding terms,
    repeat steps 2 to 4.
6.  To add additional term and description groupings,
    repeat steps 1 to 5.

As an example, the following glossary written in Markdown is
structured with a description list:

```markdown
# Glossary

Markdown
: A plain-text markup language for writing structured documents.

HTML
: Hypertext Markup Language
: The standard markup language for defining the
  meaning and structure of documents for the web.

Description list
: A collection of terms and their corresponding descriptions.

  Description lists are useful for structuring a variety of content, such as:

  - Glossaries
  - Property descriptions
  - Frequently asked questions

: Also known as definition lists.

Dart
: An approachable, portable, and productive programming language for
  building high-quality apps on any platform.
: Free and open source, supported by Google.
```
