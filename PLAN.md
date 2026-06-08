# FinanFlow — Plano de Desenvolvimento

## Visão Geral
App de finanças pessoais em Flutter com controle de receitas, despesas, categorias e relatórios visuais.

## Stack
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Banco de dados:** SQLite (sqflite)
- **Gráficos:** fl_chart
- **Fontes:** Google Fonts (Poppins)

---

## Fases de Desenvolvimento

### ✅ Fase 1 — Setup e Estrutura Base
- [x] Estrutura de pastas do projeto
- [x] pubspec.yaml com dependências
- [x] Sistema de cores e tema (Material 3)
- [x] Banco de dados SQLite (DatabaseHelper) com categorias padrão
- [x] Modelos de dados (Transaction, Category, User)
- [x] Providers de estado (AuthProvider, FinanceProvider)
- [x] Widgets compartilhados (CustomButton, CustomTextField)
- [x] Navegação principal (MainScaffold com BottomNavigationBar)

### ✅ Fase 2 — Autenticação
- [x] Tela de Login com validação
- [x] Tela de Cadastro
- [x] Persistência de sessão (SharedPreferences)
- [x] Logout

### ✅ Fase 3 — Home / Dashboard
- [x] Card de saldo total com gradiente
- [x] Resumo do mês (receitas vs despesas)
- [x] Lista das últimas 5 transações
- [x] Botão de ação rápida (FAB)

### ✅ Fase 4 — Transações
- [x] Listagem com filtro (Tudo / Receitas / Despesas)
- [x] Formulário de nova transação (bottom sheet)
- [x] Seleção de data
- [x] Seleção de categoria
- [x] Exclusão com confirmação (swipe to delete)

### ✅ Fase 5 — Categorias
- [x] Listagem com ícones e cores personalizadas
- [x] Categorias padrão (Alimentação, Transporte, Salário, etc.)
- [x] Separadas por tipo (receita / despesa)

### ✅ Fase 6 — Relatórios
- [x] Gráfico de pizza (gastos por categoria)
- [x] Gráfico de barras (receitas vs despesas dos últimos 6 meses)
- [x] Resumo financeiro do mês atual

### ✅ Fase 7 — Perfil e Configurações
- [x] Informações do usuário logado
- [x] Botão de sair (logout)
- [x] Créditos do app

### ✅ Fase 8 — Polimento Final
- [x] Splash screen animada (logo com scale + fade, texto com slide)
- [x] Transição suave da splash para o app (FadeTransition)
- [x] Contador animado no card de saldo (TweenAnimationBuilder)
- [x] Dark mode completo (ThemeProvider + AppTheme.darkTheme)
- [x] Edição de transação (tap no card abre formulário preenchido)
- [x] AuthGate para roteamento automático em login/logout
- [x] Correção de bugs: icon_code → icon_name, generate:true, locale pt_BR

### ✅ Fase 9 — Revisão de Qualidade (QA) e Correções
*Revisão completa do código realizada antes da entrega.*

- [x] **Correção de teste quebrado:** `test/widget_test.dart` ainda era o template
      padrão do Flutter (testava um contador e a classe `MyApp`, que não existem
      no projeto). Rodar `flutter test` falhava na compilação. Foi substituído por
      testes reais que cobrem a serialização dos modelos (`TransactionModel`,
      `CategoryModel`) e o widget `CustomButton`.
- [x] **Correção de bug no parser de valores:** o campo "Valor" rejeitava entradas
      no formato brasileiro com separador de milhar (ex.: `1.500,00`). Foi criado o
      helper `Formatters.parseAmount()`, que trata o ponto como separador de milhar
      e a vírgula como separador decimal, eliminando a lógica duplicada que existia
      no validador e no salvamento.

### ✅ Fase 10 — Melhorias Nível 1 e Nível 2 implementadas

**Nível 1 — Qualidade e segurança**
- [x] **Senha com hash + salt (SHA-256):** novo `PasswordHasher` (pacote `crypto`).
      As senhas deixam de ser gravadas em texto puro. Contas antigas continuam
      funcionando: no primeiro login a senha é migrada automaticamente para hash.
- [x] **Mensagens de erro amigáveis** no cadastro/login (sem expor detalhes técnicos).
- [x] **Validação de e-mail robusta no login** (mesmo `RegExp` do cadastro).
- [x] **Feedback visual** de sucesso/erro com SnackBars padronizados (`AppSnackbar`).
- [x] **Mais testes automatizados:** hash de senha, parser de valores e modelos
      (`BudgetModel`, `RecurringModel`, `CategoryModel`, `UserModel`).

**Nível 2 — Novas funcionalidades**
- [x] **Categorias personalizadas:** criar, editar e excluir categorias (com seletor
      de ícone e cor). Categorias padrão são protegidas e não se exclui categoria em uso.
- [x] **Orçamento mensal** com barra de progresso colorida (verde/laranja/vermelho)
      na tela de Relatórios.
- [x] **Filtro por período (mês a mês)** nos Relatórios e nas Transações.
- [x] **Busca por título** na tela de Transações.
- [x] **Exportar transações em CSV** e compartilhar (`path_provider` + `share_plus`).
- [x] **Transações recorrentes:** regras mensais (ex.: aluguel, salário) que geram
      lançamentos automaticamente a cada abertura do app.

> Schema do banco migrado para a **versão 2** com `onUpgrade` — quem já tinha o app
> instalado mantém todos os dados; apenas as novas colunas/tabelas são adicionadas.

---

## Pontos Fortes do Projeto (para destacar na apresentação)
Vale a pena ressaltar estes aspectos ao professor, pois mostram cuidado de engenharia:

- **Arquitetura em camadas e por features:** separação clara entre `core`
  (tema, banco, utils), `models`, `providers` (estado) e `features` (cada tela em
  sua pasta). Facilita manutenção e mostra organização profissional.
- **State management com Provider + `ChangeNotifier`:** UI reativa, sem `setState`
  espalhado pela lógica de negócio.
- **Persistência local com SQLite** (sqflite), incluindo chaves estrangeiras e
  categorias padrão inseridas na criação do banco.
- **Suporte multiplataforma real:** o app roda em Android, iOS, Web e Desktop
  (a `main.dart` configura o `databaseFactory` correto para Web vs. nativo).
- **Material 3 + tema claro/escuro completo**, com tipografia Poppins (Google Fonts).
- **Internacionalização pt-BR:** moeda (R$), datas por extenso e meses em português.
- **Boas práticas de UI:** `IndexedStack` preserva o estado das abas, animações
  suaves (splash, contador de saldo), e tratamento de estados vazios em todas as listas.

---

## Melhorias Recomendadas (priorizadas)
Sugestões de evolução, ordenadas por impacto x esforço. As do "Nível 1" são as que
mais agregam valor técnico para a entrega.

### 🔴 Nível 1 — Alto impacto (✅ IMPLEMENTADO — ver Fase 10)
- [x] **Segurança: senha com hash (SHA-256 + salt)** via `crypto`, com migração
      automática de contas antigas.
- [x] **Mensagens de erro amigáveis** no cadastro e login.
- [x] **Validação de e-mail mais robusta no login** (mesmo `RegExp` do cadastro).
- [x] **Mais testes automatizados** (hash, formatadores e modelos).
- [x] **Feedback de sucesso ao salvar/excluir** (SnackBar de confirmação).

### 🟡 Nível 2 — Funcionalidades (✅ IMPLEMENTADO — ver Fase 10)
- [x] Criação, edição e exclusão de **categorias personalizadas**.
- [x] **Orçamento mensal** com barra de progresso.
- [x] **Filtro por período** (mês a mês) nas transações e relatórios.
- [x] **Busca** por título de transação.
- [x] **Exportar transações em CSV** (com compartilhamento).
- [x] **Transações recorrentes** (ex.: aluguel, salário mensal).

### 🟢 Nível 3 — Polimento e escala (backlog)
- [ ] Notificações de alerta de orçamento.
- [ ] Backup em nuvem (Firebase) e sincronização entre dispositivos.
- [ ] Autenticação biométrica (impressão digital).
- [ ] Múltiplas moedas.
- [ ] Skeleton loading (shimmer ao carregar).
- [ ] Widget na tela inicial do celular.
- [ ] Internacionalização para outros idiomas (en, es).

---

## Como Rodar o Projeto

### 1. Instalar Flutter
```
https://docs.flutter.dev/get-started/install
```

### 2. Configurar o projeto
```bash
# Na pasta do projeto:
flutter create . --project-name finanflow --org com.finanflow
flutter pub get
flutter run
```

> Os arquivos em `lib/` já estão implementados — o `flutter create .` apenas gerará
> os arquivos de plataforma (Android/iOS) sem sobrescrever o código existente.
