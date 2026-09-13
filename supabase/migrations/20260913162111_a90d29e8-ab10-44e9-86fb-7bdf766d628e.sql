-- Enums
DO $$ BEGIN CREATE TYPE public.challenge_status AS ENUM ('submitted','validated','routed','proposal_received','in_project','completed','rejected','duplicate'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.institution_type AS ENUM ('university','industry','startup','msme','csr','research_lab','incubator'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.milestone_status AS ENUM ('pending','in_progress','done','blocked'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.partnership_status AS ENUM ('proposed','active','completed','withdrawn'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.partnership_type AS ENUM ('mentorship','funding','prototyping','pilot','tech_transfer','csr_grant'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.project_status AS ENUM ('planning','in_progress','testing','piloting','deployed','completed','stalled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.proposal_status AS ENUM ('draft','submitted','approved','rejected'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.route_status AS ENUM ('routed','accepted','declined'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE public.submitter_type AS ENUM ('citizen','community_org','panchayat','urban_local_body','government_dept','ngo'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Challenges
CREATE TABLE public.challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  domain text NOT NULL DEFAULT 'general',
  tags text[] NOT NULL DEFAULT '{}',
  status public.challenge_status NOT NULL DEFAULT 'submitted',
  submitter_id uuid,
  submitter_type public.submitter_type NOT NULL DEFAULT 'citizen',
  organisation_name text,
  address text,
  district text,
  latitude double precision,
  longitude double precision,
  media_paths text[] NOT NULL DEFAULT '{}',
  document_paths text[] NOT NULL DEFAULT '{}',
  beneficiaries integer NOT NULL DEFAULT 0,
  severity_score numeric NOT NULL DEFAULT 0,
  priority_score numeric NOT NULL DEFAULT 0,
  support_count integer NOT NULL DEFAULT 0,
  ai_confidence numeric NOT NULL DEFAULT 0,
  ai_rationale text,
  ai_summary text,
  duplicate_of uuid REFERENCES public.challenges(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.challenges TO authenticated;
GRANT SELECT ON public.challenges TO anon;
GRANT ALL ON public.challenges TO service_role;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "challenges read all" ON public.challenges FOR SELECT USING (true);
CREATE POLICY "challenges insert own" ON public.challenges FOR INSERT TO authenticated WITH CHECK (submitter_id = auth.uid());
CREATE POLICY "challenges update own or admin" ON public.challenges FOR UPDATE TO authenticated
  USING (submitter_id = auth.uid() OR private.has_role(auth.uid(),'official_admin'));
CREATE POLICY "challenges delete admin" ON public.challenges FOR DELETE TO authenticated
  USING (private.has_role(auth.uid(),'official_admin'));

-- Institutions
CREATE TABLE public.institutions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type public.institution_type NOT NULL,
  description text,
  district text,
  domains text[] NOT NULL DEFAULT '{}',
  contact_email text,
  website text,
  owner_id uuid,
  verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.institutions TO authenticated;
GRANT SELECT ON public.institutions TO anon;
GRANT ALL ON public.institutions TO service_role;
ALTER TABLE public.institutions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "institutions read all" ON public.institutions FOR SELECT USING (true);
CREATE POLICY "institutions insert own" ON public.institutions FOR INSERT TO authenticated WITH CHECK (owner_id = auth.uid());
CREATE POLICY "institutions update own or admin" ON public.institutions FOR UPDATE TO authenticated
  USING (owner_id = auth.uid() OR private.has_role(auth.uid(),'official_admin'));
CREATE POLICY "institutions delete admin" ON public.institutions FOR DELETE TO authenticated
  USING (private.has_role(auth.uid(),'official_admin'));

-- Challenge supports
CREATE TABLE public.challenge_supports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id uuid NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (challenge_id, user_id)
);
GRANT SELECT, INSERT, DELETE ON public.challenge_supports TO authenticated;
GRANT ALL ON public.challenge_supports TO service_role;
ALTER TABLE public.challenge_supports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "supports read authenticated" ON public.challenge_supports FOR SELECT TO authenticated USING (true);
CREATE POLICY "supports insert own" ON public.challenge_supports FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "supports delete own" ON public.challenge_supports FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Challenge messages
CREATE TABLE public.challenge_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id uuid NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  author_name text,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.challenge_messages TO authenticated;
GRANT ALL ON public.challenge_messages TO service_role;
ALTER TABLE public.challenge_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "messages read authenticated" ON public.challenge_messages FOR SELECT TO authenticated USING (true);
CREATE POLICY "messages insert own" ON public.challenge_messages FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "messages delete own or admin" ON public.challenge_messages FOR DELETE TO authenticated
  USING (user_id = auth.uid() OR private.has_role(auth.uid(),'official_admin'));

-- Challenge routes
CREATE TABLE public.challenge_routes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id uuid NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  institution_id uuid NOT NULL REFERENCES public.institutions(id) ON DELETE CASCADE,
  match_score numeric NOT NULL DEFAULT 0,
  rationale text,
  status public.route_status NOT NULL DEFAULT 'routed',
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.challenge_routes TO authenticated;
GRANT ALL ON public.challenge_routes TO service_role;
ALTER TABLE public.challenge_routes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "routes read authenticated" ON public.challenge_routes FOR SELECT TO authenticated USING (true);
CREATE POLICY "routes insert authenticated" ON public.challenge_routes FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "routes update by institution or admin" ON public.challenge_routes FOR UPDATE TO authenticated
  USING (
    private.has_role(auth.uid(),'official_admin')
    OR EXISTS (SELECT 1 FROM public.institutions i WHERE i.id = challenge_routes.institution_id AND i.owner_id = auth.uid())
  );

-- Proposals
CREATE TABLE public.proposals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id uuid NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  institution_id uuid NOT NULL REFERENCES public.institutions(id) ON DELETE CASCADE,
  title text NOT NULL,
  abstract text NOT NULL,
  approach text,
  budget_inr numeric NOT NULL DEFAULT 0,
  duration_weeks integer NOT NULL DEFAULT 0,
  faculty_mentor text,
  team_members jsonb NOT NULL DEFAULT '[]'::jsonb,
  status public.proposal_status NOT NULL DEFAULT 'draft',
  review_notes text,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.proposals TO authenticated;
GRANT ALL ON public.proposals TO service_role;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "proposals read authenticated" ON public.proposals FOR SELECT TO authenticated USING (true);
CREATE POLICY "proposals insert own" ON public.proposals FOR INSERT TO authenticated WITH CHECK (created_by = auth.uid());
CREATE POLICY "proposals update own or admin" ON public.proposals FOR UPDATE TO authenticated
  USING (created_by = auth.uid() OR private.has_role(auth.uid(),'official_admin'));
CREATE POLICY "proposals delete own or admin" ON public.proposals FOR DELETE TO authenticated
  USING (created_by = auth.uid() OR private.has_role(auth.uid(),'official_admin'));

-- Projects
CREATE TABLE public.projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id uuid NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  institution_id uuid NOT NULL REFERENCES public.institutions(id) ON DELETE CASCADE,
  proposal_id uuid UNIQUE REFERENCES public.proposals(id) ON DELETE SET NULL,
  title text NOT NULL,
  status public.project_status NOT NULL DEFAULT 'planning',
  progress numeric NOT NULL DEFAULT 0,
  beneficiaries integer NOT NULL DEFAULT 0,
  patents integer NOT NULL DEFAULT 0,
  startups_created integer NOT NULL DEFAULT 0,
  outcome_summary text,
  started_at timestamptz NOT NULL DEFAULT now(),
  target_date timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.projects TO authenticated;
GRANT SELECT ON public.projects TO anon;
GRANT ALL ON public.projects TO service_role;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "projects read all" ON public.projects FOR SELECT USING (true);
CREATE POLICY "projects insert authenticated" ON public.projects FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "projects update by institution or admin" ON public.projects FOR UPDATE TO authenticated
  USING (
    private.has_role(auth.uid(),'official_admin')
    OR EXISTS (SELECT 1 FROM public.institutions i WHERE i.id = projects.institution_id AND i.owner_id = auth.uid())
  );

-- Milestones
CREATE TABLE public.milestones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  status public.milestone_status NOT NULL DEFAULT 'pending',
  order_index integer NOT NULL DEFAULT 0,
  due_date timestamptz,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.milestones TO authenticated;
GRANT SELECT ON public.milestones TO anon;
GRANT ALL ON public.milestones TO service_role;
ALTER TABLE public.milestones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "milestones read all" ON public.milestones FOR SELECT USING (true);
CREATE POLICY "milestones write authenticated" ON public.milestones FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "milestones update authenticated" ON public.milestones FOR UPDATE TO authenticated USING (true);
CREATE POLICY "milestones delete admin" ON public.milestones FOR DELETE TO authenticated
  USING (private.has_role(auth.uid(),'official_admin'));

-- Partnerships
CREATE TABLE public.partnerships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  institution_id uuid NOT NULL REFERENCES public.institutions(id) ON DELETE CASCADE,
  partner_type public.partnership_type NOT NULL DEFAULT 'mentorship',
  status public.partnership_status NOT NULL DEFAULT 'proposed',
  amount_inr numeric NOT NULL DEFAULT 0,
  notes text,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.partnerships TO authenticated;
GRANT SELECT ON public.partnerships TO anon;
GRANT ALL ON public.partnerships TO service_role;
ALTER TABLE public.partnerships ENABLE ROW LEVEL SECURITY;
CREATE POLICY "partnerships read all" ON public.partnerships FOR SELECT USING (true);
CREATE POLICY "partnerships insert own" ON public.partnerships FOR INSERT TO authenticated WITH CHECK (created_by = auth.uid());
CREATE POLICY "partnerships update own or admin" ON public.partnerships FOR UPDATE TO authenticated
  USING (created_by = auth.uid() OR private.has_role(auth.uid(),'official_admin'));

-- Notifications
CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  body text,
  link text,
  read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notifications read own" ON public.notifications FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "notifications insert authenticated" ON public.notifications FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "notifications update own" ON public.notifications FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "notifications delete own" ON public.notifications FOR DELETE TO authenticated USING (user_id = auth.uid());

-- updated_at triggers
CREATE TRIGGER challenges_set_updated_at BEFORE UPDATE ON public.challenges FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER institutions_set_updated_at BEFORE UPDATE ON public.institutions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER proposals_set_updated_at BEFORE UPDATE ON public.proposals FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER projects_set_updated_at BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();