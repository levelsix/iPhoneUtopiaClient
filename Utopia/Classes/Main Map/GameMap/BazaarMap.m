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
    
    CritStruct *cs = [[CritStruct alloc] initWithType:CritStructTypeMarketplace];
    CritStructBuilding *csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(35, 35, 2, 2) map:self];
    [self addChild:csb z:100];
    
    cs = [[CritStruct alloc] initWithType:CritStructTypeArmory];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(42, 35, 2, 2) map:self];
    [self addChild:csb z:100];
    
    cs = [[CritStruct alloc] initWithType:CritStructTypeVault];
    csb = [[CritStructBuilding alloc] initWithCritStruct:cs location:CGRectMake(35, 42, 2, 2) map:self];
    [self addChild:csb z:100];
    
    CGRect r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    _questGiver = [[QuestGiver alloc] initWithQuest:nil questGiverState:kNoQuest file:@"FemaleFarmer.png" map:self location:r];
    [self addChild:_questGiver];
    [_questGiver release];
    
    [self reloadQuestGivers];
    
    [self doReorder];
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

- (void) moveToCritStruct:(CritStructType)type {
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
