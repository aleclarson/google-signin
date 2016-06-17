
#import <React/RCTBridgeModule.h>

#import "GoogleSignIn.h"

@interface RNGoogleSignIn : NSObject<RCTBridgeModule, GIDSignInDelegate, GIDSignInUIDelegate>

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
