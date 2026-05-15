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

---

## Melhorias Futuras (Backlog)
- [ ] Notificações de alerta de orçamento
- [ ] Transações recorrentes (ex: aluguel mensal)
- [ ] Exportar relatório em PDF
- [ ] Backup em nuvem (Firebase)
- [ ] Autenticação biométrica (fingerprint)
- [ ] Múltiplas moedas
- [ ] Metas financeiras com progresso
- [ ] Widget na tela inicial do celular
- [ ] Skeleton loading (shimmer ao carregar)

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
