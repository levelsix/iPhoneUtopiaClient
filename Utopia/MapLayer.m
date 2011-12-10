//
//  HelloWorldLayer.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "MapLayer.h"
#import "Building.h"
#import "GameMap.h"

// HelloWorldLayer implementation
@implementation MapLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MapLayer *layer = [MapLayer node];
	
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
    
    GameMap *map = [GameMap tiledMapWithTMXFile:@"iso-test2.tmx"];
    [map reorderChild:[map layerNamed:@"MetaLayer"] z:0];
    [self addChild:map z:1 tag:1];
    
    // move map to the center of the screen
    CGSize ms = [map mapSize];
    CGSize ts = [map tileSize];
    map.position = ccp( -(ms.width-8) * ts.width/2, 0 );
//    [map runAction:[CCMoveTo actionWithDuration:1.0f position: ]];
    
    Building *acad = [HomeBuilding homeWithFile:@"acad.png" location:CGRectMake(1,1, 2,2) map:map];
    [map addChild:acad z:1];
    
    Building *acad2 = [HomeBuilding homeWithFile:@"acad.png" location:CGRectMake(5,1, 2,2) map:map];
    [map addChild:acad2 z:1];
    
    
  }
  return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

//
//-(void) slideAfterTouch: (ccTime) dt {
//  float accel = -5000;
//  _slideVelocity += accel*dt;
//  
//  if (_slideVelocity < 0) {
//    [self unschedule:@selector(slideAfterTouch:)];
//  }
//  
//  CCNode *map = [self getChildByTag:1];
//  float amountToMove = _slideVelocity * dt;
//  CGPoint diff = ccp(amountToMove*cos(_slideDirection), amountToMove*sin(_slideDirection));
//  
//	[map setPosition: ccpAdd(map.position, diff)];
//}
//
//-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//  [self unschedule:@selector(slideAfterTouch:)];
//}
//
//-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//  UITouch *touch = [touches anyObject];
//	CGPoint touchLocation = [touch locationInView: [touch view]];	
//	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
//	
//	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
//	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
//  float time = [touch timestamp] - _prevTouchTime;
//  
//  float dist = ccpDistance(touchLocation, prevLocation);
//  _slideDirection = ccpToAngle(ccpSub(touchLocation, prevLocation));
//  _slideVelocity = dist/time;
//  
//  [self schedule:@selector(slideAfterTouch:)];
//}
//
//-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
//{
//}
//
//-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//  UITouch *touch = [touches anyObject];
//	CGPoint touchLocation = [touch locationInView: [touch view]];	
//	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
//	
//	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
//	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
//	
//	CGPoint diff = ccpSub(touchLocation,prevLocation);
//	
//	CCNode *node = [self getChildByTag:1];
//	CGPoint currentPos = [node position];
//	[node setPosition: ccpAdd(currentPos, diff)];
//  
//  _prevTouchTime = [touch timestamp];
//}
@end
