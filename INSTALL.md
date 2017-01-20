
# install (ios only)

Follow these steps to get started with `RNGoogleSignIn`!

#### 1. Search paths

- Drag `ios/RNGoogleSignIn.xcodeproj` into your own Xcode project/workspace.

- Goto `Build Settings` in **your project's target**.

- For both `Framework Search Paths` and `Header Search Paths`, add this to the list:

```
$(SRCROOT)/../node_modules/google-signin/ios/**
```

#### 2. Supporting files

- Follow the steps on [this page](https://developers.google.com/identity/sign-in/ios/start-integrating).

#### 3. Frameworks

- Goto `Build Phases > Link Binary With Libraries` in **your project's target**.

- Add these frameworks:

```
SystemConfiguration.framework
SafariServices.framework
AddressBook.framework
```

- Goto `Build Settings > Linking` in **your project's target**.

- Add `-lz` to the `Other Linker Flags` array (this links `libz.dylib` for the SDK).

#### 4. Import away!

```objc
#import "RNGoogleSignIn.h"
```

#### Run into a problem?

Let me know in [the issues](https://github.com/aleclarson/google-signin/issues)!
