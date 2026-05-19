import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropdownSearch - single selection', () {
    testWidgets('renders without error with empty items list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSearch<String>(
              items: const [],
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(DropdownSearch<String>), findsOneWidget);
    });

    testWidgets('displays pre-selected item text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSearch<String>(
              items: const ['Apple', 'Banana', 'Cherry'],
              selectedItem: 'Apple',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('opens menu popup when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSearch<String>(
              items: const ['Apple', 'Banana', 'Cherry'],
              popupProps: const PopupProps.menu(showSearchBox: false),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DropdownSearch<String>));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('calls onChanged when item is selected', (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSearch<String>(
              items: const ['Apple', 'Banana', 'Cherry'],
              popupProps: const PopupProps.menu(showSearchBox: false),
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DropdownSearch<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(selected, equals('Banana'));
    });

    testWidgets('opens modal bottom sheet popup without throwing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSearch<String>(
              items: const ['Apple', 'Banana', 'Cherry'],
              popupProps: const PopupProps.modalBottomSheet(
                showSearchBox: false,
              ),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DropdownSearch<String>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Banana'), findsOneWidget);
    });
  });

  group('DropdownSearch - multi selection', () {
    testWidgets('renders pre-selected items as chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSearch<String>.multiSelection(
              items: const ['Apple', 'Banana', 'Cherry'],
              selectedItems: const ['Apple', 'Banana'],
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
    });
  });
}
