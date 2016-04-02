var EventEmitter, observable, util,
  __hasProp = {}.hasOwnProperty;

require("harmony-reflect");

util = require("util");

EventEmitter = require("events").EventEmitter;

observable = function(obj) {
  var events, handlers, k, properties, proxy, v, wrap;
  properties = {};
  events = new EventEmitter();
  wrap = function(name, value) {
    if (typeof value !== "object") {
      return value;
    }
    value = observable(value);
    value.on("changed", function(n, o, v) {
      return events.emit("changed", "" + name + "." + n, o, v);
    });
    return value;
  };
  handlers = {
    get: function(target, name) {
      return properties[name];
    },
    set: function(target, name, value) {
      var old;
      old = properties[name];
      properties[name] = wrap(name, value);
      return events.emit("changed", name, old, value);
    }
  };
  for (k in obj) {
    if (!__hasProp.call(obj, k)) continue;
    v = obj[k];
    properties[k] = wrap(k, v);
  }
  proxy = Proxy(obj, handlers);
  proxy.on = function(name, handler) {
    return events.on(name, handler);
  };
  return proxy;
};

module.exports = observable;
