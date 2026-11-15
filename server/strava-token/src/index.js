// run4share Strava token exchange.
//
// The app never holds the Strava client secret. It sends the one-time code
// (or a refresh token) here; this worker adds the client ID and secret,
// asks Strava for tokens, and returns only the fields the app needs.
//
//   POST /token    {"code": "..."}           -> first connection
//   POST /refresh  {"refresh_token": "..."}  -> new access token
//
// Secrets (set with `wrangler secret put`): STRAVA_CLIENT_ID,
// STRAVA_CLIENT_SECRET. Nothing is stored and nothing is logged.

const STRAVA_TOKEN_URL = 'https://www.strava.com/oauth/token';

export default {
  async fetch(request, env) {
    const { pathname } = new URL(request.url);
    if (request.method !== 'POST') {
      return json({ error: 'method_not_allowed' }, 405);
    }
    if (!env.STRAVA_CLIENT_ID || !env.STRAVA_CLIENT_SECRET) {
      return json({ error: 'not_configured' }, 500);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'invalid_json' }, 400);
    }

    let grant;
    if (pathname === '/token' && isToken(body?.code)) {
      grant = { grant_type: 'authorization_code', code: body.code };
    } else if (pathname === '/refresh' && isToken(body?.refresh_token)) {
      grant = { grant_type: 'refresh_token', refresh_token: body.refresh_token };
    } else if (pathname === '/token' || pathname === '/refresh') {
      return json({ error: 'invalid_request' }, 400);
    } else {
      return json({ error: 'not_found' }, 404);
    }

    const response = await fetch(STRAVA_TOKEN_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: env.STRAVA_CLIENT_ID,
        client_secret: env.STRAVA_CLIENT_SECRET,
        ...grant,
      }),
    });
    const data = await response.json().catch(() => null);

    if (!response.ok || !data?.access_token) {
      // 4xx from Strava means a bad or used code: the app's fault, not ours.
      const status = response.status >= 400 && response.status < 500 ? 400 : 502;
      return json({ error: 'strava_error', strava_status: response.status }, status);
    }

    const out = {
      access_token: data.access_token,
      refresh_token: data.refresh_token,
      expires_at: data.expires_at,
    };
    if (data.athlete) {
      out.athlete = {
        id: data.athlete.id,
        firstname: data.athlete.firstname,
        lastname: data.athlete.lastname,
      };
    }
    return json(out);
  },
};

// Strava codes and tokens are 40 hex characters; allow some slack.
function isToken(value) {
  return typeof value === 'string' && /^[A-Za-z0-9]{16,128}$/.test(value);
}

function json(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'content-type': 'application/json', 'cache-control': 'no-store' },
  });
}
