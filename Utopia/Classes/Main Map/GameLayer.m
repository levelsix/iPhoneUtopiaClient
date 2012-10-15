//
//  HelloWorldLayer.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright LVL6 2011. All rights reserved.
//

// Import the interfaces
#import "GameLayer.h"
#import "Building.h"
#import "GameMap.h"
#import "HomeMap.h"
#import "BattleLayer.h"
#import "MaskedSprite.h"
#import "ProfilePicture.h"
#import "GoldShoppeViewController.h"
#import "AnimatedSprite.h"
#import "Downloader.h"
#import "GameState.h"
#import "Globals.h"
#import "QuestLogController.h"
#import "TopBar.h"
#import "LNSynthesizeSingleton.h"
#import "MissionMap.h"
#import "OutgoingEventController.h"
#import "SoundEngine.h"
#import "TutorialMissionMap.h"
#import "CarpenterMenuController.h"
#import "MapViewController.h"

@implementation TravelingLoadingView

@synthesize label;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) displayWithText:(NSString *)text {
  [super display:[[[CCDirector sharedDirector] openGLView] superview]];
  self.label.text = text;
}

- (void) dealloc {
  self.label = nil;
  [super dealloc];
}

@end

@implementation WelcomeView

@synthesize nameLabel, rankLabel, middleLine;

- (void) awakeFromNib {
  self.alpha = 0.f;
}

- (void) displayForName:(NSString *)name rank:(int)rank {
  nameLabel.text = name;
  rankLabel.text = rank > 0 ? [NSString stringWithFormat:@"Rank %d", rank] : @"";
  
  self.alpha = 0.f;
  [UIView animateWithDuration:1.2f delay:0.5f options:UIViewAnimationOptionTransitionNone animations:^{
    self.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1.2f delay:1.f options:UIViewAnimationOptionTransitionNone animations:^{
      self.alpha = 0.f;
    } completion:nil];
  }];
}

- (void) dealloc {
  self.nameLabel = nil;
  self.rankLabel = nil;
  self.middleLine = nil;
  [super dealloc];
}

@end

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize assetId, enemyType, currentCity;
@synthesize missionMap = _missionMap;
@synthesize welcomeView, loadingView;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameLayer);

+(CCScene *) scene
{
  // 'scene' is an autorelease object.
  CCScene *scene = [CCScene node];
  
  // 'layer' is an autorelease object.
  GameLayer *layer = [GameLayer sharedGameLayer];
  
  // add layer as a child to scene
  [scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super initWithColor:ccc4(75, 78, 29, 255)])) {
    [[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self options:nil];
    [[[[CCDirector sharedDirector] openGLView] superview] insertSubview:self.welcomeView atIndex:1];
    
    [self begin];
  }
  return self;
}

- (TravelingLoadingView *)loadingView {
  if (!loadingView) {
    [[NSBundle mainBundle] loadNibNamed:@"TravelingLoadingView" owner:self options:nil];
  }
  return loadingView;
}

- (void) begin {
  if (![[GameState sharedGameState] isTutorial]) {
    [self checkHomeMapExists];
    
    _topBar = [TopBar sharedTopBar];
    [self addChild:_topBar z:2];
    
    [self displayHomeMap];
  } else {
    _topBar = [TopBar sharedTopBar];
    [self addChild:_topBar z:2];
  }
}

- (void) setEnemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type {
  enemyType = type;
  _shouldCenterOnEnemy = YES;
}

- (void) unloadCurrentMissionMap {
  if (_missionMap) {
    _missionMap.selected = nil;
    [self removeChild:_missionMap cleanup:YES];
    self.missionMap = nil;
  }
}

- (void) loadMissionMapWithProto:(LoadNeutralCityResponseProto *)proto {
  // Need this to be able to run on background thread
  //  EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
  //  [EAGLContext setCurrentContext:k_context];
  
  MissionMap *m = [[MissionMap alloc] initWithProto:proto];
  GameState *gs = [GameState sharedGameState];
  FullCityProto *fcp = [gs cityWithId:proto.cityId];
  UserCity *uc = [gs myCityWithId:proto.cityId];
  
  [self unloadCurrentMissionMap];
  [self closeHomeMap];
  [self closeBazaarMap];
  
  [m moveToCenter];
  if (_shouldCenterOnEnemy) {
    [m moveToEnemyType:enemyType];
    _shouldCenterOnEnemy = NO;
  } else if (assetId != 0) {
    [m moveToAssetId:assetId];
    self.assetId = 0;
  }
  
  [self addChild:m z:1];
  currentCity = proto.cityId;
  
  [_topBar loadNormalConfiguration];
  
  _missionMap = m;
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playMissionMapMusic];
  }
  
  [self.loadingView stop];
  if ([MapViewController isInitialized]) {
    [[MapViewController sharedMapViewController] close];
  }
  
  [welcomeView displayForName:fcp.name rank:uc.curRank];
}

- (void) unloadTutorialMissionMap {
  [[TutorialMissionMap sharedTutorialMissionMap] removeFromParentAndCleanup:YES];
  [TutorialMissionMap purgeSingleton];
  _missionMap = nil;
}

- (void) loadTutorialMissionMap {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  // Need this to be able to run on background thread
  EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
  [EAGLContext setCurrentContext:k_context];
  
  [self unloadCurrentMissionMap];
  CCLayer *layer = [CCLayer node];
  [self.parent addChild:layer z:1000];
  
  TutorialMissionMap *map = [TutorialMissionMap sharedTutorialMissionMap];
  currentCity = 1;
  _missionMap = map;
  
  [_missionMap moveToCenter];
  [_topBar loadNormalConfiguration];
  
  [self addChild:_missionMap z:1];
  [map allowBlink];
  
  [self closeHomeMap];
  [layer removeFromParentAndCleanup:YES];
  
  [pool release];
}

- (void) checkHomeMapExists {
  if (!_homeMap) {
    _homeMap = [HomeMap sharedHomeMap];
    [self addChild:_homeMap z:1 tag:2];
    [_homeMap moveToCenter];
    _homeMap.visible = NO;
  }
}

- (void) loadHomeMap {
  if (!_homeMap.visible) {
    [self.loadingView displayWithText:@"Traveling\nHome"];
    _loading = YES;
    // Do move in load so that other classes can move it elsewhere
    [_homeMap moveToCenter];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(displayHomeMap)], nil]];
  }
  
  [self checkHomeMapExists];
}

- (void) displayHomeMap {
  [self checkHomeMapExists];
  
  [self unloadCurrentMissionMap];
  [_homeMap refresh];
  
  if (_topBar.isStarted) {
    [_homeMap beginTimers];
  }
  
  currentCity = 0;
  [self closeBazaarMap];
  [_topBar loadHomeConfiguration];
  [_homeMap reloadQuestGivers];
  _homeMap.visible = YES;
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playHomeMapMusic];
  }
  
  if (_loading) {
    [self.loadingView stop];
    _loading = NO;
  }
  
  [welcomeView displayForName:@"My City" rank:0];
}

- (void) closeHomeMap {
  if (_homeMap) {
    _homeMap.selected = nil;
    
    [_homeMap removeFromParentAndCleanup:YES];
    [_homeMap invalidateAllTimers];
    [HomeMap purgeSingleton];
    _homeMap = nil;
    
    [CarpenterMenuController removeView];
  }
}

- (GameMap *) currentMap {
  if (currentCity == 0) {
    if (_bazaarMap.parent) {
      return _bazaarMap;
    } else {
      return _homeMap;
    }
  } else {
    return _missionMap;
  }
}

- (void) checkBazaarMapExists {
  if (!_bazaarMap) {
    _bazaarMap = [BazaarMap sharedBazaarMap];
    [_bazaarMap moveToCenter];
  }
}

- (void) loadBazaarMap {
  if (!_bazaarMap.parent) {
    [self.loadingView displayWithText:@"Traveling\nTo Bazaar"];
    _loading = YES;
    // Do move in load so that other classes can move it elsewhere
    [_bazaarMap moveToCenter];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(displayBazaarMap)], nil]];
  }
  
  [self checkBazaarMapExists];
}

- (void) displayBazaarMap {
  if (!_bazaarMap.parent) {
    [self checkBazaarMapExists];
    [self unloadCurrentMissionMap];
    [self closeHomeMap];
    
    currentCity = 0;
    
    [self addChild:_bazaarMap z:1];
    [_topBar loadBazaarConfiguration];
    
    [_bazaarMap reloadAllies];
    [_bazaarMap reloadQuestGivers];
  }
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playBazaarMusic];
  }
  
  if (_loading) {
    [self.loadingView stop];
    _loading = NO;
  }
  
  [welcomeView displayForName:@"Bazaar" rank:0];
}

- (void) closeBazaarMap {
  if (_bazaarMap.parent) {
    [self removeChild:_bazaarMap cleanup:YES];
    
    [BazaarMap purgeSingleton];
    _bazaarMap = nil;
  }
}

- (void) toggleBazaarMap {
  if (_bazaarMap.parent) {
    [self closeBazaarMap];
  } else {
    [self displayBazaarMap];
  }
}

- (void) startHomeMapTimersIfOkay {
  if (currentCity == 0) {
    [_homeMap beginTimers];
  }
}

- (void) onEnter {
  [super onEnter];
  if (currentCity == 0) {
    if (_bazaarMap.parent) {
      [[SoundEngine sharedSoundEngine] playBazaarMusic];
    } else {
      [[SoundEngine sharedSoundEngine] playHomeMapMusic];
    }
  } else {
    [[SoundEngine sharedSoundEngine] playMissionMapMusic];
  }
}

- (void) closeMenus {
  _missionMap.selected = nil;
  _homeMap.selected = nil;
}

- (void) dealloc {
  self.missionMap = nil;
  self.welcomeView = nil;
  self.loadingView = nil;
  [super dealloc];
}

@end
