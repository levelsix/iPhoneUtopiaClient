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
#import "SynthesizeSingleton.h"
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

#define DOOR_CLOSE_DURATION 2.f
#define DOOR_OPEN_DURATION 1.5f

@implementation GameView

@synthesize glView;

- (void) didAddSubview:(UIView *)subview {
  if ([subview isKindOfClass:[EAGLView class]]) {
    self.glView = (EAGLView *)subview;
  }
  else if (self.glView && subview != self.glView) {
    self.glView.userInteractionEnabled = NO;
  }
}

- (void) willRemoveSubview:(UIView *)subview {
  if (self.glView && subview != self.glView) {
    self.glView.userInteractionEnabled = YES;
  }
}

- (void) dealloc {
  self.glView = nil;
  [super dealloc];
}

@end

@implementation GameViewController

@synthesize isTutorial;
@synthesize canLoad;

+ (void) releaseAllViews {
  [GameState purgeSingleton];
  [Globals purgeSingleton];
  [ActivityFeedController removeView];
  [ActivityFeedController purgeSingleton];
  [CarpenterMenuController removeView];
  [CarpenterMenuController purgeSingleton];
  [ArmoryViewController removeView];
  [ArmoryViewController purgeSingleton];
  [GoldShoppeViewController removeView];
  [GoldShoppeViewController purgeSingleton];
  [MapViewController removeView];
  [MapViewController purgeSingleton];
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
  [HomeMap purgeSingleton];
  [BattleLayer purgeSingleton];
  
  [[[CCDirector sharedDirector] runningScene] removeAllChildrenWithCleanup:YES];
}

SYNTHESIZE_SINGLETON_FOR_CLASS(GameViewController);

- (void) startDoorAnimation {
  CCScene *scene = [[CCDirector sharedDirector] runningScene];
  if (!scene) {
    scene = [CCScene node];
    [[CCDirector sharedDirector] runWithScene:scene];
  }
  
  CCLayer *layer = [CCLayer node];
  [scene addChild:layer z:1];
  
  splash= [CCSprite spriteWithFile:@"Default.png"];
  [layer addChild:splash z:10];
  splash.position = ccp(layer.contentSize.width/2, layer.contentSize.height/2);
  splash.rotation = 90;
  
  doorleft = [CCSprite spriteWithFile:@"doorleft.png"];
  doorleft.anchorPoint = ccp(1, 0.5);
  doorleft.position = ccp(0, doorleft.contentSize.height/2);
  [layer addChild:doorleft z:11];
  
  doorright = [CCSprite spriteWithFile:@"doorright.png"];
  doorright.anchorPoint = ccp(0, 0.5);
  doorright.position = ccp(layer.contentSize.width, doorright.contentSize.height/2);
  [layer addChild:doorright z:11];
  
  CCSprite *fillButtonSprite = [CCSprite spriteWithFile:@"middlecoin.png"];
  CCMenuItemSprite *s = [CCMenuItemSprite itemFromNormalSprite:fillButtonSprite selectedSprite:nil target:self selector:@selector(crestClicked)];
  
  crest = [CCMenu menuWithItems:s,nil];
  [doorright addChild:crest];
  crest.position = ccp(-8, doorright.contentSize.height/2);
  
  [doorleft runAction:[CCEaseBounceOut actionWithAction:[CCSequence actions:
                                                         [CCMoveBy actionWithDuration:DOOR_CLOSE_DURATION position:ccp(doorleft.contentSize.width, 0)],
                                                         [CCCallFunc actionWithTarget:self selector:@selector(doorClosed)],
                                                         nil]]];
  [doorright runAction:[CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:DOOR_CLOSE_DURATION position:ccp(-doorright.contentSize.width, 0)]]];
  
  self.canLoad = NO;
  _isRunning = NO;
}

- (void) doorClosed {
  [splash removeFromParentAndCleanup:YES];
  self.canLoad = YES;
}

- (void) crestClicked {
  if ([[GameState sharedGameState] connected] && !_isRunning) {
    // Open door
    [doorleft runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:DOOR_OPEN_DURATION position:ccp(-doorleft.contentSize.width-100, 0)],
                         [CCCallFunc actionWithTarget:self selector:@selector(openDoorDone)],
                         nil]];
    [doorright runAction:[CCMoveBy actionWithDuration:DOOR_OPEN_DURATION position:ccp(doorright.contentSize.width+100, 0)]];
    _isRunning = YES;
  }
}

- (void) openDoorDone {
  [doorright.parent removeFromParentAndCleanup:YES];
  
  if (self.isTutorial) {
    TutorialStartLayer *tsl = (TutorialStartLayer *)[[[CCDirector sharedDirector] runningScene] getChildByTag:5];
    [tsl start];
  }
}

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

- (void)setupCocos2D {
  EAGLView *glView = [EAGLView viewWithFrame:self.view.bounds
                                 pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
                                 depthFormat:0                        // GL_DEPTH_COMPONENT16_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil 
                               multiSampling:YES 
                             numberOfSamples:3];
  
  [[CCDirector sharedDirector] setOpenGLView:glView];
  
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [[CCDirector sharedDirector] enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
  
  [self removeStartupFlicker];
  
  [self.view insertSubview:glView atIndex:0];
  
  [self startDoorAnimation];
  
  [[[self.view subviews] objectAtIndex:1] removeFromSuperview];
}

- (void) setIsTutorial:(BOOL)i {
  isTutorial = i;
  
  while (!self.canLoad) {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
  }
  
  if (isTutorial) {
    TopBar *tb = [TutorialTopBar sharedTopBar];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:tb];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:tb.profilePic];
    
    // Startup the tutorial home map
    [TutorialHomeMap sharedHomeMap];
  }
  
  CCLayer *layer = isTutorial ? [TutorialStartLayer node] : [GameLayer sharedGameLayer];
  layer.tag = 5;
  [[[CCDirector sharedDirector] runningScene] addChild:layer];
}

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  rect.size = CGSizeMake( rect.size.height, rect.size.width );
  GameView *v = [[GameView alloc] initWithFrame:rect];
  UIImageView *i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
  i.layer.transform = CATransform3DMakeRotation(M_PI_2, 0.f, 0.f, 1.f);
  i.center = CGPointMake(v.frame.size.width/2, v.frame.size.height/2);
  [v addSubview:i];
  [i release];
  self.view = v;
  [v release];
  [self setupCocos2D];
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

