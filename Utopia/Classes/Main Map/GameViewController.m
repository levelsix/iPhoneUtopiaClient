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

+ (void) releaseAllViews {
  [[GameState sharedGameState] clearAllData];
  
  [sharedGameViewController dismissModalViewControllerAnimated:NO];
  
  [ActivityFeedController removeView];
  [ActivityFeedController purgeSingleton];
  [CarpenterMenuController removeView];
  [CarpenterMenuController purgeSingleton];
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
  [[HomeMap sharedHomeMap] invalidateAllTimers];
  [HomeMap purgeSingleton];
  [BazaarMap purgeSingleton];
  [BattleLayer purgeSingleton];
  [[TopBar sharedTopBar] invalidateTimers];
  [TopBar purgeSingleton];
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (UIView *view in sharedGameViewController.view.subviews) {
    if (![view isKindOfClass:[EAGLView class]]) {
      [toRemove addObject:view];
    }
  }
  for (UIView *view in toRemove) {
    [view removeFromSuperview];
  }
  
  [[[CCDirector sharedDirector] runningScene] removeAllChildrenWithCleanup:YES];
  
  [sharedGameViewController loadDefaultImage];
}

SYNTHESIZE_SINGLETON_FOR_CLASS(GameViewController);

- (void) fadeToLoadingScreen {
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  
  UIView *v = self.view;
  UIImageView *imgView = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"kingdom.png"]];
  imgView.transform = CGAffineTransformMakeRotation(M_PI/2);
  imgView.tag = KINGDOM_PNG_IMAGE_VIEW_TAG;
  imgView.center = CGPointMake(v.frame.size.width/2, v.frame.size.height/2);
  [v addSubview:imgView];
  [imgView release];
  
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  // Remember to position at bottom right corner to account for the flip
  spinner.center = CGPointMake(imgView.frame.size.height-(spinner.frame.size.width/2+5), imgView.frame.size.width-(spinner.frame.size.height/2+5));
  [imgView addSubview:spinner];
  [spinner startAnimating];
  [spinner release];
  
  imgView.alpha = 0.f;
  [UIView animateWithDuration:1.f animations:^{
    imgView.alpha = 1.f;
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
  [UIView animateWithDuration:0.4f animations:^{
    v.alpha = 0.f;
  } completion:^(BOOL finished) {
    [v removeFromSuperview];
  }];
}

- (void) startGame {
  GameState *gs = [GameState sharedGameState];
  
  [self removeKingdomImageView];
  
  if (gs.isTutorial) {
    TutorialStartLayer *tsl = (TutorialStartLayer *)[[[CCDirector sharedDirector] runningScene] getChildByTag:5];
    [tsl start];
    [Analytics tutorialOpenedDoor];
  } else {
    [[TopBar sharedTopBar] start];
  }
}

- (void)setupCocos2D {
  EAGLView *glView = [EAGLView viewWithFrame:self.view.bounds
                                 pixelFormat:kEAGLColorFormatRGBA8	// kEAGLColorFormatRGBA8
                                 depthFormat:0];                       // GL_DEPTH_COMPONENT16_OES
  
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
  EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
  [EAGLContext setCurrentContext:k_context];
  
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
  
  [self performSelectorInBackground:@selector(preloadLayer) withObject:nil];
}

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  rect.size = CGSizeMake( rect.size.height, rect.size.width );
  GameView *v = [[GameView alloc] initWithFrame:rect];
  
  self.view = v;
  [v release];
  
  [self loadDefaultImage];
  
  [self setupCocos2D];
}

- (void) loadDefaultImage {
  UIView *v = self.view;
  UIImageView *imgView = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"Default.png"]];
  imgView.transform = CGAffineTransformMakeRotation(M_PI/2);
  imgView.tag = DEFAULT_PNG_IMAGE_VIEW_TAG;
  imgView.center = CGPointMake(v.frame.size.width/2, v.frame.size.height/2);
  [v addSubview:imgView];
  [imgView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

- (void)didReceiveMemoryWarning {
  // Don't allow release of this
  return;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [[CCDirector sharedDirector] end];
}


- (void)dealloc {
  [super dealloc];
}


@end

