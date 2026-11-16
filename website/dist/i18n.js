import { languages, findLanguage } from './languages.js';

export { languages };

const PREFERENCE_KEY = 'portfolio.language';
const CACHE_PREFIX = 'portfolio.translation.v1.';
const TRANSLATION_ENDPOINT = 'https://translate.googleapis.com/translate_a/t';
const messages = {
  ru: {
    '@i18n.local': 'Встроенный перевод · работает без интернета',
    '@i18n.automatic': 'Автоматический перевод Google · возможны неточности',
    '@i18n.loading': 'Переводим страницу… Можно выбрать другой язык.',
    '@i18n.error': 'Перевод сейчас недоступен. Сохранён предыдущий язык. Попробуйте ещё раз или выберите русский, English, O‘zbekcha.',
    '@i18n.localGroup': 'Встроенные переводы',
    '@i18n.autoGroup': 'Автоматический перевод · нужен интернет',
  },
  en: {
    '@i18n.local': 'Built-in translation · works offline',
    '@i18n.automatic': 'Automatic translation by Google · may contain inaccuracies',
    '@i18n.loading': 'Translating the page… You can choose another language.',
    '@i18n.error': 'Translation is unavailable. Your previous language is unchanged. Try again or choose Русский, English or O‘zbekcha.',
    '@i18n.localGroup': 'Built-in translations',
    '@i18n.autoGroup': 'Automatic translation · internet required',
  },
  uz: {
    '@i18n.local': 'Tayyor tarjima · internetsiz ishlaydi',
    '@i18n.automatic': 'Google avtomatik tarjimasi · xatolar bo‘lishi mumkin',
    '@i18n.loading': 'Sahifa tarjima qilinmoqda… Boshqa tilni tanlashingiz mumkin.',
    '@i18n.error': 'Tarjima hozir mavjud emas. Avvalgi til saqlandi. Qayta urinib ko‘ring yoki Русский, English, O‘zbekcha tillaridan birini tanlang.',
    '@i18n.localGroup': 'Tayyor tarjimalar',
    '@i18n.autoGroup': 'Avtomatik tarjima · internet kerak',
  },
};

function readStorage(key) {
  try { return localStorage.getItem(key); } catch { return null; }
}
function writeStorage(key, value) {
  try { localStorage.setItem(key, value); } catch { /* Private mode or storage quota. */ }
}
function sourceHash(source) {
  const text = JSON.stringify(source);
  let hash = 2166136261;
  for (let i = 0; i < text.length; i += 1) {
    hash = Math.imul(hash ^ text.charCodeAt(i), 16777619);
  }
  return (hash >>> 0).toString(36);
}
function collectBindings() {
  const bindings = [];
  const attributes = ['aria-label', 'title', 'placeholder', 'alt', 'content'];
  document.querySelectorAll('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (key) bindings.push({ element, key, attribute: null, source: element.textContent.trim() });
  });
  for (const attribute of attributes) {
    document.querySelectorAll(`[data-i18n-${attribute}]`).forEach(element => {
      const key = element.getAttribute(`data-i18n-${attribute}`);
      if (key) bindings.push({ element, key, attribute, source: element.getAttribute(attribute) || '' });
    });
  }
  return bindings;
}
function makeBatches(entries, language) {
  const batches = [];
  let batch = [];
  let encodedLength = TRANSLATION_ENDPOINT.length + 80 + language.length;
  for (const entry of entries) {
    const length = encodeURIComponent(entry[1]).length + 3;
    if (batch.length && (encodedLength + length > 6000 || batch.length >= 18)) {
      batches.push(batch);
      batch = [];
      encodedLength = TRANSLATION_ENDPOINT.length + 80 + language.length;
    }
    batch.push(entry);
    encodedLength += length;
  }
  if (batch.length) batches.push(batch);
  return batches;
}

/** Optional keyless Google endpoint. It is not a guaranteed or official API.
 * Only public static portfolio text is sent, after choosing an additional language.
 * RU/EN/UZ and cached translations never require a network request.
 */
async function translateDictionary(source, language, signal) {
  const result = {};
  const entries = Object.entries(source);
  const pending = makeBatches(entries, language);
  async function worker() {
    while (pending.length) {
      if (signal.aborted) throw new DOMException('Translation cancelled', 'AbortError');
      const batch = pending.shift();
      const url = new URL(TRANSLATION_ENDPOINT);
      url.searchParams.set('client', 'gtx');
      url.searchParams.set('sl', 'ru');
      url.searchParams.set('tl', language);
      for (const [, text] of batch) url.searchParams.append('q', text);
      const response = await fetch(url, { signal, credentials: 'omit', referrerPolicy: 'no-referrer' });
      if (!response.ok) throw new Error(`Translation service returned ${response.status}`);
      const translated = await response.json();
      if (!Array.isArray(translated) || translated.length !== batch.length ||
          translated.some(text => typeof text !== 'string' || !text.trim())) {
        throw new Error('Incomplete translation response');
      }
      translated.forEach((text, index) => { result[batch[index][0]] = text; });
    }
  }
  await Promise.all([worker(), worker()]);
  return result;
}

let controller;

/**
 * Mark plain-text DOM nodes with data-i18n="key" and pass authored EN/UZ dictionaries.
 * The Russian source dictionary is collected before the first language change.
 * Attributes supported: data-i18n-aria-label, data-i18n-title, data-i18n-placeholder,
 * data-i18n-alt. Mark text-only nodes: translations use textContent, never innerHTML.
 */
export function setupI18n(dictionaries = {}, options = {}) {
  controller?.destroy();
  const bindings = collectBindings();
  const source = { ...messages.ru, copied: 'Скопировано', copyFailed: 'Не удалось скопировать. Выделите контакт вручную.', openMenu: 'Открыть меню', closeMenu: 'Закрыть меню' };
  bindings.forEach(binding => { source[binding.key] = binding.source; });
  Object.assign(source, dictionaries.ru || {});
  const manual = {
    ru: source,
    en: { ...source, ...messages.en, ...(dictionaries.en || {}) },
    uz: { ...source, ...messages.uz, ...(dictionaries.uz || {}) },
  };
  const sourceVersion = sourceHash(source);
  const select = document.getElementById('language-select');
  const status = document.getElementById('language-status');
  const onChange = options.onChange || dictionaries.onChange;
  let activeLanguage = 'ru';
  let activeDictionary = manual.ru;
  let requestNumber = 0;
  let request;
  let disposed = false;
  let localGroup;
  let automaticGroup;

  if (status) {
    status.setAttribute('role', 'status');
    status.setAttribute('aria-live', 'polite');
    status.setAttribute('aria-atomic', 'true');
  }
  if (select) {
    select.replaceChildren();
    localGroup = document.createElement('optgroup');
    automaticGroup = document.createElement('optgroup');
    for (const language of languages.filter(language => language.manual)) {
      const option = new Option(language.nativeName, language.code);
      localGroup.append(option);
    }
    for (const language of languages.filter(language => !language.manual)) {
      const label = language.nativeName === language.name
        ? language.name : `${language.nativeName} · ${language.name}`;
      automaticGroup.append(new Option(label, language.code));
    }
    select.append(localGroup, automaticGroup);
    select.value = 'ru';
  }

  function setStatus(key, state) {
    if (status) {
      status.textContent = activeDictionary[key] || messages.ru[key];
      status.dataset.state = state;
    }
    if (select) select.setAttribute('aria-busy', state === 'loading' ? 'true' : 'false');
  }
  function apply(language, dictionary, automatic) {
    activeLanguage = language.code;
    activeDictionary = dictionary;
    for (const { element, key, attribute } of bindings) {
      const text = dictionary[key] ?? source[key];
      if (typeof text !== 'string') continue;
      if (attribute) element.setAttribute(attribute, text);
      else element.textContent = text;
    }
    const htmlLanguage = language.code === 'iw' ? 'he' : language.code === 'jw' ? 'jv' : language.code;
    document.documentElement.lang = htmlLanguage;
    document.documentElement.dir = language.dir;
    if (select) {
      select.value = language.code;
      localGroup.label = dictionary['@i18n.localGroup'];
      automaticGroup.label = dictionary['@i18n.autoGroup'];
    }
    setStatus(automatic ? '@i18n.automatic' : '@i18n.local', automatic ? 'automatic' : 'local');
    writeStorage(PREFERENCE_KEY, language.code);
    try {
      const url = new URL(window.location.href);
      url.searchParams.set('lang', language.code);
      history.replaceState(null, '', url);
    } catch { /* Sandboxed embeds can forbid history changes. */ }
    document.dispatchEvent(new CustomEvent('portfolio:languagechange', {
      detail: { language: language.code, automatic },
    }));
    if (typeof onChange === 'function') onChange(language.code, dictionary);
  }
  function readCache(language) {
    try {
      const dictionary = JSON.parse(readStorage(`${CACHE_PREFIX}${sourceVersion}.${language}`));
      if (dictionary && Object.keys(source).every(key => typeof dictionary[key] === 'string')) return dictionary;
    } catch { /* A stale or incomplete cache is safe to ignore. */ }
    return null;
  }
  async function changeLanguage(value) {
    if (disposed) return false;
    const language = findLanguage(value);
    if (!language) {
      if (select) select.value = activeLanguage;
      return false;
    }
    const currentRequest = ++requestNumber;
    request?.abort();
    request = null;
    if (manual[language.code]) {
      apply(language, manual[language.code], false);
      return true;
    }
    const cached = readCache(language.code);
    if (cached) {
      apply(language, cached, true);
      return true;
    }
    request = new AbortController();
    const ownRequest = request;
    const timeout = setTimeout(() => ownRequest.abort(), 35000);
    setStatus('@i18n.loading', 'loading');
    try {
      const dictionary = await translateDictionary(source, language.code, ownRequest.signal);
      if (currentRequest !== requestNumber || disposed) return false;
      writeStorage(`${CACHE_PREFIX}${sourceVersion}.${language.code}`, JSON.stringify(dictionary));
      apply(language, dictionary, true);
      return true;
    } catch {
      if (currentRequest !== requestNumber || disposed) return false;
      ownRequest.abort();
      if (select) select.value = activeLanguage;
      setStatus('@i18n.error', 'error');
      return false;
    } finally {
      clearTimeout(timeout);
      if (request === ownRequest) request = null;
    }
  }
  const onSelect = event => { void changeLanguage(event.target.value); };
  select?.addEventListener('change', onSelect);
  let requested;
  try { requested = new URL(window.location.href).searchParams.get('lang'); } catch { /* Use local preference. */ }
  const initial = findLanguage(requested) || findLanguage(readStorage(PREFERENCE_KEY)) || findLanguage('ru');
  controller = {
    ready: Promise.resolve(false),
    setLanguage: changeLanguage,
    getLanguage: () => activeLanguage,
    t: key => activeDictionary[key] ?? source[key] ?? key,
    languages,
    destroy() {
      disposed = true;
      requestNumber += 1;
      request?.abort();
      select?.removeEventListener('change', onSelect);
    },
  };
  controller.ready = changeLanguage(initial.code);
  return controller;
}

export function setLanguage(code) {
  if (!controller) throw new Error('Call setupI18n before selecting a language.');
  return controller.setLanguage(code);
}
export function getLanguage() { return controller?.getLanguage() || 'ru'; }

export function t(key) { return controller?.t(key) ?? messages.ru[key] ?? key; }
export const translate = t;
