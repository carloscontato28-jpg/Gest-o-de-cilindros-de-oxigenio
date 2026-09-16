# PLANO DE TAREFAS DE DESENVOLVIMENTO
## Sistema de Monitoramento de Entregas — Oxigenoterapia Domiciliar
### Prefeitura Municipal de Caieiras

---

## INSTRUÇÕES GERAIS PARA O AGENTE DE IA

### 1. Regras de Conduta

- **Nunca apague código funcional sem autorização.** Se precisar substituir, comente o antigo e explique o motivo no backlog.
- **Sempre registre alterações.** Toda correção, ajuste, refatoração ou mudança de escopo deve ser documentada no arquivo `BACKLOG.md`.
- **Dúvidas = Interação humana.** Se houver ambiguidade, contradição ou falta de informação, pare e solicite esclarecimento. Não invente requisitos.
- **Uma tarefa por vez.** Conclua, teste e valide antes de iniciar a próxima.
- **Teste antes de entregar.** Cada tarefa deve ser testável isoladamente, sem depender de tarefas futuras.

### 2. Regras de UI/UX

- **Interface limpa e profissional.** Sem emojis. Use apenas ícones de bibliotecas (Phosphor Icons).
- **Aproveitamento do espaço da tela.** Evite containers excessivamente estreitos ou centralizados com grandes margens vazias. Use grids e layouts fluidos.
- **Consistência visual.** Mesmas cores, espaçamentos, bordas arredondadas e tipografia em toda a aplicação.
- **Feedback visual imediato.** Loading states, hover effects, focus rings, mensagens de erro/sucesso.
- **Sem poluição visual.** Evite sombras excessivas, gradientes chamativos, animações desnecessárias.
- **Ícones via Phosphor apenas.** `<i class="ph ph-icon-name"></i>`. Nada de emojis, SVGs inline ou imagens de ícone.

### 3. Arquivo de Backlog

Crie e mantenha o arquivo `BACKLOG.md` na raiz do projeto com o seguinte formato:

```markdown
# BACKLOG

## [YYYY-MM-DD HH:MM] — Tarefa X
### Ação: [correção / ajuste / alteração / dúvida]
### Contexto:
[Descreva o que aconteceu ou o que precisa ser decidido]
### Decisão tomada:
[O que foi feito ou o que precisa de aprovação humana]
### Arquivos afetados:
- `caminho/do/arquivo.js`
### Status: [resolvido / pendente / aguardando aprovação]
```

---

## PRINCÍPIOS DE INDEPENDÊNCIA ENTRE TAREFAS

Cada tarefa abaixo foi desenhada para ser **autocontida**. Isso significa:

1. **Contratos explícitos:** Cada tarefa documenta o que espera encontrar no ambiente (funções globais, IDs de elementos, estrutura de dados).
2. **Páginas de teste isoladas:** Toda tarefa que produzir módulo JS deve incluir uma página HTML de teste (`test/tarefa-X.html`) que valida o funcionamento sem depender do restante da aplicação.
3. **Mocks permitidos:** Se uma tarefa precisa de dados que outra tarefa ainda não gerou, use dados mockados no formato correto.
4. **Não quebre o que funciona:** Se uma tarefa precisar alterar algo criado em tarefa anterior, trate como refatoração documentada no backlog.

---

## TAREFAS

---

### TAREFA 1 — Fundação do Supabase
**Independente de:** Nenhuma (primeira tarefa)
**Contrato para tarefas futuras:** Disponibiliza tabelas, RLS, triggers, funções RPC e Storage

#### Escopo
Configurar todo o backend no Supabase via SQL Editor. Nenhum código de frontend nesta tarefa.

#### Entregáveis
1. Script SQL único (`sql/setup_supabase.sql`) contendo:
   - Criação das tabelas: `pacientes`, `entregas`, `auditoria`, `perfis`
   - Índices em todos os campos de busca frequente
   - Trigger `update_updated_at()`
   - Triggers de auditoria `log_auditoria()` aplicados em `pacientes` e `entregas`
   - Funções RPC: `verificar_duplicidade_entrega()`, `kpi_entregas_mes()`
   - Bucket `comprovantes` no Storage
   - Políticas RLS em todas as tabelas e no Storage
2. Print ou log de confirmação de execução bem-sucedida no Supabase SQL Editor
3. Inserção de dados de teste (mínimo 5 pacientes, 10 entregas) via SQL para validação

#### Critérios de Aceite
- [ ] Todas as tabelas criadas sem erro
- [ ] RLS ativo em todas as tabelas
- [ ] Insert de teste bem-sucedido (dados mock inseridos via SQL Editor)
- [ ] Select com usuário anônimo retorna vazio (RLS funcionando)
- [ ] Função RPC `kpi_entregas_mes(9, 2026)` retorna dados coerentes

#### Notas de Independência
Esta tarefa não toca em frontend. As tarefas futuras podem usar os dados de teste inseridos aqui.

---

### TAREFA 2 — Estrutura Base da Aplicação (Shell)
**Independente de:** T1 (usa apenas CDN, não precisa de dados)
**Contrato para tarefas futuras:** Define IDs, classes e convenções de layout

#### Escopo
Criar o esqueleto HTML/CSS/JS que servirá de container para todos os módulos.

#### Entregáveis
1. `index.html` — Tela de login com:
   - Logo da prefeitura (placeholder se não houver imagem)
   - Formulário: e-mail, senha, botão "Entrar"
   - Link "Esqueci minha senha" (placeholder, não precisa funcionar ainda)
   - Layout centralizado, limpo, sem emojis, ícones Phosphor nos inputs
2. `app.html` — Layout principal com:
   - Sidebar fixa à esquerda (colapsável em mobile) com menu de navegação
   - Header com nome do usuário logado e botão de logout
   - Área de conteúdo dinâmico: `<main id="main-content" class="flex-1 p-6 overflow-auto">`
   - Footer mínimo com versão do sistema
   - Todos os imports CDN no `<head>`
3. `css/custom.css` — Overrides mínimos:
   - Variáveis CSS para cores primárias
   - Animação de fade para transições de página
   - Scrollbar estilizada
4. `js/config.js` — Variáveis `SUPABASE_URL` e `SUPABASE_ANON_KEY` (use valores fictícios, com comentário indicando onde inserir os reais)
5. `js/supabase-client.js` — Singleton do cliente Supabase exportado como `window.sb`
6. `js/utils.js` — Helpers:
   - `formatDate(date)` → "DD/MM/YYYY"
   - `formatCPF(cpf)` → "XXX.XXX.XXX-XX"
   - `maskPhone(phone)` → "(XX) XXXXX-XXXX"
   - `toast(message, type)` — notificação visual temporária (sem SweetAlert2 ainda, use div customizada)
7. `js/validators.js` — Validações puras (sem dependência de DOM):
   - `validarCPF(cpf)` — algoritmo completo
   - `validarEmail(email)` — regex simples
   - `validarObrigatorio(valor, nomeCampo)` — retorna string de erro ou null

#### Critérios de Aceite
- [ ] `index.html` abre no navegador e exibe formulário de login visualmente correto
- [ ] `app.html` abre no navegador e exibe sidebar + header + área de conteúdo vazia
- [ ] `utils.js` passa em testes manuais no console do navegador (`formatDate`, `validarCPF`)
- [ ] Layout responsivo: sidebar vira hamburger em telas < 768px
- [ ] Nenhum emoji no código. Ícones Phosphor em todos os botões de ação.

#### Notas de Independência
Não precisa de Supabase configurado. Use credenciais fictícias em `config.js`. A autenticação real vem na Tarefa 4.

---

### TAREFA 3 — Estado Global e Navegação (Router + Store)
**Independente de:** T1, T2
**Contrato para tarefas futuras:** Disponibiliza `Alpine.store('app')` e função `navegar(pagina)`

#### Escopo
Implementar o sistema de estado compartilhado e navegação SPA.

#### Entregáveis
1. `js/store.js` — Alpine Store `app` com:
   - `usuario: null`
   - `perfil: null`
   - `paginaAtual: 'dashboard'`
   - `notificacoes: []`
   - Métodos: `init()`, `carregarPerfil(userId)`, `temPermissao(...perfis)`, `navegar(pagina)`, `addNotificacao(msg, tipo)`
   - Stub de autenticação: método `simularLogin(perfil)` para testes (será substituído na T4)
2. `js/router.js` — Sistema de navegação:
   - Objeto `views` mapeando nomes para URLs de módulos
   - Função `async navegar(para)` que:
     - Atualiza `store.paginaAtual`
     - Limpa `#main-content`
     - Carrega HTML do módulo via `fetch()`
     - Injeta no DOM e executa script de inicialização
   - Fallback: se fetch falhar, exibe mensagem "Módulo em desenvolvimento"
3. `components/sidebar.html` — HTML do menu lateral com links que chamam `navegar()`:
   - Dashboard
   - Pacientes
   - Entregas
   - Relatórios
   - Auditoria (visível apenas se perfil for admin/auditor — use Alpine `x-show`)
4. `components/header.html` — HTML da barra superior
5. Página de teste: `test/router.html` que simula navegação entre views mock

#### Critérios de Aceite
- [ ] Abrir `app.html` e clicar em menu items alterna o conteúdo de `#main-content`
- [ ] Store mantém estado entre navegações (ex: notificações não somem)
- [ ] `store.temPermissao('admin', 'gestor')` retorna true/false corretamente após simular login
- [ ] Navegação funciona sem recarregar a página
- [ ] Ícones Phosphor em todos os itens de menu

#### Notas de Independência
Pode usar `store.simularLogin('gestor')` para testar permissões. Não precisa de Supabase real.

---

### TAREFA 4 — Autenticação (Login, Logout, Controle de Sessão)
**Independente de:** T1 (usa Supabase real), T2, T3
**Contrato para tarefas futuras:** Garante que `store.usuario` e `store.perfil` estejam populados após login

#### Escopo
Conectar o formulário de login ao Supabase Auth e implementar controle de sessão.

#### Entregáveis
1. `js/auth.js` — Módulo com:
   - `async login(email, senha)` — autentica no Supabase, busca perfil na tabela `perfis`, redireciona para `app.html`
   - `async logout()` — encerra sessão, limpa store, redireciona para `index.html`
   - `async verificarSessao()` — executado no load de `app.html`; se não houver sessão, redireciona para login
   - `async recuperarSenha(email)` — placeholder que chama `supabase.auth.resetPasswordForEmail()`
2. Atualização de `index.html` — conectar formulário ao `auth.js`
3. Atualização de `app.html` — adicionar `verificarSessao()` no `x-init` do body
4. Atualização de `store.js` — remover `simularLogin()` e integrar com `auth.js`
5. Inserção de usuários de teste no Supabase (via SQL ou Auth UI):
   - admin@teste.com / senha123 — perfil: admin
   - gestor@teste.com / senha123 — perfil: gestor
   - operador@teste.com / senha123 — perfil: operador
   - auditor@teste.com / senha123 — perfil: auditor

#### Critérios de Aceite
- [ ] Login com credenciais válidas redireciona para `app.html`
- [ ] Login com credenciais inválidas exibe erro amigável (SweetAlert2)
- [ ] Acesso direto a `app.html` sem sessão redireciona para login
- [ ] Logout limpa a sessão e redireciona para login
- [ ] Nome do usuário logado aparece no header
- [ ] Usuário sem perfil na tabela `perfis` recebe mensagem de bloqueio

#### Notas de Independência
Esta é a primeira tarefa que exige Supabase configurado (T1). Pode ser desenvolvida em paralelo com T5, T6, T7 desde que o dev tenha acesso ao Supabase.

---

### TAREFA 5 — Módulo de Pacientes (CRUD completo)
**Independente de:** T1 (dados mock), T2, T3
**Contrato com tarefas futuras:** Espera `window.sb` (Supabase client). Se não existir, usa mock.

#### Escopo
CRUD completo de pacientes com busca, validação e inativação.

#### Entregáveis
1. `js/modules/pacientes.js` — Módulo com:
   - `template` — string HTML da tela completa
   - `init()` — inicializa Tabulator na `#tabela-pacientes`
   - `carregar()` — busca pacientes no Supabase (ou usa mock se `window.sb` não estiver pronto)
   - `salvar(dados)` — insert/update com validação
   - `inativar(id, motivo)` — soft delete
   - `buscar(termo)` — filtro por nome ou CPF
2. `components/modal-paciente.html` — Formulário modal:
   - Campos: nome, CPF, CEP (com busca ViaCEP), endereço, número, complemento, bairro, telefone, responsável, CID, data ingresso
   - Validações em tempo real (CPF, telefone, campos obrigatórios)
   - Botões: Salvar, Cancelar
3. Mock de dados em `js/modules/pacientes.mock.js` — 5 pacientes para teste offline
4. Página de teste: `test/pacientes.html`

#### Critérios de Aceite
- [ ] Listagem renderiza dados (mock ou real) em tabela ordenável e filtrável
- [ ] Busca por nome/CPF funciona em tempo real
- [ ] Modal de cadastro abre, valida e fecha corretamente
- [ ] CPF inválido bloqueia o submit com mensagem clara
- [ ] Inativação exige preenchimento de motivo
- [ ] Layout usa espaço da tela de forma eficiente (tabela wide, sem containers estreitos)
- [ ] Ícones Phosphor em botões de ação (editar, excluir, adicionar)

#### Notas de Independência
Pode ser testado 100% com mock. Quando T1 e T4 estiverem prontos, basta trocar `mockMode = false`.

---

### TAREFA 6 — Módulo de Entregas (Registro e Listagem)
**Independente de:** T1 (dados mock), T2, T3, T5
**Contrato com tarefas futuras:** Espera `window.sb`. Se pacientes não estiverem prontos, usa mock de pacientes.

#### Escopo
Registro de entregas com upload de comprovante, detecção de duplicidade e listagem.

#### Entregáveis
1. `js/modules/entregas.js` — Módulo com:
   - `template` — tela de listagem + botão "Nova Entrega"
   - `init()` — inicializa Tabulator
   - `carregar()` — busca entregas com join em pacientes (ou mock)
   - `registrar(dados, arquivo)` — insert + upload para Storage
   - `conferir(id, status, justificativa)` — gestor valida entrega
2. `components/modal-entrega.html` — Formulário modal:
   - Select de paciente (busca async com debounce)
   - Datepicker (Flatpickr) para data da entrega
   - Select: tipo de cilindro (1m³ a 10m³)
   - Input: quantidade (1-10)
   - Input: recebedor e vínculo
   - Upload: comprovante (obrigatório)
   - Upload opcional: foto da entrega
   - Checkbox: "Confirmo que verifiquei duplicidade"
3. `js/modules/entregas.mock.js` — 10 entregas mockadas vinculadas a pacientes mock
4. Página de teste: `test/entregas.html`

#### Critérios de Aceite
- [ ] Listagem mostra entregas com nome do paciente, data, quantidade, status
- [ ] Filtro por período funciona
- [ ] Modal de nova entrega valida todos os campos
- [ ] Upload de comprovante mostra preview e progresso
- [ ] Se duplicidade detectada (mock ou real), exibe warning amarelo com justificativa
- [ ] Status de conferência muda visualmente (badge colorido: verde/vermelho/amarelo)
- [ ] Ícones Phosphor em todas as ações

#### Notas de Independência
Mock de pacientes incluído no arquivo mock. Quando T5 estiver pronta, o select de pacientes passa a usar dados reais automaticamente.

---

### TAREFA 7 — Dashboard (KPIs e Gráficos)
**Independente de:** T1, T2, T3
**Contrato com tarefas futuras:** Espera dados de entregas. Usa mock se necessário.

#### Escopo
Tela inicial com indicadores visuais e gráficos.

#### Entregáveis
1. `js/modules/dashboard.js` — Módulo com:
   - `template` — grid de cards + área de gráficos
   - `init()` — busca dados e renderiza gráficos
   - Dados via RPC `kpi_entregas_mes()` ou mock
2. Cards de KPI (4 cards em grid 2x2 ou 4 colunas):
   - Total de entregas no mês
   - Entregas validadas
   - Entregas divergentes
   - Entregas pendentes de conferência
3. Gráficos Chart.js:
   - Linha: entregas por dia (últimos 30 dias)
   - Doughnut: entregas por tipo de cilindro
   - Barra: status de conferência
4. Alertas rápidos: lista das 5 entregas mais recentes com link para detalhe
5. `js/modules/dashboard.mock.js` — dados de KPI e série temporal para teste
6. Página de teste: `test/dashboard.html`

#### Critérios de Aceite
- [ ] Cards exibem números grandes e legíveis
- [ ] Gráficos renderizam sem erro com dados mock
- [ ] Gráficos são responsivos (redimensionam com a tela)
- [ ] Cores consistentes: azul para normal, verde para validada, vermelho para divergente, amarelo para pendente
- [ ] Layout usa largura total disponível, sem containers centralizados pequenos
- [ ] Ícones Phosphor nos cards (nunca emojis)

#### Notas de Independência
100% testável com mock. Integração com dados reais é apenas trocar a fonte da função `carregarDados()`.

---

### TAREFA 8 — Relatórios (Filtros e Exportação)
**Independente de:** T1, T2, T3
**Contrato com tarefas futuras:** Espera estrutura de entregas. Usa mock.

#### Escopo
Tela de relatórios com filtros avançados e exportação.

#### Entregáveis
1. `js/modules/relatorios.js` — Módulo com:
   - `template` — área de filtros + tabela + botões de export
   - `init()` — inicializa Tabulator com dados
   - `aplicarFiltros()` — coleta filtros e refaz query
   - `exportarExcel()` — usa built-in do Tabulator
   - `exportarPDF()` — gera PDF com jsPDF + autoTable (via CDN)
2. Filtros:
   - Período: Flatpickr range
   - Paciente: select busca async
   - Status de conferência: multi-select
   - Origem (empresa/prefeitura): select
3. Tabela com colunas: Data, Paciente, CPF, Qtd, Tipo, Recebedor, Status, Origem
4. `js/modules/relatorios.mock.js` — dados para teste
5. Página de teste: `test/relatorios.html`

#### Critérios de Aceite
- [ ] Filtro por período restringe resultados corretamente
- [ ] Exportação Excel gera arquivo .csv abrível no Excel
- [ ] Exportação PDF gera documento formatado com cabeçalho
- [ ] Tabela permite ordenação por qualquer coluna
- [ ] Paginação funciona para grandes volumes
- [ ] Layout usa espaço horizontal eficientemente

#### Notas de Independência
Mock incluso. Funciona sem T6 ou T7.

---

### TAREFA 9 — Módulo de Auditoria (Logs e Diff)
**Independente de:** T1 (requer triggers já criados), T2, T3
**Contrato com tarefas futuras:** Lê tabela `auditoria`. Requer perfil admin/auditor.

#### Escopo
Visualização de logs de auditoria com diff entre versões.

#### Entregáveis
1. `js/modules/auditoria.js` — Módulo com:
   - `template` — filtros + tabela de logs
   - `init()` — busca logs (ou exibe mensagem se sem permissão)
   - `carregar()` — query na tabela `auditoria` com filtros
   - `verDiff(logId)` — modal mostrando antes/depois lado a lado
2. Filtros:
   - Tabela afetada (pacientes, entregas)
   - Usuário (e-mail)
   - Período
   - Ação (INSERT, UPDATE, DELETE)
3. Tabela com: Data/Hora, Usuário, Ação, Tabela, Resumo
4. Modal de diff:
   - Coluna esquerda: `dados_anteriores` (JSON formatado)
   - Coluna direita: `dados_novos` (JSON formatado)
   - Campos alterados destacados em amarelo
5. `js/modules/auditoria.mock.js` — logs mockados
6. Página de teste: `test/auditoria.html`

#### Critérios de Aceite
- [ ] Tabela lista logs em ordem cronológica inversa
- [ ] Filtros por tabela, usuário e ação funcionam
- [ ] Modal de diff destaca campos alterados
- [ ] DELETE mostra apenas coluna "Anterior" (não há "Novo")
- [ ] INSERT mostra apenas coluna "Novo"
- [ ] UPDATE mostra ambas com destaque
- [ ] Usuário sem perfil admin/auditor vê tela de acesso negado

#### Notas de Independência
Requer que os triggers de T1 estejam funcionando para dados reais. Para teste, usa mock. Pode ser desenvolvida em paralelo com T5-T8.

---

### TAREFA 10 — Integração Final e Navegação SPA
**Depende de:** T2, T3, T4, T5, T6, T7, T8, T9 (mas pode ser feita parcialmente)
**Escopo:** Conectar todos os módulos no `app.html` e garantir fluxo completo

#### Entregáveis
1. Atualização de `app.html` para importar todos os módulos
2. Atualização de `js/router.js` para carregar módulos reais (remover mocks)
3. Atualização de `components/sidebar.html` para ativar todos os links
4. Remoção dos stubs e mocks de teste (ou movê-los para `/test/`)
5. Fluxo end-to-end validado:
   - Login → Dashboard → Pacientes → Nova Entrega → Relatório → Auditoria → Logout
6. Página `test/e2e.html` com checklist de validação manual

#### Critérios de Aceite
- [ ] Navegação entre todas as telas funciona sem recarregar
- [ ] Dados persistem no Supabase (testar com refresh de página)
- [ ] Upload de comprovante aparece no Storage do Supabase
- [ ] Auditoria registra ações de pacientes e entregas
- [ ] RLS funciona: operador não acessa auditoria, gestor acessa tudo
- [ ] Nenhum erro no console do navegador durante navegação

---

### TAREFA 11 — Polimento UX, Responsividade e Testes
**Depende de:** T10 (ou pode rodar parcialmente em paralelo)

#### Escopo
Refinamento visual, testes em múltiplos dispositivos e correções.

#### Entregáveis
1. Revisão de todos os modais: foco automático no primeiro campo, ESC fecha, Tab navega
2. Teste responsivo em:
   - Desktop 1920px
   - Desktop 1366px
   - Tablet 768px (modo paisagem)
   - Tablet 768px (modo retrato)
3. Estados de loading em todas as ações async (spinner no botão, overlay na tabela)
4. Mensagens de erro amigáveis para falhas de rede
5. Revisão de contraste e acessibilidade (labels, focus rings, aria-labels)
6. Verificação final: nenhum emoji, apenas ícones Phosphor
7. Revisão de uso de espaço: eliminar containers estreitos, aproveitar largura total

#### Critérios de Aceite
- [ ] Aplicação usável em tablet sem zoom
- [ ] Todos os botões async têm estado de loading
- [ ] Erros de rede exibem toast com mensagem clara
- [ ] Navegação por teclado funciona em todos os formulários
- [ ] Score Lighthouse > 90 em Performance e Acessibilidade

---

### TAREFA 12 — Documentação e Entrega
**Depende de:** T11

#### Escopo
Documentação final do projeto.

#### Entregáveis
1. `README.md` — Instruções de instalação (substituir config.js, rodar SQL, criar usuários)
2. `MANUAL_DO_USUARIO.md` — Guia para gestores e operadores (com prints)
3. `BACKLOG.md` completo com todas as alterações registradas
4. `CHANGELOG.md` — Resumo das funcionalidades entregues
5. Script SQL final consolidado: `sql/setup_final.sql`
6. Lista de todos os arquivos entregues com descrição

#### Critérios de Aceite
- [ ] README permite que um técnico de TI configure o sistema em < 30 min
- [ ] Manual do usuário cobre todas as telas
- [ ] Backlog documenta todas as decisões técnicas

---

## ORDEM SUGERIDA DE EXECUÇÃO

```
FASE 1 (Paralelo máximo)
├── T1: Fundação Supabase
├── T2: Estrutura Base
└── T3: Estado Global e Router

FASE 2 (Paralelo após FASE 1)
├── T4: Autenticação
├── T5: Módulo Pacientes
├── T6: Módulo Entregas
├── T7: Dashboard
├── T8: Relatórios
└── T9: Auditoria

FASE 3 (Sequencial)
├── T10: Integração Final
├── T11: Polimento e Testes
└── T12: Documentação
```

> **Nota:** T5, T6, T7, T8 e T9 podem ser desenvolvidas simultaneamente por agentes diferentes, desde que respeitem os contratos (stubs do `window.sb`, IDs de DOM, formato de dados mock).

---

## CONTRATOS ENTRE TAREFAS

### Contrato 1: Supabase Client
Toda tarefa que precisa do Supabase espera:
```javascript
// Disponível globalmente via js/supabase-client.js
window.sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

### Contrato 2: Área de Conteúdo
Toda tarefa que renderiza uma view injeta HTML em:
```html
<main id="main-content" class="flex-1 p-6 overflow-auto"></main>
```

### Contrato 3: Store Alpine
Toda tarefa que precisa de estado global usa:
```javascript
Alpine.store('app').usuario      // objeto usuário logado
Alpine.store('app').perfil       // 'admin' | 'gestor' | 'operador' | 'auditor'
Alpine.store('app').temPermissao('admin', 'gestor') // boolean
Alpine.store('app').navegar('pagina') // troca de view
```

### Contrato 4: Toast
Toda tarefa que exibe notificação usa:
```javascript
window.toast('Mensagem', 'success' | 'error' | 'warning' | 'info');
```

### Contrato 5: Ícones
Toda tarefa usa Phosphor Icons:
```html
<i class="ph ph-icon-name"></i>
```

---

*Plano de Tarefas v1.0 — 02/09/2026*
