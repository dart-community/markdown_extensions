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
  /// Pattern that matches a description line starting with a colon and a space.
  static final _descriptionPattern = RegExp(r'^\s*:\s+(.*)$');

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
      _skipEmptyLines(parser);
    }

    return elements.isNotEmpty ? md.Element('dl', elements) : null;
  }

  /// Parses a consecutive terms and their descriptions.
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

    while (!parser.isDone && isValidTerm(parser.current.content)) {
      final termLine = parser.current;
      parser.advance();

      // Parse the term line with document context for link references.
      final termNodes = md.BlockParser(
        [termLine],
        parser.document,
      ).parseLines();

      // If the content is wrapped in a paragraph, unwrap it.
      final firstNode = termNodes.firstOrNull;
      if (firstNode == null) continue;

      termElements.add(
        md.Element('dt', [
          if (firstNode is md.Element && firstNode.tag == 'p')
            ...?firstNode.children
          else
            firstNode,
        ]),
      );
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
        final line = parser.current.content;
        final trimmedLine = line.trimLeft();
        final isIndented = trimmedLine.length != line.length;
        final isEmpty = trimmedLine.isEmpty;

        if (isEmpty) {
          // If this line is empty, add it and continue on to the next line.
          // If the description doesn't continue on, we'll remove it later.
          lines.add('');
        } else if (isIndented) {
          // If this line is indented, add it to the description's lines with
          // the related indentation removed.
          lines.add(removeIndentation(line));
        } else {
          // If this line is not indented or empty, don't include it.
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

    // Check if current line is a term that's part of a sequence
    // leading to descriptions.
    if (isValidTerm(parser.current.content)) {
      // Look ahead to find the first non-term line,
      // up to the limit of consecutive terms allowed.
      for (
        var lookAheadOffset = 1;
        lookAheadOffset <= maxTermsPerDescription;
        lookAheadOffset += 1
      ) {
        final nextLine = parser.peek(lookAheadOffset);
        if (nextLine == null) {
          // End of file reached before finding a description.
          return false;
        }

        final nextContent = nextLine.content;
        if (isValidTerm(nextContent)) {
          // If the next line is a term, then keep looking.
          continue;
        }

        // Found a non-term line, check if it's a description.
        return _descriptionPattern.hasMatch(nextContent);
      }
    }

    return false;
  }

  /// Checks if the specified [content] is a valid term for a description list.
  ///
  /// Returns `true` if [content] contains non-whitespace content and
  /// doesn't start with a colon (`:`) or indentation.
  @visibleForTesting
  static bool isValidTerm(String content) {
    final withoutLeadingSpaceContent = content.trimLeft();
    if (withoutLeadingSpaceContent.isEmpty ||
        withoutLeadingSpaceContent.length != content.length) {
      return false;
    }

    return !content.startsWith(':') || !_descriptionPattern.hasMatch(content);
  }

  /// Advances the [parser] past any consecutive empty lines.
  ///
  /// Used to skip whitespace between description list entries while
  /// maintaining proper parsing position.
  static void _skipEmptyLines(md.BlockParser parser) {
    while (!parser.isDone && parser.current.content.trim().isEmpty) {
      parser.advance();
    }
  }
}
