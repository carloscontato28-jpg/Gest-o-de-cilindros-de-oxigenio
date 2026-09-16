-- ============================================================
-- ESQUEMA SQL COMPLETO — SUPABASE
-- Sistema de Monitoramento de Entregas — Oxigenoterapia Domiciliar
-- Prefeitura Municipal de Caieiras
-- Execute no SQL Editor do Supabase (Dashboard > SQL Editor > New query)
-- ============================================================

-- ============================================================
-- 1. EXTENSÕES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pg_trgm";      -- Busca por similaridade de texto (índice GIN em nomes)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";    -- Geração de UUIDs

-- ============================================================
-- 2. TABELA: PACIENTES
-- ============================================================
CREATE TABLE IF NOT EXISTS pacientes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome            TEXT NOT NULL,
  cpf             TEXT UNIQUE NOT NULL,
  cep             TEXT,
  endereco        TEXT NOT NULL,
  numero          TEXT,
  complemento     TEXT,
  bairro          TEXT NOT NULL,
  cidade          TEXT DEFAULT 'Caieiras',
  estado          TEXT DEFAULT 'SP',
  telefone        TEXT,
  responsavel_nome      TEXT,
  responsavel_vinculo   TEXT,
  cid             TEXT,
  data_ingresso   DATE DEFAULT CURRENT_DATE,
  ativo           BOOLEAN DEFAULT TRUE,
  motivo_inativacao     TEXT,
  data_inativacao       DATE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_pacientes_cpf    ON pacientes(cpf);
CREATE INDEX IF NOT EXISTS idx_pacientes_ativo  ON pacientes(ativo);
CREATE INDEX IF NOT EXISTS idx_pacientes_nome   ON pacientes USING gin(nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_pacientes_data   ON pacientes(data_ingresso);

-- ============================================================
-- 3. TABELA: ENTREGAS
-- ============================================================
CREATE TABLE IF NOT EXISTS entregas (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id           UUID NOT NULL REFERENCES pacientes(id) ON DELETE RESTRICT,
  data_entrega          DATE NOT NULL,
  quantidade            INTEGER NOT NULL CHECK (quantidade > 0 AND quantidade <= 10),
  tipo_cilindro         TEXT NOT NULL CHECK (tipo_cilindro IN ('1m³','2m³','3m³','5m³','10m³')),
  numeros_cilindros     TEXT[],
  recebedor_nome        TEXT NOT NULL,
  recebedor_vinculo     TEXT NOT NULL CHECK (recebedor_vinculo IN ('Paciente','Cuidador','Familiar','Vizinho','Outro')),
  comprovante_url       TEXT,
  foto_entrega_url      TEXT,
  observacoes           TEXT,
  registrado_por        UUID REFERENCES auth.users(id),
  origem                TEXT NOT NULL DEFAULT 'empresa' CHECK (origem IN ('empresa','prefeitura')),
  status_conferencia    TEXT DEFAULT 'pendente' CHECK (status_conferencia IN ('pendente','validada','divergente')),
  conferido_por         UUID REFERENCES auth.users(id),
  data_conferencia      TIMESTAMPTZ,
  justificativa_divergencia TEXT,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_entregas_paciente    ON entregas(paciente_id);
CREATE INDEX IF NOT EXISTS idx_entregas_data        ON entregas(data_entrega);
CREATE INDEX IF NOT EXISTS idx_entregas_status      ON entregas(status_conferencia);
CREATE INDEX IF NOT EXISTS idx_entregas_origem      ON entregas(origem);
CREATE INDEX IF NOT EXISTS idx_entregas_registrador ON entregas(registrado_por);

-- ============================================================
-- 4. TABELA: PERFIS (extensão do auth.users)
-- ============================================================
CREATE TABLE IF NOT EXISTS perfis (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome        TEXT NOT NULL,
  perfil      TEXT NOT NULL CHECK (perfil IN ('admin','gestor','operador','auditor')),
  ativo       BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_perfis_perfil ON perfis(perfil);
CREATE INDEX IF NOT EXISTS idx_perfis_ativo  ON perfis(ativo);

-- ============================================================
-- 5. TABELA: AUDITORIA (log imutável)
-- ============================================================
CREATE TABLE IF NOT EXISTS auditoria (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tabela          TEXT NOT NULL,
  registro_id     UUID NOT NULL,
  acao            TEXT NOT NULL CHECK (acao IN ('INSERT','UPDATE','DELETE')),
  dados_anteriores    JSONB,
  dados_novos         JSONB,
  usuario_id      UUID REFERENCES auth.users(id),
  usuario_email   TEXT,
  ip_address      TEXT,
  user_agent      TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_auditoria_tabela     ON auditoria(tabela);
CREATE INDEX IF NOT EXISTS idx_auditoria_registro   ON auditoria(registro_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_data       ON auditoria(created_at);
CREATE INDEX IF NOT EXISTS idx_auditoria_usuario    ON auditoria(usuario_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_acao       ON auditoria(acao);

-- ============================================================
-- 6. FUNÇÃO: ATUALIZAR updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers updated_at
DROP TRIGGER IF EXISTS trg_pacientes_updated_at ON pacientes;
CREATE TRIGGER trg_pacientes_updated_at
  BEFORE UPDATE ON pacientes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_entregas_updated_at ON entregas;
CREATE TRIGGER trg_entregas_updated_at
  BEFORE UPDATE ON entregas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 7. FUNÇÃO: LOG DE AUDITORIA
-- ============================================================
CREATE OR REPLACE FUNCTION log_auditoria()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO auditoria(
      tabela, registro_id, acao, dados_anteriores,
      usuario_id, usuario_email, ip_address, user_agent
    ) VALUES (
      TG_TABLE_NAME, OLD.id, 'DELETE', row_to_json(OLD),
      auth.uid(), auth.email(),
      current_setting('request.headers', true)::json->>'x-forwarded-for',
      current_setting('request.headers', true)::json->>'user-agent'
    );
    RETURN OLD;

  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO auditoria(
      tabela, registro_id, acao, dados_anteriores, dados_novos,
      usuario_id, usuario_email, ip_address, user_agent
    ) VALUES (
      TG_TABLE_NAME, NEW.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW),
      auth.uid(), auth.email(),
      current_setting('request.headers', true)::json->>'x-forwarded-for',
      current_setting('request.headers', true)::json->>'user-agent'
    );
    RETURN NEW;

  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO auditoria(
      tabela, registro_id, acao, dados_novos,
      usuario_id, usuario_email, ip_address, user_agent
    ) VALUES (
      TG_TABLE_NAME, NEW.id, 'INSERT', row_to_json(NEW),
      auth.uid(), auth.email(),
      current_setting('request.headers', true)::json->>'x-forwarded-for',
      current_setting('request.headers', true)::json->>'user-agent'
    );
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers de auditoria
DROP TRIGGER IF EXISTS trg_auditoria_pacientes ON pacientes;
CREATE TRIGGER trg_auditoria_pacientes
  AFTER INSERT OR UPDATE OR DELETE ON pacientes
  FOR EACH ROW EXECUTE FUNCTION log_auditoria();

DROP TRIGGER IF EXISTS trg_auditoria_entregas ON entregas;
CREATE TRIGGER trg_auditoria_entregas
  AFTER INSERT OR UPDATE OR DELETE ON entregas
  FOR EACH ROW EXECUTE FUNCTION log_auditoria();

-- ============================================================
-- 8. FUNÇÕES RPC
-- ============================================================

-- 8.1 Verificar duplicidade de entrega nos últimos 7 dias
CREATE OR REPLACE FUNCTION verificar_duplicidade_entrega(
  p_paciente_id UUID,
  p_data_entrega DATE,
  p_tipo_cilindro TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM entregas
    WHERE paciente_id = p_paciente_id
      AND tipo_cilindro = p_tipo_cilindro
      AND data_entrega BETWEEN p_data_entrega - INTERVAL '7 days' AND p_data_entrega
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8.2 KPIs do dashboard por mês/ano
CREATE OR REPLACE FUNCTION kpi_entregas_mes(
  p_mes INTEGER,
  p_ano INTEGER
) RETURNS TABLE(
  total_entregas      BIGINT,
  total_cilindros     BIGINT,
  entregas_validadas  BIGINT,
  entregas_divergentes BIGINT,
  entregas_pendentes  BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::BIGINT AS total_entregas,
    COALESCE(SUM(quantidade), 0)::BIGINT AS total_cilindros,
    COUNT(*) FILTER (WHERE status_conferencia = 'validada')::BIGINT AS entregas_validadas,
    COUNT(*) FILTER (WHERE status_conferencia = 'divergente')::BIGINT AS entregas_divergentes,
    COUNT(*) FILTER (WHERE status_conferencia = 'pendente')::BIGINT AS entregas_pendentes
  FROM entregas
  WHERE EXTRACT(MONTH FROM data_entrega) = p_mes
    AND EXTRACT(YEAR FROM data_entrega) = p_ano;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8.3 Listar entregas com dados do paciente (evita múltiplas queries no cliente)
CREATE OR REPLACE FUNCTION listar_entregas_com_paciente(
  p_data_inicio DATE DEFAULT NULL,
  p_data_fim    DATE DEFAULT NULL,
  p_paciente_id UUID DEFAULT NULL,
  p_status      TEXT DEFAULT NULL
) RETURNS TABLE(
  id                UUID,
  data_entrega      DATE,
  quantidade        INTEGER,
  tipo_cilindro     TEXT,
  recebedor_nome    TEXT,
  recebedor_vinculo TEXT,
  status_conferencia TEXT,
  origem            TEXT,
  observacoes       TEXT,
  created_at        TIMESTAMPTZ,
  paciente_nome     TEXT,
  paciente_cpf      TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.id,
    e.data_entrega,
    e.quantidade,
    e.tipo_cilindro,
    e.recebedor_nome,
    e.recebedor_vinculo,
    e.status_conferencia,
    e.origem,
    e.observacoes,
    e.created_at,
    p.nome AS paciente_nome,
    p.cpf AS paciente_cpf
  FROM entregas e
  JOIN pacientes p ON p.id = e.paciente_id
  WHERE (p_data_inicio IS NULL OR e.data_entrega >= p_data_inicio)
    AND (p_data_fim IS NULL OR e.data_entrega <= p_data_fim)
    AND (p_paciente_id IS NULL OR e.paciente_id = p_paciente_id)
    AND (p_status IS NULL OR e.status_conferencia = p_status)
  ORDER BY e.data_entrega DESC, e.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8.4 Resumo de entregas por paciente (para relatórios)
CREATE OR REPLACE FUNCTION resumo_entregas_por_paciente(
  p_data_inicio DATE,
  p_data_fim    DATE
) RETURNS TABLE(
  paciente_id       UUID,
  paciente_nome     TEXT,
  paciente_cpf      TEXT,
  total_entregas    BIGINT,
  total_cilindros   BIGINT,
  ultima_entrega    DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id AS paciente_id,
    p.nome AS paciente_nome,
    p.cpf AS paciente_cpf,
    COUNT(e.id)::BIGINT AS total_entregas,
    COALESCE(SUM(e.quantidade), 0)::BIGINT AS total_cilindros,
    MAX(e.data_entrega) AS ultima_entrega
  FROM pacientes p
  LEFT JOIN entregas e ON e.paciente_id = p.id
    AND e.data_entrega BETWEEN p_data_inicio AND p_data_fim
  WHERE p.ativo = TRUE
  GROUP BY p.id, p.nome, p.cpf
  ORDER BY total_entregas DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 9. ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Habilitar RLS
ALTER TABLE pacientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE entregas ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE perfis ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas (se reexecutar o script)
DROP POLICY IF EXISTS perfis_select ON perfis;
DROP POLICY IF EXISTS perfis_insert ON perfis;
DROP POLICY IF EXISTS perfis_update ON perfis;
DROP POLICY IF EXISTS perfis_delete ON perfis;

DROP POLICY IF EXISTS pacientes_select ON pacientes;
DROP POLICY IF EXISTS pacientes_insert ON pacientes;
DROP POLICY IF EXISTS pacientes_update ON pacientes;
DROP POLICY IF EXISTS pacientes_delete ON pacientes;

DROP POLICY IF EXISTS entregas_select ON entregas;
DROP POLICY IF EXISTS entregas_insert ON entregas;
DROP POLICY IF EXISTS entregas_update ON entregas;
DROP POLICY IF EXISTS entregas_delete ON entregas;

DROP POLICY IF EXISTS auditoria_select ON auditoria;

-- 9.1 Políticas: PERFIS
CREATE POLICY perfis_select ON perfis
  FOR SELECT USING (
    auth.uid() = id
    OR EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil = 'admin')
  );

CREATE POLICY perfis_insert ON perfis
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil = 'admin')
  );

CREATE POLICY perfis_update ON perfis
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil = 'admin')
  );

-- 9.2 Políticas: PACIENTES
CREATE POLICY pacientes_select ON pacientes
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY pacientes_insert ON pacientes
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor'))
  );

CREATE POLICY pacientes_update ON pacientes
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor'))
  );

-- 9.3 Políticas: ENTREGAS
CREATE POLICY entregas_select ON entregas
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor','operador','auditor'))
  );

CREATE POLICY entregas_insert ON entregas
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor','operador'))
  );

CREATE POLICY entregas_update ON entregas
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor'))
  );

-- 9.4 Políticas: AUDITORIA (somente leitura para admin e auditor)
CREATE POLICY auditoria_select ON auditoria
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','auditor'))
  );

-- ============================================================
-- 10. STORAGE — BUCKET DE COMPROVANTES
-- ============================================================

-- Criar bucket (execute via SQL ou via UI: Storage > New bucket)
-- Nota: buckets via SQL podem precisar de permissões especiais.
-- Alternativa: crie pelo Dashboard em Storage > New bucket, nome: "comprovantes", Public: false

-- Se tiver permissão para criar via SQL:
INSERT INTO storage.buckets (id, name, public)
VALUES ('comprovantes', 'comprovantes', false)
ON CONFLICT (id) DO NOTHING;

-- Políticas do Storage
DROP POLICY IF EXISTS comprovantes_upload ON storage.objects;
DROP POLICY IF EXISTS comprovantes_select ON storage.objects;
DROP POLICY IF EXISTS comprovantes_delete ON storage.objects;

CREATE POLICY comprovantes_upload ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'comprovantes'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY comprovantes_select ON storage.objects
  FOR SELECT USING (
    bucket_id = 'comprovantes'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY comprovantes_delete ON storage.objects
  FOR DELETE USING (
    bucket_id = 'comprovantes'
    AND EXISTS (SELECT 1 FROM perfis p WHERE p.id = auth.uid() AND p.perfil IN ('admin','gestor'))
  );

-- ============================================================
-- 11. DADOS DE TESTE
-- ============================================================

-- Pacientes de teste
INSERT INTO pacientes (nome, cpf, cep, endereco, numero, complemento, bairro, telefone, responsavel_nome, responsavel_vinculo, cid, data_ingresso, ativo)
VALUES
  ('Maria Silva Oliveira', '12345678901', '07700-000', 'Rua das Flores', '123', 'Apto 45', 'Centro', '(11) 98765-4321', 'João Oliveira', 'Familiar', 'J44', '2024-03-15', TRUE),
  ('José Santos Lima', '23456789012', '07710-000', 'Av. Brasil', '456', NULL, 'Vila Nova', '(11) 97654-3210', NULL, NULL, 'J45', '2024-05-20', TRUE),
  ('Ana Paula Costa', '34567890123', '07720-000', 'Rua do Sol', '789', 'Casa 2', 'Jardim Europa', '(11) 96543-2109', 'Carlos Costa', 'Cuidador', 'J46', '2024-07-10', TRUE),
  ('Pedro Henrique Souza', '45678901234', '07730-000', 'Travessa da Paz', '12', NULL, 'Bela Vista', '(11) 95432-1098', NULL, NULL, 'J44', '2024-08-05', TRUE),
  ('Francisca Mendes', '56789012345', '07740-000', 'Rua Primavera', '345', 'Bloco B', 'Santa Tereza', '(11) 94321-0987', 'Lucas Mendes', 'Familiar', 'J47', '2024-09-01', TRUE)
ON CONFLICT (cpf) DO NOTHING;

-- ============================================================
-- 12. INSTRUÇÕES PARA USUÁRIOS DE TESTE
-- ============================================================

-- Os usuários do Auth devem ser criados via Dashboard do Supabase ou via API.
-- Não é possível inserir diretamente na tabela auth.users via SQL Editor.

-- PASSO A PASSO:
-- 1. Acesse: Dashboard > Authentication > Users > Add user
-- 2. Crie os 4 usuários abaixo com senha temporária (ex: "Senha@123")
-- 3. Anote os UUIDs gerados para cada usuário
-- 4. Execute os INSERTS na tabela perfis abaixo, substituindo os UUIDs

/*
-- Substitua <UUID_ADMIN>, <UUID_GESTOR>, <UUID_OPERADOR>, <UUID_AUDITOR>
-- pelos UUIDs reais gerados no passo anterior.

INSERT INTO perfis (id, nome, perfil, ativo) VALUES
  ('<UUID_ADMIN>',    'Administrador do Sistema', 'admin',    TRUE),
  ('<UUID_GESTOR>',   'Gestor do Programa',       'gestor',   TRUE),
  ('<UUID_OPERADOR>', 'Operador da Empresa',      'operador', TRUE),
  ('<UUID_AUDITOR>',  'Auditor Interno',          'auditor',  TRUE);
*/

-- ============================================================
-- 13. VERIFICAÇÃO RÁPIDA (queries de teste)
-- ============================================================

-- Liste todos os pacientes
-- SELECT * FROM pacientes;

-- Teste a função de duplicidade (deve retornar false inicialmente)
-- SELECT verificar_duplicidade_entrega(
--   (SELECT id FROM pacientes LIMIT 1),
--   CURRENT_DATE,
--   '5m³'
-- );

-- Teste KPIs do mês atual
-- SELECT * FROM kpi_entregas_mes(EXTRACT(MONTH FROM CURRENT_DATE)::INT, EXTRACT(YEAR FROM CURRENT_DATE)::INT);

-- Verifique se RLS está ativo
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('pacientes','entregas','auditoria','perfis');

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
