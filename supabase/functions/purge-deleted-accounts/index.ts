// =====================================================================
// purge-deleted-accounts — Silme talebinin üzerinden 30 gün geçen hesapları
// ve tüm verilerini (dosyalar dahil) kalıcı olarak siler.
// pg_cron her gün bir kez çağırır (bkz. 20261123000600_cron_push.sql).
//
// Gerekli gizli değer: WEBHOOK_SECRET (Vault'taki 'webhook_secret' ile aynı)
// Dağıtım: supabase functions deploy purge-deleted-accounts --no-verify-jwt
// =====================================================================
import { createClient } from "npm:@supabase/supabase-js@2.49.4";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

const BUCKETS = ["avatars", "covers", "post-images"];

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== Deno.env.get("WEBHOOK_SECRET")) {
    return new Response("unauthorized", { status: 401 });
  }

  const cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
  const { data: due, error } = await supabase
    .from("profiles")
    .select("id")
    .not("deletion_requested_at", "is", null)
    .lt("deletion_requested_at", cutoff)
    .limit(100);
  if (error) return new Response(error.message, { status: 500 });

  const deleted: string[] = [];
  for (const { id } of due ?? []) {
    // 1) Dosyalar: <user_id>/ klasörü altındaki her şey
    for (const bucket of BUCKETS) {
      const paths = await listAll(bucket, id);
      for (let i = 0; i < paths.length; i += 100) {
        await supabase.storage.from(bucket).remove(paths.slice(i, i + 100));
      }
    }
    // 2) Auth kullanıcısı: profil ve bağlı tüm satırlar (cascade) silinir.
    const { error: delError } = await supabase.auth.admin.deleteUser(id);
    if (!delError) deleted.push(id);
  }

  return new Response(JSON.stringify({ deleted: deleted.length }), {
    headers: { "Content-Type": "application/json" },
  });
});

// Bir klasördeki tüm dosya yollarını (alt klasörler dahil) toplar.
async function listAll(bucket: string, prefix: string): Promise<string[]> {
  const out: string[] = [];
  const { data } = await supabase.storage.from(bucket).list(prefix, { limit: 1000 });
  for (const item of data ?? []) {
    const path = `${prefix}/${item.name}`;
    if (item.id === null) {
      out.push(...(await listAll(bucket, path))); // klasör
    } else {
      out.push(path);
    }
  }
  return out;
}
