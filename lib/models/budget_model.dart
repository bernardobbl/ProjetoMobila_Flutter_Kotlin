/// Orçamento (meta) mensal de gastos do usuário.
///
/// É um valor único por usuário que representa quanto ele pretende gastar
/// no mês. A tela de Relatórios mostra o progresso em relação a essa meta.
class BudgetModel {
  final int userId;
  final double amount;

  const BudgetModel({
    required this.userId,
    required this.amount,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'amount': amount,
      };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
        userId: map['user_id'] as int,
        amount: (map['amount'] as num).toDouble(),
      );
}
