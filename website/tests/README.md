Run the language regression tests with Node.js 22.7 or newer:

```sh
cd tests
npm ci
npm test
```

The tests inspect the actual site HTML and run the language controller in jsdom.
Network responses are mocked: tests work offline and do not rely on Google's
availability. They cover manual dictionary completeness, accessible attributes,
URL and saved preferences, automatic translation, caching, failure recovery,
races, RTL languages, safe text rendering and disabled browser storage.

These checks do not validate visual layout or third-party translation accuracy.
The website itself needs no Node.js or npm dependencies.
