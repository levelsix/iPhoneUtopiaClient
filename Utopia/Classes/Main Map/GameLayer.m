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
#import "BattleLayer.h"
#import "MaskedSprite.h"
#import "ProfilePicture.h"
#import "DiamondShopViewController.h"
#import "AnimatedSprite.h"
#import "ComboBar.h"
#import "ImageDownloader.h"
#import "GameState.h"
#import "QuestLogController.h"

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
    
    _map = [GameMap tiledMapWithTMXFile:@"iso-test2.tmx"];
    [self addChild:_map z:1 tag:2];
    
    // move map to the center of the screen
    CGSize ms = [_map mapSize];
    CGSize ts = [_map tileSize];
    _map.position = ccp( -(ms.width-8) * ts.width/2, 0 );
    
    [HomeBuilding homeWithFile:@"acad.png" location:CGRectMake(1,1, 2,2) map:_map];
    ((HomeBuilding *)[HomeBuilding homeWithFile:@"acad.png" location:CGRectMake(5,1, 1,1) map:_map]).scale = 0.5;
    ((HomeBuilding *)[HomeBuilding homeWithFile:@"acad.png" location:CGRectMake(10,1, 1,1) map:_map]).scale = 0.5;
    ((HomeBuilding *)[HomeBuilding homeWithFile:@"acad.png" location:CGRectMake(17, 1, 6,6) map:_map]).scale = 3;
    
    _enstBgd = [CCSprite spriteWithFile:@"enstbg.png"];
    [self addChild:_enstBgd z:2];
    _enstBgd.position = ccp(190, self.contentSize.height+_enstBgd.contentSize.height/2);
    _enstBgd.visible = YES;
    
    // Make the progress bars and place them on top of the background image
    CCSprite *staminaBar = [CCSprite spriteWithFile:@"stambar.png"];
    CCSprite *topBarMask = [CCSprite spriteWithFile:@"barmask.png"];
    // For some reason, the name energybar.png DOES NOT WORK!! why??
    CCSprite *energyBar = [CCSprite spriteWithFile:@"engybar.png"];
    _energyBar = [[MaskedBar maskedBarWithFile:energyBar andMask:topBarMask] retain];
    _staminaBar = [[MaskedBar maskedBarWithFile:staminaBar andMask:topBarMask] retain];
    _energyBar.percentage = 0;
    _staminaBar.percentage = 0;
    
    // Just add the sprites so it doesnt complain when we try to remove to update
    // Must set them to invisible or they end up showing up for a split second in the wrong position
    CCSprite *e = [_energyBar updateSprite];
    e.visible = NO;
    [_enstBgd addChild:e z:1 tag:1];
    CCSprite *s = [_staminaBar updateSprite];
    s.visible = NO;
    [_enstBgd addChild:s z:1 tag:2];
    
    _coinBar = [CCSprite spriteWithFile:@"coinbar.png"];
    [self addChild:_coinBar z:2];
    _coinBar.position = ccp(370, self.contentSize.height+_coinBar.contentSize.height/2);
    
    NSString *fontName = [GameState font];
    _coinLabel = [CCLabelTTF labelWithString:@"2,000,000" fontName:fontName fontSize:12];
    [_coinBar addChild:_coinLabel];
    _coinLabel.color = ccc3(212,210,199);
    _coinLabel.position = ccp(55, 15);
    
    _diamondLabel = [CCLabelTTF labelWithString:@"30" fontName:fontName fontSize:12];
    [_coinBar addChild:_diamondLabel];
    _diamondLabel.color = ccc3(212,210,199);
    _diamondLabel.position = ccp(125, 15);
    
    _diamondButton = [CCSprite spriteWithFile:@"plus.png"];
    [_coinBar addChild:_diamondButton z:-1];
    _diamondButton.position = ccp(100, _diamondButton.contentSize.height/2);
    [_diamondButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:ccp(155, _diamondButton.contentSize.height/2+2)]], nil]];
    
    // Drop the bars down
    [_enstBgd runAction:[CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_enstBgd.contentSize.height)]]];
    [_coinBar runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2], [CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_coinBar.contentSize.height)]], nil]];
    
    _profileBgd = [ProfilePicture profileWithType:UserTypeBadMage];
    [self addChild:_profileBgd z:2];
    _profileBgd.position = ccp(45, self.contentSize.height-45);
    
    [self schedule:@selector(update)];
    
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

- (void) update {
  // Remove the initial renderings
  [_enstBgd removeChildByTag:1 cleanup:YES];
  [_enstBgd removeChildByTag:2 cleanup:YES];
  
  // Wish we didn't have to hardcode where the bar was :/
  float x = (int)(_energyBar.percentage+1) %101;
  _energyBar.percentage = x;
  CCSprite *e = [_energyBar updateSprite];
  [_enstBgd addChild:e z:1 tag:1];
  e.position = ccp(53,15);
  
  x = (int)(_staminaBar.percentage+1) %101;
  _staminaBar.percentage = x;
  CCSprite *s = [_staminaBar updateSprite];
  [_enstBgd addChild:s z:1 tag:2];
  s.position = ccp(149,15);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
  [_energyBar release];
	[super dealloc];
}
@end
