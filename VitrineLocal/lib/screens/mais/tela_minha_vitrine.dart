import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/empresa.dart';
import '../../providers/empresa_provider.dart';
import '../../utils/imagens.dart';
import '../../widgets/seletor_foto.dart';
import '../catalogo/compartilhar_catalogo.dart';

class TelaMinhaVitrine extends StatefulWidget {
  const TelaMinhaVitrine({super.key});

  @override
  State<TelaMinhaVitrine> createState() => _TelaMinhaVitrineState();
}

class _TelaMinhaVitrineState extends State<TelaMinhaVitrine> {
  final _formulario = GlobalKey<FormState>();
  late final Empresa? _atual = context.read<EmpresaProvider>().empresa;
  late final _nome = TextEditingController(text: _atual?.nome);
  late final _slogan = TextEditingController(text: _atual?.slogan);
  late final _whatsapp = TextEditingController(text: _atual?.whatsapp);
  late final _instagram = TextEditingController(text: _atual?.instagram);
  late final _horario =
      TextEditingController(text: _atual?.horarioAtendimento);
  late String? _logoSalvo = _atual?.logoPath;
  late String? _logoPath = _logoSalvo;

  @override
  void dispose() {
    if (_logoPath != _logoSalvo) excluirFoto(_logoPath);
    for (final campo in [_nome, _slogan, _whatsapp, _instagram, _horario]) {
      campo.dispose();
    }
    super.dispose();
  }

  String? _opcional(TextEditingController campo) {
    final texto = campo.text.trim();
    return texto.isEmpty ? null : texto;
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;

    final mensageiro = ScaffoldMessenger.of(context);
    await context.read<EmpresaProvider>().salvar(Empresa(
          nome: _nome.text.trim(),
          slogan: _opcional(_slogan),
          whatsapp: _opcional(_whatsapp),
          instagram: _opcional(_instagram),
          horarioAtendimento: _opcional(_horario),
          logoPath: _logoPath,
        ));
    if (_logoSalvo != _logoPath) await excluirFoto(_logoSalvo);
    _logoSalvo = _logoPath;
    mensageiro.showSnackBar(const SnackBar(content: Text('Dados salvos')));
  }

  void _trocarLogo(String caminho) {
    if (_logoPath != _logoSalvo) excluirFoto(_logoPath);
    setState(() => _logoPath = caminho);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha vitrine digital')),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SeletorFoto(
              caminho: _logoPath,
              icone: Icons.storefront_outlined,
              aoAlterar: _trocarLogo,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Nome do negócio'),
              textCapitalization: TextCapitalization.words,
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty ? 'Informe o nome' : null,
            ),
            TextFormField(
              controller: _slogan,
              decoration: const InputDecoration(labelText: 'Slogan'),
              textCapitalization: TextCapitalization.sentences,
            ),
            TextFormField(
              controller: _whatsapp,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _instagram,
              decoration: const InputDecoration(
                labelText: 'Instagram',
                prefixText: '@',
              ),
            ),
            TextFormField(
              controller: _horario,
              decoration: const InputDecoration(
                labelText: 'Horário de atendimento',
                hintText: 'Seg a sex, 9h às 18h',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _salvar, child: const Text('Salvar')),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => compartilharCatalogo(context),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartilhar catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
