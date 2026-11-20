import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vitrine/models/empresa.dart';
import 'package:vitrine/models/produto.dart';
import 'package:vitrine/utils/formatadores.dart';
import 'package:vitrine/utils/texto_catalogo.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('formatarMoeda', () {
    test('formata centavos em reais', () {
      expect(formatarMoeda(1250), 'R\$ 12,50');
      expect(formatarMoeda(482000), 'R\$ 4.820,00');
    });
  });

  group('textoParaCentavos', () {
    test('aceita vírgula ou ponto como separador decimal', () {
      expect(textoParaCentavos('12,50'), 1250);
      expect(textoParaCentavos('12.5'), 1250);
      expect(textoParaCentavos('12'), 1200);
    });

    test('ignora símbolo e separador de milhar', () {
      expect(textoParaCentavos('R\$ 1.234,56'), 123456);
    });

    test('rejeita valores inválidos', () {
      expect(textoParaCentavos(''), isNull);
      expect(textoParaCentavos('abc'), isNull);
      expect(textoParaCentavos('1,234'), isNull);
      expect(textoParaCentavos('1,2,3'), isNull);
    });

    test('é o inverso de centavosParaTexto', () {
      expect(textoParaCentavos(centavosParaTexto(990)), 990);
    });
  });

  test('formatarData usa dia/mês/ano', () {
    expect(formatarData(DateTime(2026, 10, 5)), '05/10/2026');
  });

  test('montarTextoCatalogo lista empresa, produtos e contatos', () {
    final texto = montarTextoCatalogo(
      const Empresa(nome: 'Doces da Ana', whatsapp: '11 99999-0000', instagram: '@docesdaana'),
      [
        Produto(nome: 'Brigadeiro', precoCentavos: 250, criadoEm: DateTime(2026)),
      ],
    );

    expect(texto, contains('*Doces da Ana*'));
    expect(texto, contains('• Brigadeiro — R\$ 2,50'));
    expect(texto, contains('WhatsApp: 11 99999-0000'));
    expect(texto, contains('Instagram: @docesdaana'));
  });
}
