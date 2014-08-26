## mocha-http-server
Lightweight HTTP server designed to run mocha tests in a browser. Bundles up
your test modules automatically for the browser.

### Features
- Your tests can use `require` and all the node-goodies browserify supports and
  still run automatically in the browser.
- Supports CoffeeScript test modules out of the box.

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
