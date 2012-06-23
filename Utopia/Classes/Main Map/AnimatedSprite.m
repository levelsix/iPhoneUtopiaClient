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

@implementation CharacterSprite


@synthesize nameLabel = _nameLabel;

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _nameLabel = [[CCLabelTTF alloc] initWithString:@"" fontName:[Globals font] fontSize:[Globals fontSize]];
    [self addChild:_nameLabel z:1];
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
@synthesize walkActionF = _walkActionF;
@synthesize walkActionN = _walkActionN;

-(id) initWithFile:(NSString *)prefix location:(CGRect)loc map:(GameMap *)map {
  prefix = [[prefix.lastPathComponent stringByReplacingOccurrencesOfString:prefix.pathExtension withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
  if((self = [super initWithFile:nil location:loc map:map])) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkNF.plist",prefix]];
    
    //create the animation for Near
    NSMutableArray *walkAnimN = [NSMutableArray array];
    for(int i = 0; true; ++i) {
      NSString *file = [NSString stringWithFormat:@"%@WalkN%02d.png",prefix, i];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
      if (frame) {
        [walkAnimN addObject:frame];
      } else {
        break;
      }
    }
    
    CCAnimation *walkAnimationN = [CCAnimation animationWithFrames:walkAnimN delay:ANIMATATION_DELAY];
    self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationN restoreOriginalFrame:NO]];
    
    //create the animation for Far
    NSMutableArray *walkAnimF= [NSMutableArray array];
    for(int i = 0; true; ++i) {
      NSString *file = [NSString stringWithFormat:@"%@WalkF%02d.png",prefix, i];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
      if (frame) {
        [walkAnimF addObject:frame];
      } else {
        break;
      }
    }
    
    // So that it registers touches
    self.contentSize = CGSizeMake(40, 70);
    
    CCAnimation *walkAnimationF = [CCAnimation animationWithFrames:walkAnimF delay:ANIMATATION_DELAY];
    self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationF restoreOriginalFrame:NO]];
    
    self.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@WalkN00.png",prefix]];
    [self addChild:_sprite];
    CoordinateProto *cp = [[Globals sharedGlobals].animatingSpriteOffsets objectForKey:prefix];
    self.sprite.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), ccp(cp.x, cp.y));
    
    _oldMapPos = loc.origin;
    
    [self walk];
    
    self.nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    
    //    [self addChild:[CCLayerColor layerWithColor:ccc4(255, 0, 0, 255) width:self.contentSize.width height:self.contentSize.height] z:-1];
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
    _curAction = nil;
  } else {
    [self walk];
  }
}

- (void) walk {
  MissionMap *missionMap = (MissionMap *)_map;
  NSLog(@"Started walking..");
  CGPoint pt = [missionMap nextWalkablePositionFromPoint:self.location.origin prevPoint:_oldMapPos];
  if (CGPointEqualToPoint(self.location.origin, pt)) {
    CGRect r = self.location;
    r.origin = [missionMap randomWalkablePosition];
    self.location = r;
    _oldMapPos = r.origin;
    [self walk];
  } else {
    _oldMapPos = self.location.origin;
    
    CGRect r = self.location;
    r.origin = pt;
    CGPoint startPt = [_map convertTilePointToCCPoint:_oldMapPos];
    CGPoint endPt = [_map convertTilePointToCCPoint:pt];
    CGFloat diff = ccpDistance(endPt, startPt);
    
    float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(endPt, startPt)));
    
    CCAction *nextAction = nil;
    if(angle <= -90 ){
      _sprite.flipX = NO;
      nextAction = _walkActionN;
    } else if(angle <= 0){
      _sprite.flipX = YES;
      nextAction = _walkActionN;
    } else if(angle <= 90) {
      _sprite.flipX = YES;
      nextAction = _walkActionF;
    } else if(angle <= 180){
      _sprite.flipX = NO;
      nextAction = _walkActionF;
    } else {
      NSLog(@"No Action");
    }
    
    if (_curAction != nextAction) {
      _curAction = nextAction;
      [_sprite stopAllActions];
      if (_curAction) {
        [_sprite runAction:_curAction];
      }
    }
    
    [self runAction:[CCSequence actions:                          
                     [MoveToLocation actionWithDuration:diff/WALKING_SPEED location:r],
                     [CCCallFunc actionWithTarget:self selector:@selector(walk)],
                     nil
                     ]];
  }
  NSLog(@"Ended walking..");
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
  self.sprite = nil;
  self.walkActionF = nil;
  self.walkActionN = nil;
	[super dealloc];
}

@end

@implementation QuestGiver

@synthesize quest, questGiverState, name;

- (id) initWithQuest:(FullQuestProto *)fqp questGiverState:(QuestGiverState)qgs file:(NSString *)file map:(GameMap *)map location:(CGRect)location {
  if ((self = [super initWithFile:@"TutorialGuide" location:location map:map])) {
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
  _aboveHeadMark.position = ccpAdd(_nameLabel.position, ccp(0, 7+_aboveHeadMark.contentSize.height*_aboveHeadMark.anchorPoint.y));
  
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
  if ((self = [super initWithFile:[Globals animatedSpritePrefix:fup.userType] location:loc map:map])) {
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
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [Globals userTypeIsGood:gs.type] ? @"TutorialGuide" : @"TutorialGuideBad";
  
  if ((self = [super initWithQuest:nil questGiverState:kNoQuest file:prefix map:map location:loc])) {
    self.name = [Globals homeQuestGiverName];
  }
  return self;
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

@end

@implementation Carpenter

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:@"TutorialGuideBad.png" location:loc map:map])) {
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

@implementation NeutralEnemy

@synthesize ftp, numTimesActedForTask, numTimesActedForQuest, name, partOfQuest;

- (void) setName:(NSString *)n {
  if (name != n) {
    [name release];
    name = [n retain];
    _nameLabel.string = name;
  }
}

- (void) dealloc {
  self.ftp = nil;
  [super dealloc];
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
@synthesize agAnimation = _agAnimation;

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:nil location:loc map:map])) {
    GameState *gs = [GameState sharedGameState];
    NSString *prefix = [Globals animatedSpritePrefix:gs.type];
    
    [self setUpAnimations];
    
    // Create sprite
    self.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@WalkN00.png",prefix]];
    _sprite.anchorPoint = ccp(0.5, 0.5);
    CoordinateProto *cp = [[Globals sharedGlobals].animatingSpriteOffsets objectForKey:prefix];
    self.sprite.position = ccp(cp.x, cp.y);
    
    [self addChild:_sprite z:5 tag:9999];
    
  }
  return self;
}

- (void) setUpAnimations {
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [Globals animatedSpritePrefix:gs.type];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkNF.plist",prefix]];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkLR.plist",prefix]];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkUD.plist",prefix]];
  
  
  //Creating animation for Near
  NSMutableArray *walkAnimN= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkN%02d.png",prefix, i]];
    if (frame) {
      [walkAnimN addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *walkAnimationN = [CCAnimation animationWithFrames:walkAnimN delay:ANIMATATION_DELAY];
  self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationN restoreOriginalFrame:NO]];
  
  //Creating animation for far
  NSMutableArray *walkAnimF= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkF%02d.png",prefix, i]];
    if (frame) {
      [walkAnimF addObject:frame];
    } else {
      break;
    }
  }
  CCAnimation *walkAnimationF = [CCAnimation animationWithFrames:walkAnimF delay:ANIMATATION_DELAY];
  self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationF restoreOriginalFrame:NO]];
  
  //creating animation for walking up
  NSMutableArray *walkAnimU = [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkU%02d.png",prefix, i]];
    if (frame) {
      [walkAnimU addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *walkAnimationU = [CCAnimation animationWithFrames:walkAnimU delay:ANIMATATION_DELAY];
  self.walkActionU = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationU restoreOriginalFrame:NO]];
  
  //create animation for walking down
  NSMutableArray *walkAnimD= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkD%02d.png",prefix, i]];
    if (frame) {
      [walkAnimD addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *walkAnimationD = [CCAnimation animationWithFrames:walkAnimD delay:ANIMATATION_DELAY];
  self.walkActionD = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationD restoreOriginalFrame:NO]];
  
  //create animation for left and right
  NSMutableArray *walkAnimLR = [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkLR%02d.png",prefix, i]];
    if (frame) {
      [walkAnimLR addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *walkAnimationLR = [CCAnimation animationWithFrames:walkAnimLR delay:ANIMATATION_DELAY];
  self.walkActionLR = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationLR restoreOriginalFrame:NO]];
}

- (void) performAnimation:(AnimationType)type atLocation:(CGPoint)point inDirection:(float)angle {
  NSString *dir = nil;
  NSString *plistDir = nil;
  
  if (angle >= 165 || angle <= -165) {
    self.sprite.flipX = NO;
    dir = @"LR";
    plistDir = @"LR";
  } else if (angle >= 120) {
    self.sprite.flipX = NO;
    dir = @"F";
    plistDir = @"NF";
  } else if (angle >= 60) {
    self.sprite.flipX = NO; 
    dir = @"U";
    plistDir = @"UD";
  } else if (angle >= 15) {
    self.sprite.flipX = YES;
    dir = @"F";
    plistDir = @"NF";
  } else if (angle >= -15) {
    self.sprite.flipX = YES;
    dir = @"LR";
    plistDir = @"LR";
  } else if (angle >= -60) {
    self.sprite.flipX = YES;
    dir = @"N";
    plistDir = @"NF";
  } else if (angle >= -120) {
    self.sprite.flipX = NO;
    dir = @"D";
    plistDir = @"UD";
  } else if (angle >= -165) {
    self.sprite.flipX = NO;
    dir = @"N";
    plistDir = @"NF";
  }
  
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [NSString stringWithFormat:@"%@%@", [Globals animatedSpritePrefix:gs.type], type == AnimationTypeGenericAction ? @"Generic" : @"Attack"];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[prefix stringByAppendingFormat:@"%@.plist", plistDir]];
  
  //create animation for left and right
  NSMutableArray *agArray = [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%@%02d.png",prefix, dir, i]];
    if (frame) {
      [agArray addObject:frame];
    } else {
      break;
    }
  }
  
  self.agAnimation = [CCAnimation animationWithFrames:agArray delay:ANIMATATION_DELAY];
  _shouldContinueAnimation = YES;
  
  [self repeatCurrentAttackAnimation]; 
  
  CGRect r = self.location;
  r.origin = point;
  self.location = r;
}

- (void) repeatCurrentAttackAnimation {
  if(_shouldContinueAnimation) {
    CCAction *agAction = [CCSequence actions:[CCAnimate actionWithAnimation:_agAnimation restoreOriginalFrame:NO],
                          [CCCallFunc actionWithTarget:self selector:@selector(repeatCurrentAttackAnimation)], nil];
    agAction.tag = 9999;
    
    [self.sprite runAction:agAction];
  } else {
    GameState *gs = [GameState sharedGameState];
    NSString *prefix = [Globals animatedSpritePrefix:gs.type];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkD00.png",prefix]];
    [self.sprite setDisplayFrame:frame];
  }
}

- (void)stopWalking{
  [self stopAllActions];
  [self.sprite stopAllActions];
}

- (void)stopPerformingAnimation {
  _shouldContinueAnimation = NO;
}

- (void) moveToLocation:(CGRect)loc {
  
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [Globals animatedSpritePrefix:gs.type];
  
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
    [self runAction:[CCSequence actions:[MoveToLocation actionWithDuration:distance/MY_WALKING_SPEED location:loc], [CCCallBlock actionWithBlock:^{
      [self.sprite stopAllActions];
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkUD.plist",prefix]];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkD00.png",prefix]];
      frame = frame ? frame : [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkN00.png",prefix]];
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
    [self runAction:[CCSequence actions:[MoveToLocation actionWithDuration:dist/MY_WALKING_SPEED location:loc], [CCCallBlock actionWithBlock:^{
      [self.sprite stopAllActions];
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkUD.plist",prefix]];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkD00.png",prefix]];
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
  self.agAnimation = nil;
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
