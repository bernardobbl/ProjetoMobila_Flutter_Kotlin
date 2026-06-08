// Testes do FinanFlow.
//
// O template padrão do Flutter (contador) foi substituído por testes reais
// que cobrem a serialização dos modelos e o widget compartilhado CustomButton.
// Esses testes não dependem de banco de dados nem de plugins, então rodam
// rapidamente com `flutter test`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finanflow/models/transaction_model.dart';
import 'package:finanflow/models/category_model.dart';
import 'package:finanflow/shared/widgets/custom_button.dart';

void main() {
  group('TransactionModel', () {
    final tx = TransactionModel(
      id: 'abc-123',
      userId: 1,
      title: 'Almoço',
      amount: 35.50,
      type: 'expense',
      categoryId: 2,
      date: DateTime(2026, 6, 8),
      description: 'Restaurante',
    );

    test('isIncome reflete o tipo da transação', () {
      expect(tx.isIncome, isFalse);
      expect(tx.copyWith(type: 'income').isIncome, isTrue);
    });

    test('toMap e fromMap preservam os dados (round-trip)', () {
      final restored = TransactionModel.fromMap(tx.toMap());
      expect(restored.id, tx.id);
      expect(restored.userId, tx.userId);
      expect(restored.title, tx.title);
      expect(restored.amount, tx.amount);
      expect(restored.type, tx.type);
      expect(restored.categoryId, tx.categoryId);
      expect(restored.date, tx.date);
      expect(restored.description, tx.description);
    });

    test('copyWith altera apenas os campos informados', () {
      final edited = tx.copyWith(title: 'Jantar', amount: 50);
      expect(edited.title, 'Jantar');
      expect(edited.amount, 50);
      expect(edited.id, tx.id); // id permanece o mesmo
      expect(edited.categoryId, tx.categoryId);
    });
  });

  group('CategoryModel', () {
    test('resolve o ícone pelo nome e cai no fallback quando desconhecido', () {
      const known = CategoryModel(
        name: 'Alimentação',
        iconName: 'restaurant',
        colorValue: 0xFFFF9800,
        type: 'expense',
      );
      const unknown = CategoryModel(
        name: 'Inexistente',
        iconName: 'icone_que_nao_existe',
        colorValue: 0xFF000000,
        type: 'expense',
      );

      expect(known.icon, Icons.restaurant);
      expect(unknown.icon, Icons.category); // fallback
    });

    test('toMap e fromMap preservam os dados (round-trip)', () {
      const cat = CategoryModel(
        id: 5,
        name: 'Transporte',
        iconName: 'directions_car',
        colorValue: 0xFF2196F3,
        type: 'expense',
      );
      final restored = CategoryModel.fromMap(cat.toMap());
      expect(restored.name, cat.name);
      expect(restored.iconName, cat.iconName);
      expect(restored.colorValue, cat.colorValue);
      expect(restored.type, cat.type);
    });
  });

  group('CustomButton', () {
    testWidgets('exibe o rótulo e dispara onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Entrar',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Entrar'), findsOneWidget);
      await tester.tap(find.byType(CustomButton));
      expect(pressed, isTrue);
    });

    testWidgets('mostra loading e ignora toques quando isLoading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Entrar',
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
      await tester.tap(find.byType(CustomButton));
      expect(pressed, isFalse); // desabilitado durante o loading
    });
  });
}
