# Strava token exchange (Cloudflare Worker)

Holds the Strava client secret so the app never contains it. The app calls
`POST /token` with the one-time code after sign-in and `POST /refresh` when
the access token is about to expire.

## Deploy (once)

Needs Node.js 20 or later (https://nodejs.org) and a free Cloudflare account.

```sh
cd server/strava-token
npx wrangler login
npx wrangler secret put STRAVA_CLIENT_ID      # paste the Strava client ID
npx wrangler secret put STRAVA_CLIENT_SECRET  # paste the Strava client secret
npx wrangler deploy
```

`deploy` prints the worker URL, e.g.
`https://run4share-strava.<your-subdomain>.workers.dev`. Put it in
`config/strava.json` as `STRAVA_TOKEN_URL` (no trailing slash).

## Check it

```sh
curl -s -X POST https://run4share-strava.<your-subdomain>.workers.dev/token \
  -H 'content-type: application/json' -d '{"code":"0000000000000000"}'
```

should answer `{"error":"strava_error","strava_status":400}`: the worker is
up and talking to Strava, which rejected the made-up code.
