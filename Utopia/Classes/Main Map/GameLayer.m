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
#import "ImageDownloader.h"
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

@synthesize assetId, currentCity;
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
	if( (self=[super init])) {
    _homeMap = [HomeMap sharedHomeMap];
    [self addChild:_homeMap z:1 tag:2];
    [self loadHomeMap];
    
    _topBar = [TopBar sharedTopBar];
    [self addChild:_topBar z:2];
    
    assetId = 0;
  }
  return self;  
}

- (void) moveMapToCenter:(GameMap *)map {
  // move map to the center of the screen
  CGSize ms = [map mapSize];
  CGSize ts = [map tileSizeInPoints];
  map.position = ccp((-(ms.width-8)*ts.width/2)*map.scale,(-(ms.height-8)*ts.height/2)*map.scale);
}

- (void) moveMap:(GameMap *)map toSprite:(CCSprite *)spr {
  CGPoint pt = spr.position;
  CGSize size = [[CCDirector sharedDirector] winSize];
  map.position = ccp((-pt.x+size.width/2), ((-pt.y-spr.contentSize.height/2)+size.height/2));
}

- (void) moveMissionMapToAssetId:(int)a {
  assetId = a;
  CCSprite *spr = [_missionMap assetWithId:assetId];
  if (spr) {
    [self moveMap:_missionMap toSprite:spr];
  } else {
    [self moveMapToCenter:_missionMap];
  }
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
  
  if (assetId == 0) {
    [self moveMapToCenter:_missionMap];
  } else {
    [self moveMissionMapToAssetId:assetId];
  }
  
  [self addChild:_missionMap z:1];
  currentCity = proto.cityId;
  
  if (_homeMap.visible) {
    _homeMap.selected = nil;
    _homeMap.visible = NO;
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
  
  [self moveMapToCenter:_missionMap];
  
  [self addChild:_missionMap z:1];
  [map doBlink];
  
  if (_homeMap.visible) {
    _homeMap.selected = nil;
    _homeMap.visible = NO;
  }
}

- (void) loadHomeMap {
  [self unloadCurrentMissionMap];
  _homeMap.visible = YES;
  [self moveMapToCenter:_homeMap];
  currentCity = 0;
  
}

- (GameMap *) currentMap {
  if (_homeMap.visible) {
    return _homeMap;
  } else {
    return _missionMap;
  }
}

- (void) onEnter {
  [super onEnter];
  if (_homeMap.visible) {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Game_Music.m4a"];
  } else {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Mission_Enemy_song.m4a"];
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
