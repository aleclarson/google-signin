
{ RNGoogleSignIn } = require "NativeModules"

isConstructor = require "isConstructor"
assertTypes = require "assertTypes"
Promise = require "Promise"
ArrayOf = require "ArrayOf"
assert = require "assert"
Maybe = require "Maybe"
Type = require "Type"

errorCodes =
  "-4": "No user is signed in!"
  "-5": "The user cancelled signing in!"

type = Type "GoogleSignIn"

type.defineValues

  _connected: no

  _connecting: null

  _revoking: null

type.defineEvents

  willConnect: null

  didConnect: null

  didDisconnect: null

type.initInstance ->
  @_addNativeListeners @_createNativeListeners()

type.defineGetters

  isConnected: -> @_connected

  isConnecting: ->
    return no if not @_connecting
    return @_connecting.promise.isPending

  isReconnecting: ->
    return no if not @_reconnecting
    return @_reconnecting.promise.isPending

  isRevoking: ->
    return no if not @_revoking
    return @_revoking.promise.isPending

type.defineMethods

  configure: (config) ->

    assertTypes config,
      clientID: String
      serverID: String.Maybe
      scopes: Maybe ArrayOf String

    RNGoogleSignIn.configure config
    return

  connect: ->
    assert not @_connected, "Already connected to Google!"
    return @_connect() if not @isReconnecting
    return @_reconnecting.promise
    .then (res) => if @_connected then res else @_connect()

  reconnect: ->
    assert not @_connected, "Already connected to Google!"
    if not @isReconnecting
      @_reconnecting = Promise.defer()
      RNGoogleSignIn.reconnect()
    return @_reconnecting.promise

  disconnect: ->
    @_disconnect()
    RNGoogleSignIn.disconnect()
    return

  revoke: ->
    if not @isRevoking
      @_disconnect()
      @_revoking = Promise.defer()
      RNGoogleSignIn.revoke()
    return @_revoking.promise

  _connect: ->
    if not @isConnecting
      @_connecting = Promise.defer()
      RNGoogleSignIn.connect()
    return @_connecting.promise

  _disconnect: ->
    @_connecting = null
    @_reconnecting = null
    if @_connected
      @_connected = no
      @_events.emit "didDisconnect"
    return

  _addNativeListeners: (listeners) ->
    emitter = require "RCTNativeAppEventEmitter"
    for event, listener of listeners
      emitter.addListener "RNGoogleSignIn." + event, listener
    return

  _createNativeListeners: ->

    connecting: => @_events.emit "willConnect"

    connected: (json) =>

      connecting = @_connecting
      reconnecting = @_reconnecting
      return unless connecting or reconnecting

      date = new Date json.accessTokenExpirationDate * 1000
      json.accessTokenExpirationDate = date

      if json.idToken
        date = new Date json.idTokenExpirationDate * 1000
        json.idTokenExpirationDate = date

      @_connected = yes

      if connecting
        @_connecting = null
        connecting.resolve json

      else if reconnecting
        @_reconnecting = null
        reconnecting.resolve json

      @_events.emit "didConnect"

    connectFailed: (error) =>

      connecting = @_connecting
      reconnecting = @_reconnecting
      return unless connecting or reconnecting

      error = Error errorCodes[error.code]

      if connecting
        connecting.reject error
        @_connecting = null

      else if reconnecting
        reconnecting.reject error
        @_reconnecting = null

    revoked: =>
      if revoking = @_revoking
        revoking.resolve()
        @_revoking = null

    revokeFailed: (error) =>
      if revoking = @_revoking
        revoking.reject error
        @_revoking = null

module.exports = type.construct()
