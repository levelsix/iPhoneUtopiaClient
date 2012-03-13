//
//  AnimatedSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AnimatedSprite.h"
#import "MissionMap.h"
#import "QuestLogController.h"
#import "OutgoingEventController.h"

@implementation AnimatedSprite

@synthesize sprite = _sprite;
@synthesize walkAction = _walkAction;

-(id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if((self = [super initWithFile:file location:loc map:map])) {
    
    // This loads an image of the same name (but ending in png), and goes through the
    // plist to add definitions of each frame to the cache.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"legionwarrior.plist"];        
    
    // Create a sprite sheet with the Happy Bear images
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"legionwarrior.png"];
    [self addChild:spriteSheet];
    
    // Load up the frames of our animation
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for(int i = 0; i <= 8; ++i) {
      [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"skeletonking-walking-nearleft_%02d.png", i]]];
    }
    CCAnimation *walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:0.05f];
    
    // Create a sprite for our bear
    self.sprite = [CCSprite spriteWithSpriteFrameName:@"skeletonking-walking-nearleft_00.png"];
    _sprite.anchorPoint = ccp(-0.3, -0.3);
    
    // Move sprite a bit up
    self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
    _sprite.scale = 0.5;
    [_sprite runAction:_walkAction];
    [spriteSheet addChild:_sprite];
    
    // So that it registers touches
    self.contentSize = self.sprite.contentSize;
    _glow.position = ccp(self.contentSize.width/2, 0);
    
    _oldMapPos = loc.origin;
    
    [self walk];
  }
  return self;
}

- (void) setOpacity:(GLubyte)opacity {
  [super setOpacity:opacity];
  _sprite.opacity = opacity;
}

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  
  if (isSelected) {
    [self stopAllActions];
    [self.sprite stopAllActions];
  } else {
    [self.sprite runAction:self.walkAction];
    [self walk];
  }
}

- (void) walk {
  MissionMap *missionMap = (MissionMap *)_map;
  CGPoint pt = [missionMap nextWalkablePositionFromPoint:self.location.origin prevPoint:_oldMapPos];
  _oldMapPos = self.location.origin;
  CGRect r = self.location;
  r.origin = pt;
  float diff = ccpDistance(_oldMapPos, pt);
  [self runAction:[CCSequence actions:                          
                     [MoveToLocation actionWithDuration:2*diff location:r],
                     [CCCallFunc actionWithTarget:self selector:@selector(walk)],
                     nil
                     ]];
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

@end

@implementation QuestGiver

@synthesize quest, isInProgress;

- (id) initWithQuest:(FullQuestProto *)fqp inProgress:(BOOL)inProg map:(GameMap *)map location:(CGRect)location {
  if ((self = [super initWithFile:nil location:location map:map])) {
    self.quest = fqp;
    self.isInProgress = inProg;
  }
  return self;
}

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  
  if (isSelected) {
    if (self.isInProgress) {
      [[OutgoingEventController sharedOutgoingEventController] retrieveQuestDetails:quest.questId];
    }
    [[QuestLogController sharedQuestLogController] displayRightPageForQuest:quest inProgress:isInProgress];
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
  } else {
    [[[QuestLogController sharedQuestLogController] rightPage] removeFromSuperview];
  }
}

- (void) setOpacity:(GLubyte)opacity {
  [super setOpacity:opacity];
  _aboveHeadMark.opacity = opacity;
}

- (void) setIsInProgress:(BOOL)i {
  isInProgress = i;
  
  [self removeChild:_aboveHeadMark cleanup:YES];
  _aboveHeadMark = nil;
  if (isInProgress) {
    _aboveHeadMark = [CCSprite spriteWithFile:@"question.png"];
  } else {
    _aboveHeadMark = [CCSprite spriteWithFile:@"exclamation.png"];
  }
  [self addChild:_aboveHeadMark];
  _aboveHeadMark.position = ccp(self.sprite.contentSize.width/2, _sprite.contentSize.height*_sprite.scale+_aboveHeadMark.contentSize.height/2+10);
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
