import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavish_flutter_application_1/main.dart';
import 'package:lavish_flutter_application_1/pages/invoicing_page.dart';

void main() {
  testWidgets('invoice totals update from decimal item and payment values',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InvoicingPage()),
    );

    await tester.enterText(
      find.byKey(const ValueKey('item-unit-price-0')),
      '12.5',
    );
    await tester.enterText(
      find.byKey(const ValueKey('item-quantity-0')),
      '2.5',
    );
    await tester.pump();

    expect(find.text('Item Total: Rs. 31.25'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Grand Total'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Rs. 31.25'), findsNWidgets(2));

    await tester.ensureVisible(find.byKey(const ValueKey('paid-amount')));
    await tester.enterText(
      find.byKey(const ValueKey('paid-amount')),
      '10.5',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Balance Amount'));
    await tester.pumpAndSettle();
    expect(find.text('Rs. 20.75'), findsOneWidget);
  });

  testWidgets('invoice items can be added and removed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InvoicingPage()),
    );

    await tester.ensureVisible(find.text('Add Item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Item'));
    await tester.pump();
    expect(find.text('Item 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('remove-item-0')));
    await tester.pump();
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsNothing);
  });

  testWidgets('Invoicing is available from the navigation drawer',
      (tester) async {
    await tester.pumpWidget(FoodCalculatorApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Invoicing'));
    await tester.pumpAndSettle();

    expect(find.text('Create Invoice'), findsOneWidget);
  });
}
