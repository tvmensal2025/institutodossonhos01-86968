-- CORREÇÃO URGENTE: Resolver Loop Infinito na RLS
-- O problema anterior foi causado porque a função de verificação lia a tabela 'profiles',
-- e a tabela 'profiles' usava a função para verificar permissão, criando um ciclo infinito
-- que bloqueava todo o acesso.

-- 1. Redefinir a função para NÃO ler a tabela profiles (evitar loop)
CREATE OR REPLACE FUNCTION public.is_rafael_or_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    -- Verifica email específico (Super Admin)
    (SELECT email FROM auth.users WHERE id = auth.uid()) = 'rafael.ids@icloud.com'
    OR
    -- Verifica metadata do usuário no auth.users (mais seguro e sem loop)
    ((SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 2. Reaplicar política da tabela User Anamnesis
DROP POLICY IF EXISTS "Users can view own anamnesis" ON user_anamnesis;
CREATE POLICY "Users can view own anamnesis" ON user_anamnesis
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

-- 3. Reaplicar política da tabela Profiles
DROP POLICY IF EXISTS "Users and admins can view profiles" ON profiles;
CREATE POLICY "Users and admins can view profiles" ON profiles
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

