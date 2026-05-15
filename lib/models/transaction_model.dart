class TransactionModel {
  final String id;
  final int userId;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final int categoryId;
  final DateTime date;
  final String? description;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.description,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'date': date.toIso8601String(),
        'description': description,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] as String,
        userId: map['user_id'] as int,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        categoryId: map['category_id'] as int,
        date: DateTime.parse(map['date'] as String),
        description: map['description'] as String?,
      );

  TransactionModel copyWith({
    String? title,
    double? amount,
    String? type,
    int? categoryId,
    DateTime? date,
    String? description,
  }) =>
      TransactionModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        description: description ?? this.description,
      );
}
