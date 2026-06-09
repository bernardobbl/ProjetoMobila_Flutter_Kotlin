# 💰 FinanFlow

> App de finanças pessoais desenvolvido em Flutter para controle de receitas, despesas e visualização de relatórios financeiros.

Projeto acadêmico desenvolvido para a disciplina de **Desenvolvimento Mobile** da **UNIPE** (Prof. Leandro Melo).

---

## 📱 Sobre o Projeto

O **FinanFlow** ajuda o usuário a organizar e visualizar sua vida financeira com uma interface moderna e intuitiva. Permite registrar entradas e saídas, categorizar gastos, acompanhar o saldo em tempo real e visualizar relatórios com gráficos interativos.

**Público-alvo:** Jovens adultos (18–35 anos) — estudantes universitários e profissionais iniciantes que querem ter mais controle financeiro pessoal.

---

## ✨ Funcionalidades

- 🔐 **Autenticação local** — Cadastro e login com persistência de sessão
- 📊 **Dashboard** — Saldo total, resumo mensal e últimas transações
- 💸 **CRUD de transações** — Adicionar, editar (toque no card) e excluir (swipe)
- 🏷️ **Categorias** — 13 categorias pré-definidas com ícones e cores
- 📈 **Relatórios visuais** — Gráfico de pizza por categoria + barras dos últimos 6 meses
- 🌓 **Dark mode** — Toggle no perfil, persiste entre sessões
- ✨ **Splash animada** — Logo com animação elástica + texto deslizante
- 🎯 **Filtros** — Visualizar tudo / só receitas / só despesas
- 🇧🇷 **Localização PT-BR** — Datas, moeda e calendário em português
- 👤 **Modal de perfil** — Toque no card do usuário abre painel com dados e formulário de alteração de senha (verificação da senha antiga + hash seguro SHA-256)
- 📷 **Foto de perfil** — Seleção via câmera ou galeria, armazenada localmente; exibida no card e no modal

---

## 🛠️ Stack Técnica

| Camada | Tecnologia |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider |
| **Banco de dados** | SQLite (sqflite) |
| **Gráficos** | fl_chart |
| **Tipografia** | Google Fonts (Poppins) |
| **Persistência leve** | SharedPreferences |
| **Formatação** | intl (datas e moeda PT-BR) |
| **IDs únicos** | uuid |
| **Seleção de imagem** | image_picker |

---

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point + setup de providers
├── app.dart                     # MaterialApp + AuthGate
├── core/
│   ├── constants/
│   │   └── app_colors.dart      # Paleta de cores
│   ├── theme/
│   │   └── app_theme.dart       # Tema claro/escuro
│   ├── utils/
│   │   └── formatters.dart      # Formatadores de moeda/data
│   └── database/
│       └── database_helper.dart # SQLite + CRUD
├── models/
│   ├── transaction_model.dart
│   ├── category_model.dart
│   └── user_model.dart
├── providers/
│   ├── auth_provider.dart       # Estado de autenticação
│   ├── finance_provider.dart    # Estado financeiro
│   └── theme_provider.dart      # Dark mode
├── shared/
│   └── widgets/                 # Widgets reutilizáveis
└── features/
    ├── splash/                  # Tela de abertura animada
    ├── auth/                    # Login e cadastro
    ├── home/                    # Dashboard
    ├── transactions/            # Lista + formulário
    ├── categories/              # Visualização de categorias
    ├── reports/                 # Gráficos
    └── profile/                 # Perfil e configurações
```

---

## 🚀 Como Rodar

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.3.0)
- Android Studio ou Xcode (para emulador)
- VS Code ou Android Studio (editor)

### Passos

```bash
# 1. Clonar o repositório
git clone https://github.com/bernardobbl/ProjetoMobila_Flutter_Kotlin.git
cd ProjetoMobila_Flutter_Kotlin

# 2. Gerar arquivos de plataforma (Android/iOS)
flutter create . --project-name finanflow --org com.finanflow

# 3. Instalar dependências
flutter pub get

# 4. Rodar o app
flutter run
```

---

## 🎨 Design

**Cores principais:**
- 🔵 **Primária:** `#3D7BFF` (azul vibrante)
- 🌑 **Header hero:** `#091830 → #0D2461 → #1A4CB8` (gradiente azul profundo)
- 🟢 **Receita:** `#1FC8A4` (teal)
- 🔴 **Despesa:** `#F26D6D` (vermelho suave)
- ⚪ **Fundo claro:** `#F4F6FA`
- ⚫ **Fundo escuro:** `#0E1116`

**Estilo:**
- Material Design 3
- Cards com cantos arredondados e sombras sutis
- Card de saldo com gradiente roxo destacado
- Tipografia Poppins
- Navegação inferior com 4 abas: Início, Transações, Relatórios, Perfil

---

## 📋 Telas Implementadas

1. **Splash** — Logo animado com gradiente
2. **Login** — E-mail e senha com validação
3. **Cadastro** — Nome, e-mail, senha e confirmação
4. **Home** — Saldo, resumo do mês, últimas transações
5. **Transações** — Lista filtrável com swipe-to-delete
6. **Nova/Editar Transação** — Modal bottom sheet com formulário
7. **Categorias** — Grid com 13 categorias (8 despesa + 5 receita)
8. **Relatórios** — Gráficos de pizza e barras
9. **Perfil** — Dados do usuário + configurações
10. **Modal de perfil** — Foto de perfil (câmera/galeria), nome, e-mail e alteração de senha

---

## 👥 Equipe

| Membro | Responsabilidade |
|---|---|
| **[Líder do grupo]** | Coordenação, Home/Dashboard, integração final |
| **[Membro 2]** | Banco de dados, models e providers |
| **[Membro 3]** | Autenticação (login/cadastro) e navegação |
| **[Membro 4]** | Tela de Transações e formulário |
| **[Membro 5]** | Relatórios, Categorias e Perfil |

---

## 📝 Status do Desenvolvimento

Veja o [PLAN.md](./PLAN.md) para o roadmap completo e o [PROJETO.md](./PROJETO.md) para o documento acadêmico.

- ✅ Fase 1 — Setup e Estrutura Base
- ✅ Fase 2 — Autenticação
- ✅ Fase 3 — Home / Dashboard
- ✅ Fase 4 — Transações (CRUD completo)
- ✅ Fase 5 — Categorias
- ✅ Fase 6 — Relatórios
- ✅ Fase 7 — Perfil e Configurações
- ✅ Fase 8 — Polimento (splash, dark mode, edição)

---

## 📄 Licença

Projeto acadêmico desenvolvido para fins educacionais — UNIPE, 2026.
