//
//  RootViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "GameViewController.h"
#import "GameConfig.h"
#import "GameLayer.h" 
#import "BattleLayer.h" 
#import "LNSynthesizeSingleton.h"
#import "QuestLogController.h"
#import "TutorialStartLayer.h"
#import "TutorialHomeMap.h"
#import "TopBar.h"
#import "TutorialTopBar.h"
#import "GameState.h"
#import "ActivityFeedController.h"
#import "CarpenterMenuController.h"
#import "GameState.h"
#import "Globals.h"
#import "ArmoryViewController.h"
#import "GenericPopupController.h"
#import "GoldShoppeViewController.h"
#import "MapViewController.h"
#import "MarketplaceViewController.h"
#import "ProfileViewController.h"
#import "QuestLogController.h"
#import "RefillMenuController.h"
#import "VaultMenuController.h"
#import "GameLayer.h"
#import "HomeMap.h"
#import "BattleLayer.h"
#import "SoundEngine.h"
#import "TopBar.h"
#import "FAQMenuController.h"
#import "ConvoMenuController.h"
#import "EquipMenuController.h"
#import "ForgeMenuController.h"
#import "AttackMenuController.h"
#import "LeaderboardController.h"
#import "ChatMenuController.h"
#import "ClanMenuController.h"
#import "LockBoxMenuController.h"
#import "ThreeCardMonteViewController.h"
#import "CharSelectionViewController.h"

#define DOOR_CLOSE_DURATION 1.5f
#define DOOR_OPEN_DURATION 1.f

#define EYES_START_ALPHA 80.f
#define EYES_END_ALPHA 180.f
#define EYES_PULSATE_DURATION 2.f

#define DEFAULT_PNG_IMAGE_VIEW_TAG 103
#define KINGDOM_PNG_IMAGE_VIEW_TAG 104

@implementation GameView

@synthesize glView;

- (void) didAddSubview:(UIView *)subview {
  if ([subview isKindOfClass:[EAGLView class]]) {
    self.glView = (EAGLView *)subview;
  }
  //  else if (self.glView && subview != self.glView) {
  //    self.glView.userInteractionEnabled = NO;
  //  }
}

//- (void) willRemoveSubview:(UIView *)subview {
//  if (self.glView && subview != self.glView) {
//    self.glView.userInteractionEnabled = YES;
//  }
//}

- (void) dealloc {
  self.glView = nil;
  [super dealloc];
}

@end

@implementation GameViewController

SYNTHESIZE_SINGLETON_FOR_CLASS(GameViewController);

+ (void) releaseAllViews {
  [[GameState sharedGameState] clearAllData];
  
  [sharedGameViewController dismissModalViewControllerAnimated:NO];
  
  [ActivityFeedController removeView];
  [ActivityFeedController purgeSingleton];
  [AttackMenuController removeView];
  [AttackMenuController purgeSingleton];
  [CarpenterMenuController removeView];
  [CarpenterMenuController purgeSingleton];
  [ChatMenuController removeView];
  [ChatMenuController purgeSingleton];
  [ClanMenuController removeView];
  [ClanMenuController purgeSingleton];
  [ConvoMenuController removeView];
  [ConvoMenuController purgeSingleton];
  [ArmoryViewController removeView];
  [ArmoryViewController purgeSingleton];
  [FAQMenuController removeView];
  [FAQMenuController purgeSingleton];
  [ForgeMenuController removeView];
  [ForgeMenuController purgeSingleton];
  [GoldShoppeViewController removeView];
  [GoldShoppeViewController purgeSingleton];
  [LeaderboardController removeView];
  [LeaderboardController purgeSingleton];
  [LockBoxMenuController removeView];
  [LockBoxMenuController purgeSingleton];
  [MapViewController cleanupAndPurgeSingleton];
  [MarketplaceViewController removeView];
  [MarketplaceViewController purgeSingleton];
  [ProfileViewController removeView];
  [ProfileViewController purgeSingleton];
  [QuestLogController removeView];
  [QuestLogController purgeSingleton];
  [RefillMenuController removeView];
  [RefillMenuController purgeSingleton];
  [VaultMenuController removeView];
  [VaultMenuController purgeSingleton];
  [GameLayer purgeSingleton];
  [GenericPopupController removeView];
  [GenericPopupController purgeSingleton];
  [EquipMenuController removeView];
  [EquipMenuController purgeSingleton];
  [ThreeCardMonteViewController removeView];
  [ThreeCardMonteViewController purgeSingleton];
  if ([HomeMap isInitialized]) [[HomeMap sharedHomeMap] invalidateAllTimers];
  [HomeMap purgeSingleton];
  [BazaarMap purgeSingleton];
  [BattleLayer purgeSingleton];
  [[TopBar sharedTopBar] invalidateTimers];
  [TopBar purgeSingleton];
  
  [sharedGameViewController removeAllSubviews];
  
  [[[CCDirector sharedDirector] runningScene] removeAllChildrenWithCleanup:YES];
  
  [sharedGameViewController loadDefaultImage];
}

- (void) removeAllSubviews {
  NSMutableArray *toRemove = [NSMutableArray array];
  for (UIView *view in sharedGameViewController.view.subviews) {
    if (![view isKindOfClass:[EAGLView class]] && view.tag != CHAR_SELECTION_VIEW_TAG) {
      [toRemove addObject:view];
    }
  }
  for (UIView *view in toRemove) {
    [view removeFromSuperview];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:CHAR_SELECTION_CLOSE_NOTIFICATION object:nil];
}

- (void) fadeToLoadingScreen {
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  
  UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:v];
  v.tag = KINGDOM_PNG_IMAGE_VIEW_TAG;
  v.backgroundColor = [UIColor blackColor];
  
  UIImageView *imgView = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"ageofchaos.png"]];
  imgView.transform = CGAffineTransformMakeRotation(M_PI/2);
  imgView.center = CGPointMake(v.frame.size.width/2, v.frame.size.height/2);
  imgView.userInteractionEnabled = YES;
  [v addSubview:imgView];
  [imgView release];
  [v release];
  
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  // Remember to position at bottom right corner to account for the flip
  spinner.center = CGPointMake(imgView.frame.size.height/2+70, imgView.frame.size.width/2);
  [imgView addSubview:spinner];
  [spinner startAnimating];
  [spinner release];
  
  v.alpha = 0.f;
  [UIView animateWithDuration:1.5f delay:1.f options:UIViewAnimationOptionTransitionNone animations:^{
    v.alpha = 1.f;
  } completion:^(BOOL finished) {
    [self removeSplashImageView];
  }];
}

- (void) connectedToHost {
  //  loadingLabel.string = @"Shining armor, so bright...";
}

- (void) startupComplete {
  //  loadingLabel.string = @"A little gel in the hair...";
}

- (void) loadPlayerCityComplete {
  //  loadingLabel.string = @"We're ready for warfare...";
}

- (void) removeSplashImageView {
  [[self.view viewWithTag:DEFAULT_PNG_IMAGE_VIEW_TAG] removeFromSuperview];
}

- (void) removeKingdomImageView {
  UIView *v = [self.view viewWithTag:KINGDOM_PNG_IMAGE_VIEW_TAG];
  [UIView animateWithDuration:1.f animations:^{
    v.alpha = 0.f;
  } completion:^(BOOL finished) {
    [v removeFromSuperview];
  }];
}

- (void) allowRestartOfGame {
  _startedGame = NO;
}

- (void) startGame {
  if (_startedGame) {
    return;
  }
  _startedGame = YES;
  
  GameState *gs = [GameState sharedGameState];
  
  if (gs.isTutorial) {
    TutorialStartLayer *tsl = (TutorialStartLayer *)[[[CCDirector sharedDirector] runningScene] getChildByTag:5];
    [tsl start];
    [Analytics tutorialOpenedDoor];
  } else {
    [[TopBar sharedTopBar] start];
  }
  
  [self removeSplashImageView];
  [self removeKingdomImageView];
}

- (void)setupCocos2D {
//  CGRect frame = CGRectMake(0, 0, 480, 320);
  EAGLView *glView = [EAGLView viewWithFrame:self.view.bounds
                                 pixelFormat:kEAGLColorFormatRGBA8	// kEAGLColorFormatRGBA8
                                 depthFormat:0];                       // GL_DEPTH_COMPONENT16_OES
  
//  glView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
  
  // Display link director is causing problems with uiscrollview and table view.
  //  [CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
  [[CCDirector sharedDirector] setOpenGLView:glView];
  
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [[CCDirector sharedDirector] enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
  
  [self.view insertSubview:glView atIndex:0];
  
  CCScene *scene = [CCScene node];
  [[CCDirector sharedDirector] runWithScene:scene];
  
  [self fadeToLoadingScreen];
}

- (void) preloadLayer {
//  EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
//  [EAGLContext setCurrentContext:k_context];
  
  GameState *gs = [GameState sharedGameState];
  CCLayer *layer = gs.isTutorial ? [TutorialStartLayer node] : [GameLayer sharedGameLayer];
  
  if (layer.parent) {
    // We are in the tutorial
    return;
  }
  
  layer.tag = 5;
  
  [[[CCDirector sharedDirector] runningScene] addChild:layer];
  
  if (gs.isTutorial) {
    [self startGame];
    [Analytics tutorialStart];
  }
}

- (void) loadGame:(BOOL)isTutorial {
  [[GameState sharedGameState] setIsTutorial:isTutorial];
  
  if (isTutorial) {
    TopBar *tb = [TutorialTopBar sharedTopBar];
    tb.isTouchEnabled = NO;
  }
  
  [self preloadLayer];
//  [self performSelectorInBackground:@selector(preloadLayer) withObject:nil];
}

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  CGSize size = rect.size;
  rect.size = CGSizeMake(rect.size.height, rect.size.width);//480, 320);
  rect.origin = CGPointMake((size.height-rect.size.width)/2, (size.width-rect.size.height)/2);
  GameView *v = [[GameView alloc] initWithFrame:rect];
  v.backgroundColor = [UIColor blackColor];
  
  self.view = v;
  [v release];
  
  [self loadDefaultImage];
  
  [self setupCocos2D];
}

- (void) loadDefaultImage {
  UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:v];
  v.tag = DEFAULT_PNG_IMAGE_VIEW_TAG;
  v.backgroundColor = [UIColor blackColor];
  
  UIImageView *imgView = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"Default.png"]];
  imgView.transform = CGAffineTransformMakeRotation(M_PI/2);
  imgView.center = CGPointMake(v.frame.size.width/2, v.frame.size.height/2);
  [v addSubview:imgView];
  [imgView release];
  [v release];
  
  _startedGame = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  BOOL should =  UIInterfaceOrientationIsLandscape(interfaceOrientation);
	return should;
}

- (void)dealloc {
  [super dealloc];
}

@end

