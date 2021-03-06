
#import "RCTBridgeModule.h"

#import <GoogleSignIn/GIDSignIn.h>

@interface RNGoogleSignIn : NSObject<RCTBridgeModule, GIDSignInDelegate, GIDSignInUIDelegate>

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
