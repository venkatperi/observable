should = require( "should" )
assert = require( "assert" )
observable = require( '../index' )

describe "observable", ->

  it "create", ( done ) ->
    obj = { a : 1 }
    o2 = observable obj
    o2.a.should.equal 1
    assert.equal o2.b, undefined
    o2.b = 2
    o2.b.should.equal 2
    o2.b = { c : 3 }
    o2.b.c.should.equal 3
    done()

  it "emits changed events", ( done ) ->
    obj = { a : 1 }
    o2 = observable obj
    o2.on "changed", ( name, old, value ) ->
      name.should.equal "a"
      value.should.equal 2
      done()
    o2.a = 2

  it "emits changed for nested properties", ( done ) ->
    o2 = observable()
    o2.a = {}
    o2.on "changed", ( name, old, value ) ->
      name.should.equal "a.b"
      value.should.equal 1
      done()
    o2.a.b = 1

  it "emits changed for nested properties", ( done ) ->
    obj = { a : { b : { c : 2 } } }
    o2 = observable obj
    o2.on "changed", ( name, old, value ) ->
      name.should.equal "a.b.c"
      value.should.equal 1
      done()
    o2.a.b.c = 1

  it "can delete a property", ( done ) ->
    obj = observable { a : { b : 2 } }
    assert.notEqual obj.a, undefined
    delete obj.a
    assert.equal obj.a, undefined
    done()

  it "emits delete", ( done ) ->
    obj = observable { a : { b : 2 } }
    obj.on "deleted", ( name ) ->
      name.should.equal "a"
      done()
    delete obj.a

  it "get keys", ( done ) ->
    obj = observable { a : 1, b : 2, c : 3 }
    keys = Object.keys obj
    for p in [ "a", "b", "c" ]
      do ( p ) =>
        assert p in keys
    done()

  it "enumerate", ( done ) ->
    obj = observable { a : 1, b : 2, c : 3 }
    keys = Object.keys obj
    for own k of obj
      do ( k ) =>
        assert k in keys
    done()

  it "handles arrays", ( done ) ->
    o2 = observable [ 1, 2, 3 ]
    o2.on "changed", ( name, old, value ) ->
      name.should.equal "0"
      value.should.equal 4
      done()

    o2[ 0 ] = 4

  it "init with deep nested obj", ( done ) ->
    o2 = observable { a : { b : { c : 3 } } }
    o2.on "changed", ( name, old, value ) ->
      name.should.equal "a.b.c"
      value.should.equal 4
      done()

    o2.a.b.c = 4

