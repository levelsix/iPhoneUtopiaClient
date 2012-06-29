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
    
    _bazaarMap = [BazaarMap sharedBazaarMap];
    
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
  EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
  [EAGLContext setCurrentContext:k_context];
  
  [self unloadCurrentMissionMap];
  _missionMap = [[MissionMap alloc] initWithProto:proto];
  
  [_missionMap moveToCenter];
  if (_shouldCenterOnEnemy) {
    [_missionMap moveToEnemyType:enemyType];
    _shouldCenterOnEnemy = NO;
  } else if (assetId != 0) {
    [_missionMap moveToAssetId:assetId];
    self.assetId = 0;
  }
  
  [self addChild:_missionMap z:1];
  currentCity = proto.cityId;
  
  [_topBar loadNormalConfiguration];
    
  [self closeHomeMap];
  [self closeBazaarMap];
  
  [[SoundEngine sharedSoundEngine] playMissionMapMusic];
  
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
  TutorialMissionMap *map = [TutorialMissionMap sharedTutorialMissionMap];
  currentCity = 1;
  _missionMap = map;
  
  [_missionMap moveToCenter];
  [_topBar loadNormalConfiguration];
  
  [self addChild:_missionMap z:1];
  [map allowBlink];
  
  [self closeHomeMap];
}

- (void) loadHomeMap {
  if (!_homeMap.visible) {
    [[MapViewController sharedMapViewController] startLoadingWithText:@"Traveling Home"];
    _loading = YES;
    [_homeMap moveToCenter];
    [self performSelector:@selector(displayHomeMap) withObject:nil afterDelay:0.5f];
  }
}

- (void) displayHomeMap {
  if (!_homeMap) {
    _homeMap = [HomeMap sharedHomeMap];
    [self addChild:_homeMap];
  }
  
  [self unloadCurrentMissionMap];
  [_homeMap refresh];
  [_homeMap beginTimers];
  _homeMap.visible = YES;
  currentCity = 0;
  [self closeBazaarMap];
  [_topBar loadHomeConfiguration];
  [_homeMap reloadQuestGivers];
  
  [[SoundEngine sharedSoundEngine] playHomeMapMusic];
  
  if (_loading) {
    [[MapViewController sharedMapViewController] close];
    _loading = NO;
  }
}

- (void) closeHomeMap {
  if (_homeMap.visible) {
    _homeMap.selected = nil;
    _homeMap.visible = NO;
    
    [[CarpenterMenuController sharedCarpenterMenuController] closeClicked:nil];
  }
}

- (GameMap *) currentMap {
  if (currentCity == 0) {
    return _homeMap;
  } else {
    return _missionMap;
  }
}

- (void) loadBazaarMap {
  if (!_bazaarMap.parent) {
    [[MapViewController sharedMapViewController] startLoadingWithText:@"Traveling to Bazaar"];
    _loading = YES;
    // Do move in load so that other classes can move it elsewhere
    [_bazaarMap moveToCenter];
    [self performSelector:@selector(displayBazaarMap) withObject:nil afterDelay:0.5f];
  }
}

- (void) displayBazaarMap {
  if (!_bazaarMap.parent) {
    [_homeMap setSelected:nil];
    [self unloadCurrentMissionMap];
    currentCity = 0;
    _homeMap.visible = NO;
    [self addChild:_bazaarMap z:1];
    [_topBar loadBazaarConfiguration];
    
    [_bazaarMap reloadAllies];
    [_bazaarMap reloadQuestGivers];
  }
  
  [[SoundEngine sharedSoundEngine] playBazaarMusic];
  
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
    [[SoundEngine sharedSoundEngine] playHomeMapMusic];
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
