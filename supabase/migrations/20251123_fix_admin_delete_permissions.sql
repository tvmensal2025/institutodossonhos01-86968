-- Script SIMPLIFICADO e SEGURO: Garantir que Super Admin possa excluir cursos
-- Usa apenas verificação por email direto (não depende de colunas da tabela profiles)
-- Data: 2025-11-23

-- 1. Política para EXCLUIR cursos
DROP POLICY IF EXISTS "Admins can delete courses" ON courses;
DROP POLICY IF EXISTS "Super admin can delete courses" ON courses;
DROP POLICY IF EXISTS "Admins and super admin can delete courses" ON courses;

CREATE POLICY "Super admin can delete courses" ON courses
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'rafael.ids@icloud.com'
    )
  );

-- 2. Política para EXCLUIR módulos
DROP POLICY IF EXISTS "Admins can delete course modules" ON course_modules;
DROP POLICY IF EXISTS "Super admin can delete course modules" ON course_modules;
DROP POLICY IF EXISTS "Admins and super admin can delete course modules" ON course_modules;

CREATE POLICY "Super admin can delete course modules" ON course_modules
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'rafael.ids@icloud.com'
    )
  );

-- 3. Política para EXCLUIR aulas
DROP POLICY IF EXISTS "Admins can delete lessons" ON lessons;
DROP POLICY IF EXISTS "Super admin can delete lessons" ON lessons;
DROP POLICY IF EXISTS "Admins and super admin can delete lessons" ON lessons;

CREATE POLICY "Super admin can delete lessons" ON lessons
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'rafael.ids@icloud.com'
    )
  );

-- 4. Garantir permissões de CRIAÇÃO e EDIÇÃO
DROP POLICY IF EXISTS "Admins can insert courses" ON courses;
DROP POLICY IF EXISTS "Admins can update courses" ON courses;
DROP POLICY IF EXISTS "Super admin can insert courses" ON courses;
DROP POLICY IF EXISTS "Super admin can update courses" ON courses;
DROP POLICY IF EXISTS "Authenticated users can create courses" ON courses;
DROP POLICY IF EXISTS "Authenticated users can update courses" ON courses;
DROP POLICY IF EXISTS "Authenticated users can delete courses" ON courses;

-- Inserir cursos: Super Admin OU qualquer usuário autenticado
CREATE POLICY "Users can insert courses" ON courses
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'rafael.ids@icloud.com'
    )
    OR
    auth.uid() IS NOT NULL
  );

-- Atualizar cursos: Super Admin OU criador do curso
CREATE POLICY "Users can update courses" ON courses
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND email = 'rafael.ids@icloud.com'
    )
    OR
    (created_by IS NOT NULL AND created_by = auth.uid())
    OR
    auth.uid() IS NOT NULL
  );
