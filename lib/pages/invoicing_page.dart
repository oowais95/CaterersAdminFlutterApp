import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/invoice_pdf_service.dart';

class InvoicingPage extends StatefulWidget {
  const InvoicingPage({
    super.key,
    this.invoicePdfService = const InvoicePdfService(),
  });

  final InvoicePdfService invoicePdfService;

  @override
  State<InvoicingPage> createState() => _InvoicingPageState();
}

class _InvoicingPageState extends State<InvoicingPage> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerContactController =
      TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final List<_InvoiceItem> _items = [_InvoiceItem()];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _invoiceDate = DateTime.now();
  String? _invoiceNumber;
  bool _isSharing = false;

  double get _grandTotal => _items.fold(0, (total, item) => total + item.total);

  double get _paidAmount =>
      double.tryParse(_paidAmountController.text.trim()) ?? 0;

  double get _balanceAmount => _grandTotal - _paidAmount;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerContactController.dispose();
    _paidAmountController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _selectInvoiceDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() => _invoiceDate = selectedDate);
    }
  }

  void _addItem() {
    setState(() => _items.add(_InvoiceItem()));
  }

  void _removeItem(int index) {
    final removedItem = _items.removeAt(index);
    removedItem.dispose();
    setState(() {});
  }

  void _refreshTotals() => setState(() {});

  Future<void> _shareInvoice() async {
    if (_isSharing || !(_formKey.currentState?.validate() ?? false)) return;

    final invoiceNumber = _invoiceNumber ?? _createInvoiceNumber();
    _invoiceNumber = invoiceNumber;
    final invoice = InvoiceData(
      invoiceNumber: invoiceNumber,
      invoiceDate: _invoiceDate,
      customerName: _customerNameController.text,
      customerContact: _customerContactController.text,
      items: _items
          .map(
            (item) => InvoiceLineItem(
              description: item.descriptionController.text,
              unitPrice:
                  double.tryParse(item.unitPriceController.text.trim()) ?? 0,
              quantity:
                  double.tryParse(item.quantityController.text.trim()) ?? 0,
            ),
          )
          .toList(),
      paidAmount: _paidAmount,
    );

    setState(() => _isSharing = true);
    try {
      await widget.invoicePdfService.generateAndShare(invoice);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Could not share invoice: $error')),
        );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  String _createInvoiceNumber() {
    final now = DateTime.now();
    final date = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}'
        '${now.microsecond.toString().padLeft(6, '0')}';
    return 'LC-$date-$time';
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final amount = double.tryParse(value);
    if (amount == null || !amount.isFinite || amount < 0) {
      return 'Enter a valid non-negative number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${_invoiceDate.day.toString().padLeft(2, '0')} ${_monthName(_invoiceDate.month)} ${_invoiceDate.year}';

    return Container(
      color: const Color(0xFFFAF8F7),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Create Invoice',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8F1719),
                  ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Invoice Details',
              icon: Icons.receipt_long,
              children: [
                InkWell(
                  key: const ValueKey('invoice-date'),
                  onTap: _selectInvoiceDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Invoice Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(dateText),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customerNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customerContactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Customer Contact Number (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Order Items',
              icon: Icons.restaurant_menu,
              children: [
                for (var index = 0; index < _items.length; index++)
                  _buildItemCard(index, _items[index]),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8F1719),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Payment Details',
              icon: Icons.payments_outlined,
              children: [
                _totalRow('Grand Total', _grandTotal, isEmphasized: true),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('paid-amount'),
                  controller: _paidAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_NonNegativeDecimalFormatter()],
                  validator: _validateAmount,
                  onChanged: (_) => _refreshTotals(),
                  decoration: const InputDecoration(
                    labelText: 'Paid Amount (optional)',
                    border: OutlineInputBorder(),
                    prefixText: 'Rs. ',
                  ),
                ),
                const SizedBox(height: 12),
                _totalRow('Balance Amount', _balanceAmount),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('share-invoice'),
                    onPressed: _isSharing ? null : _shareInvoice,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.share),
                    label: Text(
                      _isSharing
                          ? 'Preparing invoice...'
                          : 'Share via WhatsApp',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8F1719),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index, _InvoiceItem item) {
    return Card(
      key: ObjectKey(item),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFFFFFCFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE9E3E1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Item ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  key: ValueKey('remove-item-$index'),
                  tooltip: 'Remove item',
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade700,
                ),
              ],
            ),
            TextFormField(
              key: ValueKey('item-description-$index'),
              controller: item.descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Item Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('item-unit-price-$index'),
                    controller: item.unitPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_NonNegativeDecimalFormatter()],
                    validator: _validateAmount,
                    onChanged: (_) => _refreshTotals(),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs. ',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('item-quantity-$index'),
                    controller: item.quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_NonNegativeDecimalFormatter()],
                    validator: _validateAmount,
                    onChanged: (_) => _refreshTotals(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Item Total: Rs. ${item.total.toStringAsFixed(2)}',
                key: ValueKey('item-total-$index'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF8F1719)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double amount, {bool isEmphasized = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isEmphasized ? 16 : 14,
            fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          'Rs. ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isEmphasized ? 18 : 16,
            fontWeight: FontWeight.w700,
            color: isEmphasized ? const Color(0xFF8F1719) : null,
          ),
        ),
      ],
    );
  }

  String _monthName(int month) => const [
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
      ][month - 1];
}

class _InvoiceItem {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  double get total {
    final unitPrice = double.tryParse(unitPriceController.text.trim()) ?? 0;
    final quantity = double.tryParse(quantityController.text.trim()) ?? 0;
    return unitPrice * quantity;
  }

  void dispose() {
    descriptionController.dispose();
    unitPriceController.dispose();
    quantityController.dispose();
  }
}

class _NonNegativeDecimalFormatter extends TextInputFormatter {
  static final _validDecimal = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _validDecimal.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
