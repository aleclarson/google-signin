
#import <React/RCTEventDispatcher.h>
#import "RNGoogleSignIn.h"

@implementation RNGoogleSignIn

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

const NSString *SCOPE_USER_PROFILE = @"https://www.googleapis.com/auth/userinfo.profile";

RCT_EXPORT_METHOD(configure:(NSDictionary*)config)
{
  GIDSignIn *signIn = [GIDSignIn sharedInstance];
  signIn.delegate = self;
  signIn.uiDelegate = self;

  // BUG: We shouldn't be forced to use 'shouldFetchBasicProfile'!
  //      This makes it backwards compatible. Remove when no longer needed.
  NSMutableArray *scopes = [NSMutableArray arrayWithArray:config[@"scopes"]];
  if ([scopes containsObject:SCOPE_USER_PROFILE]) {
    [scopes removeObject:SCOPE_USER_PROFILE];
    signIn.shouldFetchBasicProfile = YES;
  }

  signIn.scopes = scopes;
  signIn.clientID = config[@"clientID"];
  signIn.serverClientID = config[@"serverClientID"];
}

// 'hasAuthInKeychain' is renamed 'isConnected'
RCT_EXPORT_METHOD(isConnected:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  resolve(@([GIDSignIn sharedInstance].hasAuthInKeychain));
}

// 'signIn' is renamed 'connect'
RCT_EXPORT_METHOD(connect)
{
  [[GIDSignIn sharedInstance] signIn];
}

// 'signInSilently' is renamed 'reconnect'
RCT_EXPORT_METHOD(reconnect)
{
  [[GIDSignIn sharedInstance] signInSilently];
}

// 'signOut' is renamed 'disconnect'
RCT_EXPORT_METHOD(disconnect)
{
  [[GIDSignIn sharedInstance] signOut];
}

// 'disconnect' is renamed 'revoke'
RCT_EXPORT_METHOD(revoke)
{
  [[GIDSignIn sharedInstance] disconnect];
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)signIn:(GIDSignIn *)signIn
        didSignInForUser:(GIDGoogleUser *)user
        withError:(NSError *)error
{
  if (error != nil) {
    return [self dispatchError:error withName:@"connectFailed"];
  }

  NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
    @"accessToken": user.authentication.accessToken,
    @"accessTokenExpirationDate": [NSNumber numberWithDouble:user.authentication.accessTokenExpirationDate.timeIntervalSince1970],
  }];

  // Used to identify a user on the server-side.
  if (user.authentication.idToken) {
    [body setValuesForKeysWithDictionary:@{
      @"idToken": user.authentication.idToken,
      @"idTokenExpirationDate": [NSNumber numberWithDouble:user.authentication.idTokenExpirationDate.timeIntervalSince1970],
    }];
  }

  // Only exists when 'signIn.serverClientID' is set.
  if (user.serverAuthCode) {
    [body setValue:user.serverAuthCode
            forKey:@"serverAuthCode"];
  }

  // Only exists if 'SCOPE_USER_PROFILE' is included in 'config.scopes'.
  if (user.userID) {
    GIDProfileData *profile = user.profile;
    NSURL *imageURL = profile.hasImage ? [profile imageURLWithDimension:120] : nil;
    body[@"user"] = @{
      @"id": user.userID,
      @"name": profile.name,
      @"givenName": profile.givenName,
      @"familyName": profile.familyName,
      @"email": profile.email ? profile.email : [NSNull null],
      @"image": imageURL ? imageURL.absoluteString : [NSNull null],
    };
  }

  NSLog(@"[RNGoogleSignIn] connected");
  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignIn.connected"
    body:body];
}

- (void) signInWillDispatch:(GIDSignIn *)signIn
         error:(NSError *)error
{
  if (error != nil) {
    return [self dispatchError:error withName:@"connectFailed"];
  }

  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignIn.connecting"
    body:@{}];
}

- (void)signIn:(GIDSignIn *)signIn
        didDisconnectWithUser:(GIDGoogleUser *)user
        withError:(NSError *)error
{
  if (error != nil) {
    return [self dispatchError:error withName:@"revokeFailed"];
  }

  NSLog(@"[RNGoogleSignIn] disconnected");
  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignIn.revoked"
    body:@{}];
}

- (void)dispatchError:(NSError *)error
        withName:(NSString *)name
{
  NSLog(@"[RNGoogleSignIn] %@", error.description);
  return [_bridge.eventDispatcher
    sendAppEventWithName:[NSString stringWithFormat:@"RNGoogleSignIn.%@", name]
    body:@{
      @"message": error.description,
      @"code": [NSNumber numberWithInteger: error.code]
    }];
}

- (void)signIn:(GIDSignIn *)signIn
        presentViewController:(UIViewController *)viewController
{
  UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
  [rootViewController
    presentViewController:viewController
    animated:true
    completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn
        dismissViewController:(UIViewController *)viewController
{
  [viewController
    dismissViewControllerAnimated:true
    completion:nil];
}

+ (BOOL)application:(UIApplication *)application
        openURL:(NSURL *)url
        sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
  return [[GIDSignIn sharedInstance]
    handleURL:url
    sourceApplication:sourceApplication
    annotation:annotation];
}

@end
