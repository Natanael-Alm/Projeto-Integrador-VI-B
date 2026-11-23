# Vitrine

> Aplicativo móvel para pequenos negócios melhorarem a presença digital e tomarem decisões com base em dados — tudo funcionando **offline**, com banco de dados local no próprio celular.

**Projeto Integrador VI-B** · Análise e Desenvolvimento de Sistemas (ADS)
Disciplinas integradas: Ciência dos Dados e Programação para Dispositivos Móveis II
**Etapa 1 — Documentação do projeto**

---

## Integrantes do grupo

| # | Nome completo |
|---|---------------|
| 1 | Erick Alves Kolhrausch |
| 2 | Natanael Almeida de Jesus |


---

## Resumo

O **Vitrine** reúne em um só app três necessidades de um pequeno comerciante: **(1)** um catálogo digital de produtos que pode ser compartilhado com clientes por WhatsApp e redes sociais, **(2)** o registro simples de clientes e pedidos e **(3)** painéis e relatórios que transformam esses registros em informação para decidir (produtos mais vendidos, ticket médio, curva ABC, clientes inativos).

Questão norteadora do projeto: *"Qual aplicativo de celular pode auxiliar no crescimento e inovação dos negócios?"*

## Índice da documentação

| Item da Etapa 1 | Documento |
|---|---|
| 1. Nome do projeto | [01-nome.md](VitrineLocal/docs/01-nome.md) |
| 2. Problema que resolve | [02-problema.md](VitrineLocal/docs/02-problema.md) |
| 3. Público-alvo | [03-publico-alvo.md](VitrineLocal/docs/03-publico-alvo.md) |
| 4. Características do aplicativo | [04-caracteristicas.md](VitrineLocal/docs/04-caracteristicas.md) |
| 5. Modelo ER do banco de dados local | [05-modelo-er.md](VitrineLocal/docs/05-modelo-er.md) |
| 6. Wireframes em alta definição | [06-wireframes.md](VitrineLocal/docs/06-wireframes.md) |
| 7. Tela com o nome dos integrantes | [06-wireframes.md#tela-9--sobre-o-app-integrantes](VitrineLocal/docs/06-wireframes.md#tela-9--sobre-o-app-integrantes) |
| 8. Geração do arquivo APK | [08-geracao-apk.md](VitrineLocal/docs/08-geracao-apk.md) |
| 9. Tecnologias, bibliotecas e linguagens | [09-tecnologias.md](VitrineLocal/docs/09-tecnologias.md) |
| 10. Banco de dados local | [10-banco-local.md](VitrineLocal/docs/10-banco-local.md) |

## Como executar

Pré-requisitos: [Flutter](https://docs.flutter.dev/get-started/install) 3.50 ou superior e Android Studio com o Android SDK (veja [08-geracao-apk.md](VitrineLocal/docs/08-geracao-apk.md)).

```bash
cd VitrineLocal
flutter pub get
flutter run         # emulador ou celular com depuração USB
```

## Andamento

| Módulo | Situação |
|---|---|
| Base: banco SQLite, navegação, tema | Concluído |
| Catálogo (RF01–RF06) e Sobre (RF20) | Concluído |
| Clientes e Pedidos (RF07–RF12) | Concluído |
| Painel e Relatórios (RF13–RF19) | Concluído |

## Estrutura do repositório

```
.
├── README.md
└── VitrineLocal/
    ├── README.md
    ├── pubspec.yaml
    ├── lib/              código do aplicativo (ver 10-banco-local.md)
    ├── android/          projeto Android gerado pelo Flutter
    ├── docs/
    │   ├── 01-nome.md
    │   ├── 02-problema.md
    │   ├── 03-publico-alvo.md
    │   ├── 04-caracteristicas.md
    │   ├── 05-modelo-er.md
    │   ├── 06-wireframes.md       (itens 6 e 7)
    │   ├── 08-geracao-apk.md
    │   ├── 09-tecnologias.md
    │   └── 10-banco-local.md
    └── wireframes/
        ├── 01-dashboard.png  (e .svg)
        ├── ...
        └── 09-sobre-integrantes.png (e .svg)
```
