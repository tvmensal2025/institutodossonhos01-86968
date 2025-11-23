-- =====================================================
-- PROTOCOLOS COMPLETOS BASEADOS NO GUIA NEMA'S WAY
-- =====================================================

-- Este arquivo deve ser executado APÓS os anteriores
-- Assumindo que as tabelas e produtos já foram criados

-- =====================================================
-- PROTOCOLO 1: ANSIEDADE
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_sdfibro_id UUID;
  v_bvbinsu_id UUID;
  v_seremix_id UUID;
  v_jejum_id UUID;
  v_apos_cafe_id UUID;
  v_30min_almoco_id UUID;
  v_30min_jantar_id UUID;
BEGIN
  -- Buscar IDs
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Ansiedade';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_sdfibro_id FROM public.supplements WHERE external_id = 'SDFIBRO';
  SELECT id INTO v_bvbinsu_id FROM public.supplements WHERE external_id = 'BVBINSU';
  SELECT id INTO v_seremix_id FROM public.supplements WHERE external_id = 'SEREMIX';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_apos_cafe_id FROM public.usage_times WHERE code = 'APOS_CAFE_MANHA';
  SELECT id INTO v_30min_almoco_id FROM public.usage_times WHERE code = '30MIN_ANTES_ALMOCO';
  SELECT id INTO v_30min_jantar_id FROM public.usage_times WHERE code = '30MIN_APOS_JANTAR';

  -- Criar protocolo
  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Ansiedade', 'Protocolo completo para redução de ansiedade e estresse', 'Acompanhamento profissional recomendado')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  -- Se não retornou ID, buscar existente
  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  -- Inserir produtos do protocolo
  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', 1),
    (v_protocol_id, v_sdfibro_id, v_apos_cafe_id, '2 Cápsulas', 2),
    (v_protocol_id, v_bvbinsu_id, v_30min_almoco_id, '2 Cápsulas', 3),
    (v_protocol_id, v_seremix_id, v_30min_jantar_id, '1 Cápsula', 4)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

-- =====================================================
-- PROTOCOLO 2: DIABETES
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_bvbinsu_id UUID;
  v_omega3_id UUID;
  v_d3k2_id UUID;
  v_jejum_id UUID;
  v_30min_almoco_id UUID;
  v_30min_jantar_id UUID;
BEGIN
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Diabetes';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_bvbinsu_id FROM public.supplements WHERE external_id = 'BVBINSU';
  SELECT id INTO v_omega3_id FROM public.supplements WHERE external_id = 'OMEGA_3';
  SELECT id INTO v_d3k2_id FROM public.supplements WHERE external_id = 'D3K2';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_30min_almoco_id FROM public.usage_times WHERE code = '30MIN_ANTES_ALMOCO';
  SELECT id INTO v_30min_jantar_id FROM public.usage_times WHERE code = '30MIN_ANTES_JANTAR';

  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Diabetes', 'Protocolo para controle glicêmico e diabetes', 'Monitorar glicemia regularmente')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', 1),
    (v_protocol_id, v_bvbinsu_id, v_jejum_id, '2 Cápsulas', 2),
    (v_protocol_id, v_omega3_id, v_30min_almoco_id, '1 Cápsula', 3),
    (v_protocol_id, v_omega3_id, v_30min_jantar_id, '1 Cápsula', 4),
    (v_protocol_id, v_d3k2_id, v_jejum_id, '2 Cápsulas', 5)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

-- =====================================================
-- PROTOCOLO 3: FIBROMIALGIA E ENXAQUECA
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_sdfibro_id UUID;
  v_d3k2_id UUID;
  v_coq10_id UUID;
  v_jejum_id UUID;
  v_apos_cafe_id UUID;
  v_30min_jantar_id UUID;
BEGIN
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Fibromialgia e Enxaqueca';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_sdfibro_id FROM public.supplements WHERE external_id = 'SDFIBRO';
  SELECT id INTO v_d3k2_id FROM public.supplements WHERE external_id = 'D3K2';
  SELECT id INTO v_coq10_id FROM public.supplements WHERE external_id = 'COENZIMA_Q10';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_apos_cafe_id FROM public.usage_times WHERE code = 'APOS_CAFE_MANHA';
  SELECT id INTO v_30min_jantar_id FROM public.usage_times WHERE code = '30MIN_APOS_JANTAR';

  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Fibromialgia e Enxaqueca', 'Protocolo para alívio de dores crônicas e enxaquecas', 'Pode levar algumas semanas para efeito completo')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', 1),
    (v_protocol_id, v_sdfibro_id, v_apos_cafe_id, '2 Cápsulas', 2),
    (v_protocol_id, v_d3k2_id, v_apos_cafe_id, '2 Cápsulas', 3),
    (v_protocol_id, v_coq10_id, v_30min_jantar_id, '2 Cápsulas', 4)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

-- =====================================================
-- PROTOCOLO 4: INSÔNIA
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_sdfibro_id UUID;
  v_seremix_id UUID;
  v_jejum_id UUID;
  v_as_10h_id UUID;
  v_30min_jantar_id UUID;
BEGIN
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Insônia';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_sdfibro_id FROM public.supplements WHERE external_id = 'SDFIBRO';
  SELECT id INTO v_seremix_id FROM public.supplements WHERE external_id = 'SEREMIX';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_as_10h_id FROM public.usage_times WHERE code = 'AS_10H_MANHA';
  SELECT id INTO v_30min_jantar_id FROM public.usage_times WHERE code = '30MIN_APOS_JANTAR';

  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Insônia', 'Protocolo para melhora da qualidade do sono', 'Tomar Seremix 30 minutos antes de dormir')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', 1),
    (v_protocol_id, v_sdfibro_id, v_as_10h_id, '2 Cápsulas', 2),
    (v_protocol_id, v_seremix_id, v_30min_jantar_id, '1 Cápsula', 3)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

-- =====================================================
-- PROTOCOLO 5: EMAGRECIMENTO
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_propoway_id UUID;
  v_spirulina_id UUID;
  v_lipoway_id UUID;
  v_amargo_id UUID;
  v_jejum_id UUID;
  v_apos_cafe_id UUID;
  v_as_10h_id UUID;
  v_30min_almoco_id UUID;
  v_30min_jantar_id UUID;
  v_apos_almoco_id UUID;
BEGIN
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Emagrecimento';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_propoway_id FROM public.supplements WHERE external_id = 'PROPOWAY_VERMELHA';
  SELECT id INTO v_spirulina_id FROM public.supplements WHERE external_id = 'SPIRULINA';
  SELECT id INTO v_lipoway_id FROM public.supplements WHERE external_id = 'LIPOWAY';
  SELECT id INTO v_amargo_id FROM public.supplements WHERE external_id = 'AMARGO';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_apos_cafe_id FROM public.usage_times WHERE code = 'APOS_CAFE_MANHA';
  SELECT id INTO v_as_10h_id FROM public.usage_times WHERE code = 'AS_10H_MANHA';
  SELECT id INTO v_30min_almoco_id FROM public.usage_times WHERE code = '30MIN_ANTES_ALMOCO';
  SELECT id INTO v_30min_jantar_id FROM public.usage_times WHERE code = '30MIN_ANTES_JANTAR';
  SELECT id INTO v_apos_almoco_id FROM public.usage_times WHERE code = 'APOS_ALMOCO';

  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Emagrecimento', 'Protocolo completo para perda de peso e redução de gordura', 'Aumentar ingestão de água. Spirulina: começar com 3 comprimidos, aumentar 1 por dia até observar fezes esverdeadas ou atingir 12 comprimidos. Não tomar com outro suplemento no mesmo horário (intervalo de 2h).')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, notes, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', NULL, 1),
    (v_protocol_id, v_propoway_id, v_jejum_id, '2 Cápsulas', NULL, 2),
    (v_protocol_id, v_spirulina_id, v_as_10h_id, '3-12 Comprimidos', 'Começar com 3, aumentar 1 por dia até fezes esverdeadas ou 12 comprimidos. Não tomar com outro suplemento no mesmo horário (intervalo 2h).', 3),
    (v_protocol_id, v_lipoway_id, v_30min_almoco_id, '1 Cápsula', 'Contém cafeína. Se interferir no sono, tomar mais cedo ou antes de exercícios.', 4),
    (v_protocol_id, v_lipoway_id, v_30min_jantar_id, '1 Cápsula', NULL, 5),
    (v_protocol_id, v_amargo_id, v_apos_almoco_id, '2 Colheres de Sopa', NULL, 6)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

-- =====================================================
-- PROTOCOLO 6: DESINTOXICAÇÃO
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_propoway_id UUID;
  v_spirulina_id UUID;
  v_amargo_id UUID;
  v_jejum_id UUID;
  v_as_10h_id UUID;
  v_apos_almoco_id UUID;
BEGIN
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Desintoxicação';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_propoway_id FROM public.supplements WHERE external_id = 'PROPOWAY_VERMELHA';
  SELECT id INTO v_spirulina_id FROM public.supplements WHERE external_id = 'SPIRULINA';
  SELECT id INTO v_amargo_id FROM public.supplements WHERE external_id = 'AMARGO';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_as_10h_id FROM public.usage_times WHERE code = 'AS_10H_MANHA';
  SELECT id INTO v_apos_almoco_id FROM public.usage_times WHERE code = 'APOS_ALMOCO';

  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Desintoxicação', 'Protocolo para desintoxicação e limpeza do organismo', 'Aumentar ingestão de água durante o protocolo')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', 1),
    (v_protocol_id, v_propoway_id, v_jejum_id, '2 Cápsulas', 2),
    (v_protocol_id, v_spirulina_id, v_as_10h_id, '3 Comprimidos', 3),
    (v_protocol_id, v_amargo_id, v_apos_almoco_id, '2 Colheres de Sopa', 4)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

-- =====================================================
-- PROTOCOLO 7: SAÚDE ÍNTIMA
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_d3k2_id UUID;
  v_propoway_id UUID;
  v_sabonete_id UUID;
  v_oleo_hot_id UUID;
  v_jejum_id UUID;
  v_apos_cafe_id UUID;
  v_uso_diario_id UUID;
BEGIN
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Saúde Íntima';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_d3k2_id FROM public.supplements WHERE external_id = 'D3K2';
  SELECT id INTO v_propoway_id FROM public.supplements WHERE external_id = 'PROPOWAY_VERMELHA';
  SELECT id INTO v_sabonete_id FROM public.supplements WHERE external_id = 'SABONETE_INTIMO';
  SELECT id INTO v_oleo_hot_id FROM public.supplements WHERE external_id = 'OLEO_HOT';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_apos_cafe_id FROM public.usage_times WHERE code = 'APOS_CAFE_MANHA';
  SELECT id INTO v_uso_diario_id FROM public.usage_times WHERE code = 'USO_DIARIO';

  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Saúde Íntima', 'Protocolo completo para saúde íntima feminina', 'Manter higiene adequada')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', 1),
    (v_protocol_id, v_d3k2_id, v_apos_cafe_id, '2 Cápsulas', 2),
    (v_protocol_id, v_propoway_id, v_jejum_id, '2 Cápsulas', 3),
    (v_protocol_id, v_sabonete_id, v_uso_diario_id, '1x ao dia', 4),
    (v_protocol_id, v_oleo_hot_id, v_uso_diario_id, 'Todas as noites', 5)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

-- =====================================================
-- PROTOCOLO 8: MENOPAUSA
-- =====================================================
DO $$
DECLARE
  v_condition_id UUID;
  v_protocol_id UUID;
  v_ozonio_id UUID;
  v_prowoman_id UUID;
  v_propoway_id UUID;
  v_d3k2_id UUID;
  v_oleo_primula_id UUID;
  v_jejum_id UUID;
  v_apos_cafe_id UUID;
  v_30min_almoco_id UUID;
BEGIN
  SELECT id INTO v_condition_id FROM public.health_conditions WHERE name = 'Menopausa';
  SELECT id INTO v_ozonio_id FROM public.supplements WHERE external_id = 'OZONIO';
  SELECT id INTO v_prowoman_id FROM public.supplements WHERE external_id = 'PROWOMAN';
  SELECT id INTO v_propoway_id FROM public.supplements WHERE external_id = 'PROPOWAY_VERMELHA';
  SELECT id INTO v_d3k2_id FROM public.supplements WHERE external_id = 'D3K2';
  SELECT id INTO v_oleo_primula_id FROM public.supplements WHERE external_id = 'OLEO_PRIMULA';
  SELECT id INTO v_jejum_id FROM public.usage_times WHERE code = 'EM_JEJUM';
  SELECT id INTO v_apos_cafe_id FROM public.usage_times WHERE code = 'APOS_CAFE_MANHA';
  SELECT id INTO v_30min_almoco_id FROM public.usage_times WHERE code = '30MIN_ANTES_ALMOCO';

  INSERT INTO public.supplement_protocols (health_condition_id, name, description, notes)
  VALUES (v_condition_id, 'Protocolo Menopausa', 'Protocolo para alívio dos sintomas da menopausa', 'Acompanhamento médico recomendado')
  ON CONFLICT (health_condition_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    notes = EXCLUDED.notes,
    updated_at = NOW()
  RETURNING id INTO v_protocol_id;

  IF v_protocol_id IS NULL THEN
    SELECT id INTO v_protocol_id FROM public.supplement_protocols WHERE health_condition_id = v_condition_id LIMIT 1;
  END IF;

  INSERT INTO public.protocol_supplements (protocol_id, supplement_id, usage_time_id, dosage, display_order)
  VALUES
    (v_protocol_id, v_ozonio_id, v_jejum_id, '2 Cápsulas', 1),
    (v_protocol_id, v_prowoman_id, v_apos_cafe_id, '2 Cápsulas', 2),
    (v_protocol_id, v_propoway_id, v_jejum_id, '2 Cápsulas', 3),
    (v_protocol_id, v_d3k2_id, v_apos_cafe_id, '2 Cápsulas', 4),
    (v_protocol_id, v_oleo_primula_id, v_30min_almoco_id, '2 Cápsulas', 5)
  ON CONFLICT (protocol_id, supplement_id, usage_time_id) DO NOTHING;
END $$;

