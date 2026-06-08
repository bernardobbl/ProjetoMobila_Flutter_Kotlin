import 'package:flutter_test/flutter_test.dart';
import 'package:finanflow/core/utils/formatters.dart';

void main() {
  group('Formatters.parseAmount', () {
    test('aceita valores simples com vírgula decimal', () {
      expect(Formatters.parseAmount('50,00'), 50.0);
      expect(Formatters.parseAmount('50'), 50.0);
      expect(Formatters.parseAmount('0,99'), 0.99);
    });

    test('entende separador de milhar no formato brasileiro', () {
      expect(Formatters.parseAmount('1.500,00'), 1500.0);
      expect(Formatters.parseAmount('1.234.567,89'), 1234567.89);
    });

    test('ignora símbolos como R\$ e espaços', () {
      expect(Formatters.parseAmount('R\$ 1.200,50'), 1200.5);
      expect(Formatters.parseAmount('  300,00 '), 300.0);
    });

    test('retorna null para entradas inválidas', () {
      expect(Formatters.parseAmount('abc'), isNull);
      expect(Formatters.parseAmount(''), isNull);
    });
  });
}
