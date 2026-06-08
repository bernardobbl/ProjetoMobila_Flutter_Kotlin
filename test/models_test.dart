import 'package:flutter_test/flutter_test.dart';
import 'package:finanflow/models/budget_model.dart';
import 'package:finanflow/models/recurring_model.dart';
import 'package:finanflow/models/category_model.dart';
import 'package:finanflow/models/user_model.dart';

void main() {
  group('BudgetModel', () {
    test('toMap/fromMap round-trip', () {
      const b = BudgetModel(userId: 1, amount: 1500.0);
      final r = BudgetModel.fromMap(b.toMap());
      expect(r.userId, 1);
      expect(r.amount, 1500.0);
    });
  });

  group('RecurringModel', () {
    final rule = RecurringModel(
      id: 'r1',
      userId: 1,
      title: 'Aluguel',
      amount: 1200,
      type: 'expense',
      categoryId: 3,
      dayOfMonth: 5,
      startDate: DateTime(2026, 1, 1),
    );

    test('toMap/fromMap round-trip preserva os campos', () {
      final r = RecurringModel.fromMap(rule.toMap());
      expect(r.id, rule.id);
      expect(r.title, rule.title);
      expect(r.dayOfMonth, 5);
      expect(r.isIncome, isFalse);
      expect(r.lastGenerated, isNull);
    });

    test('copyWith atualiza apenas lastGenerated', () {
      final updated = rule.copyWith(lastGenerated: DateTime(2026, 3, 1));
      expect(updated.lastGenerated, DateTime(2026, 3, 1));
      expect(updated.title, rule.title);
      expect(updated.dayOfMonth, rule.dayOfMonth);
    });
  });

  group('CategoryModel.isDefault', () {
    test('categoria nova é não-padrão por omissão', () {
      const c = CategoryModel(
        name: 'Assinaturas',
        iconName: 'phone_android',
        colorValue: 0xFF2196F3,
        type: 'expense',
      );
      expect(c.isDefault, isFalse);
    });

    test('fromMap trata is_default ausente como padrão (1)', () {
      final c = CategoryModel.fromMap({
        'id': 1,
        'name': 'Salário',
        'icon_name': 'work',
        'color_value': 0xFF4CAF50,
        'type': 'income',
        // is_default ausente
      });
      expect(c.isDefault, isTrue);
    });
  });

  group('UserModel.isLegacy', () {
    test('sem salt é considerado legado', () {
      const u = UserModel(name: 'A', email: 'a@a.com', password: '123');
      expect(u.isLegacy, isTrue);
    });

    test('com salt não é legado', () {
      const u = UserModel(name: 'A', email: 'a@a.com', password: 'hash', salt: 'xyz');
      expect(u.isLegacy, isFalse);
    });
  });
}
