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
#import "BossEventMenuController.h"
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
#import "TournamentMenuController.h"
#import "TutorialBattleLayer.h"
#import "GameLayer.h"

#define DOOR_CLOSE_DURATION 1.5f
#define DOOR_OPEN_DURATION 1.f

#define EYES_START_ALPHA 80.f
#define EYES_END_ALPHA 180.f
#define EYES_PULSATE_DURATION 2.f

#define DEFAULT_PNG_IMAGE_VIEW_TAG 103
#define KINGDOM_PNG_IMAGE_VIEW_TAG 104

#define PART_0_PERCENT 0.f
#define PART_1_PERCENT 0.05f
#define PART_2_PERCENT 0.85f
#define PART_3_PERCENT 1.f
#define SECONDS_PER_PART 10.f

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
  [BossEventMenuController removeView];
  [BossEventMenuController purgeSingleton];
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
  [TournamentMenuController removeView];
  [TournamentMenuController purgeSingleton];
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
  imgView.center = CGPointMake(v.frame.size.width/2, v.frame.size.height/2);
  imgView.userInteractionEnabled = YES;
  [v addSubview:imgView];
  [imgView release];
  [v release];
  
  self.loadingBar = [[ProgressBar alloc] initWithImage:[Globals imageNamed:@"loadingbar.png"]];
  [self.loadingBar awakeFromNib];
  self.loadingBar.center = CGPointMake(imgView.frame.size.width/2, imgView.frame.size.height/2+87);
  [imgView addSubview:self.loadingBar];
  self.loadingBar.percentage = 0.f;
  [self.loadingBar release];
  [self progressFrom:PART_0_PERCENT to:PART_1_PERCENT];
  
  self.loadingLabel = [[NiceFontLabel alloc] initWithFrame:CGRectZero];
  [Globals adjustFontSizeForSize:12.f withUIView:self.loadingLabel];
  [imgView addSubview:self.loadingLabel];
  self.loadingLabel.text = @"Loading...";
  self.loadingLabel.backgroundColor = [UIColor clearColor];
  self.loadingLabel.textAlignment = NSTextAlignmentCenter;
  self.loadingLabel.textColor = [UIColor whiteColor];
  self.loadingLabel.shadowColor = [UIColor colorWithWhite:0.f alpha:0.3f];
  self.loadingLabel.shadowOffset = CGSizeMake(0, 1);
  [self.loadingLabel release];
  
  CGRect f = self.loadingLabel.frame;
  f.origin = self.loadingBar.frame.origin;
  f.origin.y -= 2.f;
  f.size = self.loadingBar.image.size;
  f.size.height += 4.f;
  self.loadingLabel.frame = f;
  [Globals adjustFontSizeForUILabel:self.loadingLabel];
  
  v.alpha = 0.f;
  [UIView animateWithDuration:1.5f delay:1.f options:UIViewAnimationOptionTransitionNone animations:^{
    v.alpha = 1.f;
  } completion:^(BOOL finished) {
    [self removeSplashImageView];
  }];
}

- (void) progressFrom:(float)f to:(float)t {
  [self.loadingBar.layer removeAllAnimations];
  self.loadingBar.percentage = f;
  [UIView animateWithDuration:SECONDS_PER_PART animations:^{
    self.loadingBar.percentage = t;
  }];
}

- (void) connectedToHost {
  //  loadingLabel.string = @"Shining armor, so bright...";
  [self progressFrom:PART_1_PERCENT to:PART_2_PERCENT];
}

- (void) startupComplete {
  //  loadingLabel.string = @"A little gel in the hair...";
  [self progressFrom:PART_2_PERCENT to:PART_3_PERCENT];
}

- (void) loadPlayerCityComplete {
  //  loadingLabel.string = @"We're ready for warfare...";
  [self progressFrom:PART_3_PERCENT to:1.f];
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
    CharSelectionViewController *csvc = [[CharSelectionViewController alloc] initWithNibName:nil bundle:nil];
    [Globals displayUIView:csvc.view];
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
  
  if (!gs.isTutorial) {
    CCLayer *layer = [GameLayer sharedGameLayer];
    
    layer.tag = 5;
    
    [[[CCDirector sharedDirector] runningScene] addChild:layer];
  } else {
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
}

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  CGSize size = rect.size;
  rect.size = CGSizeMake(rect.size.height, rect.size.width);
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

