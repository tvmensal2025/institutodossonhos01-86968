-- Create supplements table
CREATE TABLE IF NOT EXISTS public.supplements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_id TEXT UNIQUE, -- Mapped from JSON "id" e.g. "CART_CONTROL"
    name TEXT NOT NULL,
    brand TEXT DEFAULT 'Nema''s Way',
    category TEXT,
    active_ingredients TEXT[],
    recommended_dosage TEXT,
    benefits TEXT[],
    contraindications TEXT[],
    description TEXT,
    original_price DECIMAL(10,2),
    discount_price DECIMAL(10,2),
    stock_quantity INTEGER DEFAULT 0,
    is_approved BOOLEAN DEFAULT true,
    image_url TEXT,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.supplements ENABLE ROW LEVEL SECURITY;

-- Create policy for read access (public)
CREATE POLICY "Allow public read access" ON public.supplements
    FOR SELECT USING (true);

-- Create policy for write access (admin only - logic to be refined, for now public for development or specific role)
-- Assuming there is an admin role check or just authenticated for now
CREATE POLICY "Allow authenticated insert/update" ON public.supplements
    FOR ALL USING (auth.role() = 'authenticated');

-- Insert data from the JSON file
INSERT INTO public.supplements (external_id, name, brand, category, active_ingredients, recommended_dosage, benefits, contraindications, description, original_price, discount_price, stock_quantity, is_approved, image_url, tags)
VALUES
  ('CART_CONTROL', 'CART CONTROL', 'Nema''s Way', 'emagrecimento', ARRAY['Cafeína', 'Chá Verde', 'L-Carnitina', 'Cromo', 'Capsaicina'], '2 cápsulas 30 minutos antes do almoço', ARRAY['Acelera metabolismo', 'Reduz gordura abdominal', 'Controla apetite', 'Aumenta termogênese'], ARRAY['Hipertensão grave não controlada', 'Gravidez', 'Lactação', 'Problemas cardíacos'], 'Complexo termogênico avançado para controle de peso e aceleração metabólica.', 189.90, 94.90, 150, true, 'https://via.placeholder.com/300x300/4F46E5/FFFFFF?text=CART+CONTROL', ARRAY['termogenico', 'emagrecimento', 'metabolismo', 'gordura_abdominal']),
  ('AZ_COMPLEX', 'A-Z COMPLEX', 'Nema''s Way', 'vitaminas', ARRAY['24 Vitaminas e Minerais', 'Vitamina A', 'Complexo B', 'Vitamina C', 'Vitamina D3', 'Vitamina E', 'Zinco', 'Selênio', 'Magnésio'], '1 cápsula ao dia com refeição principal', ARRAY['Suporte nutricional completo', 'Aumenta energia', 'Fortalece imunidade', 'Melhora concentração'], ARRAY['Hipervitaminose', 'Alergia a algum componente'], 'Multivitamínico completo com 24 nutrientes essenciais em doses ideais.', 159.90, 79.90, 200, true, 'https://via.placeholder.com/300x300/10B981/FFFFFF?text=A-Z+COMPLEX', ARRAY['multivitaminico', 'essencial', 'energia', 'imunidade']),
  ('OMEGA_3', 'OMEGA 3', 'Nema''s Way', 'cardiovascular', ARRAY['EPA 500mg', 'DHA 250mg', 'Vitamina E'], '2 cápsulas ao dia com refeições', ARRAY['Saúde cardiovascular', 'Reduz triglicerídeos', 'Anti-inflamatório', 'Melhora cognição'], ARRAY['Alergia a peixes', 'Uso de anticoagulantes (consultar médico)'], 'Ômega 3 de alta concentração (EPA + DHA) purificado por destilação molecular.', 149.90, 74.90, 180, true, 'https://via.placeholder.com/300x300/F59E0B/FFFFFF?text=OMEGA+3', ARRAY['omega3', 'cardiovascular', 'antiinflamatorio', 'cerebro']),
  ('CLORETO_MAGNESIO', 'CLORETO DE MAGNÉSIO', 'Nema''s Way', 'minerais', ARRAY['Cloreto de Magnésio P.A. 500mg'], '1 cápsula 2x ao dia (manhã e noite)', ARRAY['Regula pressão arterial', 'Melhora sono', 'Relaxa músculos', 'Reduz cãibras'], ARRAY['Insuficiência renal', 'Bloqueio cardíaco'], 'Magnésio P.A. de alta biodisponibilidade para saúde cardiovascular e muscular.', 89.90, 44.90, 250, true, 'https://via.placeholder.com/300x300/8B5CF6/FFFFFF?text=CLORETO+DE+MAGNÉSIO', ARRAY['magnesio', 'sono', 'pressao', 'cãibras']),
  ('MACA_PERUANA', 'MACA PERUANA', 'Nema''s Way', 'energia', ARRAY['Extrato de Maca Peruana 500mg', 'Padronizado em macamidas'], '2 cápsulas ao dia (manhã)', ARRAY['Aumenta energia', 'Melhora libido', 'Equilíbrio hormonal', 'Combate fadiga'], ARRAY['Gravidez', 'Lactação', 'Problemas tireoidianos não controlados'], 'Maca Peruana premium dos Andes, padronizada em macamidas para máxima eficácia.', 139.90, 69.90, 120, true, 'https://via.placeholder.com/300x300/F59E0B/FFFFFF?text=MACA+PERUANA', ARRAY['energia', 'libido', 'hormonal', 'fadiga']),
  ('VITAMINA_D3', 'VITAMINA D3 2000UI', 'Nema''s Way', 'vitaminas', ARRAY['Colecalciferol (D3) 2000UI'], '1 cápsula ao dia com refeição', ARRAY['Fortalece ossos', 'Melhora imunidade', 'Previne osteoporose', 'Melhora humor'], ARRAY['Hipercalcemia', 'Sarcoidose'], 'Vitamina D3 na forma ativa com máxima biodisponibilidade.', 79.90, 39.90, 300, true, 'https://via.placeholder.com/300x300/10B981/FFFFFF?text=VITAMINA+D3', ARRAY['vitamina_d', 'ossos', 'imunidade', 'essencial']),
  ('VITAMINA_B12', 'VITAMINA B12 METILCOBALAMINA', 'Nema''s Way', 'vitaminas', ARRAY['Metilcobalamina 1000mcg'], '1 cápsula ao dia', ARRAY['Combate fadiga', 'Melhora memória', 'Protege nervos', 'Essencial para vegetarianos'], ARRAY['Alergia a cobalamina'], 'B12 na forma metilada, mais biodisponível e ativa.', 89.90, 44.90, 200, true, 'https://via.placeholder.com/300x300/EF4444/FFFFFF?text=VITAMINA+B12', ARRAY['b12', 'energia', 'memoria', 'vegetarianos']),
  ('COLAGENO', 'COLÁGENO HIDROLISADO TIPO II', 'Nema''s Way', 'colageno', ARRAY['Colágeno Hidrolisado Tipo II 10g', 'Vitamina C 45mg'], '1 scoop ao dia dissolvido em água', ARRAY['Melhora pele', 'Reduz dor articular', 'Fortalece cabelo e unhas', 'Previne rugas'], ARRAY['Alergia a proteínas bovinas ou suínas'], 'Colágeno hidrolisado de baixo peso molecular para máxima absorção.', 119.90, 59.90, 180, true, 'https://via.placeholder.com/300x300/F59E0B/FFFFFF?text=COLÁGENO', ARRAY['colageno', 'pele', 'articulacoes', 'beleza']),
  ('PROBIOTICOS', 'PROBIÓTICOS 10 BILHÕES UFC', 'Nema''s Way', 'digestao', ARRAY['10 bilhões UFC', 'Lactobacillus', 'Bifidobacterium', 'FOS (prebiótico)'], '1 cápsula ao dia em jejum', ARRAY['Regula intestino', 'Fortalece imunidade', 'Reduz gases', 'Melhora digestão'], ARRAY['Imunocomprometidos (consultar médico)'], 'Complexo probiótico com 10 cepas selecionadas + prebióticos.', 109.90, 54.90, 150, true, 'https://via.placeholder.com/300x300/8B5CF6/FFFFFF?text=PROBIÓTICOS', ARRAY['probioticos', 'intestino', 'imunidade', 'digestao']),
  ('CREATINA', 'CREATINA MONOHIDRATADA PURA', 'Nema''s Way', 'performance', ARRAY['Creatina Monohidratada 3g'], '1 scoop (3g) ao dia, qualquer horário', ARRAY['Aumenta força', 'Ganha massa muscular', 'Melhora performance', 'Acelera recuperação'], ARRAY['Problemas renais'], 'Creatina 100% pura, micronizada, sem aditivos.', 129.90, 64.90, 200, true, 'https://via.placeholder.com/300x300/10B981/FFFFFF?text=CREATINA', ARRAY['creatina', 'forca', 'massa_muscular', 'treino']),
  ('WHEY_PROTEIN', 'WHEY PROTEIN CONCENTRADO 80%', 'Nema''s Way', 'proteinas', ARRAY['Whey Protein Concentrado 25g', 'BCAAs 5.5g'], '1 scoop (30g) pós-treino ou entre refeições', ARRAY['Ganho muscular', 'Recuperação', 'Saciedade', 'Aminoácidos essenciais'], ARRAY['Alergia ao leite', 'Intolerância à lactose severa'], 'Whey protein de alto valor biológico com 80% de proteína.', 179.90, 89.90, 150, true, 'https://via.placeholder.com/300x300/EF4444/FFFFFF?text=WHEY+PROTEIN', ARRAY['whey', 'proteina', 'massa_muscular', 'recuperacao']),
  ('ZINCO', 'ZINCO QUELADO 30mg', 'Nema''s Way', 'minerais', ARRAY['Zinco Quelado 30mg'], '1 cápsula ao dia com refeição', ARRAY['Fortalece imunidade', 'Melhora pele', 'Acelera cicatrização', 'Saúde da tireoide'], ARRAY['Uso prolongado acima de 40mg/dia'], 'Zinco quelado de alta absorção para imunidade e saúde celular.', 79.90, 39.90, 220, true, 'https://via.placeholder.com/300x300/8B5CF6/FFFFFF?text=ZINCO', ARRAY['zinco', 'imunidade', 'pele', 'cicatrizacao']),
  ('VITAMINA_C', 'VITAMINA C 1000mg', 'Nema''s Way', 'vitaminas', ARRAY['Ácido Ascórbico 1000mg'], '1 cápsula ao dia', ARRAY['Antioxidante', 'Imunidade', 'Produção de colágeno', 'Absorção de ferro'], ARRAY['Cálculos renais de oxalato'], 'Vitamina C pura de alta potência para imunidade e antioxidação.', 69.90, 34.90, 250, true, 'https://via.placeholder.com/300x300/EF4444/FFFFFF?text=VITAMINA+C', ARRAY['vitamina_c', 'antioxidante', 'imunidade', 'colageno']),
  ('SELENIO', 'SELÊNIO 200mcg', 'Nema''s Way', 'minerais', ARRAY['Selenometionina 200mcg'], '1 cápsula ao dia', ARRAY['Saúde da tireoide', 'Antioxidante', 'Imunidade', 'Proteção celular'], ARRAY['Selenose (intoxicação por selênio)'], 'Selênio orgânico de alta biodisponibilidade para tireoide e imunidade.', 79.90, 39.90, 180, true, 'https://via.placeholder.com/300x300/F59E0B/FFFFFF?text=SELÊNIO', ARRAY['selenio', 'tireoide', 'antioxidante', 'imunidade']),
  ('ASHWAGANDHA', 'ASHWAGANDHA 500mg', 'Nema''s Way', 'adaptogenos', ARRAY['Extrato de Ashwagandha 500mg', 'Padronizado 5% withanolidas'], '1 cápsula 2x ao dia', ARRAY['Reduz estresse', 'Equilibra cortisol', 'Melhora sono', 'Aumenta energia'], ARRAY['Gravidez', 'Lactação', 'Hipertireoidismo'], 'Ashwagandha premium padronizada, adaptógeno milenar ayurvédico.', 139.90, 69.90, 130, true, 'https://via.placeholder.com/300x300/10B981/FFFFFF?text=ASHWAGANDHA', ARRAY['ashwagandha', 'estresse', 'adaptogeno', 'cortisol']),
  ('MELATONINA', 'MELATONINA 3mg', 'Nema''s Way', 'sono', ARRAY['Melatonina 3mg'], '1 cápsula 30 minutos antes de dormir', ARRAY['Melhora sono', 'Regula ciclo circadiano', 'Reduz jet lag', 'Antioxidante'], ARRAY['Gravidez', 'Lactação', 'Doenças autoimunes'], 'Melatonina pura para regularização do ciclo do sono.', 69.90, 34.90, 280, true, 'https://via.placeholder.com/300x300/8B5CF6/FFFFFF?text=MELATONINA', ARRAY['melatonina', 'sono', 'insonia', 'circadiano']),
  ('GLUTAMINA', 'L-GLUTAMINA 5g', 'Nema''s Way', 'aminoacidos', ARRAY['L-Glutamina 5g'], '1 scoop (5g) pós-treino ou antes de dormir', ARRAY['Saúde intestinal', 'Recuperação muscular', 'Imunidade', 'Anti-catabolismo'], ARRAY['Problemas hepáticos graves'], 'L-Glutamina pura para intestino e recuperação muscular.', 119.90, 59.90, 140, true, 'https://via.placeholder.com/300x300/EF4444/FFFFFF?text=L-GLUTAMINA', ARRAY['glutamina', 'intestino', 'recuperacao', 'imunidade']),
  ('BCAA', 'BCAA 2:1:1 5g', 'Nema''s Way', 'aminoacidos', ARRAY['L-Leucina 2.5g', 'L-Isoleucina 1.25g', 'L-Valina 1.25g'], '1 scoop durante ou pós-treino', ARRAY['Reduz fadiga', 'Recuperação muscular', 'Preserva massa', 'Performance'], ARRAY['ELA (Esclerose Lateral Amiotrófica)'], 'BCAAs na proporção ideal 2:1:1 para máxima eficácia.', 129.90, 64.90, 160, true, 'https://via.placeholder.com/300x300/F59E0B/FFFFFF?text=BCAA', ARRAY['bcaa', 'aminoacidos', 'fadiga', 'treino']),
  ('COENZIMA_Q10', 'COENZIMA Q10 100mg', 'Nema''s Way', 'energia', ARRAY['Ubiquinona (CoQ10) 100mg'], '1 cápsula ao dia com refeição gordurosa', ARRAY['Energia celular', 'Saúde cardíaca', 'Antioxidante', 'Anti-envelhecimento'], ARRAY['Uso de varfarina (consultar médico)'], 'Coenzima Q10 de alta pureza para produção de energia mitocondrial.', 159.90, 79.90, 100, true, 'https://via.placeholder.com/300x300/10B981/FFFFFF?text=COENZIMA+Q10', ARRAY['coq10', 'energia', 'cardiovascular', 'mitocondria']),
  ('CURCUMA', 'CÚRCUMA + PIPERINA 500mg', 'Nema''s Way', 'antiinflamatorios', ARRAY['Extrato de Cúrcuma 450mg (95% curcuminoides)', 'Piperina 5mg'], '1 cápsula 2x ao dia com refeições', ARRAY['Anti-inflamatório', 'Reduz dor articular', 'Antioxidante', 'Saúde digestiva'], ARRAY['Obstrução das vias biliares', 'Gravidez'], 'Curcumina padronizada 95% com piperina para máxima absorção.', 129.90, 64.90, 150, true, 'https://via.placeholder.com/300x300/8B5CF6/FFFFFF?text=CÚRCUMA', ARRAY['curcuma', 'antiinflamatorio', 'dor', 'antioxidante']),
  ('SPIRULINA', 'SPIRULINA 500mg', 'Nema''s Way', 'superalimentos', ARRAY['Spirulina platensis 500mg'], '2 cápsulas 2x ao dia', ARRAY['Proteína completa', 'Antioxidante', 'Energia', 'Desintoxicação'], ARRAY['Fenilcetonúria', 'Doenças autoimunes'], 'Spirulina orgânica, superalimento rico em proteínas e nutrientes.', 99.90, 49.90, 170, true, 'https://via.placeholder.com/300x300/EF4444/FFFFFF?text=SPIRULINA', ARRAY['spirulina', 'superalimento', 'proteina', 'energia']),
  ('FERRO', 'FERRO QUELADO 14mg', 'Nema''s Way', 'minerais', ARRAY['Ferro Bisglicinato 14mg', 'Vitamina C 45mg'], '1 cápsula ao dia em jejum', ARRAY['Combate anemia', 'Aumenta energia', 'Melhora concentração', 'Sem desconforto gástrico'], ARRAY['Hemocromatose', 'Hemossiderose'], 'Ferro quelado de alta absorção sem desconforto gastrointestinal.', 89.90, 44.90, 200, true, 'https://via.placeholder.com/300x300/F59E0B/FFFFFF?text=FERRO', ARRAY['ferro', 'anemia', 'energia', 'concentracao']),
  ('CALCIO_VITAMINA_K2', 'CÁLCIO + VITAMINA D3 + K2', 'Nema''s Way', 'ossos', ARRAY['Cálcio 600mg', 'Vitamina D3 400UI', 'Vitamina K2 (MK-7) 45mcg'], '1 cápsula 2x ao dia com refeições', ARRAY['Fortalece ossos', 'Previne osteoporose', 'Saúde cardiovascular', 'Absorção ideal'], ARRAY['Hipercalcemia', 'Uso de anticoagulantes'], 'Trio sinérgico para saúde óssea e cardiovascular máxima.', 139.90, 69.90, 130, true, 'https://via.placeholder.com/300x300/10B981/FFFFFF?text=CÁLCIO+K2', ARRAY['calcio', 'ossos', 'vitamina_k2', 'osteoporose']);

ON CONFLICT (external_id) DO UPDATE SET
    name = EXCLUDED.name,
    brand = EXCLUDED.brand,
    category = EXCLUDED.category,
    active_ingredients = EXCLUDED.active_ingredients,
    recommended_dosage = EXCLUDED.recommended_dosage,
    benefits = EXCLUDED.benefits,
    contraindications = EXCLUDED.contraindications,
    description = EXCLUDED.description,
    original_price = EXCLUDED.original_price,
    discount_price = ROUND(EXCLUDED.original_price * 0.5, 2), -- 50% de desconto automático para cadastrados
    stock_quantity = EXCLUDED.stock_quantity,
    image_url = EXCLUDED.image_url,
    tags = EXCLUDED.tags,
    updated_at = NOW();

