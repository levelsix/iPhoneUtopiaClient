//
//  AnimatedSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AnimatedSprite.h"
#import "MissionMap.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "ConvoMenuController.h"
#import "QuestLogController.h"
#import "GameState.h"
#import "CarpenterMenuController.h"

#define ABOVE_HEAD_FADE_DURATION 1.5f
#define ABOVE_HEAD_FADE_OPACITY 100

#define VERTICAL_OFFSET 10.f

@implementation CharacterSprite

@synthesize nameLabel = _nameLabel;

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _nameLabel = [[CCLabelTTF alloc] initWithString:@"" fontName:[Globals font] fontSize:[Globals fontSize]];
    [self addChild:_nameLabel];
    _nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    _nameLabel.color = ccc3(255,200,0);
    
    self.flipX = arc4random() % 2;
  }
  return self;
}

- (void) displayArrow {
  [super displayArrow];
  _arrow.position = ccpAdd(_arrow.position, ccp(0, 10.f));
}

- (void) setOpacity:(GLubyte)opacity {
  [super setOpacity:opacity];
  _nameLabel.opacity = opacity;
}

- (void) setLocation:(CGRect)location {
  [super setLocation:location];
  self.position = ccpAdd(self.position, ccp(0, VERTICAL_OFFSET));
}

- (void) dealloc {
  self.nameLabel = nil;
  [super dealloc];
}

@end

@implementation AnimatedSprite

@synthesize sprite = _sprite;
@synthesize walkAction = _walkAction;
@synthesize walkActionFL = _walkActionFL;
@synthesize walkActionFR = _walkActionFR;
@synthesize walkActionNL = _walkActionNL;
@synthesize walkActionNR = _walkActionNR;

-(id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if((self = [super initWithFile:file location:loc map:map])) {
    
    // This loads an image of the same name (but ending in png), and goes through the
    // plist to add definitions of each frame to the cache.
    
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DrowAnimations.plist"]; 
    
    // Create a sprite sheet with the Happy Bear images
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"DrowAnimations.png"];
    [self addChild:spriteSheet];
    
    //Creating animation for Near Left
    NSMutableArray *walkAnimNL= [NSMutableArray array];
    for(int i = 0; i <= 7; ++i) {
      [walkAnimNL addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkNL%d.png", i]]];
    }
    CCAnimation *walkAnimationNL = [CCAnimation animationWithFrames:walkAnimNL delay:0.14f];
    self.walkActionNL = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationNL restoreOriginalFrame:NO]];
    
    //Creating animation for Near Right
    NSMutableArray *walkAnimNR= [NSMutableArray array];
    for(int i = 0; i <= 7; ++i) {
      [walkAnimNR addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkNL%d.png", i]]];
    }
    CCAnimation *walkAnimationNR = [CCAnimation animationWithFrames:walkAnimNR delay:0.14f];
    self.walkActionNR = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationNR]];
    
    //Creating animation for far left
    NSMutableArray *walkAnimFL= [NSMutableArray array];
    for(int i = 0; i <= 7; ++i) {
      [walkAnimFL addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkFL%d.png", i]]];
    }
    CCAnimation *walkAnimationFL = [CCAnimation animationWithFrames:walkAnimFL delay:0.14f];
    self.walkActionFL = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationFL]];
    
    //Creating animation for Far Right
    NSMutableArray *walkAnimFR= [NSMutableArray array];
    for(int i = 0; i <= 7; ++i) {
      [walkAnimFR addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkFL%d.png", i]]];
    }
    CCAnimation *walkAnimationFR = [CCAnimation animationWithFrames:walkAnimFR delay:0.14f];
    self.walkActionFR = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationFR]];    
    
    // Create sprite
    self.sprite = [CCSprite spriteWithSpriteFrameName:@"DrowWalkNL0.png"];
    _sprite.anchorPoint = ccp(0, 0);
    
    
    // Move sprite a bit up
    //[_sprite runAction:_walkActionNL];
    [spriteSheet addChild:_sprite];
    
    // So that it registers touches
    self.contentSize = self.sprite.contentSize;
    _glow.position = ccp(self.contentSize.width/2, 0);
    
    _oldMapPos = loc.origin;
    
    self.nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    
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
  
  CGPoint difference = ccpSub(pt, _oldMapPos);
  CGPoint fr = CGPointMake(1, 0);
  CGPoint fl = CGPointMake(0, 1);
  CGPoint nl = CGPointMake(-1, 0);
  CGPoint nr = CGPointMake(0, -1);
  
   [_sprite stopAllActions];
  if(CGPointEqualToPoint(difference, fr)){
    _sprite.flipX = YES;
    [_sprite runAction:_walkActionFR];
  }else if(CGPointEqualToPoint(difference, fl)){
    _sprite.flipX = NO;
    [_sprite runAction:_walkActionFL];
  }else if(CGPointEqualToPoint(difference, nl)) {
    _sprite.flipX = NO;
    [_sprite runAction:_walkActionNL];
  }else if(CGPointEqualToPoint(difference, nr)){
    _sprite.flipX = YES;
    [_sprite runAction:_walkActionNR];
  }
  
  [self runAction:[CCSequence actions:                          
                   [MoveToLocation actionWithDuration:2*diff location:r],
                   [CCCallFunc actionWithTarget:self selector:@selector(walk)],
                   nil
                   ]];
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
  self.sprite = nil;
  self.walkAction = nil;
  self.walkActionFR = nil;
  self.walkActionFL = nil;
  self.walkActionNR = nil;
  self.walkActionNL = nil;
	[super dealloc];
}

@end

@implementation QuestGiver

@synthesize quest, questGiverState, name;

- (id) initWithQuest:(FullQuestProto *)fqp questGiverState:(QuestGiverState)qgs file:(NSString *)file map:(GameMap *)map location:(CGRect)location {
  if ((self = [super initWithFile:file location:location map:map])) {
    self.quest = fqp;
    self.questGiverState = qgs;
  }
  return self;
}

- (void) setName:(NSString *)n {
  if (name != n) {
    [name release];
    name = [n copy];
    _nameLabel.string = name;
  }
}

- (void) setIsSelected:(BOOL)isSelected {
  if (isSelected) {
    if (quest) {
      if (questGiverState == kInProgress) {
        [[QuestLogController sharedQuestLogController] loadQuest:quest];
      } else if (questGiverState == kAvailable) {
        [[ConvoMenuController sharedConvoMenuController] displayQuestConversationForQuest:self.quest];
      } else if (questGiverState == kCompleted) {
        [[QuestLogController sharedQuestLogController] loadQuestRedeemScreen:quest];
      }
    }
    [_map setSelected:nil];
  }
}

- (void) setQuestGiverState:(QuestGiverState)i {
  questGiverState = i;
  
  [self removeChild:_aboveHeadMark cleanup:YES];
  _aboveHeadMark = nil;
  if (questGiverState == kInProgress) {
    _aboveHeadMark = [CCProgressTimer progressWithFile:@"questinprogress.png"];
    ((CCProgressTimer *) _aboveHeadMark).type = kCCProgressTimerTypeHorizontalBarLR;
  } else if (questGiverState == kAvailable) {
    _aboveHeadMark = [CCSprite spriteWithFile:@"questnew.png"];
  } else if (questGiverState == kCompleted) {
    _aboveHeadMark = [CCSprite spriteWithFile:@"questcomplete.png"];
  }
  
  if (_aboveHeadMark) {
    [self addChild:_aboveHeadMark];
  }
  _aboveHeadMark.anchorPoint = ccp(0.5, 0.2f);
  _aboveHeadMark.position = ccp(self.contentSize.width/2, self.contentSize.height+10+_aboveHeadMark.contentSize.height*_aboveHeadMark.anchorPoint.y);
  
  if (questGiverState == kAvailable || questGiverState == kCompleted) {
    CCRotateBy *right = [CCRotateBy actionWithDuration:0.03f angle:3];
    CCActionInterval *left = right.reverse;
    CCRepeat *ring = [CCRepeat actionWithAction:[CCSequence actions:right, left, left, right, nil] times:5];
    [_aboveHeadMark runAction:[CCRepeatForever actionWithAction:
                               [CCSequence actions:
                                ring,
                                [CCDelayTime actionWithDuration:1.f],
                                nil]]];
  } else {
    CCProgressTimer *pt = (CCProgressTimer *)_aboveHeadMark;
    pt.percentage = 0;
    [_aboveHeadMark runAction:
     [CCRepeatForever actionWithAction:
      [CCSequence actions:
       [CCCallBlock actionWithBlock:
        ^{
          if (pt.percentage > 99.f) {
            pt.percentage = 0.f;
          } else {
            pt.percentage += 100.f/3;
          }
        }],
       [CCDelayTime actionWithDuration:1.f],
       nil]]];
  }
}

- (void) dealloc {
  self.quest = nil;
  self.name = nil;
  [super dealloc];
}

@end

@implementation Enemy

@synthesize user;

- (id) initWithUser:(FullUserProto *)fup location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:[Globals spriteImageNameForUser:fup.userType] location:loc map:map])) {
    self.user = fup;
  }
  return self;
}

- (void) setUser:(FullUserProto *)u {
  if (user != u) {
    [user release];
    user = [u retain];
    _nameLabel.string = u.name;
  }
}

- (void) dealloc {
  self.user = nil;
  [super dealloc];
}

@end

@implementation TutorialGirl

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
//  GameState *gs = [GameState sharedGameState];
//  NSString *file = [Globals userTypeIsGood:gs.type] ? @"AllianceTutorialGuide.png" : @"AllianceTutorialGuide.png";
  if ((self = [super initWithQuest:nil questGiverState:kNoQuest file:nil map:map location:loc])) {
    
  }
  return self;
}

@end

@implementation Carpenter

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:@"Syndicate.png" location:loc map:map])) {
    CCSprite *carpIcon = [CCSprite spriteWithFile:@"carpentericon.png"];
    [self addChild:carpIcon];
    carpIcon.position = ccp(self.contentSize.width/2, self.contentSize.height+carpIcon.contentSize.height/2);
    
    self.touchableArea = CGSizeMake(self.contentSize.width, self.contentSize.height+carpIcon.contentSize.height);
  }
  return self;
}

- (void) setIsSelected:(BOOL)isSelected {
  if (isSelected) {
    [CarpenterMenuController displayView];
    [_map setSelected:nil];
  }
}

@end

@implementation MyPlayer

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:@"Syndicate.png" location:loc map:map])) {
  }
  return self;
}

- (void) moveToLocation:(CGRect)loc {
  self.location = loc;
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
  [(MapSprite *)target_ setLocation: r];
}

@end
