-- =====================================================
-- APLICAR 50% DE DESCONTO PARA CLIENTES CADASTRADOS
-- =====================================================

-- 1. Atualizar TODOS os produtos existentes para terem 50% de desconto
UPDATE public.supplements
SET discount_price = ROUND(original_price * 0.5, 2)
WHERE original_price IS NOT NULL;

-- 2. Criar função para calcular automaticamente o desconto de 50%
CREATE OR REPLACE FUNCTION public.calculate_discount_price()
RETURNS TRIGGER AS $$
BEGIN
  -- Se original_price foi atualizado, recalcula discount_price como 50%
  IF NEW.original_price IS NOT NULL THEN
    NEW.discount_price := ROUND(NEW.original_price * 0.5, 2);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Criar trigger para aplicar desconto automaticamente
DROP TRIGGER IF EXISTS trigger_calculate_discount_price ON public.supplements;
CREATE TRIGGER trigger_calculate_discount_price
  BEFORE INSERT OR UPDATE OF original_price ON public.supplements
  FOR EACH ROW
  EXECUTE FUNCTION public.calculate_discount_price();

-- 4. Comentário na coluna para documentação
COMMENT ON COLUMN public.supplements.discount_price IS 'Preço com 50% de desconto para clientes cadastrados. Calculado automaticamente como 50% do original_price.';

