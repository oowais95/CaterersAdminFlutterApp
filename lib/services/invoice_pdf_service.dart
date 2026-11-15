import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceData {
  InvoiceData({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.customerContact,
    required List<InvoiceLineItem> items,
    required double paidAmount,
  })  : items = List.unmodifiable(items),
        paidAmount = _roundToCents(paidAmount);

  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String customerContact;
  final List<InvoiceLineItem> items;
  final double paidAmount;

  double get grandTotal =>
      _roundToCents(items.fold(0, (total, item) => total + item.total));

  double get balanceAmount => _roundToCents(grandTotal - paidAmount);
}

class InvoiceLineItem {
  const InvoiceLineItem({
    required this.description,
    required this.unitPrice,
    required this.quantity,
  });

  final String description;
  final double unitPrice;
  final double quantity;

  double get total => _roundToCents(unitPrice * quantity);
}

double _roundToCents(double amount) => (amount * 100).round() / 100;

class InvoiceHtmlTemplate {
  static const assetPath = 'htmlTemplate/LavishInvoice.html';

  static String render({
    required String template,
    required InvoiceData invoice,
  }) {
    var html = template;
    final replacements = <String, String>{
      '{{invoice-number}}': _escapeHtml(invoice.invoiceNumber),
      '{{invoice-date}}': _formatDate(invoice.invoiceDate),
      '{{customer-name}}': _optionalText(invoice.customerName),
      '{{customer-contact}}': _optionalText(invoice.customerContact),
      '{{order-items}}': _renderItems(invoice.items),
      '{{grand-total}}': _formatCurrency(invoice.grandTotal),
      '{{paid-amount}}': _formatCurrency(invoice.paidAmount),
      '{{balance-amount}}': _formatCurrency(invoice.balanceAmount),
    };

    for (final entry in replacements.entries) {
      if (!html.contains(entry.key)) {
        throw FormatException('Invoice template is missing ${entry.key}.');
      }
      html = html.replaceAll(entry.key, entry.value);
    }

    return html;
  }

  static String _renderItems(List<InvoiceLineItem> items) {
    if (items.isEmpty) {
      return '<tr><td colspan="4" style="text-align:center;color:#707070">No order items</td></tr>';
    }

    return List.generate(items.length, (index) {
      final item = items[index];
      final unitPrice = item.unitPrice.toString();
      final quantity = item.quantity.toString();
      return '<tr data-field="order-item-$index" '
          'data-unit-price="$unitPrice" data-quantity="$quantity">'
          '<td data-field="item-$index-description">${_optionalText(item.description)}</td>'
          '<td class="unit-price" data-field="item-$index-unit-price">${_formatCurrency(item.unitPrice)}</td>'
          '<td data-field="item-$index-quantity">${_formatNumber(item.quantity)}</td>'
          '<td class="line-total" data-field="item-$index-total">${_formatCurrency(item.total)}</td>'
          '</tr>';
    }).join();
  }

  static String _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '—' : _escapeHtml(trimmed);
  }

  static String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  static String _formatCurrency(double amount) =>
      'Rs. ${_formatNumber(amount)}';

  static String _formatNumber(double amount) {
    final isNegative = amount < 0;
    final fixed = amount.abs().toStringAsFixed(2).split('.');
    final integer = fixed.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final fraction = fixed.last.replaceFirst(RegExp(r'0+$'), '');
    final decimal = fraction.isEmpty ? '' : '.$fraction';
    return '${isNegative ? '-' : ''}$integer$decimal';
  }
}

class InvoicePdfService {
  const InvoicePdfService();

  Future<void> generateAndShare(InvoiceData invoice) async {
    _ensureSupportedPlatform();

    final template = await rootBundle.loadString(InvoiceHtmlTemplate.assetPath);
    final html = InvoiceHtmlTemplate.render(
      template: template,
      invoice: invoice,
    );
    final directory = await getTemporaryDirectory();
    final safeInvoiceNumber =
        invoice.invoiceNumber.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final pdfFile = await HtmlToPdfConverter().convertHtmlToPdf(
      html: html,
      targetDirectory: directory.path,
      targetName: 'invoice_$safeInvoiceNumber',
      pageSize: PdfPageSize.a4,
    );

    if (!await pdfFile.exists() || await pdfFile.length() == 0) {
      throw FileSystemException('Invoice PDF was not created.', pdfFile.path);
    }

    await Share.shareXFiles(
      [XFile(pdfFile.path, mimeType: 'application/pdf')],
      subject: 'Invoice ${invoice.invoiceNumber}',
      text: 'Please find attached invoice ${invoice.invoiceNumber}.',
    );
  }

  Future<void> generateAndSharePng(InvoiceData invoice) async {
    _ensureSupportedPlatform();
    final pngBytes = await createPng(invoice);
    final directory = await getTemporaryDirectory();
    final safeInvoiceNumber =
        invoice.invoiceNumber.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final pngFile = File(
      '${directory.path}${Platform.pathSeparator}invoice_$safeInvoiceNumber.png',
    );
    await pngFile.writeAsBytes(pngBytes, flush: true);

    if (!await pngFile.exists() || await pngFile.length() == 0) {
      throw FileSystemException('Invoice PNG was not created.', pngFile.path);
    }

    await Share.shareXFiles(
      [XFile(pngFile.path, mimeType: 'image/png')],
      subject: 'Invoice ${invoice.invoiceNumber}',
      text: 'Please find attached invoice ${invoice.invoiceNumber}.',
    );
  }

  Future<Uint8List> createPng(InvoiceData invoice) {
    return ScreenshotController().captureFromLongWidget(
      _InvoicePngDocument(invoice: invoice),
      pixelRatio: 2,
      constraints: const BoxConstraints(maxWidth: 820),
    );
  }

  void _ensureSupportedPlatform() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      throw UnsupportedError(
        'Invoice sharing is currently supported on Android and iOS.',
      );
    }
  }
}

class _InvoicePngDocument extends StatelessWidget {
  const _InvoicePngDocument({required this.invoice});

  final InvoiceData invoice;

  static const _brand = Color(0xFFA91618);
  static const _ink = Color(0xFF292929);
  static const _muted = Color(0xFF707070);
  static const _line = Color(0xFFE9E3E1);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: _ink,
        fontFamily: 'Arial',
        fontSize: 14,
      ),
      child: Container(
        width: 820,
        padding: const EdgeInsets.all(40),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAVISH CATERERS',
                      style: TextStyle(
                        color: _brand,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Catering services for every occasion',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'INVOICE',
                      style: TextStyle(
                        color: _brand,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('No. ${invoice.invoiceNumber}'),
                    const SizedBox(height: 4),
                    Text(InvoiceHtmlTemplate._formatDate(invoice.invoiceDate)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Divider(color: _brand, thickness: 2, height: 2),
            const SizedBox(height: 24),
            const Text(
              'BILL TO',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              invoice.customerName.trim().isEmpty
                  ? '—'
                  : invoice.customerName.trim(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (invoice.customerContact.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                invoice.customerContact.trim(),
                style: const TextStyle(color: _muted),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              color: const Color(0xFFFBF7F6),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: const Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'ITEM DESCRIPTION',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'UNIT PRICE',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'QTY',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'TOTAL',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            if (invoice.items.isEmpty)
              _itemRow('No order items', '', '', '')
            else
              ...invoice.items.map(
                (item) => _itemRow(
                  item.description.trim().isEmpty ? '—' : item.description,
                  InvoiceHtmlTemplate._formatCurrency(item.unitPrice),
                  InvoiceHtmlTemplate._formatNumber(item.quantity),
                  InvoiceHtmlTemplate._formatCurrency(item.total),
                ),
              ),
            const SizedBox(height: 20),
            const Divider(color: _line),
            _amountRow('Total Amount', invoice.grandTotal),
            const SizedBox(height: 10),
            _amountRow('Paid Amount', invoice.paidAmount),
            const SizedBox(height: 10),
            _amountRow(
              'Balance Amount',
              invoice.balanceAmount,
              emphasize: true,
            ),
            const SizedBox(height: 28),
            const Divider(color: _line),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Thank you for choosing Lavish Caterers',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '0300-8929033  |  0315-2497674',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Federal B Area, Block 16, Shop No. LS36, Karachi',
                style: TextStyle(color: _muted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'lavishcaterers.com.pk  |  Instagram: lavishcateringservices',
                style: TextStyle(color: _muted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Proudly serving since 1995',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(
      String description, String price, String quantity, String total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(description)),
          Expanded(flex: 2, child: Text(price, textAlign: TextAlign.right)),
          Expanded(child: Text(quantity, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text(total, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _amountRow(String label, double amount, {bool emphasize = false}) {
    final color = emphasize ? _brand : _ink;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 180,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: emphasize ? 17 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: Text(
            InvoiceHtmlTemplate._formatCurrency(amount),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: emphasize ? 17 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
