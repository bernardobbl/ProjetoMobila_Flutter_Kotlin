import '../../../core/utils/formatters.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';
import 'csv_platform_stub.dart'
    if (dart.library.html) 'csv_platform_web.dart'
    if (dart.library.io) 'csv_platform_native.dart';

class CsvExporter {
  CsvExporter._();

  static Future<void> exportTransactions(
    List<TransactionModel> transactions,
    CategoryModel? Function(int id) categoryLookup,
  ) async {
    final buffer = StringBuffer();
    // BOM (U+FEFF) para o Excel reconhecer UTF-8 (acentos corretos).
    buffer.write('\u{FEFF}');
    buffer.writeln('Data;Título;Categoria;Tipo;Valor');

    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));

    for (final tx in sorted) {
      final category = categoryLookup(tx.categoryId)?.name ?? 'Sem categoria';
      final tipo = tx.isIncome ? 'Receita' : 'Despesa';
      final valor = tx.amount.toStringAsFixed(2).replaceAll('.', ',');
      final row = [
        Formatters.dateShort(tx.date),
        tx.title,
        category,
        tipo,
        valor,
      ].map(_escape).join(';');
      buffer.writeln(row);
    }

    final now = DateTime.now();
    final stamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}';
    final fileName = 'finanflow_transacoes_$stamp.csv';

    await saveCsvAndShare(buffer.toString(), fileName);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _escape(String field) {
    if (field.contains(';') || field.contains('"') || field.contains('\n') || field.contains('\r')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
