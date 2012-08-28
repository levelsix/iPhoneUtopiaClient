//
//  BazaarMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BazaarMap.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"

#define NUM_ALLIES 8

#define DEFAULT_BAZAAR_ZOOM 0.6

@implementation BazaarMap

SYNTHESIZE_SINGLETON_FOR_CLASS(BazaarMap);

- (id) init {
  if ((self = [super initWithTMXFile:@"Bazaar.tmx"])) {
    self.walkableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        [row addObject:[NSNumber numberWithBool:NO]];
      }
      [self.walkableData addObject:row];
    }
    
    int width = self.mapSize.width;
    int height = self.mapSize.height;
    // Get the walkable data
    CCTMXLayer *layer = [self layerNamed:@"Walkable"];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        NSMutableArray *row = [self.walkableData objectAtIndex:i];
        // Convert their coordinates to our coordinate system
        CGPoint tileCoord = ccp(height-j-1, width-i-1);
        int tileGid = [layer tileGIDAt:tileCoord];
        if (tileGid) {
          [row replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
        }
      }
    }
    [self removeChild:layer cleanup:YES];
    
    CritStruct *cs = [[CritStruct alloc] initWithType:BazaarStructTypeMarketplace];
    CritStructBuilding *csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(35, 31, 4, 4) map:self];
    [self addChild:csb z:100];
    [cs release];
    [csb release];
    
    cs = [[CritStruct alloc] initWithType:BazaarStructTypeArmory];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(42, 31, 4, 4) map:self];
    [self addChild:csb z:100];
    [cs release];
    [csb release];
    
    cs = [[CritStruct alloc] initWithType:BazaarStructTypeVault];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(31, 42, 4, 4) map:self];
    [self addChild:csb z:100];
    [cs release];
    [csb release];
    
    cs = [[CritStruct alloc] initWithType:BazaarStructTypeBlacksmith];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(31, 35, 4, 4) map:self];
    [self addChild:csb z:100];
    [cs release];
    [csb release];
    
    cs = [[CritStruct alloc] initWithType:BazaarStructTypeLeaderboard];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(39, 39, 3, 3) map:self];
    [self addChild:csb z:100];
    [cs release];
    [csb release];
    
    CGRect r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    _questGiver = [[QuestGiver alloc] initWithQuest:nil questGiverState:kNoQuest file:@"BlackSmith" map:self location:r];
    _questGiver.name = [Globals bazaarQuestGiverName];
    [self addChild:_questGiver];
    [_questGiver release];
    
    [self reloadQuestGivers];
    
    [self doReorder];
    
    self.scale = DEFAULT_BAZAAR_ZOOM;
  }
  return self;
}

- (void) setSelected:(SelectableSprite *)selected {
  if (selected != _selected) {
    if ([selected isKindOfClass: [CritStructBuilding class]]) {
      [super setSelected:nil];
      [[(CritStructBuilding *)selected critStruct] openMenu];
    } else {
      [super setSelected:selected];
    }
  }
}

- (void) drag:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  self.selected = nil;
  [super drag:recognizer node:node];
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  self.selected = nil;
  [super scale:recognizer node:node];
}

- (void) moveToQuestGiver {
  [self moveToSprite:_questGiver];
}

- (void) moveToCritStruct:(BazaarStructType)type {
  CCSprite *csb = nil;
  for (CCNode *c in children_) {
    if ([c isKindOfClass:[CritStructBuilding class]]) {
      CritStructBuilding *check = (CritStructBuilding *)c;
      if (check.critStruct.type == type) {
        csb = check;
        break;
      }
    }
  }
  [self moveToSprite:csb];
}

- (void) reloadAllies {
  GameState *gs = [GameState sharedGameState];
  NSArray *allies = gs.allies;
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (CCNode *node in children_) {
    if ([node isKindOfClass:[Ally class]]) {
      [toRemove addObject:node];
    }
  }
  for (CCNode *node in toRemove) {
    [node removeFromParentAndCleanup:YES];
  }
  
  // Need to get unique nums
  NSMutableSet *nums = [NSMutableSet set];
  while (nums.count < NUM_ALLIES && nums.count != allies.count) {
    int index = arc4random() % allies.count;
    [nums addObject:[NSNumber numberWithInt:index]];
  }
  
  for (NSNumber *num in nums) {
    MinimumUserProtoWithLevel *mup = [allies objectAtIndex:num.intValue];
    CGRect r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    Ally *ally = [[Ally alloc] initWithUser:mup location:r map:self];
    [self addChild:ally];
    [ally release];
  }
}

- (void) reloadQuestGivers {
  GameState *gs = [GameState sharedGameState];
  for (FullQuestProto *fqp in [gs.inProgressCompleteQuests allValues]) {
    if (fqp.cityId == 0 && fqp.assetNumWithinCity == 2) {
      QuestGiver *qg = _questGiver;
      qg.quest = fqp;
      qg.questGiverState = kCompleted;
      qg.visible = YES;
      return;
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressIncompleteQuests allValues]) {
    if (fqp.cityId == 0 && fqp.assetNumWithinCity == 2) {
      QuestGiver *qg = _questGiver;
      qg.quest = fqp;
      qg.questGiverState = kInProgress;
      return;
    }
  }
  for (FullQuestProto *fqp in [gs.availableQuests allValues]) {
    if (fqp.cityId == 0 && fqp.assetNumWithinCity == 2) {
      QuestGiver *qg = _questGiver;
      qg.quest = fqp;
      qg.questGiverState = kAvailable;
      return;
    }
  }
  
  // No quest was found for this guy
  _questGiver.quest = nil;
  _questGiver.questGiverState = kNoQuest;
}

- (void) questAccepted:(FullQuestProto *)fqp {
  if (fqp.cityId == 0 && fqp.assetNumWithinCity == 2) {
  QuestGiver *qg = _questGiver;
  qg.quest = fqp;
  qg.questGiverState = kInProgress;
  }
}

- (void) questRedeemed:(FullQuestProto *)fqp {
  if (fqp.cityId == 0 && fqp.assetNumWithinCity == 2) {
  QuestGiver *qg = _questGiver;
  qg.quest = nil;
  qg.questGiverState = kNoQuest;
  }
}

@end
