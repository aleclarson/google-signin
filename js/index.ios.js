var ArrayOf, Maybe, Promise, RNGoogleSignIn, Type, assert, assertTypes, errorCodes, isConstructor, type;

RNGoogleSignIn = require("NativeModules").RNGoogleSignIn;

isConstructor = require("isConstructor");

assertTypes = require("assertTypes");

Promise = require("Promise");

ArrayOf = require("ArrayOf");

assert = require("assert");

Maybe = require("Maybe");

Type = require("Type");

errorCodes = {
  "-4": "No user is signed in!",
  "-5": "The user cancelled signing in!"
};

type = Type("GoogleSignIn");

type.defineValues({
  _connected: false,
  _connecting: null,
  _revoking: null
});

type.defineEvents({
  willConnect: null,
  didConnect: {
    json: Object
  },
  didDisconnect: null
});

type.initInstance(function() {
  return this._addNativeListeners(this._createNativeListeners());
});

type.defineGetters({
  isConnected: function() {
    return this._connected;
  },
  isConnecting: function() {
    if (!this._connecting) {
      return false;
    }
    return this._connecting.promise.isPending;
  },
  isReconnecting: function() {
    if (!this._reconnecting) {
      return false;
    }
    return this._reconnecting.promise.isPending;
  },
  isRevoking: function() {
    if (!this._revoking) {
      return false;
    }
    return this._revoking.promise.isPending;
  }
});

type.defineMethods({
  configure: function(config) {
    assertTypes(config, {
      clientID: String,
      serverID: String.Maybe,
      scopes: Maybe(ArrayOf(String))
    });
    RNGoogleSignIn.configure(config);
  },
  connect: function() {
    assert(!this._connected, "Already connected to Google!");
    if (!this.isReconnecting) {
      return this._connect();
    }
    return this._reconnecting.promise.fail((function(_this) {
      return function() {
        return _this._connect();
      };
    })(this));
  },
  reconnect: function() {
    assert(!this._connected, "Already connected to Google!");
    if (!this.isReconnecting) {
      this._reconnecting = Promise.defer();
      RNGoogleSignIn.reconnect();
    }
    return this._reconnecting.promise;
  },
  disconnect: function() {
    this._disconnect();
    RNGoogleSignIn.disconnect();
  },
  revoke: function() {
    if (!this.isRevoking) {
      this._disconnect();
      this._revoking = Promise.defer();
      RNGoogleSignIn.revoke();
    }
    return this._revoking.promise;
  },
  _connect: function() {
    if (!this.isConnecting) {
      this._connecting = Promise.defer();
      RNGoogleSignIn.connect();
    }
    return this._connecting.promise;
  },
  _disconnect: function() {
    this._connecting = null;
    this._reconnecting = null;
    if (this._connected) {
      this._connected = false;
      this._events.emit("didDisconnect");
    }
  },
  _addNativeListeners: function(listeners) {
    var emitter, event, listener;
    emitter = require("RCTNativeAppEventEmitter");
    for (event in listeners) {
      listener = listeners[event];
      emitter.addListener("RNGoogleSignIn." + event, listener);
    }
  },
  _createNativeListeners: function() {
    return {
      connecting: (function(_this) {
        return function() {
          return _this._events.emit("willConnect");
        };
      })(this),
      connected: (function(_this) {
        return function(json) {
          var connecting, date, reconnecting;
          connecting = _this._connecting;
          reconnecting = _this._reconnecting;
          if (!(connecting || reconnecting)) {
            return;
          }
          date = new Date(json.accessTokenExpirationDate * 1000);
          json.accessTokenExpirationDate = date;
          if (json.idToken) {
            date = new Date(json.idTokenExpirationDate * 1000);
            json.idTokenExpirationDate = date;
          }
          _this._connected = true;
          if (connecting) {
            _this._connecting = null;
            connecting.resolve(json);
          } else if (reconnecting) {
            _this._reconnecting = null;
            reconnecting.resolve(json);
          }
          return _this._events.emit("didConnect", [json]);
        };
      })(this),
      connectFailed: (function(_this) {
        return function(error) {
          var connecting, reconnecting;
          connecting = _this._connecting;
          reconnecting = _this._reconnecting;
          if (!(connecting || reconnecting)) {
            return;
          }
          error = Error(errorCodes[error.code]);
          if (connecting) {
            connecting.reject(error);
            return _this._connecting = null;
          } else if (reconnecting) {
            reconnecting.reject(error);
            return _this._reconnecting = null;
          }
        };
      })(this),
      revoked: (function(_this) {
        return function() {
          var revoking;
          if (revoking = _this._revoking) {
            revoking.resolve();
            return _this._revoking = null;
          }
        };
      })(this),
      revokeFailed: (function(_this) {
        return function(error) {
          var revoking;
          if (revoking = _this._revoking) {
            revoking.reject(error);
            return _this._revoking = null;
          }
        };
      })(this)
    };
  }
});

module.exports = type.construct();

//# sourceMappingURL=map/index.ios.map
