/// Regra de transação recorrente (ex.: aluguel todo dia 5, salário todo dia 1).
///
/// A cada abertura do app, o app gera automaticamente as transações que
/// "venceram" desde a última geração, até o mês atual.
class RecurringModel {
  final String id;
  final int userId;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final int categoryId;
  final int dayOfMonth; // dia do mês em que a transação é lançada (1–28)
  final DateTime startDate; // a partir de quando a regra vale
  final DateTime? lastGenerated; // último mês já gerado (dia 1 do mês)

  const RecurringModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.dayOfMonth,
    required this.startDate,
    this.lastGenerated,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'day_of_month': dayOfMonth,
        'start_date': startDate.toIso8601String(),
        'last_generated': lastGenerated?.toIso8601String(),
      };

  factory RecurringModel.fromMap(Map<String, dynamic> map) => RecurringModel(
        id: map['id'] as String,
        userId: map['user_id'] as int,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        categoryId: map['category_id'] as int,
        dayOfMonth: map['day_of_month'] as int,
        startDate: DateTime.parse(map['start_date'] as String),
        lastGenerated: map['last_generated'] == null
            ? null
            : DateTime.parse(map['last_generated'] as String),
      );

  RecurringModel copyWith({DateTime? lastGenerated}) => RecurringModel(
        id: id,
        userId: userId,
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        dayOfMonth: dayOfMonth,
        startDate: startDate,
        lastGenerated: lastGenerated ?? this.lastGenerated,
      );
}
