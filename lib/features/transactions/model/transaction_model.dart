class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'sent', 'received', 'pending'
  final String iconKey; // NEW: String key for icon
  final String colorKey; // NEW: String key for color

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.iconKey,
    required this.colorKey,
  });
}
