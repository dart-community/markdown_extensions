import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

import 'util.dart';

/// A custom block syntax for parsing description lists with `package:markdown`.
///
/// Description lists, sometimes known as definition lists,
/// are composed of terms and their descriptions.
/// Terms are written on their own lines, and descriptions are
/// written on the following lines, starting with a colon and a space (`: `).
///
/// For example, the following description list with two terms:
///
/// ```md
/// First term
/// : This is a description of the first term.
///
/// Second term
/// : This is one description of the second term.
/// : This is another description of the second term.
/// ```
///
/// Renders to the following HTML:
///
/// ```html
/// <dl>
///   <dt>First term</dt>
///   <dd><p>This is a description of the first term.</p></dd>
///   <dt>Second term</dt>
///   <dd><p>This is one description of the second term.</p></dd>
///   <dd><p>This is another description of the second term.</p></dd>
/// </dl>
/// ```
final class DescriptionListSyntax extends md.BlockSyntax {
  /// Pattern that matches a description line with
  /// optional leading whitespace, a colon, then whitespace.
  static final RegExp _descriptionPattern = RegExp(r'^\s*:\s+(.*)$');

  /// The maximum number of consecutive terms to
  /// associate with a single description.
  final int maxTermsPerDescription;

  @override
  RegExp get pattern => _descriptionPattern;

  /// Creates a new [DescriptionListSyntax].
  ///
  /// By default, the created syntax allows up to 5 consecutive terms to
  /// be associated with a single description.
  /// To configure this amount, specify a value for
  /// [maxTermsPerDescription] of 1 or greater.
  const DescriptionListSyntax({this.maxTermsPerDescription = 5})
    : assert(
        maxTermsPerDescription >= 1,
        'The \'maxTermsPerDescription\' must be at least 1.',
      );

  @override
  bool canParse(md.BlockParser parser) => _isDescriptionListStart(parser);

  @override
  md.Node? parse(md.BlockParser parser) {
    final elements = <md.Element>[];

    while (!parser.isDone && _isDescriptionListStart(parser)) {
      final groupElements = _parseTermsAndDescriptions(parser);
      elements.addAll(groupElements);
      parser._skipBlankLines();
    }

    return elements.isNotEmpty ? md.Element('dl', elements) : null;
  }

  /// Parses consecutive terms and their descriptions.
  ///
  /// Returns a list of `<dt>` and `<dd>` elements that
  /// correspond to the terms and their descriptions respectively.
  List<md.Element> _parseTermsAndDescriptions(md.BlockParser parser) => [
    // Parse all consecutive terms and add them to the list.
    ..._parseTerms(parser),

    // Parse all consecutive descriptions and add them to the list.
    ..._parseDescriptions(parser),
  ];

  /// Parses consecutive terms and returns a list of `<dt>` elements.
  static List<md.Element> _parseTerms(md.BlockParser parser) {
    final termElements = <md.Element>[];

    while (!parser.isDone) {
      final currentLine = parser.current;

      // Skip any blank lines while we look for the next term.
      if (currentLine.isBlankLine) {
        parser.advance();
        continue;
      }

      final currentContent = currentLine.content;

      // If this line is not blank and it's content isn't a valid term,
      // stop looking for additional terms.
      if (!isValidTerm(currentContent)) {
        break;
      }

      termElements.add(
        md.Element('dt', [
          // Keep terms as inline content.
          // Re-parsing a single term line as a block can turn
          // block-like text such as "- Term" or "---"
          // into a list or horizontal rule inside the `<dt>`.
          md.UnparsedContent(currentContent.trimRight()),
        ]),
      );
      parser.advance();
    }

    return termElements;
  }

  /// Parses consecutive descriptions and returns a list of `<dd>` elements.
  List<md.Element> _parseDescriptions(md.BlockParser parser) {
    final elements = <md.Element>[];
    while (!parser.isDone) {
      final match = _descriptionPattern.firstMatch(parser.current.content);
      final firstLine = match?.group(1);
      if (firstLine == null) break;

      final lines = <String>[firstLine];
      parser.advance();

      // Collect lines that continue this description.
      while (!parser.isDone) {
        final currentLine = parser.current;
        final lineContent = currentLine.content;

        if (currentLine.isBlankLine) {
          // If this line is blank, add it and continue on to the next line.
          // If the description doesn't continue on, we'll remove it later.
          lines.add('');
        } else if (lineContent.startsWith('  ')) {
          // Two leading spaces continue a description.
          // Remove those spaces before parsing the description content.
          lines.add(lineContent.substring(2));
        } else if (lineContent.startsWith('\t')) {
          // A leading tab also continues a description.
          // Remove the tab before parsing the description content.
          lines.add(lineContent.substring(1));
        } else {
          // If this line is not a continuation or blank, don't include it.
          break;
        }

        parser.advance();
      }

      // Parse as blocks for multi-paragraph content.
      final nodes = md.BlockParser(
        lines.withoutTrailingEmptyStrings
            .map(md.Line.new)
            .toList(growable: false),
        parser.document,
      ).parseLines(parentSyntax: this);
      final descriptionElement = md.Element('dd', nodes);

      elements.add(descriptionElement);
    }
    return elements;
  }

  /// Determines if the current position starts a description list.
  ///
  /// Returns `true` if the current line is a term,
  /// followed potentially by other terms and eventually a description.
  bool _isDescriptionListStart(md.BlockParser parser) {
    if (parser.isDone) return false;

    // If the current line isn't a valid term,
    // it doesn't start a description list.
    if (!isValidTerm(parser.current.content)) {
      return false;
    }

    // Look ahead to find the description line.
    // The furthest it can appear is
    // after the maximum term count and one optional blank line.
    final maxLookAheadOffset = maxTermsPerDescription + 1;
    var termsFound = 1;
    var foundBlankLineAfterTerm = false;

    for (
      var lookAheadOffset = 1;
      lookAheadOffset <= maxLookAheadOffset;
      lookAheadOffset += 1
    ) {
      final nextLine = parser.peek(lookAheadOffset);
      if (nextLine == null) {
        // End of file reached before finding a description.
        return false;
      }

      if (nextLine.isBlankLine) {
        // Only a single blank line is allowed before the first description.
        if (foundBlankLineAfterTerm) {
          return false;
        }

        foundBlankLineAfterTerm = true;
        continue;
      }

      final nextContent = nextLine.content;

      // Found the first description, so this is a description list start.
      if (_descriptionPattern.hasMatch(nextContent)) {
        return true;
      }

      if (isValidTerm(nextContent)) {
        // If we already found a blank line, we can't have more terms.
        if (foundBlankLineAfterTerm) {
          return false;
        }

        termsFound += 1;
        if (termsFound > maxTermsPerDescription) {
          // Already found the maximum number of consecutive terms.
          return false;
        }
        continue;
      }

      return false;
    }

    return false;
  }

  /// Checks if the specified [content] is a valid term for a description list.
  ///
  /// Returns `true` if [content] contains non-whitespace content and
  /// doesn't start with a colon (`:`) or hash (`#`),
  /// after optional leading whitespace.
  @visibleForTesting
  static bool isValidTerm(String content) {
    final trimmedContent = content.trimLeft();
    if (trimmedContent.isEmpty) {
      return false;
    }

    final firstChar = trimmedContent.codeUnitAt(0);
    const colon = 0x3a;
    const hash = 0x23;

    return firstChar != colon && firstChar != hash;
  }
}

/// Parsing extension methods for [md.BlockParser].
extension _BlockParserExtensions on md.BlockParser {
  /// Advances this parser past any consecutive blank lines.
  ///
  /// Used to skip whitespace between description list entries while
  /// maintaining proper parsing position.
  void _skipBlankLines() {
    while (!isDone && current.isBlankLine) {
      advance();
    }
  }
}
