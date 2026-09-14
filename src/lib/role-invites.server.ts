// Server-only role elevation via single-use, expiring, hashed invitation codes.
import { supabaseAdmin } from "@/integrations/supabase/client.server";

type Role = "worker" | "official_admin" | "university" | "industry" | "government";

async function hashCode(code: string): Promise<string> {
  const bytes = new TextEncoder().encode(code.trim());
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/** Redeem an invitation code and grant the role it carries. Codes are single-use and expiring. */
export async function redeemRoleInvite(userId: string, code: string, allowed: Role[]) {
  const codeHash = await hashCode(code);
  const { data: invite } = await supabaseAdmin
    .from("role_invites")
    .select("id, role, expires_at, used_by")
    .eq("code_hash", codeHash)
    .maybeSingle();

  if (!invite || invite.used_by || new Date(invite.expires_at).getTime() < Date.now()) {
    throw new Error("Invalid or expired invitation code");
  }
  if (!allowed.includes(invite.role as Role)) {
    throw new Error("Invalid or expired invitation code");
  }

  // Claim the invite atomically-ish: only succeeds while still unused.
  const { data: claimed } = await supabaseAdmin
    .from("role_invites")
    .update({ used_by: userId, used_at: new Date().toISOString() })
    .eq("id", invite.id)
    .is("used_by", null)
    .select("id")
    .maybeSingle();
  if (!claimed) throw new Error("Invalid or expired invitation code");

  const { error } = await supabaseAdmin
    .from("user_roles")
    .upsert({ user_id: userId, role: invite.role }, { onConflict: "user_id,role" });
  if (error) throw new Error("Could not apply invitation");

  return { role: invite.role as Role };
}

/** Issue a new invitation code. Caller must already be an administrator. */
export async function issueRoleInvite(adminUserId: string, role: Role, expiresInDays = 7) {
  const { data: isAdmin } = await supabaseAdmin
    .from("user_roles")
    .select("role")
    .eq("user_id", adminUserId)
    .eq("role", "official_admin")
    .maybeSingle();
  if (!isAdmin) throw new Error("Not authorised");

  const raw = crypto.randomUUID().replace(/-/g, "") + crypto.randomUUID().replace(/-/g, "");
  const code = raw.slice(0, 32).toUpperCase();
  const { error } = await supabaseAdmin.from("role_invites").insert({
    code_hash: await hashCode(code),
    role,
    created_by: adminUserId,
    expires_at: new Date(Date.now() + expiresInDays * 86400000).toISOString(),
  });
  if (error) throw new Error("Could not create invitation");
  // Returned once; never stored or retrievable in plaintext.
  return { code, role, expiresInDays };
}
