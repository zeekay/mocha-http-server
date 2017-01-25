## mocha-http-server

[![Greenkeeper badge](https://badges.greenkeeper.io/zeekay/mocha-http-server.svg)](https://greenkeeper.io/)
Lightweight HTTP server designed to run mocha tests in a browser. Bundles up
your test modules automatically, deduping dependencies and adds source map support.

### Features
- Use CommonJS modules in your tests
- Built-in modules supported via browserify shims.
- Supports CoffeeScript test modules out of the box.
- Automatic source map support in Chrome.

### CLI
```
mocha-http [options] [files]

Options:
  -?, --help                      output usage information
  -v, --version                   output the version number
  -b, --browser                   open browser automatically
  -h, --host                      hostname to bind to
  -p, --port                      port to listen on
  -t, --timeout <ms>              set test-case timeout in milliseconds [2000]
  --check-leaks                   check for global variable leaks
  --globals <names>,...           allow the given global [names]
  --recursive                     include sub directories
```

#### Usage:
```
$ mocha-http tests
```
