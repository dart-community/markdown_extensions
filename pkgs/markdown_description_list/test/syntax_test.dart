import 'package:markdown/markdown.dart' as md;
import 'package:markdown_description_list/markdown_description_list.dart';
import 'package:test/test.dart';

void main() {
  group('DescriptionListSyntax', () {
    late md.Document document;
    late DescriptionListSyntax syntax;

    setUp(() {
      syntax = const DescriptionListSyntax();
      document = md.Document(blockSyntaxes: [syntax]);
    });

    String renderMarkdown(String markdown) {
      final nodes = document.parse(markdown);
      return md.renderToHtml(nodes);
    }

    group('basic parsing', () {
      test('parses single term with single description', () {
        const markdown = '''
Term
: A single description.''';

        expect(
          renderMarkdown(markdown),
          equals(
            '''
<dl>
<dt>Term</dt>
<dd>
<p>A single description.</p>
</dd>
</dl>''',
          ),
        );
      });

      test('parses single term with multiple descriptions', () {
        const markdown = '''
Term
: The first description.
: The second description.
: The third description.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>The first description.</p>
</dd>
<dd>
<p>The second description.</p>
</dd>
<dd>
<p>The third description.</p>
</dd>
</dl>'''),
        );
      });

      test('parses multiple terms with single descriptions', () {
        const markdown = '''
First term
: Description of the first term.

Second term
: Description of the second term.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>First term</dt>
<dd>
<p>Description of the first term.</p>
</dd>
<dt>Second term</dt>
<dd>
<p>Description of the second term.</p>
</dd>
</dl>'''),
        );
      });

      test('parses multiple consecutive terms sharing descriptions', () {
        const markdown = '''
First term
Second term
: Shared description for both terms.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>First term</dt>
<dt>Second term</dt>
<dd>
<p>Shared description for both terms.</p>
</dd>
</dl>'''),
        );
      });

      test('parses three consecutive terms with multiple descriptions', () {
        const markdown = '''
Term one
Term two
Term three
: The first description.
: The second description.
: The third description.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term one</dt>
<dt>Term two</dt>
<dt>Term three</dt>
<dd>
<p>The first description.</p>
</dd>
<dd>
<p>The second description.</p>
</dd>
<dd>
<p>The third description.</p>
</dd>
</dl>'''),
        );
      });

      test('handles mixed groupings of terms and descriptions', () {
        const markdown = '''
Single term
: Its description.

First grouped term
Second grouped term
Third grouped term
: First shared description.
: Second shared description.

Another single term
: Another single description.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Single term</dt>
<dd>
<p>Its description.</p>
</dd>
<dt>First grouped term</dt>
<dt>Second grouped term</dt>
<dt>Third grouped term</dt>
<dd>
<p>First shared description.</p>
</dd>
<dd>
<p>Second shared description.</p>
</dd>
<dt>Another single term</dt>
<dd>
<p>Another single description.</p>
</dd>
</dl>'''),
        );
      });

      test('handles empty markdown', () {
        const markdown = '';
        final html = renderMarkdown(markdown);
        expect(html, isEmpty);
      });

      test('does not appear in markdown without description lists', () {
        const markdown = '''
# Heading

This is a paragraph.

- List item 1
- List item 2''';

        final html = renderMarkdown(markdown);
        expect(html, isNot(contains('<dl>')));
        expect(html, contains('<h1>Heading</h1>'));
        expect(html, contains('<p>This is a paragraph.</p>'));
      });
    });

    group('multi-line descriptions', () {
      test('parses descriptions with indented continuation (spaces)', () {
        const markdown = '''
Term
: First line of description.
  Second line of description.
  Third line of description.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>First line of description.
Second line of description.
Third line of description.</p>
</dd>
</dl>'''),
        );
      });

      test('parses description with indented continuation (tabs)', () {
        const markdown = '''
Term
: First line of description.
\tSecond line of description.
\tThird line of description.
''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>First line of description.
Second line of description.
Third line of description.</p>
</dd>
</dl>'''),
        );
      });

      test('parses multi-paragraph description', () {
        const markdown = '''
Term
: First paragraph of description.

  Second paragraph of description.
  
  Third paragraph of description.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>First paragraph of description.</p>
<p>Second paragraph of description.</p>
<p>Third paragraph of description.</p>
</dd>
</dl>'''),
        );
      });

      test('handles empty lines between descriptions', () {
        const markdown = '''
Term
: First description.

: Second description after an empty line.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>First description.</p>
</dd>
<dd>
<p>Second description after an empty line.</p>
</dd>
</dl>'''),
        );
      });
    });

    group('inline formatting', () {
      test('supports inline formatting in terms', () {
        const markdown = '''
**Bold term**
: Description of bold term.

*Italic term*
: Description of italic term.

`Code term`
: Description of code term.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt><strong>Bold term</strong></dt>
<dd>
<p>Description of bold term.</p>
</dd>
<dt><em>Italic term</em></dt>
<dd>
<p>Description of italic term.</p>
</dd>
<dt><code>Code term</code></dt>
<dd>
<p>Description of code term.</p>
</dd>
</dl>'''),
        );
      });

      test('supports inline formatting in descriptions', () {
        const markdown = '''
Term
: Description with **bold** text.
: Description with *italic* text.
: Description with `code` text.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>Description with <strong>bold</strong> text.</p>
</dd>
<dd>
<p>Description with <em>italic</em> text.</p>
</dd>
<dd>
<p>Description with <code>code</code> text.</p>
</dd>
</dl>'''),
        );
      });

      test('supports links in terms and descriptions', () {
        const markdown = '''
[Link term](https://dart.dev)
: Description with [a link](https://pub.dev).''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt><a href="https://dart.dev">Link term</a></dt>
<dd>
<p>Description with <a href="https://pub.dev">a link</a>.</p>
</dd>
</dl>'''),
        );
      });

      test('supports link references', () {
        const markdown = '''
[Term][ref1]
: Description with [reference][ref2].

[ref1]: https://example1.com
[ref2]: https://example2.com''';

        final html = renderMarkdown(markdown);
        expect(
          html,
          contains('<dt><a href="https://example1.com">Term</a></dt>'),
        );
        expect(html, contains('<a href="https://example2.com">reference</a>'));
      });
    });

    group('nested block elements', () {
      test('supports fenced code blocks in descriptions', () {
        const markdown = '''
Code example
: Here is some code:

  ```dart
  void main() {
    print('Hello, World!');
  }
  ```''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Code example</dt>
<dd>
<p>Here is some code:</p>
<pre><code class="language-dart">void main() {
  print('Hello, World!');
}
</code></pre>
</dd>
</dl>'''),
        );
      });

      test('supports indented code blocks in descriptions', () {
        const markdown = '''
Indented code
: Example with indented code:

      void main() {
        print('Hello, World!');
      }''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Indented code</dt>
<dd>
<p>Example with indented code:</p>
<pre><code>void main() {
  print('Hello, World!');
}
</code></pre>
</dd>
</dl>'''),
        );
      });

      test('supports lists in descriptions', () {
        const markdown = '''
List term
: Description with a list:
  
  - First item
  - Second item
  - Third item''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>List term</dt>
<dd>
<p>Description with a list:</p>
<ul>
<li>First item</li>
<li>Second item</li>
<li>Third item</li>
</ul>
</dd>
</dl>'''),
        );
      });

      test('supports ordered lists in descriptions', () {
        const markdown = '''
Ordered list term
: Description with an ordered list:
  
  1. First step
  2. Second step
  3. Third step''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Ordered list term</dt>
<dd>
<p>Description with an ordered list:</p>
<ol>
<li>First step</li>
<li>Second step</li>
<li>Third step</li>
</ol>
</dd>
</dl>'''),
        );
      });

      test('supports blockquotes in descriptions', () {
        const markdown = '''
Quote term
: Description with quote:
  
  > This is a blockquote
  > spanning multiple lines.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Quote term</dt>
<dd>
<p>Description with quote:</p>
<blockquote>
<p>This is a blockquote
spanning multiple lines.</p>
</blockquote>
</dd>
</dl>'''),
        );
      });
    });

    group('empty lines between terms and descriptions', () {
      test('allows a single empty line between term and description', () {
        const markdown = '''
Term

: Description after an empty line.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>Description after an empty line.</p>
</dd>
</dl>'''),
        );
      });

      test('rejects multiple empty lines between term and description', () {
        const markdown = '''
Term


: This should not be parsed as a description list.''';

        final html = renderMarkdown(markdown);
        expect(html, isNot(contains('<dl>')));
        expect(html, contains('<p>Term</p>'));
        expect(html, contains(': This should not be parsed'));
      });

      test('allows consecutive terms without empty lines', () {
        const markdown = '''
First term
Second term
Third term

: Description for all three terms.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>First term</dt>
<dt>Second term</dt>
<dt>Third term</dt>
<dd>
<p>Description for all three terms.</p>
</dd>
</dl>'''),
        );
      });

      test('handles mixed scenarios correctly', () {
        const markdown = '''
First term
: First description without an empty line.

Second term

: Second description with a single empty line.

Third term
Fourth term

: Shared description for consecutive terms.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>First term</dt>
<dd>
<p>First description without an empty line.</p>
</dd>
<dt>Second term</dt>
<dd>
<p>Second description with a single empty line.</p>
</dd>
<dt>Third term</dt>
<dt>Fourth term</dt>
<dd>
<p>Shared description for consecutive terms.</p>
</dd>
</dl>'''),
        );
      });

      test('allows empty lines with multiple descriptions', () {
        const markdown = '''
Term

: First description after an empty line.

: Second description after another empty line.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>First description after an empty line.</p>
</dd>
<dd>
<p>Second description after another empty line.</p>
</dd>
</dl>'''),
        );
      });
    });

    group('edge cases', () {
      test('handles description without preceding term', () {
        const markdown = ': This is a description without a term.';
        final html = renderMarkdown(markdown);
        expect(html, contains('This is a description without a term.'));
        expect(html, isNot(contains('<dl>')));
        expect(html, isNot(contains('<dt>')));
        expect(html, isNot(contains('<dd>')));
      });

      test('ignores term without following description', () {
        const markdown = '''
Term without description

Regular paragraph after.''';

        final html = renderMarkdown(markdown);
        expect(html, isNot(contains('<dl>')));
        expect(html, contains('<p>Term without description</p>'));
      });

      test('handles mixed content', () {
        const markdown = '''
# Heading

First term
: First description.

Regular paragraph.

Second term
: Second description.

- List item
- Another item''';

        expect(
          renderMarkdown(markdown),
          equals('''
<h1>Heading</h1>
<dl>
<dt>First term</dt>
<dd>
<p>First description.</p>
</dd>
</dl>
<p>Regular paragraph.</p>
<dl>
<dt>Second term</dt>
<dd>
<p>Second description.</p>
</dd>
</dl>
<ul>
<li>List item</li>
<li>Another item</li>
</ul>'''),
        );
      });

      test('handles colons in regular text', () {
        const markdown = '''
This is not a description: just regular text.

URL example: https://dart.dev''';

        final html = renderMarkdown(markdown);
        expect(html, isNot(contains('<dl>')));
        expect(html, contains('This is not a description: just regular text.'));
        expect(html, contains('URL example: https://dart.dev'));
      });

      test('handles special characters without losing them', () {
        const markdown = r'''
Term with $special & characters
: Description with <html> & "quotes" and 'apostrophes'.''';

        final html = renderMarkdown(markdown);
        expect(html, contains(r'Term with $special &amp; characters'));
        expect(html, contains('Description with <html>'));
        expect(html, contains('&quot;quotes&quot;'));
      });

      test('handles very long terms and descriptions', () {
        final longTerm = 'A' * 500;
        final longDescription = 'B' * 1000;
        final markdown = '$longTerm\n: $longDescription';

        final html = renderMarkdown(markdown);
        expect(html, contains('<dt>$longTerm</dt>'));
        expect(html, contains(longDescription));
      });

      test('handles multiple empty lines between items', () {
        const markdown = '''
First term
: First description.



Second term
: Second description.''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>First term</dt>
<dd>
<p>First description.</p>
</dd>
<dt>Second term</dt>
<dd>
<p>Second description.</p>
</dd>
</dl>'''),
        );
      });

      test('handles description with only colon and space', () {
        const markdown = '''
Term
: ''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Term</dt>
<dd></dd>
</dl>'''),
        );
      });

      test('handles term at EOF without description', () {
        const markdown = 'Term at the end of a file';

        final html = renderMarkdown(markdown);
        // A term at the end of the content without a description should not
        // be parsed as a description list.
        expect(html, isNot(contains('<dl>')));
        expect(html, contains('<p>Term at the end of a file</p>'));
      });

      test('handles description list ending at EOF', () {
        const markdown = '''
Valid term
: Description at EOF''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Valid term</dt>
<dd>
<p>Description at EOF</p>
</dd>
</dl>'''),
        );
      });
    });

    group('pattern matching', () {
      test('recognizes description pattern variations', () {
        final testCases = [
          (': Description', true),
          (':  Description', true),
          (':\tDescription', true),
          (':Description', false),
          ('  : Description', true),
          ('\t: Description', true),
          ('Not a description', false),
          (':', false),
          (': ', true),
        ];

        for (final (line, shouldMatch) in testCases) {
          expect(
            const DescriptionListSyntax().pattern.hasMatch(line),
            equals(shouldMatch),
            reason: 'Line "$line" should ${shouldMatch ? "" : "not "}match',
          );
        }
      });

      test('recognizes term pattern', () {
        final testCases = [
          ('Simple term', true),
          ('  Indented term', true),
          (': Not a term', false),
          ('# A header', false),
          ('', false),
          ('   ', false),
          ('Term with spaces', true),
        ];

        for (final (line, shouldBeTerm) in testCases) {
          expect(
            DescriptionListSyntax.isValidTerm(line),
            equals(shouldBeTerm),
            reason:
                'Line "$line" should ${shouldBeTerm ? "" : "not "}be a term',
          );
        }
      });
    });

    group('complex scenarios', () {
      test('handles nested description lists', () {
        const markdown = '''
Outer term
: Outer description with nested list:
  
  Inner term
  : Inner description 1
  : Inner description 2
  
  Another inner term
  : Another inner description''';

        final html = renderMarkdown(markdown);
        expect(html, contains('<dt>Outer term</dt>'));
        expect(html, contains('Outer description with nested list:'));
        expect(html, contains('<dt>Inner term</dt>'));
        expect(html, contains('<p>Inner description 1</p>'));
        expect(html, contains('<dt>Another inner term</dt>'));
        expect(html, contains('<p>Another inner description</p>'));
      });

      test('handles mixed indentation correctly', () {
        const markdown = '''
Term
: First line
  Second line with spaces
\tThird line with tab
    Fourth line with 4 spaces
''';

        final html = renderMarkdown(markdown);
        expect(
          html,
          equals('''
<dl>
<dt>Term</dt>
<dd>
<p>First line
Second line with spaces
Third line with tab
Fourth line with 4 spaces</p>
</dd>
</dl>'''),
        );
      });

      test('handles consecutive description lists', () {
        const markdown = '''
First list term 1
: Description 1.1
: Description 1.2

First list term 2
: Description 2.1

Second list term 1
: Description 1

Second list term 2
: Description 2''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>First list term 1</dt>
<dd>
<p>Description 1.1</p>
</dd>
<dd>
<p>Description 1.2</p>
</dd>
<dt>First list term 2</dt>
<dd>
<p>Description 2.1</p>
</dd>
<dt>Second list term 1</dt>
<dd>
<p>Description 1</p>
</dd>
<dt>Second list term 2</dt>
<dd>
<p>Description 2</p>
</dd>
</dl>'''),
        );
      });

      test('preserves complex markdown in descriptions', () {
        const markdown = r'''
Complex term
: This description has **bold**, _italic_, `code`, and even math: $x^2 + y^2 = z^2$.
  
  It also has a [link](https://dart.dev) and an image reference.
  
  ```dart
  void main() {
    print('Hello, World!');
  }
  ```
  
  > And a quote for good measure.''';

        final html = renderMarkdown(markdown);
        expect(html, contains('<strong>bold</strong>'));
        expect(html, contains('<em>italic</em>'));
        expect(html, contains('<code>code</code>'));
        expect(html, contains(r'$x^2 + y^2 = z^2$'));
        expect(html, contains('href="https://dart.dev"'));
        expect(html, contains('<pre><code class="language-dart">'));
        expect(html, contains('<blockquote>'));
      });
    });

    group('canParse method', () {
      test('correctly identifies parseable content', () {
        final testCases = [
          (': Description alone', false),
          ('Term\n: Description', true),
          ('Regular paragraph', false),
          ('# Heading', false),
          ('- List item', false),
          ('', false),
        ];

        for (final (markdown, shouldParse) in testCases) {
          final lines = markdown.split('\n');
          final parser = md.BlockParser(
            lines.map(md.Line.new).toList(),
            document,
          );
          expect(
            syntax.canParse(parser),
            equals(shouldParse),
            reason:
                'Content "$markdown" should '
                '${shouldParse ? "" : "not "}be parseable',
          );
        }
      });
    });

    group('Unattached descriptions', () {
      test('are ignored but not consumed', () {
        const markdown = '''
: Unattached description at start.
: Another unattached description.

Valid term
: Valid description.''';

        final html = renderMarkdown(markdown);

        // Unattached descriptions should be treated as regular paragraphs.
        expect(html, contains('<p>: Unattached description at start.'));
        expect(html, contains(': Another unattached description.</p>'));

        expect(
          html,
          contains('''
<dl>
<dt>Valid term</dt>
<dd>
<p>Valid description.</p>
</dd>
</dl>'''),
        );
      });
    });

    group('nested content scenarios', () {
      test('supports unordered list inside description', () {
        const markdown = '''
Shopping list
: Items to buy:
  
  - Apples
  - Bananas
  - Oranges
  - Milk''';

        expect(
          renderMarkdown(markdown),
          equals(
            '''
<dl>
<dt>Shopping list</dt>
<dd>
<p>Items to buy:</p>
<ul>
<li>Apples</li>
<li>Bananas</li>
<li>Oranges</li>
<li>Milk</li>
</ul>
</dd>
</dl>''',
          ),
        );
      });

      test('supports description list inside unordered list item', () {
        const markdown = '''
- The first item in the list.
- The second item with a nested description list:
  
  Nested term
  : Nested description inside a list item.
  : Another nested description.
  
- The third item in the list.''';

        expect(
          renderMarkdown(markdown),
          equals(
            '''
<ul>
<li>
<p>The first item in the list.</p>
</li>
<li>
<p>The second item with a nested description list:</p>
<dl>
<dt>Nested term</dt>
<dd>
<p>Nested description inside a list item.</p>
</dd>
<dd>
<p>Another nested description.</p>
</dd>
</dl>
</li>
<li>
<p>The third item in the list.</p>
</li>
</ul>''',
          ),
        );
      });

      test('supports ordered list inside description', () {
        const markdown = '''
Recipe steps
: Follow these steps:
  
  1. Preheat oven to 350°F
  2. Mix dry ingredients
  3. Add wet ingredients
  4. Bake for 25 minutes''';

        expect(
          renderMarkdown(markdown),
          equals(
            '''
<dl>
<dt>Recipe steps</dt>
<dd>
<p>Follow these steps:</p>
<ol>
<li>Preheat oven to 350°F</li>
<li>Mix dry ingredients</li>
<li>Add wet ingredients</li>
<li>Bake for 25 minutes</li>
</ol>
</dd>
</dl>''',
          ),
        );
      });

      test('supports description list inside ordered list item', () {
        const markdown = '''
1. First step of the process.
2. Second step with a nested description:
   
   Important concept
   : This is a key description within the ordered list.
   : Additional clarification of the concept.
   
3. Final step of the process.''';

        expect(
          renderMarkdown(markdown),
          equals(
            '''
<ol>
<li>
<p>First step of the process.</p>
</li>
<li>
<p>Second step with a nested description:</p>
<dl>
<dt>Important concept</dt>
<dd>
<p>This is a key description within the ordered list.</p>
</dd>
<dd>
<p>Additional clarification of the concept.</p>
</dd>
</dl>
</li>
<li>
<p>Final step of the process.</p>
</li>
</ol>''',
          ),
        );
      });

      test('supports multiple levels of nesting', () {
        const markdown = '''
Complex term
: Description with multiple nested elements:
  
  - List item with nested description:
    
    Sub-term
    : Sub-description
    
  - Another list item
  
  And a numbered list:
  
  1. First numbered item
  2. Second numbered item with code:
     
     ```dart
     print('Hello');
     ```''';

        expect(
          renderMarkdown(markdown),
          equals('''
<dl>
<dt>Complex term</dt>
<dd>
<p>Description with multiple nested elements:</p>
<ul>
<li>
<p>List item with nested description:</p>
<dl>
<dt>Sub-term</dt>
<dd>
<p>Sub-description</p>
</dd>
</dl>
</li>
<li>
<p>Another list item</p>
</li>
</ul>
<p>And a numbered list:</p>
<ol>
<li>
<p>First numbered item</p>
</li>
<li>
<p>Second numbered item with code:</p>
<pre><code class="language-dart">print('Hello');
</code></pre>
</li>
</ol>
</dd>
</dl>'''),
        );
      });
    });

    group('integration with standard markdown', () {
      test('works with markdownToHtml without document', () {
        const markdown = '''
# Document with description lists

Term 1
: Description 1

> A blockquote.

Term 2
: Description 2

```
Code block.
```''';

        final html = md.markdownToHtml(
          markdown,
          blockSyntaxes: [
            const DescriptionListSyntax(),
          ],
        );

        expect(html, contains('<h1>Document with description lists</h1>'));
        expect(html, contains('<dl>'));
        expect(html, contains('<blockquote>'));
        expect(html, contains('<pre><code>'));
      });

      test('preserves document metadata and link references', () {
        const markdown = '''
[ref]: https://dart.dev "Example"

Term with [reference][ref]
: Description with [inline link](https://flutter.dev).

[ref2]: https://pub.dev

Another term
: Uses [ref2][].''';

        final html = renderMarkdown(markdown);
        expect(html, contains('href="https://dart.dev"'));
        expect(html, contains('href="https://flutter.dev"'));
        expect(html, contains('href="https://pub.dev"'));
      });
    });

    group('Consecutive term limit', () {
      test('respects maxTermsPerDescription limit of 1', () {
        const syntax = DescriptionListSyntax(maxTermsPerDescription: 1);
        final document = md.Document(blockSyntaxes: [syntax]);

        const markdown = '''
Term 1
Term 2
: This should be parsed as a description list.''';

        final html = md.renderToHtml(document.parse(markdown));

        // Term 1 should not be part of description list.
        expect(html, contains('<p>Term 1</p>'));
        expect(html, contains('<dt>Term 2</dt>'));
      });

      test('allows single term within maxTermsPerDescription limit of 1', () {
        const syntax = DescriptionListSyntax(maxTermsPerDescription: 1);
        final document = md.Document(blockSyntaxes: [syntax]);

        const markdown = '''
Term 1
: This should be parsed as a description list.''';

        final html = md.renderToHtml(document.parse(markdown));

        // Should be parsed as a description list and include term.
        expect(html, contains('<dl>'));
        expect(html, contains('<dt>Term 1</dt>'));
        expect(html, contains('<dd>'));
      });

      test('respects maxTermsPerDescription limit of 5', () {
        const syntax = DescriptionListSyntax(maxTermsPerDescription: 5);
        final document = md.Document(blockSyntaxes: [syntax]);

        // Only the last 5 terms should be parsed as part of description list.
        const markdown = '''
Term 1
Term 2
Term 3
Term 4
Term 5
Term 6
Term 7
: This should be parsed as a description list.''';

        final html = md.renderToHtml(document.parse(markdown));

        expect(html, contains('<p>Term 1'));
        expect(html, contains('Term 2</p>'));
        expect(html, contains('<dt>Term 3</dt>'));
        expect(html, contains('<dt>Term 7</dt>'));
      });
    });
  });
}
