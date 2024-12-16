class CalculationService {
  Map<String, dynamic> calculateTotal(
    Map<String, dynamic> menu,
    int totalGuests,
  ) {
    int grandTotal = 0;
    double perHeadCost = 0.0;

    menu.forEach((item, details) {
      int price = details['price'];
      double factor = details['factor'];
      int quantity = (totalGuests / factor).ceil();
      grandTotal += quantity * price;
    });

    if (totalGuests > 0) {
      perHeadCost = grandTotal / totalGuests;
    }

    return {'grandTotal': grandTotal, 'perHeadCost': perHeadCost};
  }
}
