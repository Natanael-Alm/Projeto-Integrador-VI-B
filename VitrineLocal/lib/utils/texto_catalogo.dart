import '../models/empresa.dart';
import '../models/produto.dart';
import 'formatadores.dart';

String montarTextoCatalogo(Empresa? empresa, List<Produto> produtos) {
  final texto = StringBuffer();

  if (empresa != null) {
    texto.writeln('*${empresa.nome}*');
    if (_preenchido(empresa.slogan)) texto.writeln(empresa.slogan);
    texto.writeln();
  }

  texto.writeln('Confira nossos produtos:');
  for (final produto in produtos) {
    texto.writeln('• ${produto.nome} — ${formatarMoeda(produto.precoCentavos)}');
  }

  if (empresa != null) {
    texto.writeln();
    if (_preenchido(empresa.whatsapp)) texto.writeln('WhatsApp: ${empresa.whatsapp}');
    if (_preenchido(empresa.instagram)) {
      texto.writeln('Instagram: @${empresa.instagram!.replaceFirst('@', '')}');
    }
    if (_preenchido(empresa.horarioAtendimento)) {
      texto.writeln('Atendimento: ${empresa.horarioAtendimento}');
    }
  }

  return texto.toString().trim();
}

bool _preenchido(String? valor) => valor != null && valor.trim().isNotEmpty;
