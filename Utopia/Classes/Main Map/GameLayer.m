//
//  HelloWorldLayer.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
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

// HelloWorldLayer implementation
@implementation GameLayer

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
    
    _map = [HomeMap sharedHomeMap];
    [self addChild:_map z:1 tag:2];
    
    // move map to the center of the screen
    CGSize ms = [_map mapSize];
    CGSize ts = [_map tileSizeInPoints];
    _map.position = ccp( -(ms.width-8) * ts.width/2, 0 );
    
    _topBar = [TopBar node];
    [self addChild:_topBar z:2];
    
//    [self schedule:@selector(update)];
    
//    BattleLayer *al = [BattleLayer node];
//    [self addChild:al z:3];
//    [al doAttackAnimation];
    
//    DiamondShopViewController *svc = [[DiamondShopViewController alloc] initWithNibName:nil bundle:nil];
//    [[[CCDirector sharedDirector] openGLView]addSubview: svc.view];
//    svc.view.center = [[CCDirector sharedDirector] openGLView].center;
    
//    ComboBar *bar = [ComboBar bar];
//    bar.position = ccp(240,160);
//    [self addChild:bar z: 5];
//    [bar doComboSequence];
  }
  return self;  
}

@end
