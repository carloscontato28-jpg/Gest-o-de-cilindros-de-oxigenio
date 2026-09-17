# Plano de Programação: Oxigenoterapia Caieiras

Baseado na especificação (`SPEC_Dev_Oxigenoterapia_Caieiras.md`), nas tarefas (`TAREFAS_Dev_Oxigenoterapia_Caieiras.md`) e nas interfaces geradas pelo Google Stitch na pasta `Theme`, este é o plano detalhado de execução para construir a aplicação.

## 1. Arquitetura e Configuração Inicial (SPA Vanilla)
A aplicação não terá build step (sem Node.js, Webpack ou Vite). Será um SPA (Single Page Application) servido via arquivos estáticos.

**Ações:**
- Criar a estrutura base de pastas: `css/`, `js/`, `js/services/`.
- Criar o `index.html` raiz.
- Importar via CDN: Tailwind CSS, Alpine.js (defer), e Supabase JS.
- Configurar as variáveis do Tailwind (`tailwind.config`) no `<head>` usando a extração dos arquivos `Theme/*/code.html`.

## 2. Integração do App Shell (Layout Base)
As interfaces do Google Stitch possuem um menu lateral (Sidebar) e um cabeçalho (Header) consistentes.

**Ações:**
- Extrair a `<aside>` (Menu Lateral) e o `<header>` (Barra Superior) de um dos arquivos do tema (ex: `Theme/dashboard_de_monitoramento_oxigenoterapia_caieiras/code.html`).
- Colar no `index.html`.
- Implementar um sistema de roteamento simples no `index.html` usando Alpine.js no `<body>`: `x-data="{ currentRoute: 'dashboard' }"`.
- Envolver as áreas de conteúdo principal (`<main>`) com `<template x-if="currentRoute === 'modulo'">`.
- Tornar os links do menu responsivos, alterando o valor de `currentRoute` ao serem clicados.

## 3. Configuração do Backend (Supabase)
O projeto depende do Supabase para banco de dados e autenticação.
(Credenciais fornecidas: URL: `https://lejngceikccqvbithqeb.supabase.co`, Key: `sb_publishable_Nq6F6m9djpW2eU8l2fDHfA_LYSRUg2t`)

**Ações:**
- Criar `js/supabase.js` contendo a inicialização do client Supabase (`window.supabaseClient = supabase.createClient('https://lejngceikccqvbithqeb.supabase.co', 'sb_publishable_Nq6F6m9djpW2eU8l2fDHfA_LYSRUg2t')`).
- Executar o script `Specs/esquema_supabase_oxigenoterapia.sql` no painel do Supabase para criar as tabelas, RLS e funções.
- Criar serviços modulares (`js/services/auth.js`, `js/services/pacientes.js`, etc.) para encapsular as chamadas ao banco.

## 4. Implementação dos Módulos (Integração de Temas + Lógica)

Para cada módulo, o processo será:
1.  **Extração**: Copiar a tag `<main>` (ou o conteúdo dentro dela) e modais do arquivo `code.html` correspondente na pasta `Theme/`.
2.  **Injeção**: Colar no `index.html` dentro do seu respectivo `<template x-if="...">`.
3.  **Dinamização (Alpine.js)**: Substituir dados mockados estáticos por variáveis Alpine (`x-text`, `x-for`, `x-model`).
4.  **Integração (Supabase)**: Conectar funções do Alpine às chamadas dos serviços JS.

### 4.1. Módulo: Dashboard (Visão Geral)
- **Fonte do Tema**: `Theme/dashboard_de_monitoramento_oxigenoterapia_caieiras/code.html`
- **Ações**:
  - Extrair os cards de métricas (Entregas, Volume, Conformidade, Divergências).
  - Extrair o gráfico de Evolução Diária.
  - Extrair a lista de Entregas Recentes e Alertas Ativos.
  - Criar um controlador Alpine (`x-data="dashboardController()"`) em `js/controllers/dashboard.js` para buscar os dados sumarizados do Supabase e popular a tela.

### 4.2. Módulo: Pacientes
- **Fonte do Tema**: `Theme/gest_o_de_pacientes_oxigenoterapia_caieiras/code.html`
- **Ações**:
  - Extrair a tabela de listagem de pacientes.
  - Extrair a barra lateral (slide-over) de Detalhes do Paciente e o Modal de Novo Paciente.
  - Lógica Alpine para paginação, busca e filtros.
  - Conectar ao Supabase: CRUD completo na tabela `pacientes` e histórico em `historico_clinico`.

### 4.3. Módulo: Entregas (Registro e Conferência)
- **Fonte do Tema**: `Theme/registro_e_confer_ncia_de_entregas_caieiras/code.html`
- **Ações**:
  - Extrair a listagem de registros de abastecimento.
  - Extrair o modal/formulário de "Nova Entrega".
  - Criar fluxo de validação e alertas (ex: duplicidade em curto espaço de tempo).
  - Conectar ao Supabase: Inserção na tabela `entregas`, alterando status de conformidade conforme os testes propostos pela especificação.

### 4.4. Módulo: Auditoria e Governança (RLS)
- **Fonte do Tema**: `Theme/auditoria_e_governan_a_oxigenoterapia_caieiras/code.html`
- **Ações**:
  - Extrair a visualização de trilha de auditoria (Logs).
  - Garantir que esta visualização reflita os registros gerados pela tabela `auditoria_logs` populada pelos triggers no Supabase.

## 5. Refinamento e UX
- Ajustar transições, tooltips e spinners de loading utilizando propriedades do Alpine.js (`x-transition`, `x-show="isLoading"`).
- Testar a responsividade das tabelas e modais gerados pelo Stitch em dispositivos móveis.
- Revisar a aplicação do Design System (`Theme/oxig_nio_domiciliar_caieiras/DESIGN.md`) nos componentes integrados.
