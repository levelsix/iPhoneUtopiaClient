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
#import "ProfileViewController.h"
#import "Globals.h"

@implementation CCSpriteFrameCache (FrameCheck)

- (BOOL) containsFrame:(NSString *)frameName {
  return [spriteFrames_ objectForKey:frameName] != nil;
}

@end

@implementation CharacterSprite


@synthesize nameLabel = _nameLabel;

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _nameLabel = [[CCLabelTTF alloc] initWithString:@"" fontName:[Globals font] fontSize:[Globals fontSize]];
    [self addChild:_nameLabel z:1];
    _nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    _nameLabel.color = ccc3(255,200,0);
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

@synthesize spritesheet = _spritesheet;
@synthesize sprite = _sprite;
@synthesize walkActionF = _walkActionF;
@synthesize walkActionN = _walkActionN;

-(id) initWithFile:(NSString *)prefix location:(CGRect)loc map:(GameMap *)map {
  prefix = [[prefix.lastPathComponent stringByReplacingOccurrencesOfString:prefix.pathExtension withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
  if((self = [super initWithFile:nil location:loc map:map])) {
    NSString *plist = [NSString stringWithFormat:@"%@WalkNF.plist",prefix];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
    
    //create the animation for Near
    NSMutableArray *walkAnimN = [NSMutableArray array];
    for(int i = 0; true; i++) {
      NSString *file = [NSString stringWithFormat:@"%@WalkN%02d.png",prefix, i];
      BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
      if (exists) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        [walkAnimN addObject:frame];
      } else {
        break;
      }
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[Globals pathToFile:plist]];
    NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
    NSDictionary *targetDict = [metadataDict objectForKey:@"target"];
    NSString *texturePath = [targetDict objectForKey:@"textureFileName"];
    NSString *end = [targetDict objectForKey:@"textureFileExtension"];
    texturePath = [[texturePath stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    texturePath = [texturePath stringByAppendingString:end];
    
    self.spritesheet = [CCSpriteBatchNode batchNodeWithFile:texturePath];
    [self addChild:_spritesheet];
    
    CCAnimation *walkAnimationN = [CCAnimation animationWithFrames:walkAnimN delay:ANIMATATION_DELAY];
    self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationN restoreOriginalFrame:NO]];
    
    //create the animation for Far
    NSMutableArray *walkAnimF = [NSMutableArray array];
    for(int i = 0; true; i++) {
      NSString *file = [NSString stringWithFormat:@"%@WalkF%02d.png",prefix, i];
      BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
      if (exists) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        [walkAnimF addObject:frame];
      } else {
        break;
      }
    }
    
    // So that it registers touches
    self.contentSize = CGSizeMake(40, 70);
    
    CCAnimation *walkAnimationF = [CCAnimation animationWithFrames:walkAnimF delay:ANIMATATION_DELAY];
    self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationF restoreOriginalFrame:NO]];
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkN00.png",prefix]];
    self.sprite = [CCSprite spriteWithSpriteFrame:frame];
    [self.spritesheet addChild:_sprite];
    CoordinateProto *cp = [[Globals sharedGlobals].animatingSpriteOffsets objectForKey:prefix];
    self.sprite.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), ccp(cp.x, cp.y));
    
    _oldMapPos = loc.origin;
    
    [self walk];
    
    self.nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
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
    [self pauseSchedulerAndActions];
    [self.sprite pauseSchedulerAndActions];
    _curAction = nil;
  } else {
    [self resumeSchedulerAndActions];
    [self.sprite resumeSchedulerAndActions];
  }
}

- (void) walk {
  MissionMap *missionMap = (MissionMap *)_map;
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
      LNLog(@"No Action");
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
  _aboveHeadMark.position = ccpAdd(_nameLabel.position, ccp(0, 7+_aboveHeadMark.contentSize.height*_aboveHeadMark.anchorPoint.y));
  
  if (questGiverState == kAvailable || questGiverState == kCompleted) {
    CCRotateBy *right1 = [CCRotateTo actionWithDuration:0.03f angle:3];
    CCActionInterval *left = [CCRotateTo actionWithDuration:0.06f angle:-3];
    CCRotateBy *right2 = [CCRotateTo actionWithDuration:0.03f angle:0];
    _aboveHeadMark.rotation = -3;
    CCRepeat *ring = [CCRepeat actionWithAction:[CCSequence actions:right1, left, right2, nil] times:5];
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

@synthesize user, isAlive;

- (id) initWithUser:(FullUserProto *)fup location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:[Globals animatedSpritePrefix:fup.userType] location:loc map:map])) {
    self.user = fup;
    self.isAlive = YES;
  }
  return self;
}

- (void) setUser:(FullUserProto *)u {
  if (user != u) {
    [user release];
    user = [u retain];
    _nameLabel.string = [Globals fullNameWithName:u.name clanTag:u.clan.tag];
  }
}

- (void) kill {
  // Need to delay time so check has time to display
  [self stopAllActions];
  [self runAction:[CCSequence actions:
                    [CCFadeOut actionWithDuration:1.5f],
                    [CCDelayTime actionWithDuration:1.5f],
                    [CCCallBlock actionWithBlock:
                     ^{
                       [self removeFromParentAndCleanup:YES];
                     }], nil]];
  
  self.isAlive = NO;
}

- (void) dealloc {
  self.user = nil;
  [super dealloc];
}

@end

@implementation Ally

@synthesize user;

- (id) initWithUser:(MinimumUserProtoWithLevel *)mup location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:[Globals animatedSpritePrefix:mup.minUserProto.userType] location:loc map:map])) {
    self.user = mup;
  }
  return self;
}

- (void) setUser:(MinimumUserProtoWithLevel *)u {
  if (user != u) {
    [user release];
    user = [u retain];
    _nameLabel.string = [Globals fullNameWithName:u.minUserProto.name clanTag:u.minUserProto.clan.tag];
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
  if ((self = [super initWithFile:@"Carpenter.png" location:loc map:map])) {
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

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  if (isSelected) {
    [Analytics taskViewed:ftp.taskId];
  } else {
    [Analytics taskClosed:ftp.taskId];
  }
}

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
