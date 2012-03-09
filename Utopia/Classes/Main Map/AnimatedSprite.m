//
//  AnimatedSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AnimatedSprite.h"
#import "MissionMap.h"

@implementation AnimatedSprite

@synthesize sprite = _sprite;
@synthesize walkAction = _walkAction;
@synthesize moveAction = _moveAction;

-(id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if((self = [super initWithFile:file location:loc map:map])) {
    
    // This loads an image of the same name (but ending in png), and goes through the
    // plist to add definitions of each frame to the cache.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lw.plist" textureFile:@"lw.png"];        
    
    // Create a sprite sheet with the Happy Bear images
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"lw.png"];
    [self addChild:spriteSheet];
    
    // Load up the frames of our animation
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for(int i = 0; i <= 3; ++i) {
      [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"lw-walk-nearleft_%02d.png", i]]];
    }
    CCAnimation *walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:0.04f];
    
    // Create a sprite for our bear
    self.sprite = [CCSprite spriteWithSpriteFrameName:@"lw-walk-nearleft_00.png"];
    self.sprite.anchorPoint = ccp(0.5, 0);
    self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
    [_sprite runAction:_walkAction];
    [spriteSheet addChild:_sprite];
    
    [self walk];
    
    self.isTouchEnabled = YES;
    
  }
  return self;
}

- (void) walk {
  MissionMap *missionMap = (MissionMap *)_map;
  CGPoint pt = [missionMap nextWalkablePositionFromPoint:self.location.origin];
  CGRect r = self.location;
  r.origin = pt;
  [self runAction:[CCSequence actions:                          
                     [MoveToLocation actionWithDuration:1 location:r],
                     [CCCallFunc actionWithTarget:self selector:@selector(walk)],
                     nil
                     ]];
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

@end

@implementation MoveToLocation

+(id) actionWithDuration: (ccTime) t location: (CGRect) p
{	
return [[[self alloc] initWithDuration:t location:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t location: (CGRect) p
{
	if( (self=[super initWithDuration: t]) )
		endLocation_ = p;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] location:endLocation_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startLocation_ = [(MapSprite*)target_ location];
	delta_ = ccpSub( endLocation_.origin, startLocation_.origin );
}

-(void) update: (ccTime) t
{	
  CGRect r = startLocation_;
  r.origin.x = (startLocation_.origin.x + delta_.x * t );
  r.origin.y = (startLocation_.origin.y + delta_.y * t );
	[target_ setLocation: r];
}

@end
