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
#import "SimpleAudioEngine.h"
#import "TopBar.h"

#define DOOR_CLOSE_DURATION 1.5f
#define DOOR_OPEN_DURATION 1.f

#define EYES_START_ALPHA 80.f
#define EYES_END_ALPHA 180.f
#define EYES_PULSATE_DURATION 2.f

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
  [TopBar purgeSingleton];
  
  [[[CCDirector sharedDirector] runningScene] removeAllChildrenWithCleanup:YES];
}

SYNTHESIZE_SINGLETON_FOR_CLASS(GameViewController);

- (void) startDoorAnimation {
  CCScene *scene = [[CCDirector sharedDirector] runningScene];
  if (!scene) {
    scene = [CCScene node];
    [[CCDirector sharedDirector] runWithScene:scene];
  }
  
  [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
  [[SimpleAudioEngine sharedEngine] playEffect:@"DoorClosing_Final.m4a"];
  
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
  
  CCSprite *crest = [CCSprite spriteWithFile:@"skullmedalnomid.png"];
  [doorright addChild:crest z:1];
  crest.position = ccp(0, doorright.contentSize.height/2);
  
  eyes = [CCSprite spriteWithFile:@"eyesbig.png"];
  [crest addChild:eyes ];
  eyes.opacity = EYES_START_ALPHA;
  eyes.position = ccp(crest.contentSize.width/2, crest.contentSize.height/2);
  
  [doorleft runAction:[CCEaseBounceOut actionWithAction:[CCSequence actions:
                                                         [CCMoveBy actionWithDuration:DOOR_CLOSE_DURATION position:ccp(doorleft.contentSize.width, 0)],
                                                         [CCCallFunc actionWithTarget:self selector:@selector(doorClosed)],
                                                         nil]]];
  [doorright runAction:[CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:DOOR_CLOSE_DURATION position:ccp(-doorright.contentSize.width, 0)]]];
  
  self.canLoad = NO;
  _isRunning = NO;
  
  leftBurn = [CCParticleSystemQuad particleWithFile:@"eyesburning.plist"];
  [eyes addChild:leftBurn z:1];
  leftBurn.position = ccp(56,70);
  leftBurn.startSize /= 2.5;
  leftBurn.endSize /= 2.5;
  
  rightBurn = [CCParticleSystemQuad particleWithFile:@"eyesburning.plist"];
  [eyes addChild:rightBurn z:1];
  rightBurn.position = ccp(93,70);
  rightBurn.startSize /= 2.5;
  rightBurn.endSize /= 2.5;
  
  [eyes runAction:[CCRepeatForever actionWithAction:
                   [CCSequence actions:
                    [CCFadeTo actionWithDuration:EYES_PULSATE_DURATION opacity:EYES_END_ALPHA],
                    [CCFadeTo actionWithDuration:EYES_PULSATE_DURATION opacity:EYES_START_ALPHA],
                    nil]]];
  
  CCParticleSystemQuad *around = [CCParticleSystemQuad particleWithFile:@"particlesaround.plist"];
  [doorright addChild:around];
  around.position = ccp(0, doorright.contentSize.height/2);
  
  _canOpenDoor = NO;
  CCMenuItem *touchLayer = [CCMenuItem itemWithBlock:^(id sender) {
    if (_canOpenDoor) {
      [self openDoor];
    }
  }];
  touchLayer.contentSize = doorright.parent.contentSize;
  
  CCMenu *menu = [CCMenu menuWithItems:touchLayer, nil];
  [doorright.parent addChild:menu];
  
}

- (void) allowOpeningOfDoor {
  if (!_isRunning) {
    [eyes stopAllActions];
    _canOpenDoor = YES;
    
    float dur = (EYES_END_ALPHA-EYES_START_ALPHA)*EYES_PULSATE_DURATION/(255-eyes.opacity);
    [eyes runAction:[CCFadeTo actionWithDuration:dur opacity:255]];
    
    leftBurn.startSize *= 4;
    leftBurn.endSize *= 4;
    leftBurn.speedVar *= 3;
    rightBurn.startSize *= 4;
    rightBurn.endSize *= 4;
    rightBurn.speedVar *= 3;
  }
}

- (void) doorClosed {
  [splash removeFromParentAndCleanup:YES];
  self.canLoad = YES;
}

- (void) openDoor {
  if ([[GameState sharedGameState] connected] && !_isRunning) {
    // Open door
    [[SimpleAudioEngine sharedEngine] playEffect:@"DoorOpening.m4a" pitch:1.f pan:0.f gain:1.f];
    
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
  } else {
    [[TopBar sharedTopBar] start];
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
}

- (void) preloadLayer {
  EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
  [EAGLContext setCurrentContext:k_context];
  
  CCLayer *layer = isTutorial ? [TutorialStartLayer node] : [GameLayer sharedGameLayer];
  layer.tag = 5;
  [[[CCDirector sharedDirector] runningScene] addChild:layer];
  
  if (isTutorial) {
    [self allowOpeningOfDoor];
  }
}

- (void) setIsTutorial:(BOOL)i {
  isTutorial = i;
  [[GameState sharedGameState] setIsTutorial:i];
  
  while (!self.canLoad) {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
  }
  
  if (isTutorial) {
    TopBar *tb = [TutorialTopBar sharedTopBar];
    tb.isTouchEnabled = NO;
    
    // Startup the tutorial home map
    [TutorialHomeMap sharedHomeMap];
  }
  
  [self performSelectorInBackground:@selector(preloadLayer) withObject:nil];
}

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  rect.size = CGSizeMake( rect.size.height, rect.size.width );
  GameView *v = [[GameView alloc] initWithFrame:rect];
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

