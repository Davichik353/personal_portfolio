const languages = new Set(['ru', 'uz']);
const placements = new Set(['hero', 'footer']);

export default {
  async fetch(request, env) {
    if (new URL(request.url).pathname !== '/api/telegram-click') {
      return env.ASSETS.fetch(request);
    }

    if (request.method !== 'POST') {
      return new Response(null, { status: 405, headers: { Allow: 'POST' } });
    }
    if (request.headers.get('Sec-Fetch-Site') === 'cross-site') {
      return new Response(null, { status: 403 });
    }
    const payload = await request.json().catch(() => null);
    if (!languages.has(payload?.language) || !placements.has(payload?.placement)) {
      return new Response(null, { status: 400 });
    }
    env.PORTFOLIO_ANALYTICS.writeDataPoint({
      blobs: [payload.language, payload.placement],
    });
    return new Response(null, { status: 204 });
  },
};
