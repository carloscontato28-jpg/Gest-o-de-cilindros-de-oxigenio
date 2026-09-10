# SPEC TÉCNICA DE DESENVOLVIMENTO
## Sistema de Monitoramento de Entregas — Oxigenoterapia Domiciliar
### Prefeitura Municipal de Caieiras

---

## 1. Visão Geral da Arquitetura

Aplicação web **single-page** (SPA leve) executada 100% no cliente, sem backend próprio. Toda a persistência, autenticação e regras de acesso são delegadas ao **Supabase** (PostgreSQL + Row Level Security + Auth). Não há servidor de aplicação, build step, nem gerenciador de pacotes. Todas as dependências são carregadas via CDN.

```
┌─────────────────────────────────────────┐
│           NAVEGADOR (Cliente)           │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │  HTML   │  │  CSS    │  │   JS    │ │
│  │(Alpine) │  │(Tailwind│  │(Vanilla │ │
│  │         │  │ + CDN)  │  │+ Supabase│ │
│  └─────────┘  └─────────┘  └─────────┘ │
│              │                          │
│              ▼ HTTPS                   │
│  ┌─────────────────────────────────┐   │
│  │         SUPABASE (Cloud)        │   │
│  │  PostgreSQL  │  Auth  │  RLS   │   │
│  │  Storage     │  Edge  │  RPC   │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

## 2. Stack Tecnológica

| Camada | Tecnologia | CDN / Origem | Motivo |
|--------|-----------|--------------|--------|
| **Framework UI** | Alpine.js v3 | `cdn.jsdelivr.net` | Reatividade declarativa direto no HTML, sem build, curva de aprendizado zero |
| **Estilização** | Tailwind CSS v3 (CDN) | `cdn.tailwindcss.com` | Utility-first, sem arquivo CSS customizado, responsivo por padrão |
| **Banco / Auth** | Supabase JS v2 | `cdn.jsdelivr.net` | PostgreSQL gratuito, auth embutida, RLS nativa, Storage para arquivos |
| **Tabelas** | Tabulator v5 | `cdn.jsdelivr.net` | Tabelas com filtro, sort, export CSV/Excel, paginação, zero config |
| **Gráficos** | Chart.js v4 | `cdn.jsdelivr.net` | Dashboard com gráficos de barras, linhas e doughnut |
| **Datepicker** | Flatpickr v4 | `cdn.jsdelivr.net` | Seleção de datas com range, tradução pt-BR embutida |
| **Alertas** | SweetAlert2 v11 | `cdn.jsdelivr.net` | Modais bonitos para confirmações, erros e sucesso |
| **Ícones** | Phosphor Icons | `cdn.jsdelivr.net` | Ícones consistentes, leves, estilo moderno |
| **Fonte** | Inter | Google Fonts | Tipografia legível e profissional |

> **Regra de Ouro:** Nenhum `npm install`. Nenhum bundler. Nenhum framework pesado (React, Vue, Angular). Tudo via CDN. Se uma biblioteca sair do ar, o projeto continua funcionando com fallback local.

---

## 3. Estrutura de Arquivos

```
/oxigenoterapia-caieiras/
├── index.html              ← Login
├── app.html                ← Layout principal (SPA shell)
├── css/
│   └── custom.css          ← Apenas overrides mínimos do Tailwind
├── js/
│   ├── config.js           ← URL e chave do Supabase
│   ├── supabase-client.js  ← Singleton do cliente Supabase
│   ├── auth.js             ← Login, logout, controle de sessão
│   ├── router.js           ← Navegação entre views sem recarregar
│   ├── store.js            ← Estado global compartilhado (Alpine)
│   ├── utils.js            ← Helpers: formatDate, formatCPF, maskPhone, toast
│   ├── validators.js       ← Validações de formulário (CPF, datas, obrigatórios)
│   └── modules/
│       ├── pacientes.js    ← CRUD de pacientes
│       ├── entregas.js     ← Registro e listagem de entregas
│       ├── dashboard.js    ← KPIs e gráficos
│       ├── relatorios.js   ← Filtros e exportação
│       └── auditoria.js    ← Logs de alterações
├── components/
│   ├── sidebar.html        ← Menu lateral (include via fetch)
│   ├── header.html         ← Barra superior com usuário logado
│   ├── modal-paciente.html ← Form modal de paciente
│   └── modal-entrega.html  ← Form modal de entrega
└── assets/
    └── logo-prefeitura.png
```

---

## 4. Configuração do Supabase

### 4.1 Variáveis de Ambiente (config.js)

```javascript
// js/config.js
const SUPABASE_URL = 'https://<seu-projeto>.supabase.co';
const SUPABASE_ANON_KEY = '<sua-chave-anon>';
```

> Em produção, estas variáveis podem ser injetadas via script no `<head>` do HTML pelo servidor estático, ou mantidas no arquivo JS (a chave anon é segura para uso público graças ao RLS).

### 4.2 Tabelas (SQL para execução no SQL Editor do Supabase)

```sql
-- ============================================
-- TABELA: pacientes
-- ============================================
create table pacientes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cpf text unique not null,
  endereco text not null,
  numero text,
  complemento text,
  bairro text not null,
  cidade text default 'Caieiras',
  estado text default 'SP',
  cep text,
  telefone text,
  responsavel_nome text,
  responsavel_vinculo text,
  cid text,
  data_ingresso date default current_date,
  ativo boolean default true,
  motivo_inativacao text,
  data_inativacao date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Índices
CREATE INDEX idx_pacientes_cpf ON pacientes(cpf);
CREATE INDEX idx_pacientes_nome ON pacientes USING gin(nome gin_trgm_ops);
CREATE INDEX idx_pacientes_ativo ON pacientes(ativo);

-- Trigger updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pacientes_updated_at
BEFORE UPDATE ON pacientes
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- TABELA: entregas
-- ============================================
create table entregas (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references pacientes(id),
  data_entrega date not null,
  quantidade integer not null check (quantidade > 0 and quantidade <= 10),
  tipo_cilindro text not null check (tipo_cilindro in ('1m³','2m³','3m³','5m³','10m³')),
  numeros_cilindros text[],
  recebedor_nome text not null,
  recebedor_vinculo text not null check (recebedor_vinculo in ('Paciente','Cuidador','Familiar','Vizinho','Outro')),
  comprovante_url text,
  foto_entrega_url text,
  observacoes text,
  registrado_por uuid references auth.users(id),
  origem text not null default 'empresa' check (origem in ('empresa','prefeitura')),
  status_conferencia text default 'pendente' check (status_conferencia in ('pendente','validada','divergente')),
  conferido_por uuid references auth.users(id),
  data_conferencia timestamptz,
  justificativa_divergencia text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

CREATE INDEX idx_entregas_paciente ON entregas(paciente_id);
CREATE INDEX idx_entregas_data ON entregas(data_entrega);
CREATE INDEX idx_entregas_status ON entregas(status_conferencia);
CREATE INDEX idx_entregas_origem ON entregas(origem);

CREATE TRIGGER trg_entregas_updated_at
BEFORE UPDATE ON entregas
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- TABELA: auditoria (log imutável)
-- ============================================
create table auditoria (
  id uuid primary key default gen_random_uuid(),
  tabela text not null,
  registro_id uuid not null,
  acao text not null check (acao in ('INSERT','UPDATE','DELETE')),
  dados_anteriores jsonb,
  dados_novos jsonb,
  usuario_id uuid references auth.users(id),
  usuario_email text,
  ip_address text,
  user_agent text,
  created_at timestamptz default now()
);

CREATE INDEX idx_auditoria_tabela ON auditoria(tabela);
CREATE INDEX idx_auditoria_registro ON auditoria(registro_id);
CREATE INDEX idx_auditoria_data ON auditoria(created_at);

-- ============================================
-- TABELA: perfis (extensão do auth.users)
-- ============================================
create table perfis (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  perfil text not null check (perfil in ('admin','gestor','operador','auditor')),
  ativo boolean default true,
  created_at timestamptz default now()
);

CREATE INDEX idx_perfis_perfil ON perfis(perfil);
```

### 4.3 Row Level Security (RLS)

```sql
-- Habilitar RLS em todas as tabelas
ALTER TABLE pacientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE entregas ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE perfis ENABLE ROW LEVEL SECURITY;

-- Política: perfis (apenas admin lê todos, usuário lê só o próprio)
CREATE POLICY "perfis_select" ON perfis
  FOR SELECT USING (
    auth.uid() = id OR 
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil = 'admin')
  );

-- Política: pacientes (todos os perfis autenticados leem; gestor/admin editam)
CREATE POLICY "pacientes_select" ON pacientes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "pacientes_insert" ON pacientes FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor'))
);
CREATE POLICY "pacientes_update" ON pacientes FOR UPDATE USING (
  EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor'))
);

-- Política: entregas (operador lê/insere; gestor/admin tudo; auditor só leitura)
CREATE POLICY "entregas_select" ON entregas FOR SELECT USING (
  EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor','operador','auditor'))
);
CREATE POLICY "entregas_insert" ON entregas FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor','operador'))
);
CREATE POLICY "entregas_update" ON entregas FOR UPDATE USING (
  EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor'))
);

-- Política: auditoria (apenas admin e auditor leem, ninguém edita)
CREATE POLICY "auditoria_select" ON auditoria FOR SELECT USING (
  EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','auditor'))
);
```

### 4.4 Storage (Bucket para comprovantes)

```sql
-- Criar bucket privado
INSERT INTO storage.buckets (id, name, public) VALUES ('comprovantes', 'comprovantes', false);

-- Política: apenas usuários autenticados podem fazer upload
CREATE POLICY "comprovantes_upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'comprovantes' AND auth.role() = 'authenticated'
  );

CREATE POLICY "comprovantes_select" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'comprovantes' AND auth.role() = 'authenticated'
  );
```

### 4.5 Funções RPC (para lógica complexa no banco)

```sql
-- Detectar duplicidade de entrega nos últimos 7 dias
CREATE OR REPLACE FUNCTION verificar_duplicidade_entrega(
  p_paciente_id uuid,
  p_data_entrega date,
  p_tipo_cilindro text
) RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM entregas
    WHERE paciente_id = p_paciente_id
      AND tipo_cilindro = p_tipo_cilindro
      AND data_entrega BETWEEN p_data_entrega - interval '7 days' AND p_data_entrega
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- KPIs para dashboard
CREATE OR REPLACE FUNCTION kpi_entregas_mes(p_mes int, p_ano int)
RETURNS TABLE(
  total_entregas bigint,
  total_cilindros bigint,
  entregas_prazo bigint,
  entregas_divergentes bigint,
  entregas_pendentes bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::bigint as total_entregas,
    COALESCE(SUM(quantidade), 0)::bigint as total_cilindros,
    COUNT(*) FILTER (WHERE status_conferencia = 'validada')::bigint as entregas_prazo,
    COUNT(*) FILTER (WHERE status_conferencia = 'divergente')::bigint as entregas_divergentes,
    COUNT(*) FILTER (WHERE status_conferencia = 'pendente')::bigint as entregas_pendentes
  FROM entregas
  WHERE EXTRACT(MONTH FROM data_entrega) = p_mes
    AND EXTRACT(YEAR FROM data_entrega) = p_ano;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 5. Módulos de Desenvolvimento

### 5.1 Autenticação (auth.js)

**Funcionalidades:**
- Login com e-mail/senha via Supabase Auth
- Controle de sessão (token JWT renovado automaticamente)
- Redirecionamento por perfil após login
- Logout com limpeza de estado

**Fluxo:**
```
login(email, senha)
  → supabase.auth.signInWithPassword()
  → buscar perfil na tabela perfis
  → redirecionar para app.html
  → inicializar Alpine store com dados do usuário
```

**Regra:** Se o usuário não tiver registro na tabela `perfis`, bloquear acesso com mensagem: *"Usuário sem perfil atribuído. Contate o administrador."*

---

### 5.2 Pacientes (pacientes.js)

**Funcionalidades:**
- Listagem com busca por nome/CPF (Tabulator)
- Cadastro com validação de CPF (algoritmo dos dígitos verificadores)
- Edição e inativação (soft delete com motivo)
- Visualização de histórico de entregas do paciente

**Validações no cliente:**
```javascript
// validators.js
function validarCPF(cpf) {
  cpf = cpf.replace(/\D/g, '');
  if (cpf.length !== 11 || /^(.)(?=\1{10}$)/.test(cpf)) return false;
  // ... algoritmo dos dígitos verificadores
}

function validarTelefone(telefone) {
  return /^\(?(\d{2})\)?[\s-]?(\d{4,5})[\s-]?(\d{4})$/.test(telefone);
}
```

**UI (Alpine + Tailwind):**
```html
<div x-data="pacientesModule()">
  <input x-model="busca" @input.debounce.300ms="carregar()" 
         placeholder="Buscar por nome ou CPF..."
         class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
  <div id="tabela-pacientes"></div> <!-- Tabulator renderiza aqui -->
</div>
```

---

### 5.3 Entregas (entregas.js)

**Funcionalidades:**
- Registro de entrega com vínculo ao paciente (select2-like via Alpine)
- Upload de comprovante para Supabase Storage
- Detecção de duplicidade via RPC `verificar_duplicidade_entrega()`
- Conferência pela prefeitura (mudança de status)
- Listagem com filtros por período, paciente, status

**Fluxo de registro:**
```
1. Selecionar paciente (busca async no Supabase)
2. Preencher data, quantidade, tipo, recebedor
3. Verificar duplicidade → se true, exibir warning (permitir prosseguir com justificativa)
4. Upload de comprovante (opcional, mas recomendado)
5. Inserir no Supabase
6. Registrar na auditoria (trigger automático no banco)
```

**Upload de arquivo:**
```javascript
async function uploadComprovante(file, entregaId) {
  const ext = file.name.split('.').pop();
  const path = `${entregaId}/comprovante_${Date.now()}.${ext}`;
  const { data, error } = await supabase.storage
    .from('comprovantes')
    .upload(path, file, { contentType: file.type });
  if (error) throw error;
  return supabase.storage.from('comprovantes').getPublicUrl(path).data.publicUrl;
}
```

---

### 5.4 Dashboard (dashboard.js)

**Funcionalidades:**
- Cards de KPI (total entregas no mês, pendentes, divergentes)
- Gráfico de entregas por dia (Chart.js — linha)
- Gráfico de entregas por tipo de cilindro (Chart.js — doughnut)
- Gráfico de status de conferência (Chart.js — barra)
- Alertas em tempo real (entregas recentes, divergências)

**Dados:** Consumir via RPC `kpi_entregas_mes()` + queries diretas no Supabase.

```javascript
// Exemplo de inicialização de gráfico
const ctx = document.getElementById('grafico-entregas-dia').getContext('2d');
new Chart(ctx, {
  type: 'line',
  data: { labels: dias, datasets: [{ label: 'Entregas', data: valores }] },
  options: { responsive: true, plugins: { legend: { position: 'top' } } }
});
```

---

### 5.5 Relatórios (relatorios.js)

**Funcionalidades:**
- Filtros por período (Flatpickr range), paciente, status, origem
- Tabela de resultado com Tabulator (filtros inline, sort, paginação)
- Exportação para Excel (Tabulator built-in) e PDF (jsPDF + autoTable via CDN)

**Query base:**
```javascript
let query = supabase
  .from('entregas')
  .select(`
    id, data_entrega, quantidade, tipo_cilindro, 
    recebedor_nome, recebedor_vinculo, status_conferencia, origem,
    pacientes(nome, cpf)
  `)
  .gte('data_entrega', dataInicio)
  .lte('data_entrega', dataFim);

if (pacienteId) query = query.eq('paciente_id', pacienteId);
if (status) query = query.eq('status_conferencia', status);
```

---

### 5.6 Auditoria (auditoria.js)

**Funcionalidades:**
- Visualização de logs (apenas admin e auditor)
- Filtro por tabela, usuário, período, ação
- Diff visual entre dados_anteriores e dados_novos

**Trigger no banco (automático):**
```sql
CREATE OR REPLACE FUNCTION log_auditoria()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO auditoria(tabela, registro_id, acao, dados_anteriores, usuario_id, usuario_email)
    VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', row_to_json(OLD), auth.uid(), auth.email());
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO auditoria(tabela, registro_id, acao, dados_anteriores, dados_novos, usuario_id, usuario_email)
    VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW), auth.uid(), auth.email());
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO auditoria(tabela, registro_id, acao, dados_novos, usuario_id, usuario_email)
    VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', row_to_json(NEW), auth.uid(), auth.email());
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar em pacientes e entregas
CREATE TRIGGER trg_auditoria_pacientes
AFTER INSERT OR UPDATE OR DELETE ON pacientes
FOR EACH ROW EXECUTE FUNCTION log_auditoria();

CREATE TRIGGER trg_auditoria_entregas
AFTER INSERT OR UPDATE OR DELETE ON entregas
FOR EACH ROW EXECUTE FUNCTION log_auditoria();
```

---

## 6. Estado Global (Alpine Store)

```javascript
// store.js — inicializado no app.html
document.addEventListener('alpine:init', () => {
  Alpine.store('app', {
    usuario: null,
    perfil: null,
    paginaAtual: 'dashboard',
    notificacoes: [],

    async init() {
      const { data: { session } } = await supabase.auth.getSession();
      if (session) await this.carregarPerfil(session.user.id);
    },

    async carregarPerfil(userId) {
      const { data } = await supabase.from('perfis').select('*').eq('id', userId).single();
      this.usuario = data;
      this.perfil = data?.perfil;
    },

    temPermissao(...perfis) {
      return perfis.includes(this.perfil);
    },

    navegar(pagina) {
      this.paginaAtual = pagina;
      window.dispatchEvent(new CustomEvent('navegar', { detail: pagina }));
    }
  });
});
```

---

## 7. Navegação SPA (router.js)

```javascript
// router.js — troca de views sem recarregar a página
const views = {
  dashboard: () => import('./modules/dashboard.js'),
  pacientes: () => import('./modules/pacientes.js'),
  entregas: () => import('./modules/entregas.js'),
  relatorios: () => import('./modules/relatorios.js'),
  auditoria: () => import('./modules/auditoria.js')
};

async function navegar(para) {
  const container = document.getElementById('main-content');
  container.innerHTML = '<div class="flex justify-center p-8"><div class="animate-spin h-8 w-8 border-4 border-blue-500 rounded-full border-t-transparent"></div></div>';

  const modulo = await views[para]();
  container.innerHTML = modulo.template; // cada módulo exporta seu HTML
  modulo.init(); // e sua função de inicialização
}
```

> Nota: Dynamic `import()` funciona nativamente em navegadores modernos. Cada módulo é um arquivo `.js` que exporta `template` (string HTML) e `init()` (função de setup).

---

## 8. UI/UX — Padrões Tailwind

### Paleta de Cores

```css
/* custom.css — apenas variáveis e overrides */
:root {
  --primary: #2563eb;      /* blue-600 */
  --primary-dark: #1d4ed8; /* blue-700 */
  --success: #16a34a;      /* green-600 */
  --warning: #ca8a04;      /* yellow-600 */
  --danger: #dc2626;       /* red-600 */
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-800: #1f2937;
}
```

### Componentes Reutilizáveis (HTML snippets)

**Botão primário:**
```html
<button class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors flex items-center gap-2">
  <i class="ph ph-plus"></i> Nova Entrega
</button>
```

**Card de KPI:**
```html
<div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-sm font-medium text-gray-500">Entregas do Mês</p>
      <p class="text-3xl font-bold text-gray-900" x-text="kpi.total"></p>
    </div>
    <div class="p-3 bg-blue-50 rounded-lg">
      <i class="ph ph-package text-2xl text-blue-600"></i>
    </div>
  </div>
</div>
```

**Badge de status:**
```html
<span class="px-2.5 py-0.5 rounded-full text-xs font-medium"
  :class="{
    'bg-green-100 text-green-800': status === 'validada',
    'bg-yellow-100 text-yellow-800': status === 'pendente',
    'bg-red-100 text-red-800': status === 'divergente'
  }"
  x-text="status"></span>
```

---

## 9. Segurança

| Camada | Medida |
|--------|--------|
| **Autenticação** | Supabase Auth com JWT, sessão gerenciada automaticamente |
| **Autorização** | RLS no PostgreSQL — nenhum dado é acessível sem política explícita |
| **Upload** | Bucket privado, apenas autenticados, path por entrega |
| **Dados sensíveis** | CPF mascarado em listagens (mostrar apenas `***.456.789-**`), completo apenas em detalhe |
| **LGPD** | Consentimento registrado no cadastro do paciente; campo `ativo` para anonimização lógica; auditoria completa |
| **HTTPS** | Obrigatório (Supabase já força) |
| **CSP** | Content-Security-Policy no HTML para bloquear scripts inline não autorizados |

---

## 10. Checklist de Entrega do Agente

- [ ] `index.html` com tela de login funcional (redireciona após auth)
- [ ] `app.html` com layout sidebar + header + área de conteúdo dinâmico
- [ ] Todas as tabelas do Supabase criadas com RLS ativo
- [ ] Triggers de auditoria funcionando (INSERT/UPDATE/DELETE logados)
- [ ] Funções RPC `verificar_duplicidade_entrega()` e `kpi_entregas_mes()` criadas
- [ ] Bucket `comprovantes` no Storage com políticas de acesso
- [ ] CRUD de pacientes com busca, validação de CPF e inativação
- [ ] Registro de entregas com upload de comprovante e detecção de duplicidade
- [ ] Dashboard com 4 KPIs e 3 gráficos Chart.js
- [ ] Relatórios com filtros e exportação Excel/PDF
- [ ] Módulo de auditoria com diff visual (admin/auditor)
- [ ] Perfis de usuário: admin, gestor, operador, auditor
- [ ] Responsivo (funciona em desktop e tablet)
- [ ] Todos os formulários com validação cliente + feedback visual
- [ ] Nenhum erro no console do navegador
- [ ] Código comentado em português

---

## 11. Notas para o Agente

1. **Não use frameworks pesados.** Alpine.js + vanilla JS são suficientes. Se sentir vontade de usar React/Vue, respire fundo e lembre-se: este é um projeto de prefeitura, não da NASA.
2. **Supabase é seu backend.** Não invente APIs, não crie servidor Node. Toda a lógica vai no banco (RPC, triggers, RLS).
3. **CDN é lei.** Todas as libs via CDN. Se quiser fallback, baixe o arquivo e coloque em `/vendor/`.
4. **Trate erros do Supabase.** Sempre verifique `error` antes de usar `data`. Exiba mensagens amigáveis via SweetAlert2.
5. **Performance:** Use `.select()` com joins apenas quando necessário. Para listagens grandes, use paginação do Tabulator (server-side ou client-side).
6. **Acessibilidade:** Todo input precisa de `<label>`, botões precisam de `type`, cores não devem ser o único indicador de status.
7. **Não hardcode dados.** Nenhum CPF, nome ou endereço fictício no código. Use dados de teste apenas em ambiente de dev.

---

*SPEC v1.0 — 02/09/2026*
*Stack: HTML + Tailwind CSS + Alpine.js + Vanilla JS + Supabase*
