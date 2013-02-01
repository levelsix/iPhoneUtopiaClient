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
#import "IAPHelper.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
//#import "Apsalar.h"
#import "LoggingContextFilter.h"
#import "SoundEngine.h"
#import "Crittercism.h"
#import "Downloader.h"
#import "GGEventLog.h"
#import <MobileAppTracker/MobileAppTracker.h>
#import <FacebookSDK/FacebookSDK.h>

#define CRASHALYTICS_API_KEY @"79eb314cfcf6a7b860185d2629d2c2791ee7f174"
#define FLURRY_API_KEY       @"2VNGQV9NXJ5GMBRZ5MTX"
#define ALAUME_API_KEY       @"d184b5bf284a45c4aa7e19e0230e1c2f"
#define ALAUME_APP_ID        @"tk"
#define APSALAR_API_KEY      @"lvl6"
#define APSALAR_SECRET       @"K7kbMwwF"
#define TEST_FLIGHT_API_KEY  @"83db3d95fe7af4e3511206c3e7254a5f_MTExODM4MjAxMi0wNy0xOCAyMTowNjoxOC41MjUzMjc"

#define MAT_ADVERTISER_ID    @"885"
#define MAT_APP_KEY          @"ba62d2918dc7b537cbeaca833085ce89"

#define GIRAFFE_GRAPH_KEY    @"eee3b73ca3f9fc3322e11be77275c13a"

#define FACEBOOK_APP_ID      @"308804055902016"

#define SHOULD_VIDEO_USER    0

@implementation AppDelegate

@synthesize window;
@synthesize isActive;
//@synthesize facebookDelegate;

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//  return [facebookDelegate application:application 
//                               openURL:url
//                     sourceApplication:sourceApplication
//                            annotation:annotation];
//}

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

-(void) setUpAlauMeRefferalTracking
{
//  AMConnect *alaume = [AMConnect sharedInstance];
//  
//  // Set to YES for debugging purposes. Trace info will be written to console.
//  alaume.isLoggingEnabled = NO;
//  
//  // Set to YES for Lite SKU.
//  alaume.isFreeSKU = NO;
//
//  [alaume initializeWithAppId:ALAUME_APP_ID apiKey:ALAUME_API_KEY];
}

-(void) setUpFlurryAnalytics 
{
//  [FlurryAnalytics startSession:FLURRY_API_KEY];
//  [FlurryAnalytics setUserID:[NSString stringWithFormat:@"%d", 
//                              [GameState sharedGameState].userId]];
}

-(void) setUpCrittercism
{
  [Crittercism initWithAppID:@"5029a2f0eeaf4125dd000001"
    andMainViewController:nil];
}

- (void) setUpMobileAppTracker {
  [[MobileAppTracker sharedManager] startTrackerWithAdvertiserId:MAT_ADVERTISER_ID
                                                   advertiserKey:MAT_APP_KEY
                                                       withError:nil];
  
  [[MobileAppTracker sharedManager] setShouldDebugResponseFromServer:NO];
  
  [[MobileAppTracker sharedManager] setDeviceId:[[UIDevice currentDevice] uniqueIdentifier]];
  
  [[MobileAppTracker sharedManager] trackInstallWithUpdateOnly:NO];
}

-(void) setUpDelightio
{
#if SHOULD_VIDEO_USER
#import <Delight/Delight.h>
  [Delight startWithAppToken:@"6a7116a21a57eacaeaafd07c133"];
#endif
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
  //	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  self.isActive = YES;
	
	CCDirector *director = [CCDirector sharedDirector];
  
#ifndef DEBUG
  [self setUpCrittercism];
#endif
	
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
  
#ifdef DEBUG
	[director setDisplayFPS:YES];
#else
	[director setDisplayFPS:NO];
#endif
	
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
  
  //  if (![[LocationManager alloc] initWithDelegate:self]) {
  //    // Inform of location services off
  //  }
#ifndef DEBUG
  [GGEventLog initializeApiKey:GIRAFFE_GRAPH_KEY trackCampaignSource:YES];
//  [Apsalar startSession:APSALAR_API_KEY withKey:APSALAR_SECRET andLaunchOptions:launchOptions];
#endif
  [Analytics beganApp];
  [Analytics openedApp];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  
  
  // Cocoa Lumberjack (logging framework)
  [DDLog addLogger:[DDASLLogger sharedInstance]];
  [DDLog addLogger:[DDTTYLogger sharedInstance]];	
	[[DDTTYLogger sharedInstance] setLogFormatter:[LoggingContextFilter 
                                                 createTagFilter]];

  // Alau.Me
  [self setUpAlauMeRefferalTracking];
  
  // Delight.io
  [self setUpDelightio];
  
  // Mobile App Tracker
  [self setUpMobileAppTracker];
  
  // Publish install
  [FBSettings publishInstall:FACEBOOK_APP_ID];
  
  // AdColony
//  adColonyDelegate = [[AdColonyDelegate createAdColonyDelegate] retain];

  // TapJoy
//  tapJoyDelegate = [[TapjoyDelegate createTapJoyDelegate] retain];
  /*
   * Disabled Sponsored offers:(Short Term)
   *  
  // Facebook
  facebookDelegate = [[FacebookDelegate createFacebookDelegate] retain];

  // FlurryClips
  flurryClipsDelegate = [[FlurryClipsDelegate createFlurryClipsDelegate] retain];
  
  // FlurryAnalytics
  [self setUpFlurryAnalytics];
 *
 */
  
  // TestFlight SDK
//  [TestFlight takeOff:TEST_FLIGHT_API_KEY];  
  
  // Kiip.me
//  kiipDelegate = [[KiipDelegate create] retain];
  
  [self removeLocalNotifications];

  return YES;
}

- (void) registerForPushNotifications {
	// Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
   (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  DDLogVerbose(@"will resign active");
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  DDLogVerbose(@"did become active");
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  DDLogWarn(@"did receive mem warning");
	[[CCDirector sharedDirector] purgeCachedData];
  [[[Globals sharedGlobals] imageCache] removeAllObjects];
  
  if (![[GameState sharedGameState] isTutorial]) {
    [[GameState sharedGameState] purgeStaticData];
  }
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
  DDLogVerbose(@"did enter background");
	[[CCDirector sharedDirector] stopAnimation];
  [self registerLocalNotifications];
  
  self.isActive = NO;
  
  [[OutgoingEventController sharedOutgoingEventController] logout];
  [[SocketCommunication sharedSocketCommunication] closeDownConnection];
  
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  
  [NSObject cancelPreviousPerformRequestsWithTarget:[Downloader sharedDownloader]];
  
  if (![[GameState sharedGameState] isTutorial]) {
    [GameViewController releaseAllViews];
  }
  [Analytics suspendedApp];
#ifndef DEBUG
//  [Apsalar endSession];
#endif
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
  DDLogVerbose(@"will enter foreground");
  self.isActive = YES;
  
#ifndef DEBUG
//  [Apsalar reStartSession:APSALAR_API_KEY withKey:APSALAR_SECRET];
#endif
  [Analytics beganApp];
  [Analytics resumedApp];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  if ([[CCDirector sharedDirector] runningScene]) {
    [[CCDirector sharedDirector] startAnimation];
    
    if (![[GameState sharedGameState] isTutorial]) {
      [[GameState sharedGameState] clearAllData];
      [[GameViewController sharedGameViewController] fadeToLoadingScreen];
    }
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  DDLogVerbose(@"will terminate");
	CCDirector *director = [CCDirector sharedDirector];
  [self registerLocalNotifications];
	
	[[director openGLView] removeFromSuperview];
	
	[window release];
	
	[director end];
  
  [[OutgoingEventController sharedOutgoingEventController] logout];
  [[SocketCommunication sharedSocketCommunication] closeDownConnection];
  
  [Analytics terminatedApp];
#ifndef DEBUG
//  [Apsalar endSession];
#endif
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  DDLogInfo(@"sig time change");
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	DDLogInfo(@"My token is: %@", deviceToken);
  [[OutgoingEventController sharedOutgoingEventController] enableApns:deviceToken];
  [Crittercism configurePushNotification:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	DDLogError(@"Failed to get token, error: %@", error);
  [[OutgoingEventController sharedOutgoingEventController] enableApns:nil];
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
  
  if (!gs.connected || gs.isTutorial) {
    return;
  }
  
  // Determine times so we can choose order of badge icons
  NSDate *energyRefilled = [gs.lastEnergyRefill dateByAddingTimeInterval:gl.energyRefillWaitMinutes*60*(gs.maxEnergy-gs.currentEnergy)];
  NSDate *staminaRefilled = [gs.lastStaminaRefill dateByAddingTimeInterval:gl.staminaRefillWaitMinutes*60*(gs.maxStamina-gs.currentStamina)];
  
  // Only send if energy and stamina are more than halfway used.
  BOOL shouldSendEnergyNotification = gs.connected ? gs.maxEnergy > 2*gs.currentEnergy : NO;
  BOOL shouldSendStaminaNotification = gs.connected ? gs.maxStamina > 2*gs.currentStamina : NO;
  
  if (shouldSendEnergyNotification) {
    // Stamina refilled
    NSString *text = [NSString stringWithFormat:@"Your energy has fully recharged! Hurry back and complete quests in the name of the %@!", [Globals factionForUserType:(gs.type+3)%6]];
    int badge = 1;//shouldSendStaminaNotification && [staminaRefilled compare:energyRefilled] == NSOrderedAscending ? 2 : 1;
    [self scheduleNotificationWithText:text badge:badge date:energyRefilled];
  }
  
  if (shouldSendStaminaNotification) {
    // Energy refilled
    NSString *text = [NSString stringWithFormat:@"Your stamina has fully recharged! Come back to show the %@ who's superior!", [Globals factionForUserType:(gs.type+3)%6]];
    int badge = 1;//shouldSendEnergyNotification && [energyRefilled compare:staminaRefilled] == NSOrderedAscending ? 2 : 1;
    [self scheduleNotificationWithText:text badge:badge date:staminaRefilled];
  }
  
  if (gs.forgeAttempt && !gs.forgeAttempt.isComplete) {
    FullEquipProto *fep = [gs equipWithId:gs.forgeAttempt.equipId];
    NSString *text = [NSString stringWithFormat:@"The Blacksmith has completed forging your %@. Come back to check if it succeeded!", fep.name];
    int minutes = [gl calculateMinutesForForge:gs.forgeAttempt.equipId level:gs.forgeAttempt.level];
    [self scheduleNotificationWithText:text badge:1 date:[gs.forgeAttempt.startTime dateByAddingTimeInterval:minutes*60.f]];
  }
  
  if (gs.equipEnhancement) {
    int mins = [gl calculateMinutesToEnhance:(UserEquip *)gs.equipEnhancement.enhancingEquip feeders:gs.equipEnhancement.feederEquipsList];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:gs.equipEnhancement.startTime/1000. + mins*60];
    if ([endDate compare:[NSDate date]] == NSOrderedDescending) {
      FullEquipProto *fep = [gs equipWithId:gs.equipEnhancement.enhancingEquip.equipId];
      NSString *text = [NSString stringWithFormat:@"The Blacksmith has completed enhancing your %@. Come back to collect it!", fep.name];
      [self scheduleNotificationWithText:text badge:1 date:endDate];
    }
  }
  
  if (gs.lastGoldmineRetrieval) {
    NSTimeInterval timeInterval = -[gs.lastGoldmineRetrieval timeIntervalSinceNow];
    int timeToStartCollect = 3600.f*gl.numHoursBeforeGoldmineRetrieval;
    int timeToEndCollect = 3600.f*(gl.numHoursBeforeGoldmineRetrieval+gl.numHoursForGoldminePickup);
    
    if (timeInterval < timeToStartCollect) {
      NSString *text = [NSString stringWithFormat:@"The Gold Mine has finished producing %d gold. Hurry and pick it up before the workers go on strike!", gl.goldAmountFromGoldminePickup];
      [self scheduleNotificationWithText:text badge:1 date:[gs.lastGoldmineRetrieval dateByAddingTimeInterval:timeToStartCollect]];
    }
    if (timeInterval < timeToEndCollect) {
      NSString *text = @"The workers at the Gold Mine have gone on strike! Come back to settle them down!";
      [self scheduleNotificationWithText:text badge:1 date:[gs.lastGoldmineRetrieval dateByAddingTimeInterval:timeToEndCollect]];
    }
  }
  
  if (gs.userExpansion.isExpanding) {
    NSString *text = @"Your expansion has completed! Come back to build a bigger city!";
    int minutes = [gl calculateNumMinutesForNewExpansion:gs.userExpansion];
    [self scheduleNotificationWithText:text badge:1 date:[gs.userExpansion.lastExpandTime dateByAddingTimeInterval:minutes*60.f]];
  }
  
  for (UserStruct *us in gs.myStructs) {
    if (us.state == kUpgrading) {
      FullStructureProto *fsp = [gs structWithId:us.structId];
      NSString *text = [NSString stringWithFormat:@"Your %@ has finished upgrading to Level %d!", fsp.name, us.level+1];
      int minutes = [gl calculateMinutesToUpgrade:us];
      [self scheduleNotificationWithText:text badge:1 date:[us.lastUpgradeTime dateByAddingTimeInterval:minutes*60.f]];
    } else if (us.state == kBuilding) {
      FullStructureProto *fsp = [gs structWithId:us.structId];
      NSString *text = [NSString stringWithFormat:@"Your %@ has finished building!", fsp.name];
      int minutes = fsp.minutesToBuild;
      [self scheduleNotificationWithText:text badge:1 date:[us.purchaseTime dateByAddingTimeInterval:minutes*60.f]];
    }
  }
  
  int curBadgeCount = 1;//shouldSendEnergyNotification + shouldSendStaminaNotification + 1;
  NSString *text = [NSString stringWithFormat:@"A kingdom cannot survive without a leader! %@, your people need you!", gs.name];
  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:12*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
  
//  curBadgeCount++;
  text = [NSString stringWithFormat:@"%@, the %@ needs you! Come back and prevent the %@ from taking over", gs.name, [Globals factionForUserType:gs.type] , [Globals factionForUserType:(gs.type+3)%6]];
  date = [NSDate dateWithTimeIntervalSinceNow:2*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
  
//  curBadgeCount++;
  text = [NSString stringWithFormat:@"%@, come back and reclaim the world for the all powerful %@!", gs.name, [Globals factionForUserType:gs.type]];
  date = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
  
//  curBadgeCount++;
  text = [NSString stringWithFormat:@"%@, the %@ needs you! Come back and prevent the %@ from taking over", gs.name, [Globals factionForUserType:gs.type] , [Globals factionForUserType:(gs.type+3)%6]];
  date = [NSDate dateWithTimeIntervalSinceNow:6*24*60*60];
  [self scheduleNotificationWithText:text badge:curBadgeCount date:date];
}

- (void) removeLocalNotifications {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
//  [adColonyDelegate release];
//  [tapJoyDelegate      release];
//  [flurryClipsDelegate release];
//  [facebookDelegate    release];
//  [kiipDelegate        release];
	[window release];
	[super dealloc];
}

@end
