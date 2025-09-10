import 'package:markdown/markdown.dart' as md;
import 'package:markdown_description_list/markdown_description_list.dart';

void main() {
  // An example document written in Markdown that utilizes description lists.
  const exampleMarkdown = '''
# Glossary

Markdown
: A plain-text markup language for writing structured documents.

HTML
: Hypertext Markup Language
: The standard markup language for defining the meaning and structure of
  documents designed to be displayed in a web browser.

Description list
: A collection of terms and their corresponding descriptions.

  Description lists are useful for structuring a variety of content, such as:

  - Glossaries
  - Property descriptions
  - Frequently asked questions

: Also known as a definition list.

Dart
: An approachable, portable, and productive programming language for
  building high-quality apps on any platform.
: Free and open source, supported by Google.
''';

  // Create a document with the description list syntax
  // added as an additional block syntax.
  final document = md.Document(
    blockSyntaxes: [const DescriptionListSyntax()],
  );

  // Parse the Markdown document as a string into a list of nodes.
  // Each node represents an HTML element or other DOM node, such as text.
  final nodes = document.parse(exampleMarkdown);

  // Render the resulting nodes into an HTML string.
  final html = md.renderToHtml(nodes);

  print(html);
}
