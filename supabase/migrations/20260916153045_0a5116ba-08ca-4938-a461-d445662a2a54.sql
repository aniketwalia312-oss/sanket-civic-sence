DROP POLICY IF EXISTS "projects read all" ON public.projects;
CREATE POLICY "projects read authenticated" ON public.projects FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "milestones read all" ON public.milestones;
CREATE POLICY "milestones read authenticated" ON public.milestones FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "partnerships read all" ON public.partnerships;
CREATE POLICY "partnerships read authenticated" ON public.partnerships FOR SELECT TO authenticated USING (true);

REVOKE SELECT ON public.projects FROM anon;
REVOKE SELECT ON public.milestones FROM anon;
REVOKE SELECT ON public.partnerships FROM anon;