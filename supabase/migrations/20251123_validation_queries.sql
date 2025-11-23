-- =====================================================
-- QUERIES DE VALIDAÇÃO E VERIFICAÇÃO
-- Execute após todas as migrações para validar integridade
-- =====================================================

-- 1. Verificar produtos duplicados por external_id
SELECT 
    external_id, 
    COUNT(*) as quantidade,
    array_agg(name) as nomes
FROM public.supplements
WHERE external_id IS NOT NULL
GROUP BY external_id
HAVING COUNT(*) > 1;

-- 2. Verificar produtos sem external_id
SELECT 
    id,
    name,
    brand
FROM public.supplements
WHERE external_id IS NULL;

-- 3. Verificar protocolos sem produtos associados
SELECT 
    sp.id,
    sp.name,
    hc.name as condicao
FROM public.supplement_protocols sp
LEFT JOIN public.protocol_supplements ps ON ps.protocol_id = sp.id
LEFT JOIN public.health_conditions hc ON hc.id = sp.health_condition_id
WHERE ps.id IS NULL;

-- 4. Verificar produtos referenciados em protocolos que não existem
SELECT DISTINCT
    ps.supplement_id,
    s.name as produto_nao_encontrado
FROM public.protocol_supplements ps
LEFT JOIN public.supplements s ON s.id = ps.supplement_id
WHERE s.id IS NULL;

-- 5. Verificar horários referenciados que não existem
SELECT DISTINCT
    ps.usage_time_id,
    ut.name as horario_nao_encontrado
FROM public.protocol_supplements ps
LEFT JOIN public.usage_times ut ON ut.id = ps.usage_time_id
WHERE ut.id IS NULL;

-- 6. Estatísticas gerais
SELECT 
    'Produtos' as tipo,
    COUNT(*) as total
FROM public.supplements
UNION ALL
SELECT 
    'Condições de Saúde',
    COUNT(*)
FROM public.health_conditions
UNION ALL
SELECT 
    'Protocolos',
    COUNT(*)
FROM public.supplement_protocols
UNION ALL
SELECT 
    'Horários',
    COUNT(*)
FROM public.usage_times
UNION ALL
SELECT 
    'Associações Protocolo-Produto',
    COUNT(*)
FROM public.protocol_supplements;

-- 7. Protocolos mais completos (com mais produtos)
SELECT 
    sp.name as protocolo,
    hc.name as condicao,
    COUNT(ps.id) as total_produtos
FROM public.supplement_protocols sp
JOIN public.health_conditions hc ON hc.id = sp.health_condition_id
LEFT JOIN public.protocol_supplements ps ON ps.protocol_id = sp.id
GROUP BY sp.id, sp.name, hc.name
ORDER BY total_produtos DESC;

-- 8. Produtos mais usados em protocolos
SELECT 
    s.name as produto,
    s.external_id,
    COUNT(DISTINCT ps.protocol_id) as total_protocolos
FROM public.supplements s
JOIN public.protocol_supplements ps ON ps.supplement_id = s.id
GROUP BY s.id, s.name, s.external_id
ORDER BY total_protocolos DESC;

-- 9. Verificar condições sem protocolos
SELECT 
    hc.name as condicao_sem_protocolo
FROM public.health_conditions hc
LEFT JOIN public.supplement_protocols sp ON sp.health_condition_id = hc.id
WHERE sp.id IS NULL;

-- 10. Listar todos os produtos e seus protocolos
SELECT 
    s.name as produto,
    s.external_id,
    hc.name as condicao,
    sp.name as protocolo,
    ut.name as horario,
    ps.dosage as dosagem
FROM public.supplements s
JOIN public.protocol_supplements ps ON ps.supplement_id = s.id
JOIN public.supplement_protocols sp ON sp.id = ps.protocol_id
JOIN public.health_conditions hc ON hc.id = sp.health_condition_id
JOIN public.usage_times ut ON ut.id = ps.usage_time_id
ORDER BY hc.name, sp.name, ut.display_order;

