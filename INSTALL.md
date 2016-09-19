
# install (ios only)

It's just 5 easy steps to using `RNGoogleSignIn`!

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

Import the library like this:

```objc
#import <RNGoogleSignIn/RNGoogleSignIn.h>
```
