import 'package:markdown_description_list/src/util.dart';
import 'package:test/test.dart';

void main() {
  group('Utilities', () {
    group('indentation removal', () {
      test('removes correct indentation', () {
        expect(removeIndentation('  Line'), equals('Line'));
        expect(removeIndentation('\tLine'), equals('Line'));
        expect(removeIndentation('    Line'), equals('  Line'));
        expect(removeIndentation('Line'), equals('Line'));
        expect(
          removeIndentation(' Line'),
          equals(' Line'),
        );
        expect(removeIndentation(''), equals(''));
      });
    });

    group('withoutTrailingEmptyStrings', () {
      test('removes trailing empty strings', () {
        final list = ['a', 'b', '', ''];
        expect(list.withoutTrailingEmptyStrings, equals(['a', 'b']));
      });

      test('preserves non-empty strings at the end', () {
        final list = ['a', 'b', 'c'];
        expect(list.withoutTrailingEmptyStrings, equals(['a', 'b', 'c']));
      });

      test('removes multiple trailing empty strings', () {
        final list = ['hello', 'world', '', '', '', ''];
        expect(list.withoutTrailingEmptyStrings, equals(['hello', 'world']));
      });

      test('preserves empty strings in the front', () {
        final list = ['', '', 'a', 'b'];
        expect(list.withoutTrailingEmptyStrings, equals(['', '', 'a', 'b']));
      });

      test('preserves empty strings in the middle', () {
        final list = ['a', '', 'b', ''];
        expect(list.withoutTrailingEmptyStrings, equals(['a', '', 'b']));
      });

      test('returns empty list when all strings are empty', () {
        final list = ['', '', ''];
        expect(list.withoutTrailingEmptyStrings, equals(<String>[]));
      });

      test('returns empty list when input is empty', () {
        final list = <String>[];
        expect(list.withoutTrailingEmptyStrings, equals(<String>[]));
      });

      test('handles single non-empty string', () {
        final list = ['hello'];
        expect(list.withoutTrailingEmptyStrings, equals(['hello']));
      });

      test('handles single empty string', () {
        final list = [''];
        expect(list.withoutTrailingEmptyStrings, equals(<String>[]));
      });

      test('handles mixed content with trailing empty strings', () {
        final list = ['', 'middle', '', 'last', '', ''];
        expect(
          list.withoutTrailingEmptyStrings,
          equals(['', 'middle', '', 'last']),
        );
      });

      test(
        'handles whitespace-only strings differently from empty strings',
        () {
          final list = ['content', ' ', ''];
          expect(list.withoutTrailingEmptyStrings, equals(['content', ' ']));
        },
      );
    });
  });
}
