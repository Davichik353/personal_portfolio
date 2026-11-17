# Davichik353 — Full-Stack Portfolio

Static multilingual portfolio website, built from the owner’s public portfolio and selected commercial projects.

## Local use

No build or runtime dependencies are required:

```bash
python3 -m http.server 5173 --directory dist
```

Open http://localhost:5173. To test from a phone on the same Wi-Fi network, bind the server to `0.0.0.0` and open your computer’s local IP address on port 5173. The deployed HTTPS Site is the easiest phone preview.

## Content

- HTML and Russian source text: `dist/index.html`.
- Authored English and Uzbek: `dist/locales.js`.
- Language handling: `dist/i18n.js`; provider language list: `dist/languages.js`.
- Styling and local serif fonts: `dist/styles.css`, `dist/assets/`.
- 249 language variants are offered. RU/EN/UZ are authored locally. Other languages use a keyless, unofficial Google Translate endpoint after selection; access may be limited or unavailable. Translations are applied atomically, cached locally, and the previous language is retained if the service fails. This is not a claim to support every language in the world.
- Vivid source remains private and is not included. Its screenshot is from the publicly available vivid-ads.com website. AI Code Mentor screenshot is from the public demo. KiroPiko character and Bubble Tea illustration are actual public project resources, labelled as such.
- KiroPiko is developed on the basis of the open-source Coucou project; attribution is present in the project case.
- Font licenses are bundled alongside Source Serif 4 and Playfair Display.

## Checks

```bash
cd tests
npm ci
npm test
```

Tests cover language switching, translation completeness, caching, failures, races, RTL, and safe text rendering. The deployment archive contains only `dist/` and `.openai/hosting.json`; test dependencies are not published.
