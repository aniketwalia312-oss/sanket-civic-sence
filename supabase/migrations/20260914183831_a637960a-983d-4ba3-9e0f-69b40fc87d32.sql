CREATE TABLE public.role_invites (
  id uuid primary key default gen_random_uuid(),
  code_hash text not null unique,
  role app_role not null,
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_by uuid references auth.users(id) on delete set null,
  used_by uuid references auth.users(id) on delete set null,
  used_at timestamptz,
  created_at timestamptz not null default now()
);
GRANT ALL ON public.role_invites TO service_role;
ALTER TABLE public.role_invites ENABLE ROW LEVEL SECURITY;
CREATE INDEX role_invites_code_hash_idx ON public.role_invites(code_hash);