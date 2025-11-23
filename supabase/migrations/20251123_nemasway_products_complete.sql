-- =====================================================
-- TODOS OS PRODUTOS NEMA'S WAY IDENTIFICADOS NO GUIA
-- =====================================================

-- Primeiro, vamos garantir que a tabela supplements existe (caso não tenha sido criada)
-- Esta é uma extensão do arquivo anterior

-- Inserir TODOS os produtos da Nema's Way identificados no guia
INSERT INTO public.supplements (external_id, name, brand, category, active_ingredients, recommended_dosage, benefits, contraindications, description, original_price, discount_price, stock_quantity, is_approved, image_url, tags)
VALUES
  -- Produtos Core da Nema's Way
  ('OZONIO', 'Ozônio em Cápsulas', 'Nema''s Way', 'desintoxicacao', ARRAY['Óleo de Girassol Ozonizado 500mg'], '2 cápsulas ao dia', ARRAY['Ação anti-inflamatória', 'Melhora oxigenação celular', 'Antioxidante', 'Regeneração celular'], ARRAY['Gravidez', 'Lactação'], 'Óleo de girassol ozonizado em cápsulas para oxigenação e regeneração celular.', 149.90, 74.90, 200, true, NULL, ARRAY['ozonio', 'oxigenacao', 'antiinflamatorio', 'regeneracao']),
  
  ('D3K2', 'D3K2 (Vitamina D3 + K2)', 'Nema''s Way', 'vitaminas', ARRAY['Vitamina D3 2000UI', 'Vitamina K2 (MK-7) 100mcg'], '2 cápsulas ao dia', ARRAY['Saúde óssea', 'Regulação imunológica', 'Prevenção calcificação arterial', 'Saúde cardiovascular'], ARRAY['Hipercalcemia'], 'Combinação sinérgica de D3 e K2 para saúde óssea e cardiovascular.', 139.90, 69.90, 180, true, NULL, ARRAY['vitamina_d', 'vitamina_k', 'ossos', 'imunidade']),
  
  ('SPIRULINA', 'Spirulina', 'Nema''s Way', 'superalimentos', ARRAY['Spirulina platensis 500mg'], '3-12 comprimidos ao dia (começar com 3)', ARRAY['Rica em proteínas', 'Antioxidante', 'Desintoxicação', 'Energia'], ARRAY['Fenilcetonúria'], 'Superalimento rico em nutrientes essenciais.', 99.90, 49.90, 250, true, NULL, ARRAY['spirulina', 'superalimento', 'proteina', 'energia']),
  
  ('OMEGA_3', 'Ômega 3', 'Nema''s Way', 'cardiovascular', ARRAY['EPA 540mg', 'DHA 360mg'], '1-2 cápsulas ao dia', ARRAY['Saúde cardiovascular', 'Anti-inflamatório', 'Função cerebral', 'Reduz triglicerídeos'], ARRAY['Alergia a peixes', 'Uso de anticoagulantes'], 'Ômega 3 de alta concentração para saúde cardiovascular e cerebral.', 149.90, 74.90, 200, true, NULL, ARRAY['omega3', 'cardiovascular', 'cerebro', 'antiinflamatorio']),
  
  ('BVB_B12', 'BVB B12', 'Nema''s Way', 'vitaminas', ARRAY['Metilcobalamina 350mg'], '1-2 cápsulas ao dia', ARRAY['Energia', 'Função neurológica', 'Produção de glóbulos vermelhos', 'Memória'], ARRAY['Alergia a cobalamina'], 'Vitamina B12 na forma metilada para máxima absorção.', 89.90, 44.90, 220, true, NULL, ARRAY['b12', 'energia', 'neurologico', 'memoria']),
  
  ('BVBINSU', 'BVBInsu', 'Nema''s Way', 'metabolismo', ARRAY['Berberina', 'Cromo', 'Ácido Alfa-Lipóico'], '2 cápsulas ao dia', ARRAY['Controle glicêmico', 'Melhora resistência à insulina', 'Reduz colesterol LDL', 'Reduz compulsão alimentar'], ARRAY['Gravidez', 'Lactação', 'Hipoglicemia'], 'Suplemento para controle glicêmico e melhora da sensibilidade à insulina.', 159.90, 79.90, 150, true, NULL, ARRAY['diabetes', 'glicemia', 'insulina', 'metabolismo']),
  
  ('SDFIBRO', 'SDFibro3 (com Cúrcuma)', 'Nema''s Way', 'antiinflamatorios', ARRAY['Magnésio Dimalato', 'Cúrcuma do Mediterrâneo'], '2 cápsulas ao dia', ARRAY['Reduz dores musculares', 'Anti-inflamatório', 'Relaxamento muscular', 'Melhora sono'], ARRAY['Obstrução das vias biliares'], 'Combinação de magnésio e cúrcuma para dores e inflamações.', 129.90, 64.90, 180, true, NULL, ARRAY['magnesio', 'curcuma', 'dor', 'antiinflamatorio']),
  
  ('PROMEN', 'ProMen', 'Nema''s Way', 'saude_masculina', ARRAY['Lycopene', 'Óleo de Semente de Uva', 'Óleo de Abóbora', 'Vitamina E'], '2 cápsulas ao dia', ARRAY['Saúde da próstata', 'Antioxidante', 'Saúde cardiovascular', 'Saúde urinária'], ARRAY['Insuficiência cardíaca'], 'Suplemento específico para saúde masculina e próstata.', 159.90, 79.90, 150, true, NULL, ARRAY['prostata', 'masculino', 'antioxidante', 'cardiovascular']),
  
  ('PROWOMAN', 'ProWoman', 'Nema''s Way', 'saude_feminina', ARRAY['Fitoestrógenos', 'Óleo de Prímula', 'Vitaminas do Complexo B'], '2-3 cápsulas ao dia', ARRAY['Equilíbrio hormonal', 'Sintomas menstruais', 'Menopausa', 'Saúde reprodutiva'], ARRAY['Câncer hormônio-dependente'], 'Suplemento específico para saúde feminina e equilíbrio hormonal.', 169.90, 84.90, 150, true, NULL, ARRAY['hormonal', 'feminino', 'menopausa', 'menstrual']),
  
  ('PROPOWAY_VERMELHA', 'PropoWay Vermelha', 'Nema''s Way', 'imunidade', ARRAY['Própolis Vermelha', 'Óleo de Linhaça', 'TCM'], '2 cápsulas ao dia', ARRAY['Antimicrobiano', 'Antioxidante', 'Fortalecimento imunológico', 'Anti-inflamatório'], ARRAY['Alergia a própolis'], 'Própolis vermelha com óleos essenciais para imunidade.', 139.90, 69.90, 170, true, NULL, ARRAY['propolis', 'imunidade', 'antimicrobiano', 'antioxidante']),
  
  ('PROPOWAY_VERDE', 'Própolis Verde', 'Nema''s Way', 'imunidade', ARRAY['Própolis Verde 300mg'], '2 cápsulas ao dia', ARRAY['Antimicrobiano', 'Antioxidante', 'Fortalecimento imunológico', 'Combate infecções'], ARRAY['Alergia a própolis'], 'Própolis verde premium para imunidade.', 129.90, 64.90, 180, true, NULL, ARRAY['propolis', 'imunidade', 'antimicrobiano']),
  
  ('SEREMIX', 'Seremix', 'Nema''s Way', 'sono', ARRAY['Melatonina', 'Magnésio', 'L-Triptofano'], '1 cápsula antes de dormir', ARRAY['Melhora sono', 'Reduz ansiedade', 'Relaxamento', 'Equilíbrio nervoso'], ARRAY['Gravidez', 'Lactação'], 'Complexo para melhora da qualidade do sono e relaxamento.', 119.90, 59.90, 200, true, NULL, ARRAY['sono', 'ansiedade', 'relaxamento', 'melatonina']),
  
  ('POLIVITAMIX', 'Polivitamix', 'Nema''s Way', 'vitaminas', ARRAY['Complexo A-Z de Vitaminas e Minerais'], '2 cápsulas ao dia', ARRAY['Suporte nutricional completo', 'Energia', 'Imunidade', 'Vitalidade'], ARRAY['Hipervitaminose'], 'Multivitamínico completo A-Z.', 159.90, 79.90, 200, true, NULL, ARRAY['multivitaminico', 'vitaminas', 'minerais', 'energia']),
  
  ('VITAMINA_C', 'Vitamina C', 'Nema''s Way', 'vitaminas', ARRAY['Ácido Ascórbico 1000mg'], '1 cápsula ao dia', ARRAY['Antioxidante', 'Imunidade', 'Produção de colágeno', 'Absorção de ferro'], ARRAY['Cálculos renais'], 'Vitamina C de alta potência.', 69.90, 34.90, 250, true, NULL, ARRAY['vitamina_c', 'antioxidante', 'imunidade']),
  
  ('COENZIMA_Q10', 'Coenzima Q10 (BVB Q10)', 'Nema''s Way', 'energia', ARRAY['Ubiquinona (CoQ10) 700mg'], '1 cápsula ao dia', ARRAY['Energia celular', 'Saúde cardíaca', 'Antioxidante', 'Performance'], ARRAY['Uso de varfarina'], 'Coenzima Q10 de alta concentração.', 179.90, 89.90, 120, true, NULL, ARRAY['coq10', 'energia', 'cardiovascular', 'mitocondria']),
  
  ('RX21', 'RX21 (Cabelos & Unhas)', 'Nema''s Way', 'beleza', ARRAY['Biotina', 'Zinco', 'Selênio', 'Colágeno'], '1 comprimido ao dia', ARRAY['Fortalecimento capilar', 'Unhas saudáveis', 'Pele radiante', 'Crescimento capilar'], ARRAY[], 'Suplemento específico para cabelos, unhas e pele.', 189.90, 94.90, 150, true, NULL, ARRAY['cabelo', 'unhas', 'pele', 'biotina']),
  
  ('VITAMIXSKIN', 'VitamixSkin', 'Nema''s Way', 'beleza', ARRAY['Vitaminas A, C, E', 'Zinco', 'Selênio'], '2 cápsulas ao dia', ARRAY['Saúde da pele', 'Antioxidante', 'Colágeno', 'Proteção solar'], ARRAY[], 'Complexo vitamínico para saúde e beleza da pele.', 149.90, 74.90, 160, true, NULL, ARRAY['pele', 'vitaminas', 'antioxidante']),
  
  ('VISIONWAY', 'VisionWay', 'Nema''s Way', 'saude_ocular', ARRAY['Luteína', 'Zeaxantina', 'Óleo de Cártamo'], '1 cápsula ao dia', ARRAY['Saúde ocular', 'Proteção da retina', 'Visão noturna', 'Prevenção degeneração macular'], ARRAY[], 'Suplemento específico para saúde ocular.', 199.90, 99.90, 100, true, NULL, ARRAY['olhos', 'visao', 'luteina', 'retina']),
  
  ('LIBWAY', 'LibWay', 'Nema''s Way', 'saude_sexual', ARRAY['Tribulus Terrestris', 'Maca Peruana', 'Zinco'], '1 cápsula ao dia', ARRAY['Aumenta libido', 'Melhora circulação', 'Equilíbrio hormonal', 'Vitalidade'], ARRAY['Câncer de próstata'], 'Suplemento para aumento de libido e vitalidade.', 179.90, 89.90, 130, true, NULL, ARRAY['libido', 'sexual', 'vitalidade', 'hormonal']),
  
  ('LIPOWAY', 'Lipoway', 'Nema''s Way', 'emagrecimento', ARRAY['Cafeína', 'Chá Verde', 'L-Carnitina'], '1 cápsula antes das refeições', ARRAY['Reduz gordura abdominal', 'Acelera metabolismo', 'Controle de peso', 'Energia'], ARRAY['Hipertensão', 'Insônia'], 'Suplemento para redução de gordura localizada.', 169.90, 84.90, 140, true, NULL, ARRAY['emagrecimento', 'gordura', 'metabolismo', 'termogenico']),
  
  ('AMARGO', 'Amargo', 'Nema''s Way', 'digestao', ARRAY['Extratos Amargos', 'Chá Verde'], '2-4 colheres de sopa ao dia', ARRAY['Digestão', 'Desintoxicação hepática', 'Produção de bile', 'Regularização intestinal'], ARRAY[], 'Extrato amargo para saúde digestiva e hepática.', 89.90, 44.90, 180, true, NULL, ARRAY['digestao', 'figado', 'bile', 'intestino']),
  
  ('OLEO_PRIMULA', 'Óleo de Prímula', 'Nema''s Way', 'saude_feminina', ARRAY['Óleo de Prímula 1000mg'], '2 cápsulas ao dia', ARRAY['Equilíbrio hormonal', 'Sintomas menstruais', 'Saúde da pele', 'Menopausa'], ARRAY[], 'Óleo de prímula para saúde hormonal feminina.', 149.90, 74.90, 160, true, NULL, ARRAY['hormonal', 'feminino', 'menstrual', 'pele']),
  
  ('OLEO_GIRASSOL_OZONIZADO', 'Óleo de Girassol Ozonizado', 'Nema''s Way', 'topico', ARRAY['Óleo de Girassol Ozonizado'], 'Uso tópico conforme necessidade', ARRAY['Cicatrização', 'Anti-inflamatório', 'Antimicrobiano', 'Regeneração'], ARRAY[], 'Óleo ozonizado para uso tópico e cicatrização.', 119.90, 59.90, 150, true, NULL, ARRAY['topico', 'ozonio', 'cicatrizacao', 'regeneracao']),
  
  ('OLEO_VERDE_OZONIZADO', 'Óleo Verde Ozonizado', 'Nema''s Way', 'topico', ARRAY['Óleo Verde Ozonizado'], 'Uso tópico ou inalação', ARRAY['Anti-inflamatório', 'Antimicrobiano', 'Saúde respiratória', 'Hidratação'], ARRAY[], 'Óleo verde ozonizado para uso tópico e respiratório.', 129.90, 64.90, 140, true, NULL, ARRAY['topico', 'respiratorio', 'ozonio']),
  
  ('OLEO_HOT', 'Óleo Hot', 'Nema''s Way', 'saude_intima', ARRAY['Óleos Essenciais', 'Extratos'], 'Uso tópico diário', ARRAY['Lubrificação', 'Antisséptico', 'Antifúngico', 'Cicatrização'], ARRAY[], 'Óleo para saúde íntima com ação antisséptica.', 99.90, 49.90, 120, true, NULL, ARRAY['intimo', 'topico', 'antisseptico']),
  
  ('SABONETE_INTIMO', 'Sabonete Íntimo Sedução', 'Nema''s Way', 'higiene', ARRAY['Extratos Naturais', 'pH Balanceado'], 'Uso diário', ARRAY['Limpeza profunda', 'Equilíbrio de pH', 'Prevenção de fungos', 'Cuidado íntimo'], ARRAY[], 'Sabonete íntimo com pH balanceado.', 49.90, 24.90, 200, true, NULL, ARRAY['higiene', 'intimo', 'ph']),
  
  ('GEL_CRIOTERAPICO', 'Gel Crioterápico', 'Nema''s Way', 'topico', ARRAY['Mentol', 'Extratos Refrescantes'], 'Aplicar antes/depois exercícios', ARRAY['Reduz gordura localizada', 'Melhora circulação', 'Reduz celulite', 'Efeito crioterápico'], ARRAY[], 'Gel com efeito crioterápico para redução de medidas.', 89.90, 44.90, 180, true, NULL, ARRAY['topico', 'crioterapia', 'gordura_localizada']),
  
  ('OLEO_MASSAGEM', 'Óleo de Massagem Ozonizado', 'Nema''s Way', 'topico', ARRAY['Óleo de Massagem Ozonizado'], 'Aplicar diariamente', ARRAY['Hidratação', 'Regeneração', 'Anti-inflamatório', 'Massagem'], ARRAY[], 'Óleo de massagem ozonizado para hidratação e regeneração.', 109.90, 54.90, 160, true, NULL, ARRAY['topico', 'massagem', 'hidratacao']),
  
  ('PEELING', 'Peeling 3 em 1', 'Nema''s Way', 'beleza', ARRAY['Ácidos de Frutas', 'Vitamina E'], '2-3x por semana', ARRAY['Esfoliação', 'Renovação celular', 'Textura da pele', 'Preparação para outros produtos'], ARRAY[], 'Peeling facial para renovação e esfoliação da pele.', 79.90, 39.90, 150, true, NULL, ARRAY['pele', 'esfoliacao', 'renovacao']),
  
  ('SERUM_VITAMINA_C', 'Sérum Vitamina C Ozonizado', 'Nema''s Way', 'beleza', ARRAY['Vitamina C', 'Óleo Ozonizado'], 'Aplicar todas as manhãs', ARRAY['Antioxidante', 'Clareamento', 'Produção de colágeno', 'Proteção solar'], ARRAY[], 'Sérum de vitamina C para clareamento e proteção.', 149.90, 74.90, 140, true, NULL, ARRAY['pele', 'vitamina_c', 'clareamento']),
  
  ('SERUM_RETINOL', 'Sérum Retinol Ozonizado', 'Nema''s Way', 'beleza', ARRAY['Retinol', 'Óleo Ozonizado'], 'Aplicar todas as noites', ARRAY['Renovação celular', 'Anti-idade', 'Reduz rugas', 'Melhora textura'], ARRAY['Gravidez', 'Lactação'], 'Sérum de retinol para renovação e anti-idade.', 169.90, 84.90, 130, true, NULL, ARRAY['pele', 'retinol', 'anti_idade']),
  
  ('COLAGENO_TIPO_II', 'Colágeno Tipo II', 'Nema''s Way', 'articulacoes', ARRAY['Colágeno Tipo II', 'Vitamina E'], '1 comprimido ao dia', ARRAY['Saúde articular', 'Regeneração', 'Reduz inflamações', 'Mobilidade'], ARRAY['Alergia a proteínas'], 'Colágeno tipo II para saúde das articulações.', 179.90, 89.90, 120, true, NULL, ARRAY['articulacoes', 'colageno', 'regeneracao']),
  
  ('SDARTRO', 'SDArtro', 'Nema''s Way', 'articulacoes', ARRAY['Magnésio', 'Extratos Anti-inflamatórios'], '2 cápsulas ao dia', ARRAY['Reduz dores articulares', 'Anti-inflamatório', 'Artrite e artrose', 'Mobilidade'], ARRAY[], 'Suplemento específico para dores articulares.', 139.90, 69.90, 150, true, NULL, ARRAY['articulacoes', 'dor', 'antiinflamatorio']),
  
  ('PROMEN_EXTENDED', 'Promen', 'Nema''s Way', 'saude_masculina', ARRAY['Extratos de Plantas', 'Antioxidantes'], '2 cápsulas ao dia', ARRAY['Saúde da próstata', 'Saúde urinária', 'Antioxidante', 'Vitalidade'], ARRAY['Insuficiência cardíaca'], 'Suplemento para saúde masculina e próstata.', 159.90, 79.90, 140, true, NULL, ARRAY['prostata', 'masculino', 'urinario'])
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

