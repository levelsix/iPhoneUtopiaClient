//
//  MissionMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MissionMap.h"
#import "GameState.h"
#import "Globals.h"
#import "UserData.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "AnimatedSprite.h"
#import "CCLabelFX.h"
#import "TopBar.h"
#import "QuestLogController.h"

#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define SUMMARY_MENU_ANIMATION_DURATION 0.15f

#define TASK_BAR_DURATION 2.f
#define EXP_LABEL_DURATION 3.f

@implementation TaskProgressBar

@synthesize isAnimating;

+ (id) node {
  return [[[self alloc] initBar] autorelease];
}

- (id) initBar {
  if ((self = [super initWithFile:@"taskbarbg.png"])) {
    _progressBar = [CCProgressTimer progressWithFile:@"yellowtaskbar.png"];
    [self addChild:_progressBar];
    _progressBar.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _progressBar.type = kCCProgressTimerTypeHorizontalBarLR;
    
    _label = [CCLabelFX labelWithString:@""
                               fontName:@"DINCond-Black"
                               fontSize:10
                           shadowOffset:CGSizeMake(0, -1) 
                             shadowBlur:1.f 
                            shadowColor:ccc4(0, 0, 0, 80) 
                              fillColor:ccc4(255,255,255,255)];
    [self addChild:_label];
    _label.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  }
  return self;
}

- (void) animateBarWithText:(NSString *)str {
  if (!isAnimating) {
    _label.string = [str uppercaseString];
    _progressBar.percentage = 0.f;
    isAnimating = YES;
    [_progressBar runAction:[CCSequence actions:
                             [CCProgressTo actionWithDuration:TASK_BAR_DURATION percent:100.f], 
                             [CCCallBlock actionWithBlock:^{ isAnimating = NO; }], 
                             [CCCallFunc actionWithTarget:self.parent selector:@selector(taskBarAnimDone)],nil]];
  }
}

@end

@implementation MissionMap

@synthesize summaryMenu, obMenu;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto {
  //  NSString *tmxFile = @"villa_montalvo.tmx";
  FullCityProto *fcp = [[GameState sharedGameState] cityWithId:proto.cityId];
  if ((self = [super initWithTMXFile:fcp.mapImgName])) {
    GameState *gs = [GameState sharedGameState];
    FullCityProto *fcp = [gs cityWithId:proto.cityId];
    
    _cityId = proto.cityId;
    
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
    
    // Add all the buildings, can't add people till after aviary placed
    NSMutableArray *peopleElems = [NSMutableArray array];
    for (NeutralCityElementProto *ncep in proto.cityElementsList) {
      if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBuilding) {
        // Add a mission building
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MissionBuilding *mb = [[MissionBuilding alloc] initWithFile:ncep.imgId location:loc map:self];
        mb.name = ncep.name;
        mb.orientation = ncep.orientation;
        [self addChild:mb z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        [mb release];
        
        [self changeTiles:mb.location canWalk:NO];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeDecoration) {
        // Decorations aren't selectable so just make a map sprite
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MapSprite *s = [[MapSprite alloc] initWithFile:ncep.imgId location:loc map:self];
        [self addChild:s z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        
        [self changeTiles:s.location canWalk:NO];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypePersonQuestGiver) {
        [peopleElems addObject:ncep];
      }
    }
    
    // Now add people, first add quest givers
    for (FullQuestProto *fqp in [gs.availableQuests allValues]) {
      if (fqp.cityId == fcp.cityId) {
        NeutralCityElementProto *ncep = nil;
        for (NeutralCityElementProto *n in peopleElems) {
          if (n.assetId == fqp.assetNumWithinCity) {
            ncep = n;
            break;
          }
        }
        [peopleElems removeObject:ncep];
        
        if (ncep) {
          CGRect r = CGRectZero;
          r.origin = [self randomWalkablePosition];
          r.size = CGSizeMake(1, 1);
          QuestGiver *qg = [[QuestGiver alloc] initWithQuest:fqp questGiverState:kAvailable file:ncep.imgId map:self location:r];
          [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
          qg.name = ncep.name;
          [qg release];
        }
      }
    }
    
    // Now add the in progress quest givers, peopleElems will hold only the non-quest givers
    for (FullQuestProto *fqp in [gs.inProgressIncompleteQuests allValues]) {
      if (fqp.cityId == fcp.cityId) {
        NeutralCityElementProto *ncep = nil;
        for (NeutralCityElementProto *n in peopleElems) {
          if (n.assetId == fqp.assetNumWithinCity) {
            ncep = n;
            break;
          }
        }
        [peopleElems removeObject:ncep];
        
        if (ncep) {
          CGRect r = CGRectZero;
          r.origin = [self randomWalkablePosition];
          r.size = CGSizeMake(1, 1);
          QuestGiver *qg = [[QuestGiver alloc] initWithQuest:fqp questGiverState:kInProgress file:ncep.imgId map:self location:r];
          [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
          qg.name = ncep.name;
          [qg release];
        } else {
          LNLog(@"%d %d", fqp.cityId, fqp.assetNumWithinCity);
        }
      }
    }
    
    // Finally add the completed quest givers
    for (FullQuestProto *fqp in [gs.inProgressCompleteQuests allValues]) {
      if (fqp.cityId == fcp.cityId) {
        NeutralCityElementProto *ncep = nil;
        for (NeutralCityElementProto *n in peopleElems) {
          if (n.assetId == fqp.assetNumWithinCity) {
            ncep = n;
            break;
          }
        }
        [peopleElems removeObject:ncep];
        
        if (ncep) {
          CGRect r = CGRectZero;
          r.origin = [self randomWalkablePosition];
          r.size = CGSizeMake(1, 1);
          QuestGiver *qg = [[QuestGiver alloc] initWithQuest:fqp questGiverState:kCompleted file:ncep.imgId map:self location:r];
          [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
          qg.name = ncep.name;
          [qg release];
        } else {
          LNLog(@"%d %d", fqp.cityId, fqp.assetNumWithinCity);
        }
      }
    }
    
    LNLog(@"%d neutral elems left", peopleElems.count);
    // Load the rest of the people in case quest becomes available later.
    // Set alpha to 0 to they can't be seen
    for (NeutralCityElementProto *ncep in peopleElems) {
      CGRect r = CGRectZero;
      r.origin = [self randomWalkablePosition];
      r.size = CGSizeMake(1, 1);
      QuestGiver *qg = [[QuestGiver alloc] initWithQuest:nil questGiverState:kNoQuest file:ncep.imgId map:self location:r];
      [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
      qg.visible = NO;
      qg.opacity = 0.f;
      [qg release];
    }
    
    [self addEnemiesFromArray:proto.defeatTypeJobEnemiesList];
    
    [self doReorder];
    
    // Load up the full task protos
    for (NSNumber *taskId in fcp.taskIdsList) {
      FullTaskProto *ftp = [gs taskWithId:taskId.intValue];
      MissionBuilding *asset = (MissionBuilding *)[self getChildByTag:ftp.assetNumWithinCity+ASSET_TAG_BASE];
      if (asset) {
        asset.ftp = ftp;
      } else {
        LNLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    // Load up the minimum user task protos
    for (MinimumUserTaskProto *mutp in proto.userTasksInfoList) {
      FullTaskProto *ftp = [gs taskWithId:mutp.taskId];
      MissionBuilding *asset = [self assetWithId:ftp.assetNumWithinCity];
      if (asset) {
        asset.numTimesActedForTask = mutp.numTimesActed;
      } else {
        LNLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    // Just use jobs for defeat type jobs, tasks are tracked on their own
    _jobs = [[NSMutableArray alloc] init];
    
    for (FullUserQuestDataLargeProto *questData in proto.inProgressUserQuestDataInCityList) {
      FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:[NSNumber numberWithInt:questData.questId]];
      fqp = fqp ? fqp : [gs.inProgressCompleteQuests objectForKey:[NSNumber numberWithInt:questData.questId]];
      if (fqp.cityId != proto.cityId) {
        continue;
      }
      
      for (MinimumUserQuestTaskProto *taskData in questData.requiredTasksProgressList) {
        FullTaskProto *ftp = [gs taskWithId:taskData.taskId];
        MissionBuilding *mb = (MissionBuilding *)[self assetWithId:ftp.assetNumWithinCity];
        
        mb.partOfQuest = YES;
        if (questData.isComplete) {
          mb.numTimesActedForQuest = ftp.numRequiredForCompletion;
        } else {
          mb.numTimesActedForQuest = taskData.numTimesActed;
          if (mb.numTimesActedForQuest < ftp.numRequiredForCompletion) {
            [mb displayArrow];
          }
        }
      }
      
      for (MinimumUserDefeatTypeJobProto *dtData in questData.requiredDefeatTypeJobProgressList) {
        DefeatTypeJobProto *job = [gs.staticDefeatTypeJobs objectForKey:[NSNumber numberWithInt:dtData.defeatTypeJobId]];
        
        if (dtData.numDefeated  < job.numEnemiesToDefeat) {
          [self displayArrowsOnEnemies:job.typeOfEnemy];
          
          UserJob *userJob = [[UserJob alloc] initWithDefeatTypeJob:job];
          userJob.numCompleted = job.numEnemiesToDefeat;
          [_jobs addObject:userJob];
        }
      }
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    [Globals displayUIView:obMenu];
    [Globals displayUIView:summaryMenu];
    [obMenu setMissionMap:self];
    obMenu.hidden = YES;
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    
    summaryMenu.center = CGPointMake(summaryMenu.frame.size.width/2+5.f, summaryMenu.superview.frame.size.height-summaryMenu.frame.size.height/2-2.f);
    summaryMenu.alpha = 0.f;
    
    _taskProgBar = [TaskProgressBar node];
    [self addChild:_taskProgBar z:1002];
    _taskProgBar.visible = NO;
  }
  return self;
}

- (void) addEnemiesFromArray:(NSArray *)arr {
  for (FullUserProto *fup in arr) {
    CGRect r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    Enemy *enemy = [[Enemy alloc] initWithUser:fup location:r map:self];
    [self addChild:enemy z:1];
    [enemy release];
    
    enemy.opacity = 0;
    [enemy runAction:[CCFadeIn actionWithDuration:0.5f]];
  }
  [self doReorder];
}

- (void) killEnemy:(int)userId {
  for (CCNode *child in children_) {
    if ([child isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)child;
      if (enemy.user.userId == userId) {
        // Need to delay time so check has time to display
        [enemy runAction:[CCSequence actions:
                          [CCFadeOut actionWithDuration:1.5f],
                          [CCDelayTime actionWithDuration:1.5f],
                          [CCCallBlock actionWithBlock:
                           ^{
                             [enemy removeFromParentAndCleanup:YES];
                           }], nil]];
        
        // This will only actually display check if the arrow is there..
        for (UserJob *job in _jobs) {
          if (job.jobType == kDefeatTypeJob && job.numCompleted < job.total) {
            DefeatTypeJobProto *dtj = [[[GameState sharedGameState] staticDefeatTypeJobs] objectForKey:[NSNumber numberWithInt:job.jobId]];
            
            if (dtj.typeOfEnemy == enemy.user.userType || dtj.typeOfEnemy == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide) {
              [enemy displayCheck];
              job.numCompleted++;
            }
          }
        }
        [self updateEnemyQuestArrows];
        
        return;
      }
    }
  }
}

- (void) displayArrowsOnEnemies:(DefeatTypeJobProto_DefeatTypeJobEnemyType)enemyType {
  for (CCNode *child in children_) {
    if ([child isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)child;
      if (enemy.user.userType == enemyType || enemyType == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide) {
        [enemy displayArrow];
      }
    }
  }
}

- (void) updateEnemyQuestArrows {
  for (CCNode *node in children_) {
    if ([node isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)node;
      [enemy removeArrowAnimated:YES];
    }
  }
  
  for (UserJob *job in _jobs) {
    if (job.jobType == kDefeatTypeJob && job.numCompleted < job.total) {
      DefeatTypeJobProto *dtj = [[[GameState sharedGameState] staticDefeatTypeJobs] objectForKey:[NSNumber numberWithInt:job.jobId]];
      [self displayArrowsOnEnemies:dtj.typeOfEnemy];
    }
  }
}

-(void) changeTiles: (CGRect) buildBlock canWalk:(BOOL)canWalk {
  for (float i = floorf(buildBlock.origin.x); i < ceilf(buildBlock.size.width+buildBlock.origin.x); i++) {
    for (float j = floorf(buildBlock.origin.y); j < ceilf(buildBlock.size.height+buildBlock.origin.y); j++) {
      [[self.walkableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canWalk]];
    }
  }
}

- (id) assetWithId:(int)assetId {
  return [self getChildByTag:assetId+ASSET_TAG_BASE];
}

- (void) moveToAssetId:(int)a {
  [self moveToSprite:[self assetWithId:a]];
}

- (void) setPosition:(CGPoint)position {
  CGPoint oldPos = position_;
  [super setPosition:position];
  if (!obMenu.hidden) {
    CGPoint diff = ccpSub(oldPos, position_);
    diff.x *= -1;
    CGRect curRect = obMenu.frame;
    curRect.origin = ccpAdd(curRect.origin, diff);
    obMenu.frame = curRect;
  }
}

- (void) updateMissionBuildingMenu {
  if (_selected && [_selected isKindOfClass:[MissionBuilding class]]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    [Globals setFrameForView:obMenu forPoint:pt];
    obMenu.hidden = NO;
  } else {
    obMenu.hidden = YES;
  }
}

- (void) performCurrentTask {
  if ([_selected isKindOfClass:[MissionBuilding class]]) {
    MissionBuilding *mb = (MissionBuilding *)_selected;
    FullTaskProto *ftp = mb.ftp;
    GameState *gs = [GameState sharedGameState];
    
    // Perform checks
    if (gs.currentEnergy < ftp.energyCost) {
      // Not enough energy
      [[RefillMenuController sharedRefillMenuController] displayEnstView:YES];
      [Analytics notEnoughEnergyForTasks:ftp.taskId];
      self.selected = nil;
    } else {
      NSMutableArray *arr = [NSMutableArray array];
      for (FullTaskProto_FullTaskEquipReqProto *equipReq in ftp.equipReqsList) {
        UserEquip *ue = [gs myEquipWithId:equipReq.equipId];
        if (!ue || ue.quantity < equipReq.quantity) {
          [arr addObject:[NSNumber numberWithInt:equipReq.equipId]];
        }
      }
      
      if (arr.count > 0) {
        [[RefillMenuController sharedRefillMenuController] displayEquipsView:arr];
        [Analytics notEnoughEquipsForTasks:ftp.taskId equipReqs:arr];
        self.selected = nil;
      } else {
        int numTimesActed = mb.partOfQuest ? mb.numTimesActedForQuest : mb.numTimesActedForTask;
        BOOL success = [[OutgoingEventController sharedOutgoingEventController] taskAction:ftp.taskId curTimesActed:numTimesActed];
        
        if (success) {
          _taskProgBar.position = ccp(mb.position.x, mb.position.y+mb.contentSize.height);
          [_taskProgBar animateBarWithText:ftp.processingText];
          _taskProgBar.visible = YES;
          mb.numTimesActedForTask = MIN(mb.numTimesActedForTask+1, ftp.numRequiredForCompletion);
          mb.numTimesActedForQuest = MIN(mb.numTimesActedForQuest+1, ftp.numRequiredForCompletion);
          _receivedTaskActionResponse = NO;
          _performingTask = YES;
        }
      }
    }
    [self closeMenus];
  }
}

- (void) receivedTaskResponse:(TaskActionResponseProto *)tarp {
  MissionBuilding *mb = (MissionBuilding *)_selected;
  FullTaskProto *ftp = mb.ftp;
  
  CCLabelTTF *expLabel =  [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d Exp.", ftp.expGained] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:expLabel z:1003];
  expLabel.position = ccp(_taskProgBar.position.x, _taskProgBar.position.y+_taskProgBar.contentSize.height);
  expLabel.color = ccc3(255,200,0);
  [expLabel runAction:[CCSequence actions:
                       [CCSpawn actions:
                        [CCFadeOut actionWithDuration:EXP_LABEL_DURATION], 
                        [CCMoveBy actionWithDuration:EXP_LABEL_DURATION position:ccp(0,40)],nil],
                       [CCCallBlock actionWithBlock:^{[expLabel removeFromParentAndCleanup:YES];}], nil]];
  
  [self addSilverDrop:tarp.coinsGained fromSprite:_selected];
  
  if (tarp.hasLootEquipId) {
    [self addEquipDrop:tarp.lootEquipId fromSprite:_selected];
  }
  
  _receivedTaskActionResponse = YES;
  
  if (!_taskProgBar.isAnimating) {
    _taskProgBar.visible = NO;
    self.selected = nil;
    _performingTask = NO;
  }
}

- (void) taskBarAnimDone {
  if (_receivedTaskActionResponse) {
    _taskProgBar.visible = NO;
    
    MissionBuilding *mb = (MissionBuilding *)_selected;
    FullTaskProto *ftp = mb.ftp;
    if (mb.partOfQuest && mb.numTimesActedForQuest >= ftp.numRequiredForCompletion) {
      [mb displayCheck];
    }
    self.selected = nil;
    
    _performingTask = NO;
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  if ([_selected isKindOfClass:[MissionBuilding class]] && selected == nil) {
    [[TopBar sharedTopBar] fadeOutToolTip:NO];
  }
  [super setSelected:selected];
  if (_selected && [_selected isKindOfClass:[MissionBuilding class]]) {
    MissionBuilding *mb = (MissionBuilding *)_selected;
    [summaryMenu updateLabelsForTask:mb.ftp name:mb.name];
    
    int numTimesActed = mb.partOfQuest ? mb.numTimesActedForQuest : mb.numTimesActedForTask;
    [obMenu updateMenuForTotal:mb.ftp.numRequiredForCompletion numTimesActed:numTimesActed isForQuest:mb.partOfQuest];
    
    [self doMenuAnimations];
    [[TopBar sharedTopBar] fadeInLittleToolTip:YES];
  } else {
    [self closeMenus];
  }
}

- (void) doMenuAnimations {
  summaryMenu.alpha = 0.f;
  
  [self updateMissionBuildingMenu];
  obMenu.alpha = 0.f;
  
  [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
    summaryMenu.alpha = 1.f;
    obMenu.alpha = 1.f;
  }];
}

- (void) closeMenus {
  [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
    summaryMenu.alpha = 0.f;
    obMenu.alpha = 0.f;
  } completion:^(BOOL finished) {
    if (finished) {
      [self updateMissionBuildingMenu];
    }
  }];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  if (_performingTask) {
    return;
  }
  
  SelectableSprite *oldSelected = _selected;
  [super tap:recognizer node:node];
  if (oldSelected == _selected && [_selected isKindOfClass:[MissionBuilding class]]) {
    [self performCurrentTask];
    return;
  }
}

- (void) drag:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  
  // During drag, take out menus
  if([recognizer state] == UIGestureRecognizerStateBegan ) {
    self.obMenu.hidden = YES;
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    [self updateMissionBuildingMenu];
  }
  self.selected = nil;
  [super drag:recognizer node:node];
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
  [self updateMissionBuildingMenu];
}

- (void) questAccepted:(FullQuestProto *)fqp {
  QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
  qg.questGiverState = kInProgress;
  
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *num in fqp.taskReqsList) {
    FullTaskProto *task = [gs taskWithId:num.intValue];
    MissionBuilding *mb = (MissionBuilding *)[self assetWithId:task.assetNumWithinCity];
    mb.numTimesActedForQuest = 0;
    mb.partOfQuest = YES;
    [mb displayArrow];
  }
  
  for (NSNumber *num in fqp.defeatTypeReqsList) {
    DefeatTypeJobProto *dtj = [gs.staticDefeatTypeJobs objectForKey:num];
    UserJob *job = [[UserJob alloc] initWithDefeatTypeJob:dtj];
    job.numCompleted = 0;
    
    [_jobs addObject:job];
  }
  [self updateEnemyQuestArrows];
//  [self reloadQuestGivers];
}

- (void) questRedeemed:(FullQuestProto *)fqp {
  QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
  qg.questGiverState = kNoQuest;
  
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *num in fqp.taskReqsList) {
    FullTaskProto *task = [gs taskWithId:num.intValue];
    MissionBuilding *mb = (MissionBuilding *)[self assetWithId:task.assetNumWithinCity];
    mb.partOfQuest = NO;
  }
  
  for (NSNumber *num in fqp.defeatTypeReqsList) {
    for (UserJob *job in _jobs) {
      if (job.jobType == kDefeatTypeJob && job.jobId == num.intValue) {
        [_jobs removeObject:job];
      }
    }
  }
  
  [self updateEnemyQuestArrows];
//  [self reloadQuestGivers];
}

- (void) reloadQuestGivers {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  
  for (FullQuestProto *fqp in [gs.availableQuests allValues]) {
    if (fqp.cityId == _cityId) {
      QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
      qg.quest = fqp;
      qg.questGiverState = kAvailable;
      qg.visible = YES;
      if (qg.opacity == 0) {
        [qg runAction:[CCFadeIn actionWithDuration:0.1f]];
      }
      [arr addObject:qg];
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressIncompleteQuests allValues]) {
    if (fqp.cityId == _cityId) {
      QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
      qg.quest = fqp;
      qg.questGiverState = kInProgress;
      qg.visible = YES;
      if (qg.opacity == 0) {
        [qg runAction:[CCFadeIn actionWithDuration:0.1f]];
      }
      [arr addObject:qg];
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressCompleteQuests allValues]) {
    if (fqp.cityId == _cityId) {
      QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
      qg.quest = fqp;
      qg.questGiverState = kCompleted;
      qg.visible = YES;
      if (qg.opacity == 0) {
        [qg runAction:[CCFadeIn actionWithDuration:0.1f]];
      }
      [arr addObject:qg];
    }
  }
  
  for (CCNode *node in children_) {
    if ([node isKindOfClass:[QuestGiver class]]) {
      QuestGiver *qg = (QuestGiver *)node;
      if (![arr containsObject:qg]) {
        qg.quest = nil;
        if (qg.opacity != 0) {
          [qg runAction:[CCFadeOut actionWithDuration:0.1f]];
        }
      }
    }
  }
  
  [arr release];
}

- (void) dealloc {
  [_jobs release];
  [summaryMenu removeFromSuperview];
  self.summaryMenu = nil;
  [obMenu removeFromSuperview];
  self.obMenu = nil;
  [super dealloc];
}

@end
