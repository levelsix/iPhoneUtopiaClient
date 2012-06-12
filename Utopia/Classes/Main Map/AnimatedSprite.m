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
#define ANIMATATION_DELAY 0.05f
#define MOVE_DISTANCE 4.0f

#define WALKING_SPEED 50.f

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
@synthesize walkActionF = _walkActionF;
@synthesize walkActionN = _walkActionN;

-(id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if((self = [super initWithFile:file location:loc map:map])) {
    
    // This loads an image of the same name (but ending in png), and goes through the
    // plist to add definitions of each frame to the cache.
    
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DrowWalkingNF.plist"]; 
    
    // Create a sprite sheet with the Happy Bear images
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"DrowWalkingNF.png"];
    [self addChild:spriteSheet];
    
    //Creating animation for Near Left
    NSMutableArray *walkAnimN= [NSMutableArray array];
    for(int i = 0; i <= 20; ++i) {
      [walkAnimN addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkingN%d.png", i]]];
    }
    CCAnimation *walkAnimationN = [CCAnimation animationWithFrames:walkAnimN delay:ANIMATATION_DELAY];
    self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationN restoreOriginalFrame:NO]];
    
    //Creating animation for far left
    NSMutableArray *walkAnimF= [NSMutableArray array];
    for(int i = 0; i <= 20; ++i) {
      [walkAnimF addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkingF%d.png", i]]];
    }
    CCAnimation *walkAnimationF = [CCAnimation animationWithFrames:walkAnimF delay:ANIMATATION_DELAY];
    self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationF]];
    
    
    // Create sprite
    self.sprite = [CCSprite spriteWithSpriteFrameName:@"DrowWalkingN0.png"];
    _sprite.anchorPoint = ccp(0, 0);
    
    
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
    [_sprite runAction:_walkActionF];
  } else if(CGPointEqualToPoint(difference, fl)){
    _sprite.flipX = NO;
    [_sprite runAction:_walkActionF];
  } else if(CGPointEqualToPoint(difference, nl)) {
    _sprite.flipX = NO;
    [_sprite runAction:_walkActionN];
  } else if(CGPointEqualToPoint(difference, nr)){
    _sprite.flipX = YES;
    [_sprite runAction:_walkActionN];
  }
  
  [self runAction:[CCSequence actions:                          
                   [MoveToLocation actionWithDuration:diff/WALKING_SPEED location:r],
                   [CCCallFunc actionWithTarget:self selector:@selector(walk)],
                   nil
                   ]];
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
  self.sprite = nil;
  self.walkAction = nil;
  self.walkActionF = nil;
  self.walkActionN = nil;
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

@synthesize walkActionD = _walkActionD;
@synthesize walkActionF = _walkActionF;
@synthesize walkActionLR = _walkActionLR;
@synthesize walkActionN = _walkActionN;
@synthesize walkActionU = _walkActionU;
@synthesize sprite = _sprite;
@synthesize currentAction = _currentAction;

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:nil location:loc map:map])) {
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DrowWalkingNF.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DrowWalkingLRUD.plist"];
    
    //Creating animation for Near Left
    NSMutableArray *walkAnimN= [NSMutableArray array];
    for(int i = 0; i <= 20; ++i) {
      [walkAnimN addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkingN%d.png", i]]];
    }
    CCAnimation *walkAnimationN = [CCAnimation animationWithFrames:walkAnimN delay:ANIMATATION_DELAY];
    self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationN restoreOriginalFrame:NO]];
    
    //Creating animation for far left
    NSMutableArray *walkAnimF= [NSMutableArray array];
    for(int i = 0; i <= 20; ++i) {
      [walkAnimF addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkingF%d.png", i]]];
    }
    CCAnimation *walkAnimationF = [CCAnimation animationWithFrames:walkAnimF delay:ANIMATATION_DELAY];
    self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationF]];
    
    //creating animation for walking up
    NSMutableArray *walkAnimU = [NSMutableArray array];
    for(int i = 0 ; i<=20; ++i){
      [walkAnimU addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkingU%d.png", i]]];
    }
    CCAnimation *walkAnimationU = [CCAnimation animationWithFrames:walkAnimU delay:ANIMATATION_DELAY];
    self.walkActionU = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationU]];
    
    //create animation for walking down
    NSMutableArray *walkAnimD = [NSMutableArray array];
    for(int i = 0 ; i<=20; ++i){
      [walkAnimD addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkingD%d.png", i]]];
    }
    CCAnimation *walkAnimationD = [CCAnimation animationWithFrames:walkAnimD delay:ANIMATATION_DELAY];
    self.walkActionD = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationD]];
    
    //create animation for left and right
    NSMutableArray *walkAnimLR = [NSMutableArray array];
    for(int i = 0 ; i<=20; ++i){
      [walkAnimLR addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"DrowWalkLR%d.png", i]]];
    }
    CCAnimation *walkAnimationLR = [CCAnimation animationWithFrames:walkAnimLR delay:ANIMATATION_DELAY];
    self.walkActionLR = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationLR]];
    
    // Create sprite
    self.sprite = [CCSprite spriteWithSpriteFrameName:@"DrowWalkingD0.png"];
     _sprite.anchorPoint = ccp(0.5, 0.5);
    
    [self addChild:_sprite];
    
  }
  return self;
}


- (void) moveToLocation:(CGRect)loc {
  CGPoint startPt = [_map convertTilePointToCCPoint:self.location.origin];
  CGPoint endPt = [_map convertTilePointToCCPoint:loc.origin];
  CGFloat distance = ccpDistance(endPt, startPt);
  float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(endPt, startPt)));
  
  int boolValue = [[[_map.walkableData objectAtIndex:loc.origin.x] objectAtIndex:loc.origin.y] boolValue];
  
  if(boolValue == 0){
    return;
  }
  
  if(distance <=100){
    CCAction *newAction = nil;
    
    if (angle >= 165 || angle <= -165) {
      self.sprite.flipX = NO;
      newAction = self.walkActionLR;
    } else if (angle >= 120) {
      self.sprite.flipX = NO;
      newAction = self.walkActionF;
    } else if (angle >= 60) {
      self.sprite.flipX = NO; 
      newAction = self.walkActionU;
    } else if (angle >= 15) {
      self.sprite.flipX = YES;
      newAction = self.walkActionF;
    } else if (angle >= -15) {
      self.sprite.flipX = YES;
      newAction = self.walkActionLR;
    } else if (angle >= -60) {
      self.sprite.flipX = YES;
      newAction = self.walkActionN;
    } else if (angle >= -120) {
      self.sprite.flipX = NO;
      newAction = self.walkActionD;
    } else if (angle >= -165) {
      self.sprite.flipX = NO;
      newAction = self.walkActionN;
    }
    
    if (self.currentAction != newAction) {
      // Only restart animation if it is different from the current one
      self.currentAction = newAction;
      [self.sprite stopAllActions];
      [self.sprite runAction:self.currentAction];
    }
    
    [self stopAllActions];
    [self runAction:[CCSequence actions:[MoveToLocation actionWithDuration:distance/WALKING_SPEED location:loc], [CCCallBlock actionWithBlock:^{
      [self.sprite stopAllActions];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DrowWalkingD0.png"];
      [self.sprite setDisplayFrame:frame];
      self.currentAction = nil;
    }], nil]];

  } else {
    CGRect startingLocation = CGRectMake(loc.origin.x-2, loc.origin.y-2,loc.size.width,loc.size.height);
    int num = [[[_map.walkableData objectAtIndex:startingLocation.origin.x]objectAtIndex:startingLocation.origin.y]boolValue];
    if(num == 0){
      startingLocation= CGRectMake(loc.origin.x-1, loc.origin.y-1,loc.size.width,loc.size.height);
      int temp = [[[_map.walkableData objectAtIndex:startingLocation.origin.x]objectAtIndex:startingLocation.origin.y]boolValue];
      if(temp == 0){
        startingLocation = CGRectMake(loc.origin.x, loc.origin.y,loc.size.width,loc.size.height);
      }
    }
    CGRect startingPosition = startingLocation;
    
    [self setLocation:startingPosition];
    [self.sprite stopAllActions];
    [self stopAllActions];
    [self.sprite runAction:self.walkActionU];
    
    float dist = ccpDistance([_map convertTilePointToCCPoint:startingPosition.origin], [_map convertTilePointToCCPoint:loc.origin]);
    [self runAction:[CCSequence actions:[MoveToLocation actionWithDuration:dist/WALKING_SPEED location:loc], [CCCallBlock actionWithBlock:^{
      [self.sprite stopAllActions];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DrowWalkingD0.png"];
      [self.sprite setDisplayFrame:frame];
    }], nil]];
  }
}

- (void) dealloc {
  self.walkActionN = nil;
  self.walkActionF = nil;
  self.walkActionLR = nil;
  self.walkActionU = nil;
  self.walkActionD = nil;
  self.currentAction = nil;
  self.sprite = nil;
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
  [(MapSprite *)target_ setLocation: r];
}

@end
