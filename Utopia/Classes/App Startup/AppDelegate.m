//
//  AppDelegate.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "GameLayer.h"
#import "GameViewController.h"
#import "SocketCommunication.h"
#import "LocationManager.h"
#import "IAPHelper.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"

@implementation AppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

	CC_ENABLE_DEFAULT_GL_STATES();
	CCDirector *director = [CCDirector sharedDirector];
	CGSize size = [director winSize];
	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	sprite.position = ccp(size.width/2, size.height/2);
	sprite.rotation = -90;
	[sprite visit];
	[[director openGLView] swapBuffers];
	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
   (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  
	// Init the window
//	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	CCDirector *director = [CCDirector sharedDirector];
	
  /*
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	*/
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	///Users/Ashwin/Utopia/Utopia/Classes/App Startup/DoorViewController.h
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	/*
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	*/
   
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  
//  if (![[LocationManager alloc] initWithDelegate:self]) {
//    // Inform of location services off
//  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  NSLog(@"will raesign active");
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  NSLog(@"did become active");
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  NSLog(@"did receive mem warning");
	[[CCDirector sharedDirector] purgeCachedData];
  [[[Globals sharedGlobals] imageCache] removeAllObjects];
  [[GameState sharedGameState] purgeStaticData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
  NSLog(@"did enter background");
	[[CCDirector sharedDirector] stopAnimation];
  UILocalNotification *ln = [[UILocalNotification alloc] init];
  ln.alertBody = @"WHY YOU NO STAY??";
  ln.alertAction = @"SERIOUSLY!?";
  ln.applicationIconBadgeNumber = 3;
  ln.soundName = UILocalNotificationDefaultSoundName;
  ln.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
  [[UIApplication sharedApplication] scheduleLocalNotification:ln];
  [ln release];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
  NSLog(@"will enter foreground");
  if ([[CCDirector sharedDirector] runningScene]) {
      [[CCDirector sharedDirector] startAnimation];
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  NSLog(@"will terminate");
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
//	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  NSLog(@"sig time change");
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  NSLog(@"Received new location: lat %f, long %f with timestamp: %@", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.timestamp);
  if ([newLocation.timestamp timeIntervalSinceNow] > -60.f) {
    [[OutgoingEventController sharedOutgoingEventController] changeUserLocationWithCoordinate:newLocation.coordinate];
    [manager stopUpdatingLocation];
    [manager release];
    NSLog(@"Terminating location manager..");
  }
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
