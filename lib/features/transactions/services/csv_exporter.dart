import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';

/// Exporta as transações para um arquivo CSV e abre o menu de compartilhamento.
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

    // Ordena da mais antiga para a mais recente no arquivo.
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

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final stamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}';
    final file = File('${dir.path}/finanflow_transacoes_$stamp.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      text: 'Minhas transações — FinanFlow',
      subject: 'Relatório FinanFlow',
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Escapa um campo CSV (aspas, ponto e vírgula ou quebra de linha).
  static String _escape(String field) {
    if (field.contains(';') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
