var ArrayOf, Event, Maybe, Promise, RNGoogleSignIn, Type, assertTypes, errorCodes, isConstructor, type;

RNGoogleSignIn = require("NativeModules").RNGoogleSignIn;

isConstructor = require("isConstructor");

assertTypes = require("assertTypes");

Promise = require("Promise");

ArrayOf = require("ArrayOf");

Maybe = require("Maybe");

Event = require("event");

Type = require("Type");

errorCodes = {
  "-4": "No user is signed in!",
  "-5": "The user cancelled signing in!"
};

type = Type("GoogleSignIn");

type.defineValues({
  willConnect: function() {
    return Event();
  },
  _connecting: null,
  _disconnecting: null
});

type.initInstance(function() {
  return this._addNativeListeners({
    connecting: this.willConnect.emit,
    connected: (function(_this) {
      return function(json) {
        var date;
        date = new Date(json.accessTokenExpirationDate * 1000);
        json.accessTokenExpirationDate = date;
        if (json.idTokenExpirationDate) {
          date = new Date(json.idTokenExpirationDate * 1000);
          json.idTokenExpirationDate = date;
        }
        _this._connecting.resolve(json);
        return _this._connecting = null;
      };
    })(this),
    connectFailed: (function(_this) {
      return function(error) {
        error = Error(errorCodes[error.code]);
        _this._connecting.reject(error);
        return _this._connecting = null;
      };
    })(this),
    disconnected: (function(_this) {
      return function() {
        _this._disconnecting.resolve();
        return _this._disconnecting = null;
      };
    })(this),
    disconnectFailed: (function(_this) {
      return function(error) {
        _this._disconnecting.reject(error);
        return _this._disconnecting = null;
      };
    })(this)
  });
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
  signIn: function(options) {
    this._connecting = Promise.defer();
    if (options && options.silent) {
      RNGoogleSignIn.signInSilently();
    } else {
      RNGoogleSignIn.signIn();
    }
    return this._connecting.promise;
  },
  signOut: function() {
    RNGoogleSignIn.signOut();
  },
  isConnected: function() {
    return RNGoogleSignIn.isConnected();
  },
  disconnect: function() {
    this._disconnecting = Promise.defer();
    RNGoogleSignIn.disconnect();
    return this._disconnecting.promise;
  },
  _addNativeListeners: function(listeners) {
    var emitter, event, listener;
    emitter = require("RCTNativeAppEventEmitter");
    for (event in listeners) {
      listener = listeners[event];
      emitter.addListener("RNGoogleSignIn." + event, listener);
    }
  }
});

module.exports = type.construct();

//# sourceMappingURL=../../map/src/index.ios.map
