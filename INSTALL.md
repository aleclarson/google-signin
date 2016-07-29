
# install

Use these steps to manually install this library.

❗️**NOTE:** RNPM and CocoaPods are not yet supported.

🚫**DANGER:** These instructions may result in compiler errors! Please create an issue if you have problems!

#### Step 1

Drag `ios/RNGoogleSignIn.xcodeproj` into your own `*.xcodeproj`.

#### Step 2

- Select your project in the `Project Navigator` sidebar.

- Goto `Target > Info > URL Types`.

- Create a new URL type.

- Set the `URL Schemes` field to the value of `REVERSED_CLIENT_ID` in the config
file you download from [this link.](https://developers.google.com/identity/sign-in/ios/sdk/#get-config)

This step sets up a custom URL scheme that the Google Sign-In SDK will
use to redirect the user back to your iOS application.

#### Step 3

- Select **your project** in the `Project Navigator` sidebar.

- Goto `Target > Build Phases > Link Binary With Libraries`.

- Add these frameworks:

  - `SystemConfiguration.framework`

  - `SafariServices.framework`

  - `AddressBook.framework`

This step links any frameworks that the Google Sign-In SDK
needs to work properly.

#### Step 4

- Select **your project** in the `Project Navigator` sidebar.

- Goto `Target > Build Settings > Linking`

- Add `-lz` to the `Other Linker Flags` array

This loads `libz.dylib` for the Google Sign-In SDK.

#### Step 5

- Select **your project** in the `Project Navigator` sidebar.

- Goto `Target > Build Settings > Search Paths`.

- Add `$(BUILT_PRODUCTS_DIR)/include` to `Header Search Paths`.

- Make sure the search path is marked as `recursive`.

This step makes the public headers of `RNGoogleSignIn` visible
to your own project's code.

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

Now you can import something from `React` like this:

```objc
#import <React/RCTRootView.h>
```

#### Step 7

Import the library like this:

```objc
#import <RNGoogleSignIn/RNGoogleSignIn.h>
```
