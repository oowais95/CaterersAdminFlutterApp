import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceData {
  InvoiceData({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.customerContact,
    required List<InvoiceLineItem> items,
    required this.paidAmount,
  }) : items = List.unmodifiable(items);

  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String customerContact;
  final List<InvoiceLineItem> items;
  final double paidAmount;

  double get grandTotal => items.fold(0, (total, item) => total + item.total);

  double get balanceAmount => grandTotal - paidAmount;
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

  double get total => unitPrice * quantity;
}

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
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      throw UnsupportedError(
        'PDF sharing is currently supported on Android and iOS.',
      );
    }

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
}
