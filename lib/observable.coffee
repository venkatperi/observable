require( "harmony-reflect" )
util = require "util"
EventEmitter = require( "events" ).EventEmitter

observable = ( obj ) ->
  properties = {}
  events = new EventEmitter()

  wrap = ( name, value ) ->
    return value unless typeof value is "object"
    value = observable value
    value.on "changed", ( n, o, v ) ->
      events.emit "changed", "#{name}.#{n}", o, v
    value.on "deleted", ( n ) ->
      events.emit "deleted", "#{name}.#{n}"
    value

  handlers =
    get : ( target, name ) ->
      if name in [ "on" ]
        return target[ name ]
      properties[ name ]

    set : ( target, name, value ) ->
      if name in [ "on" ]
        return target[ name ] = value

      old = properties[ name ]
      properties[ name ] = wrap name, value
      events.emit "changed", name, old, value

    deleteProperty : ( target, name ) ->
      return unless properties[ name ]?
      delete properties[ name ]
      events.emit "deleted", name

    ownKeys : ->
      Object.keys properties

    has : ( target, name ) ->
      name in properties

    defineProperty : ( target, name, desc ) ->
      properties.setKey name, desc
      target

    getOwnPropertyDescriptor : ( target, name ) ->
      val = properties[ name ]
      return unless val?
      value : val
      writable : true
      enumerable : true
      configurable : true


  for own k,v of obj
    properties[ k ] = wrap k, v

  proxy = Proxy obj, handlers
  proxy.on = ( name, handler ) -> events.on name, handler

  proxy


module.exports = observable
