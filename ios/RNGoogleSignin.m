
#import <React/RCTEventDispatcher.h>

#import "RNGoogleSignIn.h"

@implementation RNGoogleSignIn

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

RCT_EXPORT_METHOD(configure:(NSArray*)scopes iosClientId:(NSString*)iosClientId webClientId:(NSString*)webClientId)
{
  GIDSignIn *signIn = [GIDSignIn sharedInstance];
  signIn.delegate = self;
  signIn.uiDelegate = self;

  signIn.scopes = scopes;
  signIn.clientID = iosClientId;

  if (webClientId.length != 0) {
    signIn.serverClientID = webClientId;
  }
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
      sendAppEventWithName:@"RNGoogleSignInError"
      body:@{
        @"message": error.description,
        @"code": [NSNumber numberWithInteger: error.code]
      }];
  }

  NSURL *imageURL;

  if (user.profile.hasImage) {
    imageURL = [user.profile imageURLWithDimension:120];
  }

  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignInSuccess"
    body:@{
      @"id": user.userID,
      @"name": user.profile.name,
      @"givenName": user.profile.givenName,
      @"familyName": user.profile.familyName,
      @"photo": imageURL ? imageURL.absoluteString : [NSNull null],
      @"email": user.profile.email,
      @"idToken": user.authentication.idToken,
      @"accessToken": user.authentication.accessToken,
      @"serverAuthCode": user.serverAuthCode ? user.serverAuthCode : [NSNull null],
      @"accessTokenExpirationDate": [NSNumber numberWithDouble:user.authentication.accessTokenExpirationDate.timeIntervalSinceNow]
    }];
}

- (void) signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleSignInWillDispatch"
    body:@{}];
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
  if (error != nil) {
    return [_bridge.eventDispatcher
      sendAppEventWithName:@"RNGoogleRevokeError"
      body:@{
        @"message": error.description,
        @"code": [NSNumber numberWithInteger: error.code]
      }];
  }

  return [_bridge.eventDispatcher
    sendAppEventWithName:@"RNGoogleRevokeSuccess"
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
