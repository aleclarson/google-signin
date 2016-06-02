
# google-signin 1.0.0 ![experimental](https://img.shields.io/badge/stability-experimental-EC5315.svg?style=flat)

> Provides native methods for signing into a Google account.

- Rendering the sign-in button is your responsibility.

- Includes the [Google Sign-In SDK v4.0.0](https://developers.google.com/identity/sign-in/ios/sdk/#download_the_google_sign-in_sdk)

- Tested with [React Native v0.19.x](https://github.com/facebook/react-native)

- 🚫Android support currently disabled

&nbsp;

## install

Use these steps to manually install this library.

CocoaPods is not yet supported.

#### Step 1

Drag `ios/RNGoogleSignIn.xcodeproj` into your own `*.xcodeproj`.

#### Step 2

- Select your project in the `Project Navigator` sidebar.

- Goto `Target > Info > URL Types`.

- Create a new URL type.

- Set the `URL Schemes` field to the value of `REVERSED_CLIENT_ID` in the config file you download from [this link.](https://developers.google.com/identity/sign-in/ios/sdk/#get-config)

This step sets up a custom URL scheme that the Google Sign-In SDK will
use to redirect the user back to your iOS application.

#### Step 3

- Select your project in the `Project Navigator` sidebar.

- Goto `Target > Build Phases > Link Binary With Libraries`.

- Add these frameworks:

  - `SystemConfiguration.framework`

  - `SafariServices.framework`

  - `AddressBook.framework`

This step links any frameworks that the Google Sign-In SDK
needs to work properly.

#### Step 4

- Select your project in the `Project Navigator` sidebar.

- Goto `Target > Build Settings > Search Paths`.

- Add `$(BUILT_PRODUCTS_DIR)/include` to `Header Search Paths`.

- Make sure the search path is marked as `recursive`.

This step makes the public headers of `RNGoogleSignIn` visible
to your own project's code.

#### Step 5

Now you can import the library as seen below:

```objc
#import <RNGoogleSignIn/RNGoogleSignIn.h>
```

#### Step 6

Some manual modifications to `React.xcodeproj` are needed
before everything works as expected.

- Select `React.xcodeproj` in the `Project Navigator` sidebar.

- Goto `Target > Build Phases`.

- Create a new `Headers` phase.

- Add every `*.h` file into the `Public` section.
  (not every header is needed, but this way requires less thinking)

- Goto `Target > Build Settings > Packaging`.

- Set `Public Headers Folder Path` to `include/$(PRODUCT_NAME)`.

This step makes the public headers of `React` visible
to the code of `RNGoogleSignIn`.

Now you can import something from `React` in a different way:

```objc
#import <React/RCTRootView.h>
```

&nbsp;
