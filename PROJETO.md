# PLANO DE PROJETO — DESENVOLVIMENTO MOBILE
**Instituição:** UNIPE  
**Disciplina:** Desenvolvimento Mobile  
**Turno:** Tarde  
**Professor:** Leandro Melo  

---

## 4.1 Nome do Projeto

**FinanFlow**

---

## 4.2 Objetivo do Aplicativo

O **FinanFlow** é um aplicativo de finanças pessoais com o objetivo de ajudar o usuário a organizar, controlar e visualizar suas receitas e despesas de forma simples e intuitiva.

**Problema que resolve:** Muitas pessoas têm dificuldade em acompanhar para onde vai o seu dinheiro ao longo do mês. O FinanFlow centraliza todas as movimentações financeiras em um só lugar, permitindo que o usuário tome decisões mais conscientes sobre seu dinheiro.

**Público-alvo:** Jovens adultos (18–35 anos) que desejam ter mais controle financeiro pessoal, como estudantes universitários e profissionais iniciantes.

---

## 4.3 Funcionalidades do Aplicativo

| # | Funcionalidade | Descrição |
|---|---|---|
| 1 | **Cadastro e Login** | O usuário cria uma conta com nome, e-mail e senha. A sessão é mantida entre usos do app. |
| 2 | **Dashboard (Tela Inicial)** | Exibe o saldo total, resumo de receitas e despesas do mês e as últimas transações registradas. |
| 3 | **Registro de Transações** | O usuário registra entradas (receitas) e saídas (despesas) com título, valor, categoria e data. |
| 4 | **Listagem e Filtro de Transações** | Tela dedicada para visualizar todas as transações, com filtro por tipo (tudo, receitas, despesas). |
| 5 | **Exclusão de Transações** | O usuário pode excluir qualquer transação com um gesto de deslizar (swipe to delete) e confirmação. |
| 6 | **Categorias** | Transações são organizadas em categorias (Alimentação, Transporte, Salário, Lazer, etc.) com ícones e cores. |
| 7 | **Relatórios Visuais** | Gráfico de pizza mostrando gastos por categoria e gráfico de barras comparando receitas vs despesas dos últimos 6 meses. |

---

## 4.4 Estrutura de Telas

| Tela | Descrição |
|---|---|
| **Splash Screen** | Tela inicial com logo do app enquanto carrega |
| **Login** | E-mail, senha e botão de login. Link para criar conta |
| **Cadastro** | Nome, e-mail, senha e confirmação de senha |
| **Home / Dashboard** | Saldo total, resumo mensal, últimas transações, botão de adicionar |
| **Transações** | Lista completa de transações com filtro e botão de nova transação |
| **Nova Transação (Modal)** | Formulário em modal: tipo, título, valor, categoria, data |
| **Categorias** | Grid de categorias organizadas por tipo (receita/despesa) |
| **Relatórios** | Gráfico de pizza + gráfico de barras com resumo em texto |
| **Perfil** | Dados do usuário, opções de configuração e logout |

---

## 4.5 Proposta de Layout (UI/UX)

**Cores:**
- **Primária:** Roxo/Índigo (`#6C63FF`) — moderno e profissional
- **Receita:** Verde (`#4CAF50`) — associação positiva
- **Despesa:** Vermelho (`#FF5252`) — atenção para gastos
- **Fundo:** Branco alavancado (`#F0F2FF`)
- **Texto principal:** Quase preto (`#1A1A2E`)

**Estilo Visual:**
- Cards com cantos arredondados e sombras suaves
- Card de saldo com gradiente roxo destacado
- Ícones representativos em cada categoria
- Tipografia Poppins (Google Fonts) — moderna e legível
- Padrão Material Design 3

**Organização:**
- Navegação inferior (Bottom Navigation Bar) com 4 abas: Home, Transações, Relatórios, Perfil
- Botão de ação flutuante (FAB) para adicionar transação rapidamente
- Formulário de nova transação em modal (bottom sheet), sem trocar de tela

---

## 4.6 Tecnologias Utilizadas

**Framework escolhido: Flutter (Dart)**

**Justificativa:**
1. **Produtividade:** Flutter permite desenvolver para Android e iOS com um único código-base
2. **UI Rica:** O sistema de widgets do Flutter facilita criar interfaces bonitas e customizadas
3. **Hot Reload:** Agiliza o desenvolvimento ao mostrar mudanças em tempo real
4. **Mercado:** Flutter é amplamente adotado por empresas brasileiras e tem grande comunidade
5. **Aprendizado:** Dart é uma linguagem simples e tipada, ideal para o nível da disciplina

**Bibliotecas/Dependências:**
| Biblioteca | Uso |
|---|---|
| `provider` | Gerenciamento de estado (dados da sessão e transações) |
| `sqflite` | Banco de dados local SQLite para persistir as transações |
| `fl_chart` | Gráficos interativos (pizza e barras) na tela de relatórios |
| `google_fonts` | Tipografia Poppins moderna |
| `shared_preferences` | Manter sessão do usuário logado |
| `intl` | Formatação de moeda (R$) e datas em português |
| `uuid` | Geração de IDs únicos para cada transação |

---

## 4.7 Divisão de Tarefas

| Membro | Responsabilidade |
|---|---|
| **[Líder do grupo]** | Coordenação geral, tela de Home/Dashboard, integração final |
| **[Membro 2]** | Banco de dados (SQLite), models e providers de estado |
| **[Membro 3]** | Telas de autenticação (Login e Cadastro), navegação |
| **[Membro 4]** | Tela de Transações e formulário de nova transação |
| **[Membro 5]** | Tela de Relatórios (gráficos), Categorias e Perfil |

---

*Projeto desenvolvido para a disciplina de Desenvolvimento Mobile — UNIPE, 2026.*
