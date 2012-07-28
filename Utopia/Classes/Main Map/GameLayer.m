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
#import "MapViewController.h"
#import "CarpenterMenuController.h"

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize assetId, enemyType, currentCity;
@synthesize missionMap = _missionMap;

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
	if( (self=[super initWithColor:ccc4(0, 140, 140, 255) fadingTo:ccc4(0, 0, 0, 255)])) {
    [self begin];
  }
  return self;
}

- (void) begin {
  if (![[GameState sharedGameState] isTutorial]) {
    _homeMap = [HomeMap sharedHomeMap];
    [self addChild:_homeMap z:1 tag:2];
    [_homeMap moveToCenter];
    
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
  
  [self unloadCurrentMissionMap];
  [self closeHomeMap];
  [self closeBazaarMap];
  
  _missionMap = m;
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playMissionMapMusic];
  }
  
  [[MapViewController sharedMapViewController] performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:YES];
}

- (void) unloadTutorialMissionMap {
  [[TutorialMissionMap sharedTutorialMissionMap] removeFromParentAndCleanup:YES];
  [TutorialMissionMap purgeSingleton];
  _missionMap = nil;
}

- (void) loadTutorialMissionMap {
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
}

- (void) loadHomeMap {
  if (!_homeMap.visible) {
    [[MapViewController sharedMapViewController] startLoadingWithText:@"Traveling\nHome"];
    _loading = YES;
    [_homeMap moveToCenter];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(displayHomeMap)], nil]];
  }
}

- (void) displayHomeMap {
  if (!_homeMap) {
    _homeMap = [HomeMap sharedHomeMap];
    [self addChild:_homeMap];
  }
  
  [self unloadCurrentMissionMap];
  [_homeMap refresh];
  
  if (_topBar.isStarted) {
    [_homeMap beginTimers];
  }
  
  _homeMap.visible = YES;
  currentCity = 0;
  [self closeBazaarMap];
  [_topBar loadHomeConfiguration];
  [_homeMap reloadQuestGivers];
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playHomeMapMusic];
  }
  
  if (_loading) {
    [[MapViewController sharedMapViewController] close];
    _loading = NO;
  }
}

- (void) closeHomeMap {
  if (_homeMap.visible) {
    _homeMap.selected = nil;
    _homeMap.visible = NO;
    
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
  }
}

- (void) loadBazaarMap {
  if (!_bazaarMap.parent) {
    [[MapViewController sharedMapViewController] startLoadingWithText:@"Traveling to Bazaar"];
    _loading = YES;
    // Do move in load so that other classes can move it elsewhere
    [self checkBazaarMapExists];
    [_bazaarMap moveToCenter];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(displayBazaarMap)], nil]];
  }
}

- (void) displayBazaarMap {
  if (!_bazaarMap.parent) {
    [self checkBazaarMapExists];
    [_homeMap setSelected:nil];
    [self unloadCurrentMissionMap];
    
    currentCity = 0;
    _homeMap.visible = NO;
    [_homeMap invalidateAllTimers];
    
    [self addChild:_bazaarMap z:1];
    [_topBar loadBazaarConfiguration];
    
    [_bazaarMap reloadAllies];
    [_bazaarMap reloadQuestGivers];
  }
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playBazaarMusic];
  }
  
  if (_loading) {
    [[MapViewController sharedMapViewController] close];
    _loading = NO;
  }
}

- (void) closeBazaarMap {
  if (_bazaarMap.parent) {
    [self removeChild:_bazaarMap cleanup:NO];
    [[self currentMap] setVisible:YES];
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
  [super dealloc];
}

@end
