var EventEmitter, observable, util,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
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
    value.on("deleted", function(n) {
      return events.emit("deleted", "" + name + "." + n);
    });
    return value;
  };
  handlers = {
    get: function(target, name) {
      if (name === "on") {
        return target[name];
      }
      return properties[name];
    },
    set: function(target, name, value) {
      var old;
      if (name === "on") {
        return target[name] = value;
      }
      old = properties[name];
      properties[name] = wrap(name, value);
      return events.emit("changed", name, old, value);
    },
    deleteProperty: function(target, name) {
      if (properties[name] == null) {
        return;
      }
      delete properties[name];
      return events.emit("deleted", name);
    },
    ownKeys: function() {
      return Object.keys(properties);
    },
    has: function(target, name) {
      return __indexOf.call(properties, name) >= 0;
    },
    defineProperty: function(target, name, desc) {
      properties.setKey(name, desc);
      return target;
    },
    getOwnPropertyDescriptor: function(target, name) {
      var val;
      val = properties[name];
      if (val == null) {
        return;
      }
      return {
        value: val,
        writable: true,
        enumerable: true,
        configurable: true
      };
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
