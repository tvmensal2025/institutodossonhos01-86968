-- Fix visibility for admin on critical tables
-- Date: 2025-11-23

-- 0. CRIAR FUNÇÃO DE VERIFICAÇÃO DE ADMIN (CRUCIAL: Executar primeiro)
CREATE OR REPLACE FUNCTION public.is_rafael_or_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    -- 1. Verifica email específico (Super Admin Hardcoded)
    (SELECT email FROM auth.users WHERE id = auth.uid()) = 'rafael.ids@icloud.com'
    OR
    -- 2. Verifica flag de admin no profile
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = auth.uid() 
      AND (role = 'admin' OR is_admin = true)
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 1. Profiles
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users and admins can view profiles" ON profiles;

CREATE POLICY "Users and admins can view profiles" ON profiles
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

-- 2. User Anamnesis
ALTER TABLE user_anamnesis ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own anamnesis" ON user_anamnesis;
DROP POLICY IF EXISTS "Users can insert own anamnesis" ON user_anamnesis;
DROP POLICY IF EXISTS "Users can update own anamnesis" ON user_anamnesis;

CREATE POLICY "Users can view own anamnesis" ON user_anamnesis
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

CREATE POLICY "Users can insert own anamnesis" ON user_anamnesis
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

CREATE POLICY "Users can update own anamnesis" ON user_anamnesis
  FOR UPDATE USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

-- 3. Weight Measurements
DROP POLICY IF EXISTS "Users can view own weight measurements" ON weight_measurements;
DROP POLICY IF EXISTS "Users and admins can view weight measurements" ON weight_measurements;

CREATE POLICY "Users and admins can view weight measurements" ON weight_measurements
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

-- 4. User Goals
DROP POLICY IF EXISTS "Users can view own goals" ON user_goals;
DROP POLICY IF EXISTS "Users and admins can view goals" ON user_goals;

CREATE POLICY "Users and admins can view goals" ON user_goals
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

-- 5. Weekly Analyses
DROP POLICY IF EXISTS "Users can view own weekly analyses" ON weekly_analyses;
DROP POLICY IF EXISTS "Users and admins can view weekly analyses" ON weekly_analyses;

CREATE POLICY "Users and admins can view weekly analyses" ON weekly_analyses
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

-- 6. User Physical Data
DROP POLICY IF EXISTS "Users can view own physical data" ON user_physical_data;
DROP POLICY IF EXISTS "Users and admins can view physical data" ON user_physical_data;

CREATE POLICY "Users and admins can view physical data" ON user_physical_data
  FOR SELECT USING (
    auth.uid() = user_id 
    OR 
    public.is_rafael_or_admin()
  );

-- 7. User Missions / Sessions
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_missions') THEN
    DROP POLICY IF EXISTS "Users can view own missions" ON user_missions;
    DROP POLICY IF EXISTS "Users and admins can view missions" ON user_missions;
    EXECUTE 'CREATE POLICY "Users and admins can view missions" ON user_missions FOR SELECT USING (auth.uid() = user_id OR public.is_rafael_or_admin())';
  END IF;

  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'daily_mission_sessions') THEN
    DROP POLICY IF EXISTS "Users can view own mission sessions" ON daily_mission_sessions;
    DROP POLICY IF EXISTS "Users and admins can view mission sessions" ON daily_mission_sessions;
    EXECUTE 'CREATE POLICY "Users and admins can view mission sessions" ON daily_mission_sessions FOR SELECT USING (auth.uid() = user_id OR public.is_rafael_or_admin())';
  END IF;
END $$;
