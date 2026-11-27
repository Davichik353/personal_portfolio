document.addEventListener('click', (event) => {
  const link = event.target.closest('[data-telegram-placement]');
  if (!link) return;

  // The link works with or without analytics.
  fetch('/api/telegram-click', {
    method: 'POST',
    body: JSON.stringify({
      language: document.documentElement.lang,
      placement: link.dataset.telegramPlacement,
    }),
    keepalive: true,
  }).catch(() => {});
});
