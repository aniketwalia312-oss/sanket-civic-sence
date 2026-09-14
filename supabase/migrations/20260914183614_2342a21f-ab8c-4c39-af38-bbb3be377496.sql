DROP POLICY IF EXISTS "challenges read all" ON public.challenges;
CREATE POLICY "challenges read authenticated" ON public.challenges FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "issues public read" ON public.civic_issues;
CREATE POLICY "issues read authenticated" ON public.civic_issues FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "institutions read all" ON public.institutions;
CREATE POLICY "institutions read authenticated" ON public.institutions FOR SELECT TO authenticated USING (true);

REVOKE SELECT ON public.challenges FROM anon;
REVOKE SELECT ON public.civic_issues FROM anon;
REVOKE SELECT ON public.institutions FROM anon;