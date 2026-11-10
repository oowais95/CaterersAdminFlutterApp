import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavish_flutter_application_1/main.dart';
import 'package:lavish_flutter_application_1/pages/invoicing_page.dart';
import 'package:lavish_flutter_application_1/services/invoice_pdf_service.dart';

void main() {
  test('bundled invoice template renders all current invoice placeholders',
      () async {
    final template = await rootBundle.loadString(InvoiceHtmlTemplate.assetPath);
    final invoice = InvoiceData(
      invoiceNumber: 'LC-20261109-123456',
      invoiceDate: DateTime(2026, 11, 9),
      customerName: 'Customer',
      customerContact: '0300-1234567',
      items: const [
        InvoiceLineItem(description: 'Catering', unitPrice: 100, quantity: 2),
      ],
      paidAmount: 50,
    );

    final html = InvoiceHtmlTemplate.render(
      template: template,
      invoice: invoice,
    );

    expect(html, contains('data-field="invoice-number">LC-20261109-123456'));
    expect(html, contains('data-field="customer-contact">0300-1234567'));
    expect(html, contains('data-field="item-0-total">Rs. 200'));
    expect(html, contains('data-field="grand-total">Rs. 200'));
    expect(html, contains('data-field="paid-amount">Rs. 50'));
    expect(html, contains('data-field="balance-amount">Rs. 150'));
    expect(html, isNot(contains('{{')));
  });

  test('invoice template renders escaped customer data and every item', () {
    const template = '''
      {{invoice-number}}|{{invoice-date}}|{{customer-name}}|{{customer-contact}}
      <tbody>{{order-items}}</tbody>
      {{grand-total}}|{{paid-amount}}|{{balance-amount}}
    ''';
    final invoice = InvoiceData(
      invoiceNumber: 'LC-20261109-123456',
      invoiceDate: DateTime(2026, 11, 9),
      customerName: '<Ahmed & Sons>',
      customerContact: '0300-1234567',
      items: const [
        InvoiceLineItem(
          description: 'Dinner <Package>',
          unitPrice: 1250,
          quantity: 2,
        ),
        InvoiceLineItem(
          description: 'Dessert & tea',
          unitPrice: 100.5,
          quantity: 3,
        ),
      ],
      paidAmount: 1000,
    );

    final html = InvoiceHtmlTemplate.render(
      template: template,
      invoice: invoice,
    );

    expect(html, contains('LC-20261109-123456|09 November 2026'));
    expect(html, contains('&lt;Ahmed &amp; Sons&gt;'));
    expect(html,
        contains('data-field="item-0-description">Dinner &lt;Package&gt;'));
    expect(html, contains('data-field="item-1-description">Dessert &amp; tea'));
    expect(
        RegExp(r'<tr data-field="order-item-\d"').allMatches(html).length, 2);
    expect(html, contains('Rs. 2,801.5|Rs. 1,000|Rs. 1,801.5'));
    expect(html, isNot(contains('{{')));
  });

  test('invoice template uses graceful values for empty optional fields', () {
    const template =
        '{{customer-name}}|{{customer-contact}}|{{order-items}}|{{grand-total}}|{{paid-amount}}|{{balance-amount}}|{{invoice-number}}|{{invoice-date}}';
    final invoice = InvoiceData(
      invoiceNumber: 'LC-1',
      invoiceDate: DateTime(2026, 1, 2),
      customerName: '',
      customerContact: '  ',
      items: const [],
      paidAmount: 0,
    );

    final html = InvoiceHtmlTemplate.render(
      template: template,
      invoice: invoice,
    );

    expect(html, startsWith('—|—|'));
    expect(html, contains('No order items'));
    expect(html, contains('Rs. 0|Rs. 0|Rs. 0'));
  });

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

  testWidgets('share action uses the latest invoice form values',
      (tester) async {
    final service = _FakeInvoicePdfService();
    await tester.pumpWidget(
      MaterialApp(home: InvoicingPage(invoicePdfService: service)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('item-description-0')),
      'Wedding dinner',
    );
    await tester.enterText(
      find.byKey(const ValueKey('item-unit-price-0')),
      '150.5',
    );
    await tester.enterText(
      find.byKey(const ValueKey('item-quantity-0')),
      '2',
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('share-invoice')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('share-invoice')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('share-invoice')));
    await tester.pumpAndSettle();

    expect(service.sharedInvoice, isNotNull);
    expect(service.sharedInvoice!.customerName, '');
    expect(service.sharedInvoice!.items.single.description, 'Wedding dinner');
    expect(service.sharedInvoice!.items.single.total, 301);
    expect(service.sharedInvoice!.grandTotal, 301);
    expect(service.sharedInvoice!.paidAmount, 0);
  });
}

class _FakeInvoicePdfService extends InvoicePdfService {
  InvoiceData? sharedInvoice;

  @override
  Future<void> generateAndShare(InvoiceData invoice) async {
    sharedInvoice = invoice;
  }
}
