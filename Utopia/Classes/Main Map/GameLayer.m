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
#import "SynthesizeSingleton.h"
#import "MissionMap.h"
#import "OutgoingEventController.h"
#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"
#import "CDXPropertyModifierAction.h"
#import "TutorialMissionMap.h"
#import "MapViewController.h"

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
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(0, 140, 140, 255) fadingTo:ccc4(0, 0, 0, 255)])) {
    [self begin];
  }
  return self;  
}

- (void) begin {
  // Used by tutorial too
  _homeMap = [HomeMap sharedHomeMap];
  [self addChild:_homeMap z:1 tag:2];
  [_homeMap moveToCenter];
  
  _bazaarMap = [BazaarMap sharedBazaarMap];
  
  _topBar = [TopBar sharedTopBar];
  [self addChild:_topBar z:2];
  
  assetId = 0;
}

- (void) setEnemyType:(UserType)type {
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
  
  [self closeBazaarMap];
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
  
  if (_homeMap.visible) {
    _homeMap.selected = nil;
    _homeMap.visible = NO;
  }
  
  if (_curMusic != kMissionMusic) {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Mission_Enemy_song.m4a"];
    _curMusic = kMissionMusic;
  }
  
  [[MapViewController sharedMapViewController] performSelectorOnMainThread:@selector(fadeOut) withObject:nil waitUntilDone:YES];
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
  _missionMap = map;
  
  [_missionMap moveToCenter];
  
  [self addChild:_missionMap z:1];
  [map doBlink];
  
  [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Mission_Enemy_song.m4a"];
  _curMusic = kMissionMusic;
  
  if (_homeMap.visible) {
    _homeMap.selected = nil;
    _homeMap.visible = NO;
  }
}

- (void) loadHomeMap {
  [self unloadCurrentMissionMap];
  [_homeMap refresh];
  [_homeMap beginTimers];
  _homeMap.visible = YES;
  [_homeMap moveToCenter];
  currentCity = 0;
  [self closeBazaarMap];
  
  if (_curMusic != kHomeMusic) {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Game_Music.m4a"];
    _curMusic = kHomeMusic;
  }
}

- (GameMap *) currentMap {
  if (currentCity == 0) {
    return _homeMap;
  } else {
    return _missionMap;
  }
}

- (void) displayBazaarMap {
  if (!_bazaarMap.parent) {
    [[self currentMap] setVisible:NO];
    [self addChild:_bazaarMap z:1];
    [_bazaarMap moveToCenter];
  }
}

- (void) closeBazaarMap {
  if (_bazaarMap.parent) {
    [self removeChild:_bazaarMap cleanup:YES];
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
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Game_Music.m4a"];
    _curMusic = kHomeMusic;
  } else {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Mission_Enemy_song.m4a"];
    _curMusic = kMissionMusic;
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
