require( "harmony-reflect" )
util = require "util"
traverse = require 'traverse'
EventEmitter = require( "events" ).EventEmitter
_ = require 'underscore'

listenerItems = [ "on", "addListener", "removeListener", "once",
  "removeAllListeners", "listeners", "listenerCount", "_events",
  "_eventsCount" ]

observable = ( obj ) ->
  properties = {}
  events = new EventEmitter()

  wrap = ( name, value ) ->
    return value unless _.isObject( value ) or _.isArray( value )
    value = observable value

    # Listen to events on child objects
    value.on "changed", ( n, o, v ) ->
      events.emit "changed", "#{name}.#{n}", o, v

    value.on "deleted", ( n ) ->
      events.emit "deleted", "#{name}.#{n}"

    value

  handlers =
    get : ( target, name ) ->
      if name in listenerItems then events[ name ] else properties[ name ]

    set : ( target, name, value ) ->
      return events[ name ] = value if name in listenerItems
      old = properties[ name ]
      properties[ name ] = wrap name, value
      events.emit "changed", name, old, value

    deleteProperty : ( target, name ) ->
      return if name in listenerItems
      return unless properties[ name ]?
      delete properties[ name ]
      events.emit "deleted", name

    ownKeys : ->
      Object.getOwnPropertyNames properties

    has : ( target, name ) ->
      name in properties

    defineProperty : ( target, name, desc ) ->
      properties.setKey name, desc
      target

    getOwnPropertyDescriptor : ( target, name ) ->
      Object.getOwnPropertyDescriptor properties, name

  obj = {} unless obj?
  properties[ k ] = wrap k, v for own k,v of obj
  Proxy obj, handlers

module.exports = observable
