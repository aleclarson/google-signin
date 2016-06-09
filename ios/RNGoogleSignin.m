
#import <React/RCTEventDispatcher.h>
#import "RNGoogleSignIn.h"

@implementation RNGoogleSignIn

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

RCT_EXPORT_METHOD(configure:(NSDictionary*)config)
{
  GIDSignIn *signIn = [GIDSignIn sharedInstance];
  signIn.delegate = self;
  signIn.uiDelegate = self;

  signIn.scopes = config[@"scopes"];
  signIn.clientID = config[@"clientID"];
  signIn.serverClientID = config[@"serverID"];
  signIn.shouldFetchBasicProfile = NO;
}

RCT_EXPORT_METHOD(signIn)
{
  [[GIDSignIn sharedInstance] signIn];
}

RCT_EXPORT_METHOD(signInSilently)
{
  [[GIDSignIn sharedInstance] signInSilently];
}

RCT_EXPORT_METHOD(signOut)
{
  [[GIDSignIn sharedInstance] signOut];
}

RCT_EXPORT_METHOD(isConnected:(RCTPromiseResolveBlock)resolve)
{
  resolve(@([GIDSignIn sharedInstance].hasAuthInKeychain));
}

RCT_EXPORT_METHOD(disconnect)
{
  [[GIDSignIn sharedInstance] disconnect];
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
  if (error != nil) {
    return [_bridge.eventDispatcher
      sendAppEventWithName:@"RNGoogleSignIn.connectFailed"
      body:@{
        @"message": error.description,
        @"code": [NSNumber numberWithInteger: error.code]
      }];
  }

  NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
    @"accessToken": user.authentication.accessToken,
    @"accessTokenExpirationDate": [NSNumber numberWithDouble:user.authentication.accessTokenExpirationDate.timeIntervalSince1970],
  }];

  if (user.serverAuthCode) {
    [body setValuesForKeysWithDictionary:@{
      @"idToken": user.authentication.idToken,
      @"idTokenExpirationDate": [NSNumber numberWithDouble:user.authentication.idTokenExpirationDate.timeIntervalSince1970],
      @"serverAuthCode": user.serverAuthCode ? user.serverAuthCode : [NSNull null],
    }];
  }

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

  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignIn.connected"
    body:body];
}

- (void) signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignIn.connecting"
    body:@{}];
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
  if (error != nil) {
    return [_bridge.eventDispatcher
      sendAppEventWithName:@"RNGoogleSignIn.disconnectFailed"
      body:@{
        @"message": error.description,
        @"code": [NSNumber numberWithInteger: error.code]
      }];
  }

  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignIn.disconnected"
    body:@{}];
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
  UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
  [rootViewController
    presentViewController:viewController
    animated:true
    completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
  [viewController
    dismissViewControllerAnimated:true
    completion:nil];
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [[GIDSignIn sharedInstance]
    handleURL:url
    sourceApplication:sourceApplication
    annotation:annotation];
}

@end
