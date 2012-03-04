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
#import "ComboBar.h"
#import "ImageDownloader.h"
#import "GameState.h"
#import "Globals.h"
#import "QuestLogController.h"
#import "TopBar.h"
#import "SynthesizeSingleton.h"
#import "MissionMap.h"

// HelloWorldLayer implementation
@implementation GameLayer

SYNTHESIZE_SINGLETON_FOR_CLASS(GameLayer);

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
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
    
    CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(64,64,64,255)];
    [self addChild:color z:-1];
    
    _homeMap = [HomeMap sharedHomeMap];
    [self addChild:_homeMap z:1 tag:2];
    [self loadHomeMap];
    
    _topBar = [TopBar node];
    [self addChild:_topBar z:2];
    
//    BattleLayer *al = [BattleLayer node];
//    [self addChild:al z:3];
//    [al doAttackAnimation];
    
//    ComboBar *bar = [ComboBar bar];
//    bar.position = ccp(240,160);
//    [self addChild:bar z: 5];
//    [bar doComboSequence];
  }
  return self;  
}

- (void) moveMapToCenter:(GameMap *)map {
  // move map to the center of the screen
  CGSize ms = [map mapSize];
  CGSize ts = [map tileSizeInPoints];
  map.position = ccp( -(ms.width-8) * ts.width/2, 0 );
}

- (void) unloadCurrentMissionMap {
  if (_missionMap) {
    [self removeChild:_missionMap cleanup:YES];
    [_missionMap release];
    _missionMap = nil;
  }
}

- (void) loadMissionMapWithProto:(LoadNeutralCityResponseProto *)proto {
  [self unloadCurrentMissionMap];
  _missionMap = [[MissionMap alloc] initWithProto:proto];
  [self addChild:_missionMap z:1];
  _homeMap.visible = NO;
  [self moveMapToCenter:_missionMap];
}

- (void) loadHomeMap {
  [self unloadCurrentMissionMap];
  _homeMap.visible = YES;
  [self moveMapToCenter:_homeMap];
}

@end
