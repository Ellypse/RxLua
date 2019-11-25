RxLua [![Build Status](https://travis-ci.org/Ellypse/RxLua.svg)](https://travis-ci.org/Ellypse/RxLua) [![Coverage Status](https://coveralls.io/repos/github/Ellypse/RxLua/badge.svg?branch=master)](https://coveralls.io/github/Ellypse/RxLua?branch=master)
===

[Reactive Extensions](http://reactivex.io) for Lua.

RxLua gives Lua the power of Observables, which are data structures that represent a stream of values that arrive over time.  They're very handy when dealing with events, streams of data, asynchronous requests, and concurrency.

Getting Started
---

#### Lua

Copy the `rx.lua` file into your project and require it:

```lua
local rx = require 'rx'
```

You can also install RxLua using luarocks:

```sh
luarocks install bjornbytes/rxlua
```

#### Luvit

Install using `lit`:

```sh
lit install bjornbytes/rx
```

Then require it:

```lua
local rx = require 'rx'
```

#### Love2D

See [RxLove](https://github.com/bjornbytes/RxLove).

#### World of Warcraft

Requires [LibStub](https://www.wowace.com/projects/libstub).

```lua
local rx = LibStub:GetLibrary("RxWoW-0.0")
```

Example Usage
---

Use RxLua to construct a simple cheer:

```lua
local Rx = require 'rx'

Rx.Observable.fromRange(1, 8)
  :filter(function(x) return x % 2 == 0 end)
  :concat(Rx.Observable.of('who do we appreciate'))
  :map(function(value) return value .. '!' end)
  :subscribe(print)

-- => 2! 4! 6! 8! who do we appreciate!
```

See [examples](examples) for more.

Resources
---

- [Documentation](doc)
- [Contributor Guide](doc/CONTRIBUTING.md)
- [Rx Introduction](http://reactivex.io/intro.html)

Tests
---

Uses [lust](https://github.com/bjornbytes/lust). Run with:

```
lua tests/runner.lua
```

or, to run a specific test:

```
lua tests/runner.lua skipUntil
```

License
---

MIT, see [`LICENSE`](LICENSE) for details.
