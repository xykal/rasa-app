/* RASA notify-worker — relay push via OneSignal REST API.
 *
 * Kenapa perlu worker? REST API key OneSignal TIDAK BOLEH ada di aplikasi.
 * Worker ini yang pegang key-nya; backend/Cloud Function cukup panggil worker.
 *
 * Secrets (JANGAN hardcode, pakai wrangler secret put):
 *   ONESIGNAL_APP_ID  -> App ID OneSignal aplikasi RASA
 *   ONESIGNAL_API_KEY -> REST API Key OneSignal aplikasi RASA
 *   NOTIFY_SECRET     -> string acak buatanmu (auth antar backend → worker)
 *
 * Request:
 *   POST /  Authorization: Bearer <NOTIFY_SECRET>
 *   {"toUserId":"<uid penulis>","title":"RASA","message":"...","postId":"<id>"}
 */
export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return json({ error: 'gunakan POST dengan JSON body' }, 405);
    }
    const auth = request.headers.get('authorization') || '';
    if (!env.NOTIFY_SECRET || auth !== `Bearer ${env.NOTIFY_SECRET}`) {
      return json({ error: 'unauthorized' }, 401);
    }
    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'body bukan JSON valid' }, 400);
    }
    const { toUserId, title, message, postId } = body || {};
    if (!toUserId || !message) {
      return json({ error: 'toUserId dan message wajib diisi' }, 400);
    }

    const res = await fetch('https://api.onesignal.com/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Basic ${env.ONESIGNAL_API_KEY}`,
      },
      body: JSON.stringify({
        app_id: env.ONESIGNAL_APP_ID,
        target_channel: 'push',
        include_aliases: { external_id: [toUserId] },
        headings: { en: title || 'RASA' },
        contents: { en: message },
        data: { postId: postId || '' },
      }),
    });
    const out = await res.json().catch(() => ({}));
    return json(
      { ok: res.ok, status: res.status, onesignal: out },
      res.ok ? 200 : 502,
    );
  },
};

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
