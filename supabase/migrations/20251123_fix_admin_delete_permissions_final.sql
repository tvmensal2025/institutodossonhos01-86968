-- Solução DEFINITIVA: Criar função SECURITY DEFINER para verificar super admin
-- A política RLS não pode acessar auth.users diretamente, então usamos uma função
-- Data: 2025-11-23

-- 1. Criar função que verifica se é super admin (SECURITY DEFINER permite acessar auth.users)
CREATE OR REPLACE FUNCTION public.is_super_admin_by_email()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'rafael.ids@icloud.com'
  );
END;
$$;

-- 2. Garantir que a função tenha as permissões corretas
GRANT EXECUTE ON FUNCTION public.is_super_admin_by_email() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_super_admin_by_email() TO anon;

-- ============================================
-- TABELA: courses
-- ============================================

-- Remover TODAS as políticas DELETE existentes
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'courses' 
        AND cmd = 'DELETE'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.courses', r.policyname);
    END LOOP;
END $$;

-- Criar política usando a função SECURITY DEFINER
CREATE POLICY "Super admin can delete courses" ON courses
  FOR DELETE USING (public.is_super_admin_by_email());

-- ============================================
-- TABELA: course_modules
-- ============================================

-- Remover TODAS as políticas DELETE existentes
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'course_modules' 
        AND cmd = 'DELETE'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.course_modules', r.policyname);
    END LOOP;
END $$;

-- Criar política usando a função SECURITY DEFINER
CREATE POLICY "Super admin can delete course modules" ON course_modules
  FOR DELETE USING (public.is_super_admin_by_email());

-- ============================================
-- TABELA: lessons
-- ============================================

-- Remover TODAS as políticas DELETE existentes
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'lessons' 
        AND cmd = 'DELETE'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.lessons', r.policyname);
    END LOOP;
END $$;

-- Criar política usando a função SECURITY DEFINER
CREATE POLICY "Super admin can delete lessons" ON lessons
  FOR DELETE USING (public.is_super_admin_by_email());

-- ============================================
-- Verificação final
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '✅ Função is_super_admin_by_email() criada com SECURITY DEFINER';
  RAISE NOTICE '✅ Políticas DELETE recriadas usando a função';
  RAISE NOTICE '📧 Super Admin: rafael.ids@icloud.com';
  RAISE NOTICE '🔐 Agora você pode excluir cursos, módulos e aulas sem erro 42501';
END $$;
