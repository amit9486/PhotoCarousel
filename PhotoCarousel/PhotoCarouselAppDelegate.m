
#import "PhotoCarouselAppDelegate.h"
#import "PhotoCarouselRootViewController.h"

@implementation PhotoCarouselAppDelegate

@synthesize window;

- (BOOL)application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[PhotoCarouselRootViewController alloc] init];
    [self.window makeKeyAndVisible];

    return YES;
}
							
@end
