// =====================================================================
// push — Yeni bildirim satırını Firebase Cloud Messaging ile telefona gönderir.
// notifications tablosundaki tetikleyici (pg_net) bu fonksiyonu çağırır.
//
// Gerekli gizli değerler (supabase secrets set ...):
//   WEBHOOK_SECRET            Vault'taki 'webhook_secret' ile aynı değer
//   FIREBASE_SERVICE_ACCOUNT  Firebase > Proje ayarları > Hizmet hesapları >
//                             "Yeni özel anahtar oluştur" ile inen JSON'un tamamı
// SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY Supabase tarafından otomatik verilir.
//
// Dağıtım: supabase functions deploy push --no-verify-jwt
// =====================================================================
import { createClient } from "npm:@supabase/supabase-js@2.49.4";

type NotificationType = "comment" | "reply" | "like" | "mention" | "moderation";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

// Bildirim metinleri (uygulamadaki TR/EN metinlerle uyumlu)
const texts: Record<"tr" | "en", Record<NotificationType, (actor: string) => string>> = {
  tr: {
    comment: (a) => `@${a} içeriğine yorum yaptı`,
    reply: (a) => `@${a} yorumuna yanıt verdi`,
    like: (a) => `@${a} içeriğini beğendi`,
    mention: (a) => `@${a} bir yorumda senden bahsetti`,
    moderation: () => "Hesabınla ilgili bir moderasyon bildirimi var",
  },
  en: {
    comment: (a) => `@${a} commented on your post`,
    reply: (a) => `@${a} replied to your comment`,
    like: (a) => `@${a} liked your post`,
    mention: (a) => `@${a} mentioned you in a comment`,
    moderation: () => "You have a moderation notice about your account",
  },
};

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== Deno.env.get("WEBHOOK_SECRET")) {
    return new Response("unauthorized", { status: 401 });
  }

  const { notification_id } = await req.json().catch(() => ({}));
  if (!notification_id) return new Response("missing notification_id", { status: 400 });

  const { data: n, error } = await supabase
    .from("notifications")
    .select("id, type, recipient_id, post_id, comment_id, actor:profiles!notifications_actor_id_fkey(nickname), recipient:profiles!notifications_recipient_id_fkey(locale), post:posts(title)")
    .eq("id", notification_id)
    .maybeSingle();
  if (error || !n) return new Response("not found", { status: 404 });

  const { data: tokens } = await supabase
    .from("device_tokens")
    .select("token")
    .eq("user_id", n.recipient_id);
  if (!tokens || tokens.length === 0) return new Response("no devices", { status: 200 });

  // deno-lint-ignore no-explicit-any
  const one = (x: any) => (Array.isArray(x) ? x[0] : x);
  const locale: "tr" | "en" = one(n.recipient)?.locale === "en" ? "en" : "tr";
  const actor = one(n.actor)?.nickname ?? "peerless";
  const title = n.type === "moderation" ? "Peerless" : (one(n.post)?.title || "Peerless");
  const body = texts[locale][n.type as NotificationType](actor);

  const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}");
  if (!serviceAccount.private_key) return new Response("firebase not configured", { status: 200 });
  const accessToken = await getGoogleAccessToken(serviceAccount);

  let sent = 0;
  for (const { token } of tokens) {
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: { Authorization: `Bearer ${accessToken}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body },
            data: {
              type: n.type,
              notification_id: n.id,
              post_id: n.post_id ?? "",
              comment_id: n.comment_id ?? "",
            },
            android: { priority: "high" },
          },
        }),
      },
    );
    if (res.ok) {
      sent++;
    } else if (res.status === 404 || res.status === 400) {
      // Uygulama silinmiş / anahtar geçersiz: kaydı temizle.
      const err = await res.text();
      if (err.includes("UNREGISTERED") || err.includes("INVALID_ARGUMENT")) {
        await supabase.from("device_tokens").delete().eq("token", token);
      }
    }
  }
  return new Response(JSON.stringify({ sent }), { headers: { "Content-Type": "application/json" } });
});

// Hizmet hesabıyla imzalı bir JWT üretip Google'dan kısa ömürlü erişim anahtarı alır.
async function getGoogleAccessToken(sa: { client_email: string; private_key: string }) {
  const now = Math.floor(Date.now() / 1000);
  const enc = (obj: unknown) => base64url(new TextEncoder().encode(JSON.stringify(obj)));
  const unsigned = `${enc({ alg: "RS256", typ: "JWT" })}.${enc({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  })}`;

  const pem = sa.private_key.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );
  const jwt = `${unsigned}.${base64url(signature)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const json = await res.json();
  if (!json.access_token) throw new Error(`Google token alınamadı: ${JSON.stringify(json)}`);
  return json.access_token as string;
}

function base64url(bytes: Uint8Array) {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
