import 'dart:io';

class QuotationItem {
  String itemDescription;
  String grade;
  String size;
  File? image;
  int boxes;
  double sqft;
  double ratePerBox;

  QuotationItem({
    this.itemDescription = '',
    this.grade = '',
    this.size = '',
    this.image,
    this.boxes = 0,
    this.sqft = 0.0,
    this.ratePerBox = 0.0,
  });

  double get finalAmount => ratePerBox * boxes;
  double get ratePerSqft => (sqft > 0) ? finalAmount / sqft : 0.0;
}

class QuotationCategory {
  String name;
  List<QuotationItem> items;

  QuotationCategory({required this.name}) : items = [];

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.finalAmount);
}

class QuotationModel {
  final String id;
  final DateTime date;
  final String generatedBy;
  final String customerName;
  final String phone;
  final String address;
  final List<QuotationCategory> categories;

  QuotationModel({
    required this.id,
    required this.date,
    required this.generatedBy,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.categories,
  });

  double get grandTotal =>
      categories.fold(0.0, (sum, cat) => sum + cat.totalAmount);
}
