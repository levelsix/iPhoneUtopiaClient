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
#import "Apsalar.h"

#define APSALAR_API_KEY @"lvl6"
#define APSALAR_SECRET @"K7kbMwwF"

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
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
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
	[director setDisplayFPS:NO];
	
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
  [Apsalar startSession:APSALAR_API_KEY withKey:APSALAR_SECRET andLaunchOptions:launchOptions];
  [Analytics beganApp];
  [Analytics openedApp];
  
  [self removeLocalNotifications];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  LNLog(@"will raesign active");
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  LNLog(@"did become active");
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  LNLog(@"did receive mem warning");
	[[CCDirector sharedDirector] purgeCachedData];
  [[[Globals sharedGlobals] imageCache] removeAllObjects];
  
  if (![[GameState sharedGameState] isTutorial]) {
    [[GameState sharedGameState] purgeStaticData];
  }
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
  LNLog(@"did enter background");
	[[CCDirector sharedDirector] stopAnimation];
  [self registerLocalNotifications];
  
  // Release all our views
  [[CCDirector sharedDirector] stopAnimation];
  
  [[SocketCommunication sharedSocketCommunication] closeDownConnection];
  
  if (![[GameState sharedGameState] isTutorial]) {
    [GameViewController releaseAllViews];
  }
  [Analytics suspendedApp];
  [Apsalar endSession];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
  LNLog(@"will enter foreground");
  [self removeLocalNotifications];
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  if ([[CCDirector sharedDirector] runningScene]) {
    [[CCDirector sharedDirector] startAnimation];
    
    if (![[GameState sharedGameState] isTutorial]) {
      [[GameViewController sharedGameViewController] startDoorAnimation];
    }
  }
  [Apsalar reStartSession:APSALAR_API_KEY withKey:APSALAR_SECRET];;
  [Analytics beganApp];
  [Analytics resumedApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  LNLog(@"will terminate");
	CCDirector *director = [CCDirector sharedDirector];
  [self registerLocalNotifications];
	
	[[director openGLView] removeFromSuperview];
	
	[window release];
	
	[director end];
  
  [Analytics terminatedApp];
  [Apsalar endSession];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  LNLog(@"sig time change");
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	LNLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	LNLog(@"Failed to get token, error: %@", error);
}

- (void) scheduleNotificationWithText:(NSString *)text badge:(int)badge date:(NSDate *)date {
  UILocalNotification *ln = [[UILocalNotification alloc] init];
  ln.alertBody = text;
  ln.applicationIconBadgeNumber = badge;
  ln.soundName = UILocalNotificationDefaultSoundName;
  ln.fireDate = date;
  [[UIApplication sharedApplication] scheduleLocalNotification:ln];
  [ln release];
}

- (void) registerLocalNotifications {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  // Determine times so we can choose order of badge icons
  NSDate *energyRefilled = [gs.lastEnergyRefill dateByAddingTimeInterval:gl.energyRefillWaitMinutes*60*(gs.maxEnergy-gs.currentEnergy)];
  NSDate *staminaRefilled = [gs.lastStaminaRefill dateByAddingTimeInterval:gl.staminaRefillWaitMinutes*60*(gs.maxStamina-gs.currentStamina)];
  
  BOOL shouldSendEnergyNotification = gs.connected ? gs.maxEnergy > gs.currentEnergy : NO;
  BOOL shouldSendStaminaNotification = gs.connected ? gs.maxStamina > gs.currentStamina : NO;
  
  if (shouldSendEnergyNotification) {
    // Stamina refilled
    NSString *text = [NSString stringWithFormat:@"Your energy has fully recharged! Hurry back and complete quests in the name of the %@!", [Globals factionForUserType:(gs.type+3)%6]];
    int badge = shouldSendStaminaNotification && [staminaRefilled compare:energyRefilled] == NSOrderedAscending ? 2 : 1;
    [self scheduleNotificationWithText:text badge:badge date:energyRefilled];
  }
  
  if (shouldSendStaminaNotification) {
    // Energy refilled
    NSString *text = [NSString stringWithFormat:@"Your stamina has fully recharged! Come back to show the %@ who's superior!", [Globals factionForUserType:(gs.type+3)%6]];
    int badge = shouldSendEnergyNotification && [energyRefilled compare:staminaRefilled] == NSOrderedAscending ? 2 : 1;
    [self scheduleNotificationWithText:text badge:badge date:staminaRefilled];
  }
  
  int curBadgeCount = shouldSendEnergyNotification + shouldSendStaminaNotification + 1;
  NSString *text = [NSString stringWithFormat:@"%@, come back and reclaim the world for the all powerful %@!", gs.name, [Globals factionForUserType:gs.type]];
  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
  
  curBadgeCount++;
  text = [NSString stringWithFormat:@"%@, the %@ needs you! Come back and prevent the %@ from taking over", gs.name, [Globals factionForUserType:gs.type] , [Globals factionForUserType:(gs.type+3)%6]];
  date = [NSDate dateWithTimeIntervalSinceNow:5*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
  
  curBadgeCount++;
  text = [NSString stringWithFormat:@"%@, come back and reclaim the world for the all powerful %@!", gs.name, [Globals factionForUserType:gs.type]];
  date = [NSDate dateWithTimeIntervalSinceNow:7*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
  
  curBadgeCount++;
  text = [NSString stringWithFormat:@"%@, the %@ needs you! Come back and prevent the %@ from taking over", gs.name, [Globals factionForUserType:gs.type] , [Globals factionForUserType:(gs.type+3)%6]];
  date = [NSDate dateWithTimeIntervalSinceNow:14*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
  
  curBadgeCount++;
  text = [NSString stringWithFormat:@"%@, come back and reclaim the world for the all powerful %@!", gs.name, [Globals factionForUserType:gs.type]];
  date = [NSDate dateWithTimeIntervalSinceNow:30*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
}

- (void) removeLocalNotifications {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
