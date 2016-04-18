# observable
Allows objects to watch for changes to an object via `Proxy`. `observable` uses `harmony-reflect` for `Proxy` support. Requires the `--harmony_proxies` flag to be set on the `nodejs` executable

`observable` is an `EventEmitter`.

## Installation
Install with npm

```
npm install observable
```

## Usage

```coffeescript
observable = require "observable"
```

## Example
### Clone an existing object

```coffeescript
obj = { a : 1 }
o2 = observable obj
assert.equal o2.a, 1
assert.equal o2.b, undefined
```

### Emit change events

```coffeescript
# Clone an existing object
obj = { a : 1 }
o2 = observable obj

# Listen for "changed" events
o2.on "changed", ( name, old, value ) ->
  assert.equal name, "a"
  assert.equal value, 2

# Modify a property on our observable object
o2.a = 2
```

### Nested Keys

```coffeescript
o2 = observable {}
o2.a = {} # o2.a is automatically converted to an observable object

o2.on "changed", ( name, old, value ) ->
  assert.equal name, "a.b"
  assert.equal value, 1

# Modify a nested property
o2.a.b = 1
```

### Delete keys

```coffeescript
obj = observable { a : { b : 2 } }
obj.on "deleted", ( name ) ->
  assert.equal name, 'a'

delete obj.a
```

## observable (obj)
- `obj` `{optional Object}` An initial object which is cloned (immutable).
- Returns a `Proxy` to the cloned object

Clones an object and returns a `Proxy` to the cloned object. Changes to the cloned object are not reflected on the original.

Objects assigned to keys of an observable object are themselves converted to observable objects.

## Events
### changed (name, old, value)
- `name` Property name with path, if nested.
- `old` The previous value
- `value` The new value

Emitted when a (possibly nested) value of a an observable object is modified.

### deleted (name)
- `name` Property name with path, if nested.

Emitted when a property is deleted
