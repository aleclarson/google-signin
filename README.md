
# google-signin 1.0.0 ![experimental](https://img.shields.io/badge/stability-experimental-EC5315.svg?style=flat)

> Provides native methods for signing into a Google account.

- Rendering the sign-in button is your responsibility.

- Includes the [Google Sign-In SDK v4.0.0](https://developers.google.com/identity/sign-in/ios/sdk/#download_the_google_sign-in_sdk)

- Tested with [React Native v0.19.x](https://github.com/facebook/react-native)

- 🚫Android support currently disabled

&nbsp;

## usage

```coffee
GoogleSignIn = require "google-signin"
```

#### GoogleSignIn.configure()

Use the `configure` method before anything else!

You must pass an object with these properties:

- `clientID: String` - **Required** The client identifier from the [API console](https://console.developers.google.com)
- `serverID: String` - Required if you need to make requests from your server
- `scopes: Array | Void` - The [OAuth scopes](https://developers.google.com/identity/protocols/googlescopes) that you need to access

#### GoogleSignIn.willConnect

This is an [`Event`](https://github.com/aleclarson/event) that emits
when the native code has determined how it will authorize the user
(eg: using Safari or the native Google app).

You should show a loading indicator until this event emits.

#### GoogleSignIn.signIn()

This function returns a [`Promise`](https://github.com/aleclarson/Promise)
that resolves into an object with these properties:

- `id: String` - The user's unique identifier.
- `accessToken: String` - A string for authorizing requests.
- `accessTokenExpirationDate: String` - When the `accessToken` expires.

If you configured a `serverID`, the promise's result will also have these properties:

- `serverAuthCode: String`
- `idToken: String`
- `idTokenExpirationDate: String` - When the `idToken` expires.

If you added `https://www.googleapis.com/auth/userinfo.profile` to the scopes array,
the promise's result will also have these properties:

- `name: String` - The user's full name.
- `givenName: String` - The user's first name.
- `familyName: String` - The user's last name.
- `image: String | Null` - The user's profile picture. (120x120)

If you added `https://www.googleapis.com/auth/userinfo.email` to the scopes array,
the promise's result will include an `email: String` property.

You can optionally pass `{ silent: true }` as the first argument
if you want to sign into the account most recently used with your app.

#### GoogleSignIn.isConnected()

This function returns a [`Promise`](https://github.com/aleclarson/Promise)
that resolves into `true` if a user is currently authorized.

#### GoogleSignIn.signOut()

This function marks the current user as signed out.

The OAuth 2.0 token is **NOT** removed from the keychain.

The return value is always `undefined`.

#### GoogleSignIn.disconnect()

This function returns a [`Promise`](https://github.com/aleclarson/Promise)
that resolves when the current user has successfully revoked its authentication.
The `Promise` will be rejected if the request fails.

Do **NOT** call `signOut` if you already called this function.
