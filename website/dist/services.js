const fields = document.querySelector('.brief-fields');
const type = document.querySelector('#brief-type');
const notes = document.querySelector('#brief-notes');
const start = document.querySelector('[data-telegram-placement="hero"]');
const telegram = document.querySelector('[data-telegram-placement="footer"]');
const copyUser = document.querySelector('[data-copy-user]');
let placement = 'footer';

function updateDraft() {
  const url = new URL('https://t.me/davichik');
  const parts = [fields.dataset.briefIntro, type.value, notes.value.trim()];
  url.searchParams.set('text', parts.filter(Boolean).join('\n'));
  telegram.href = url.href;
}

fields.hidden = false;
copyUser.hidden = false;
start.href = '#project-brief';
start.addEventListener('click', () => { placement = 'hero'; });
type.addEventListener('change', updateDraft);
notes.addEventListener('input', updateDraft);
window.addEventListener('pageshow', updateDraft);
updateDraft();

telegram.addEventListener('click', () => {
  updateDraft();
  fetch('/api/telegram-click', {
    method: 'POST',
    body: JSON.stringify({ language: document.documentElement.lang, placement }),
    keepalive: true,
  }).catch(() => {});
});

copyUser.addEventListener('click', async () => {
  const status = document.querySelector('.brief-status');
  try {
    await navigator.clipboard.writeText('@davichik');
    status.textContent = copyUser.dataset.success;
  } catch {
    status.textContent = copyUser.dataset.fallback;
  }
});
