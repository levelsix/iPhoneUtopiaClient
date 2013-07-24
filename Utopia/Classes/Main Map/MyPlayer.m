//
//  MyPlayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MyPlayer.h"
#import "GameState.h"
#import "Globals.h"
#import "SoundEngine.h"
#import "AnimatedSprite.h"

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
    
    [self schedule:@selector(incrementalLoad) interval:0.1f];
    
    // Create sprite
    self.contentSize = CGSizeMake(40, 70);
    
    self.sprite = [CCSprite node];
    
    CoordinateProto *cp = [[Globals sharedGlobals].animatingSpriteOffsets objectForKey:prefix];
    self.sprite.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), ccp(cp.x, cp.y+5));
    
    [self addChild:_sprite z:5 tag:9999];
  }
  return self;
}

- (void) incrementalLoad {
  if (_isDownloading) {
    return;
  }
  _isDownloading = YES;
  
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [Globals animatedSpritePrefix:gs.type];
  switch (_incrementalLoadCounter) {
    case 0:
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkNF.plist",prefix]];
      break;
      
    case 1:
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkLR.plist",prefix]];
      break;
      
    case 2:
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkUD.plist",prefix]];
      break;
      
    case 3:
      [self setUpAnimations:prefix];
      break;
      
    case 4:
      [self unschedule:@selector(incrementalLoad)];
      
    default:
      break;
  }
  _incrementalLoadCounter++;
  _isDownloading = NO;
}

- (void) setUpAnimations:(NSString *)prefix {
  //Creating animation for Near
  NSMutableArray *walkAnimN= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    NSString *file = [NSString stringWithFormat:@"%@WalkN%02d.png",prefix, i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
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
    NSString *file = [NSString stringWithFormat:@"%@WalkF%02d.png",prefix, i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
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
    NSString *file = [NSString stringWithFormat:@"%@WalkU%02d.png",prefix, i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
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
    NSString *file = [NSString stringWithFormat:@"%@WalkD%02d.png",prefix, i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
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
    NSString *file = [NSString stringWithFormat:@"%@WalkLR%02d.png", prefix, i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
      [walkAnimLR addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *walkAnimationLR = [CCAnimation animationWithFrames:walkAnimLR delay:ANIMATATION_DELAY];
  self.walkActionLR = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationLR restoreOriginalFrame:NO]];
  
  NSString *name1 = [NSString stringWithFormat:@"%@WalkD00.png",prefix];
  CCSpriteFrame *frame = nil;
  if ([[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:name1]) {
    frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name1];
  }
  
  if (frame) {
    [self.sprite setDisplayFrame:frame];
  }
}

- (void) performAnimation:(AnimationType)type atLocation:(CGPoint)point inDirection:(float)angle {
  GameState *gs = [GameState sharedGameState];
  
  // Alliance Warrior, Legion Mage, Both archers
//  if (gs.type == UserTypeGoodWarrior || gs.type == UserTypeGoodArcher || gs.type == UserTypeBadArcher) {
    type = AnimationTypeGenericAction;
//  }
  
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
  
  // Play the appropriate sound
  if (type == AnimationTypeGenericAction) {
    _soundSelector = @selector(genericTaskSound);
  } else if (type == AnimationTypeAttack) {
    switch (gs.type) {
      case UserTypeBadArcher:
      case UserTypeGoodArcher:
        _soundSelector = @selector(archerTaskSound);
        break;
        
      case UserTypeBadMage:
      case UserTypeGoodMage:
        _soundSelector = @selector(mageTaskSound);
        break;
        
      case UserTypeBadWarrior:
      case UserTypeGoodWarrior:
        _soundSelector = @selector(warriorTaskSound);
        break;
        
      default:
        break;
    }
  }
  
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
    
    [[SoundEngine sharedSoundEngine] performSelector:_soundSelector];
  } else {
    GameState *gs = [GameState sharedGameState];
    NSString *prefix = [Globals animatedSpritePrefix:gs.type];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkUD.plist",prefix]];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkD00.png",prefix]];
    [self.sprite setDisplayFrame:frame];
  }
}

- (void) stopWalking {
  [self stopAllActions];
  [self.sprite stopAllActions];
}

- (void) stopPerformingAnimation {
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