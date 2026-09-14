
-- challenge_routes insert
DROP POLICY IF EXISTS "routes insert authenticated" ON public.challenge_routes;
CREATE POLICY "routes insert by institution or admin" ON public.challenge_routes
FOR INSERT TO authenticated WITH CHECK (
  private.has_role(auth.uid(), 'official_admin'::app_role)
  OR EXISTS (SELECT 1 FROM public.institutions i WHERE i.id = challenge_routes.institution_id AND i.owner_id = auth.uid())
);

-- milestones insert/update
DROP POLICY IF EXISTS "milestones write authenticated" ON public.milestones;
CREATE POLICY "milestones insert by institution or admin" ON public.milestones
FOR INSERT TO authenticated WITH CHECK (
  private.has_role(auth.uid(), 'official_admin'::app_role)
  OR EXISTS (
    SELECT 1 FROM public.projects p JOIN public.institutions i ON i.id = p.institution_id
    WHERE p.id = milestones.project_id AND i.owner_id = auth.uid())
);

DROP POLICY IF EXISTS "milestones update authenticated" ON public.milestones;
CREATE POLICY "milestones update by institution or admin" ON public.milestones
FOR UPDATE TO authenticated USING (
  private.has_role(auth.uid(), 'official_admin'::app_role)
  OR EXISTS (
    SELECT 1 FROM public.projects p JOIN public.institutions i ON i.id = p.institution_id
    WHERE p.id = milestones.project_id AND i.owner_id = auth.uid())
) WITH CHECK (
  private.has_role(auth.uid(), 'official_admin'::app_role)
  OR EXISTS (
    SELECT 1 FROM public.projects p JOIN public.institutions i ON i.id = p.institution_id
    WHERE p.id = milestones.project_id AND i.owner_id = auth.uid())
);

-- notifications insert
DROP POLICY IF EXISTS "notifications insert authenticated" ON public.notifications;
CREATE POLICY "notifications insert own" ON public.notifications
FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- projects insert
DROP POLICY IF EXISTS "projects insert authenticated" ON public.projects;
CREATE POLICY "projects insert by institution or admin" ON public.projects
FOR INSERT TO authenticated WITH CHECK (
  private.has_role(auth.uid(), 'official_admin'::app_role)
  OR EXISTS (SELECT 1 FROM public.institutions i WHERE i.id = projects.institution_id AND i.owner_id = auth.uid())
);

-- resolution_proofs read
DROP POLICY IF EXISTS "proofs read authenticated" ON public.resolution_proofs;
CREATE POLICY "proofs read scoped" ON public.resolution_proofs
FOR SELECT TO authenticated USING (
  worker_id = auth.uid()
  OR private.has_role(auth.uid(), 'official_admin'::app_role)
  OR private.has_role(auth.uid(), 'worker'::app_role)
  OR EXISTS (SELECT 1 FROM public.civic_issues c WHERE c.id = resolution_proofs.civic_issue_id AND c.created_by = auth.uid())
);

-- verifications read
DROP POLICY IF EXISTS "votes read authenticated" ON public.verifications;
CREATE POLICY "votes read scoped" ON public.verifications
FOR SELECT TO authenticated USING (
  user_id = auth.uid()
  OR private.has_role(auth.uid(), 'official_admin'::app_role)
  OR EXISTS (SELECT 1 FROM public.civic_issues c WHERE c.id = verifications.civic_issue_id AND c.created_by = auth.uid())
);

-- storage: civic-evidence ownership + update/delete
DROP POLICY IF EXISTS "evidence read" ON storage.objects;
CREATE POLICY "evidence read own or staff" ON storage.objects
FOR SELECT TO authenticated USING (
  bucket_id = 'civic-evidence' AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR private.has_role(auth.uid(), 'official_admin'::app_role)
    OR private.has_role(auth.uid(), 'worker'::app_role)
  )
);

DROP POLICY IF EXISTS "evidence upload" ON storage.objects;
CREATE POLICY "evidence upload own or staff" ON storage.objects
FOR INSERT TO authenticated WITH CHECK (
  bucket_id = 'civic-evidence' AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR ((storage.foldername(name))[1] = 'resolutions' AND (
      private.has_role(auth.uid(), 'worker'::app_role)
      OR private.has_role(auth.uid(), 'official_admin'::app_role)))
  )
);

CREATE POLICY "evidence update own or admin" ON storage.objects
FOR UPDATE TO authenticated USING (
  bucket_id = 'civic-evidence' AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR private.has_role(auth.uid(), 'official_admin'::app_role))
) WITH CHECK (
  bucket_id = 'civic-evidence' AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR private.has_role(auth.uid(), 'official_admin'::app_role))
);

CREATE POLICY "evidence delete own or admin" ON storage.objects
FOR DELETE TO authenticated USING (
  bucket_id = 'civic-evidence' AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR private.has_role(auth.uid(), 'official_admin'::app_role))
);
