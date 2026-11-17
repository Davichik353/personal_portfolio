import assert from 'node:assert/strict';
import { beforeEach, afterEach, describe, it } from 'node:test';
import { access, readFile } from 'node:fs/promises';
import { JSDOM } from 'jsdom';

// Supports either website/dist + website/tests or a flat website + website/tests.
let site = new URL('../dist/', import.meta.url);
try { await access(new URL('index.html', site)); }
catch { site = new URL('../', import.meta.url); }
const { setupI18n, t, languages } = await import(new URL('i18n.js', site));
const { en, uz } = await import(new URL('locales.js', site));
const html = await readFile(new URL('index.html', site), 'utf8');
const realFetch = globalThis.fetch;
let dom;
let i18n;

function mockTranslation(prefix = 'translated:') {
  globalThis.fetch = async (url) => ({
    ok: true,
    json: async () => new URL(url).searchParams.getAll('q').map(text => prefix + text),
  });
}
function getText(key) {
  return document.querySelector(`[data-i18n="${key}"]`).textContent;
}
async function start(query = '') {
  history.replaceState(null, '', `/${query}`);
  i18n = setupI18n({ en, uz });
  await i18n.ready;
  return i18n;
}

describe('Portfolio language switching', { concurrency: false }, () => {
  beforeEach(() => {
    dom = new JSDOM(html, { url: 'https://portfolio.example/' });
    for (const key of ['document', 'localStorage', 'history', 'Option', 'CustomEvent']) {
      globalThis[key] = dom.window[key];
    }
    globalThis.window = dom.window;
    globalThis.fetch = () => { throw new Error('Unexpected network request'); };
  });
  afterEach(() => {
    i18n?.destroy();
    dom.window.close();
    globalThis.fetch = realFetch;
  });

  it('provides authored EN and UZ translations for every marked HTML string and attribute', () => {
    const keys = new Set();
    document.querySelectorAll('*').forEach(element => {
      for (const attribute of element.attributes) {
        if (attribute.name === 'data-i18n' || attribute.name.startsWith('data-i18n-')) {
          keys.add(attribute.value);
        }
      }
    });
    for (const [code, dictionary] of Object.entries({ en, uz })) {
      assert.deepEqual([...keys].filter(key => typeof dictionary[key] !== 'string'), [], `Missing ${code} translations`);
    }
  });

  it('offers the service language list without duplicate codes', async () => {
    await start();
    assert.ok(languages.length >= 200);
    assert.equal(new Set(languages.map(language => language.code)).size, languages.length);
    assert.equal(document.querySelectorAll('#language-select option').length, languages.length);
    for (const code of ['ru', 'en', 'uz']) assert.ok(languages.some(language => language.code === code && language.manual));
  });

  it('switches RU/EN/UZ and accessible labels offline', async () => {
    await start('?lang=en');
    assert.equal(getText('heroLead'), en.heroLead);
    assert.equal(document.documentElement.lang, 'en');
    assert.equal(document.querySelector('#menu-toggle').getAttribute('aria-label'), en.openMenu);
    assert.equal(t('copied'), en.copied);
    await i18n.setLanguage('uz');
    assert.equal(getText('heroLead'), uz.heroLead);
    assert.equal(t('copyFailed'), uz.copyFailed);
    await i18n.setLanguage('ru');
    assert.equal(document.documentElement.lang, 'ru');
    assert.equal(document.documentElement.dir, 'ltr');
  });

  it('restores a saved language and lets a valid URL language override it', async () => {
    localStorage.setItem('portfolio.language', 'uz');
    await start();
    assert.equal(i18n.getLanguage(), 'uz');
    await start('?lang=en');
    assert.equal(i18n.getLanguage(), 'en');
  });

  it('applies complete automatic translations and reuses them offline', async () => {
    await start();
    const russianLead = getText('heroLead');
    mockTranslation('FR:');
    assert.equal(await i18n.setLanguage('fr'), true);
    assert.equal(getText('heroLead'), 'FR:' + russianLead);
    assert.equal(document.querySelector('#language-status').dataset.state, 'automatic');
    await i18n.setLanguage('ru');
    globalThis.fetch = () => { throw new Error('Offline'); };
    assert.equal(await i18n.setLanguage('fr'), true);
    assert.equal(document.documentElement.lang, 'fr');
  });

  it('keeps the previous text, language and preference when translation fails', async () => {
    await start('?lang=en');
    globalThis.fetch = async () => { throw new Error('Service unavailable'); };
    assert.equal(await i18n.setLanguage('de'), false);
    assert.equal(getText('heroLead'), en.heroLead);
    assert.equal(document.documentElement.lang, 'en');
    assert.equal(document.querySelector('#language-select').value, 'en');
    assert.equal(localStorage.getItem('portfolio.language'), 'en');
    assert.equal(document.querySelector('#language-status').dataset.state, 'error');
  });

  it('rejects partial service responses instead of applying incomplete text', async () => {
    await start('?lang=en');
    globalThis.fetch = async () => ({ ok: true, json: async () => ['incomplete'] });
    assert.equal(await i18n.setLanguage('de'), false);
    assert.equal(getText('heroLead'), en.heroLead);
  });

  it('does not let an older pending request override a newer language choice', async () => {
    await start('?lang=en');
    const finish = [];
    globalThis.fetch = url => new Promise(resolve => {
      finish.push(() => resolve({ ok: true, json: async () => new URL(url).searchParams.getAll('q').map(text => 'DE:' + text) }));
    });
    const pending = i18n.setLanguage('de');
    assert.equal(getText('heroLead'), en.heroLead);
    await i18n.setLanguage('uz');
    finish.forEach(resolve => resolve());
    assert.equal(await pending, false);
    assert.equal(getText('heroLead'), uz.heroLead);
  });

  it('sets RTL direction and renders translated markup as plain text', async () => {
    await start();
    const originalScriptCount = document.querySelectorAll('script').length;
    mockTranslation('<script>untrusted()</script>');
    await i18n.setLanguage('ar');
    assert.equal(document.documentElement.dir, 'rtl');
    assert.ok(getText('heroLead').startsWith('<script>'));
    assert.equal(document.querySelectorAll('script').length, originalScriptCount);
    await i18n.setLanguage('ru');
    assert.equal(document.documentElement.dir, 'ltr');
  });

  it('works with unavailable localStorage and ignores invalid language codes', async () => {
    globalThis.localStorage = { getItem() { throw new Error('Blocked'); }, setItem() { throw new Error('Blocked'); } };
    await start('?lang=uz');
    assert.equal(getText('heroLead'), uz.heroLead);
    assert.equal(await i18n.setLanguage('xx-invalid'), false);
    assert.equal(i18n.getLanguage(), 'uz');
  });
});
