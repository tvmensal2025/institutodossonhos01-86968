-- =====================================================
-- ESTRUTURA COMPLETA DE PROTOCOLOS E PRODUTOS NEMA'S WAY
-- Baseado no Guia Prático de Suplementação
-- =====================================================

-- 1. Tabela de Condições de Saúde (Categorias de Protocolos)
CREATE TABLE IF NOT EXISTS public.health_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE, -- Ex: "Ansiedade", "Diabetes", "Fibromialgia"
    description TEXT,
    icon_name TEXT, -- Para ícones no frontend
    color_code TEXT, -- Cor da categoria
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabela de Protocolos (Cada protocolo é para uma condição específica)
CREATE TABLE IF NOT EXISTS public.supplement_protocols (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    health_condition_id UUID REFERENCES public.health_conditions(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- Ex: "Protocolo Ansiedade", "Protocolo Diabetes"
    description TEXT,
    duration_days INTEGER, -- Duração sugerida do protocolo (opcional)
    notes TEXT, -- Observações importantes
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(health_condition_id, name) -- Evita protocolos duplicados para mesma condição
);

-- 3. Tabela de Horários de Uso (Padronização de horários)
CREATE TABLE IF NOT EXISTS public.usage_times (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE, -- Ex: "EM_JEJUM", "APOS_CAFE_MANHA", "AS_10H_MANHA"
    name TEXT NOT NULL, -- Ex: "Em Jejum", "Após o Café da Manhã"
    time_of_day TIME, -- Para ordenação (opcional)
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Tabela de Associação Produto-Protocolo (O coração do sistema)
CREATE TABLE IF NOT EXISTS public.protocol_supplements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    protocol_id UUID NOT NULL REFERENCES public.supplement_protocols(id) ON DELETE CASCADE,
    supplement_id UUID NOT NULL REFERENCES public.supplements(id) ON DELETE CASCADE,
    usage_time_id UUID NOT NULL REFERENCES public.usage_times(id),
    dosage TEXT NOT NULL, -- Ex: "2 Cápsulas", "3 Comprimidos", "2 colheres de sopa"
    notes TEXT, -- Observações específicas (ex: "Não tomar com outro suplemento no mesmo horário")
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(protocol_id, supplement_id, usage_time_id) -- Evita duplicatas
);

-- 5. Índices para performance
CREATE INDEX IF NOT EXISTS idx_protocols_condition ON public.supplement_protocols(health_condition_id);
CREATE INDEX IF NOT EXISTS idx_protocol_supplements_protocol ON public.protocol_supplements(protocol_id);
CREATE INDEX IF NOT EXISTS idx_protocol_supplements_supplement ON public.protocol_supplements(supplement_id);
CREATE INDEX IF NOT EXISTS idx_protocol_supplements_time ON public.protocol_supplements(usage_time_id);

-- 6. RLS Policies
ALTER TABLE public.health_conditions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplement_protocols ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.protocol_supplements ENABLE ROW LEVEL SECURITY;

-- Políticas de leitura pública
CREATE POLICY "Allow public read access" ON public.health_conditions FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.supplement_protocols FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.usage_times FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON public.protocol_supplements FOR SELECT USING (true);

-- Políticas de escrita (admin apenas)
CREATE POLICY "Allow authenticated insert/update" ON public.health_conditions FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated insert/update" ON public.supplement_protocols FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated insert/update" ON public.usage_times FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated insert/update" ON public.protocol_supplements FOR ALL USING (auth.role() = 'authenticated');

-- =====================================================
-- INSERÇÃO DE DADOS BASE
-- =====================================================

-- Inserir Horários Padronizados
INSERT INTO public.usage_times (code, name, time_of_day, display_order) VALUES
  ('EM_JEJUM', 'Em Jejum', '07:00:00', 1),
  ('APOS_CAFE_MANHA', 'Após o Café da Manhã', '08:00:00', 2),
  ('AS_10H_MANHA', 'Às 10h da Manhã', '10:00:00', 3),
  ('30MIN_ANTES_ALMOCO', '30 Minutos Antes do Almoço', '11:30:00', 4),
  ('APOS_ALMOCO', 'Após o Almoço', '13:00:00', 5),
  ('AS_18H_NOITE', 'Às 18h da Noite', '18:00:00', 6),
  ('30MIN_ANTES_JANTAR', '30 Minutos Antes do Jantar', '18:30:00', 7),
  ('30MIN_APOS_JANTAR', '30 Minutos Após o Jantar', '20:30:00', 8),
  ('ANTES_DORMIR', 'Antes de Dormir', '22:00:00', 9),
  ('USO_DIARIO', 'Uso Diário', NULL, 10),
  ('ANTES_EXERCICIOS', 'Antes dos Exercícios', NULL, 11),
  ('APOS_EXERCICIOS', 'Após os Exercícios', NULL, 12)
ON CONFLICT (code) DO NOTHING;

-- Inserir Condições de Saúde Principais (baseado no guia)
INSERT INTO public.health_conditions (name, description, icon_name, color_code) VALUES
  ('Ansiedade', 'Protocolo para redução de ansiedade e estresse', 'brain', '#8B5CF6'),
  ('Diabetes', 'Protocolo para controle glicêmico e diabetes', 'activity', '#EF4444'),
  ('Fibromialgia e Enxaqueca', 'Protocolo para dores crônicas e enxaquecas', 'heart', '#F59E0B'),
  ('Insônia', 'Protocolo para melhora do sono', 'moon', '#6366F1'),
  ('Alzheimer e Memória', 'Protocolo para saúde cognitiva', 'brain', '#10B981'),
  ('Candidíase', 'Protocolo para tratamento de candidíase', 'shield', '#EC4899'),
  ('Saúde Íntima', 'Protocolo para saúde íntima feminina', 'heart', '#F472B6'),
  ('Menopausa', 'Protocolo para sintomas da menopausa', 'flower', '#A855F7'),
  ('Emagrecimento', 'Protocolo para perda de peso', 'trending-down', '#14B8A6'),
  ('Hipertensão', 'Protocolo para controle de pressão arterial', 'activity', '#F97316'),
  ('Saúde Cardiovascular', 'Protocolo para saúde do coração', 'heart', '#DC2626'),
  ('Saúde Intestinal', 'Protocolo para saúde digestiva', 'stomach', '#059669'),
  ('Saúde Ocular', 'Protocolo para saúde dos olhos', 'eye', '#0284C7'),
  ('Saúde da Pele', 'Protocolo para saúde e beleza da pele', 'sparkles', '#F59E0B'),
  ('Saúde do Homem', 'Protocolo específico para saúde masculina', 'user', '#3B82F6'),
  ('Saúde da Mulher', 'Protocolo específico para saúde feminina', 'heart', '#EC4899'),
  ('Desintoxicação', 'Protocolo para desintoxicação do organismo', 'zap', '#10B981'),
  ('Sono e Estresse', 'Protocolo para qualidade do sono e redução de estresse', 'moon', '#6366F1'),
  ('Performance e Energia', 'Protocolo para aumento de energia e performance', 'zap', '#F59E0B'),
  ('Imunidade', 'Protocolo para fortalecimento do sistema imunológico', 'shield', '#10B981')
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  icon_name = EXCLUDED.icon_name,
  color_code = EXCLUDED.color_code,
  updated_at = NOW();

