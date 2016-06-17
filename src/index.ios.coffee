
{ RNGoogleSignIn } = require "NativeModules"

isConstructor = require "isConstructor"
assertTypes = require "assertTypes"
Promise = require "Promise"
ArrayOf = require "ArrayOf"
Maybe = require "Maybe"
Event = require "Event"
Type = require "Type"

errorCodes =
  "-4": "No user is signed in!"
  "-5": "The user cancelled signing in!"

type = Type "GoogleSignIn"

type.defineValues

  willConnect: -> Event()

  _connecting: null

  _disconnecting: null

type.initInstance ->

  @_addNativeListeners

    connecting: @willConnect.emit

    connected: (json) =>

      date = new Date json.accessTokenExpirationDate * 1000
      json.accessTokenExpirationDate = date

      if json.idTokenExpirationDate
        date = new Date json.idTokenExpirationDate * 1000
        json.idTokenExpirationDate = date

      @_connecting.resolve json
      @_connecting = null

    connectFailed: (error) =>
      error = Error errorCodes[error.code]
      @_connecting.reject error
      @_connecting = null

    disconnected: =>
      @_disconnecting.resolve()
      @_disconnecting = null

    disconnectFailed: (error) =>
      @_disconnecting.reject error
      @_disconnecting = null

type.defineMethods

  configure: (config) ->

    assertTypes config,
      clientID: String
      serverID: String.Maybe
      scopes: Maybe ArrayOf String

    RNGoogleSignIn.configure config
    return

  signIn: (options) ->
    @_connecting = Promise.defer()
    if options and options.silent
      RNGoogleSignIn.signInSilently()
    else RNGoogleSignIn.signIn()
    return @_connecting.promise

  signOut: ->
    RNGoogleSignIn.signOut()
    return

  isConnected: ->
    return RNGoogleSignIn.isConnected()

  disconnect: ->
    @_disconnecting = Promise.defer()
    RNGoogleSignIn.disconnect()
    return @_disconnecting.promise

  _addNativeListeners: (listeners) ->
    emitter = require "RCTNativeAppEventEmitter"
    for event, listener of listeners
      emitter.addListener "RNGoogleSignIn." + event, listener
    return

module.exports = type.construct()
