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
#import "BossEventMenuController.h"
#import <AudioToolbox/AudioServices.h>
#import "Drops.h"
#import "CityRankupViewController.h"

#define LAST_BOSS_RESET_STAMINA_TIME_KEY @"Last boss reset stamina time key"

#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define SUMMARY_MENU_ANIMATION_DURATION 0.3f

#define TASK_BAR_DURATION 2.f
#define EXP_LABEL_DURATION 3.f

#define DROP_SPACE 40.f

#define SHAKE_SCREEN_ACTION_TAG 50

#define DRAGON_TAG 5456

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
  GameState *gs = [GameState sharedGameState];
  FullCityProto *fcp = [gs cityWithId:proto.cityId];
  if ((self = [super initWithTMXFile:fcp.mapImgName])) {
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
    for (NeutralCityElementProto *ncep in proto.cityElementsList) {
      if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBuilding) {
        // Add a mission building
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MissionBuilding *mb = [[MissionBuilding alloc] initWithFile:ncep.imgId location:loc map:self];
        if (!mb) continue;
        mb.name = ncep.name;
        mb.orientation = ncep.orientation;
        [self addChild:mb z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        [mb release];
        
        [self changeTiles:mb.location canWalk:NO];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeDecoration) {
        // Decorations aren't selectable so just make a map sprite
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MapSprite *s = [[MapSprite alloc] initWithFile:ncep.imgId location:loc map:self];
        if (!s) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:s z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        
        [self changeTiles:s.location canWalk:NO];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypePersonQuestGiver) {
        CGRect r = CGRectZero;
        r.origin = [self randomWalkablePosition];
        r.size = CGSizeMake(1, 1);
        QuestGiver *qg = [[QuestGiver alloc] initWithQuest:nil questGiverState:kNoQuest file:ncep.imgId map:self location:r];
        if (!qg) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        qg.name = ncep.name;
        [qg release];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypePersonNeutralEnemy) {
        CGRect r = CGRectZero;
        r.origin = [self randomWalkablePosition];
        r.size = CGSizeMake(1, 1);
        NeutralEnemy *ne = [[NeutralEnemy alloc] initWithFile:ncep.imgId location:r map:self];
        if (!ne) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:ne z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        ne.name = ncep.name;
        [ne release];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBoss) {
        CGRect r = CGRectZero;
        r.origin = [self randomWalkablePosition];
        r.size = CGSizeMake(1, 1);
        BossSprite *bs = [[BossSprite alloc] initWithFile:ncep.imgId location:r map:self];
        if (!bs) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:bs z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        bs.name = ncep.name;
        [bs release];
      }
    }
    
    [self reloadQuestGivers];
    
    [self addEnemiesFromArray:proto.defeatTypeJobEnemiesList];
    
    [self doReorder];
    
    // Load up the full task protos
    for (NSNumber *taskId in fcp.taskIdsList) {
      FullTaskProto *ftp = [gs taskWithId:taskId.intValue];
      id<TaskElement> asset = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
      if (asset) {
        asset.ftp = ftp;
      } else {
        ContextLogError(LN_CONTEXT_MAP, @"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    // Load up the minimum user task protos
    for (MinimumUserTaskProto *mutp in proto.userTasksInfoList) {
      FullTaskProto *ftp = [gs taskWithId:mutp.taskId];
      id<TaskElement> asset = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
      if (asset) {
        asset.numTimesActedForTask = mutp.numTimesActed;
      } else {
        ContextLogError(LN_CONTEXT_MAP, @"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    // Same for bosses
    for (NSNumber *bossId in fcp.bossIdsList) {
      FullBossProto *fbp = [gs bossWithId:bossId.intValue];
      BossSprite *asset = (BossSprite *)[self assetWithId:fbp.assetNumWithinCity];
      if (asset) {
        asset.fbp = fbp;
      } else {
        ContextLogError(LN_CONTEXT_MAP, @"Could not find asset number %d.", fbp.assetNumWithinCity);
      }
    }
    
    for (FullUserBossProto *ub in proto.userBossesList) {
      FullBossProto *fbp = [gs bossWithId:ub.bossId];
      BossSprite *asset = (BossSprite *)[self assetWithId:fbp.assetNumWithinCity];
      if (asset) {
        asset.ub = [UserBoss userBossWithFullUserBossProto:ub];
        asset.ub.delegate = self;
        [asset.ub createTimer];
      } else {
        ContextLogError(LN_CONTEXT_MAP, @"Could not find asset number %d.", fbp.assetNumWithinCity);
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
      
      for (NSNumber *taskNum in fqp.taskReqsList) {
        int taskId = taskNum.intValue;
        FullTaskProto *ftp = [gs taskWithId:taskId];
        id<TaskElement> te = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
        
        te.partOfQuest = YES;
        
        if (questData.isComplete) {
          te.numTimesActedForQuest = ftp.numRequiredForCompletion;
        } else {
          for (MinimumUserQuestTaskProto *taskData in questData.requiredTasksProgressList) {
            if (taskData.taskId == taskId) {
              te.numTimesActedForQuest = taskData.numTimesActed;
              if (te.numTimesActedForQuest < ftp.numRequiredForCompletion) {
                [te displayArrow];
              }
            }
          }
        }
      }
      
      for (MinimumUserDefeatTypeJobProto *dtData in questData.requiredDefeatTypeJobProgressList) {
        DefeatTypeJobProto *job = [gs.staticDefeatTypeJobs objectForKey:[NSNumber numberWithInt:dtData.defeatTypeJobId]];
        
        if (job.cityId == _cityId && dtData.numDefeated  < job.numEnemiesToDefeat) {
          [self displayArrowsOnEnemies:job.typeOfEnemy];
          
          UserJob *userJob = [[UserJob alloc] initWithDefeatTypeJob:job];
          userJob.numCompleted = dtData.numDefeated;
          [_jobs addObject:userJob];
          [userJob release];
        }
      }
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"CityBossView" owner:self options:nil];
    [Globals displayUIView:obMenu];
    [Globals displayUIView:summaryMenu];
    [Globals displayUIView:self.bossView];
    [obMenu setMissionMap:self];
    obMenu.hidden = YES;
    self.bossView.hidden = YES;
    
    summaryMenu.alpha = 0.f;
    
    _taskProgBar = [TaskProgressBar node];
    [self addChild:_taskProgBar z:1002];
    _taskProgBar.visible = NO;
    
    _myPlayer.location = CGRectMake(fcp.center.x, fcp.center.y, 1, 1);
    [self moveToSprite:_myPlayer animated:NO];
    
    self.userGems = proto.myGemsList.count > 0 ? proto.myGemsList.mutableCopy : [NSMutableArray array];
    BOOL hasAllGems = YES;
    for (int i = 0; i < 5; i++) {
      BOOL hasGem = NO;
      for (UserCityGemProto *gem in self.userGems) {
        if (gem.gemId == i+1) {
          if (gem.quantity > 0) {
            hasGem = YES;
          }
        }
      }
      
      hasAllGems &= hasGem;
    }
    
    [[TopBar sharedTopBar] shouldDisplayGemsBadge:hasAllGems];
  }
  return self;
}

- (ResetStaminaView *) resetStaminaView {
  if (!_resetStaminaView) {
    [[NSBundle mainBundle] loadNibNamed:@"ResetStaminaView" owner:self options:nil];
  }
  return _resetStaminaView;
}

- (CityGemsView *) gemsView {
  if (!_gemsView) {
    [[NSBundle mainBundle] loadNibNamed:@"CityGemsView" owner:self options:nil];
  }
  return _gemsView;
}

- (BossUnlockedView *) bossUnlockedView {
  if (!_bossUnlockedView) {
    [[NSBundle mainBundle] loadNibNamed:@"BossUnlockedView" owner:self options:nil];
  }
  return _bossUnlockedView;
}

- (GemTutorialView *) tutView {
  if (!_tutView) {
    [[NSBundle mainBundle] loadNibNamed:@"GemTutorialView" owner:self options:nil];
  }
  return _tutView;
}

- (void) displayGemsView {
  [self.gemsView displayWithGems:self.userGems andCityId:_cityId];
}

- (void) addGemDrop:(int)gemId fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup {
  GemDrop *gd = [[GemDrop alloc] initWithGemId:gemId];
  [self addChild:gd z:1004];
  [gd release];
  gd.position = ccpAdd(sprite.position, ccp(0,sprite.contentSize.height/2));
  gd.scale = 0.01;
  gd.opacity = 5;
  
  
  float scale = MIN(50.f/gd.contentSize.width, 50.f/gd.contentSize.height);
  
  // Need to fade in, scale to 1, bounce in y dir, move normal in x dir
  float xPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*120-60 : pt.x-gd.position.x;
  float yPos = CGPointEqualToPoint(pt, CGPointZero) ? ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*20-10 : pt.y-gd.position.y;
  
  // -1 seconds means don't pickup, 0 seconds means default
  secondsToPickup = secondsToPickup == 0 ? PICK_UP_WAIT_TIME : secondsToPickup;
  CCDelayTime *dt = secondsToPickup > 0 ? [CCDelayTime actionWithDuration:secondsToPickup] : nil;
  [gd runAction:[CCSpawn actions:
                 [CCFadeIn actionWithDuration:0.1],
                 [CCScaleTo actionWithDuration:0.1 scale:scale],
                 [CCRotateBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION angle:DROP_ROTATION],
                 [CCSequence actions:
                  [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,40)],
                  [CCEaseBounceOut actionWithAction:
                   [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-85+yPos)]],
                  dt,
                  [CCCallFuncN actionWithTarget:self selector:@selector(pickUpGemDrop:)],
                  nil],
                 [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION position:ccp(xPos, 0)],
                 nil]];
}

- (void) pickUpGemDrop:(GemDrop *)ss {
  [ss stopAllActions];
  
  GameState *gs = [GameState sharedGameState];
  CGPoint world = [ss.parent convertToWorldSpace:ss.position];
  CityGemProto *gem = [gs gemForId:ss.gemId];
  UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:gem.gemImageName]];
  img.contentMode = UIViewContentModeScaleAspectFit;
  img.center = world;
  
  // 0.5 is added to account for position starting in center
  CGPoint offset = ccpMult(ccp(ss.contentSize.width, ss.contentSize.height), 0.5f*ss.scale);
  CGPoint worldBL = [ss.parent convertToWorldSpace:ccpSub(ss.position, offset)];
  CGPoint worldTR = [ss.parent convertToWorldSpace:ccpAdd(ss.position, offset)];
  CGSize size = CGSizeMake(worldTR.x-worldBL.x, worldTR.y-worldBL.y);
  img.frame = CGRectMake(worldBL.x, self.gemsView.frame.size.height-worldTR.y, size.width, size.height);
  
  [self removeChild:ss cleanup:YES];
  
  [self.gemsView animateGem:img withGemId:gem.gemId andGems:self.userGems andCityId:_cityId];
}

- (void) pickUpDrop:(CCNode *)drop {
  if ([drop isKindOfClass:[GemDrop class]]) {
    [self pickUpGemDrop:(GemDrop *)drop];
  } else {
    [super pickUpDrop:drop];
  }
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
  Enemy *enemy = [self enemyWithUserId:userId];
  
  if (enemy) {
    [enemy kill];
    
    // This will only actually display check if the arrow is there..
    for (UserJob *job in _jobs) {
      if (job.jobType == kDefeatTypeJob && job.numCompleted < job.total) {
        DefeatTypeJobProto *dtj = [[[GameState sharedGameState] staticDefeatTypeJobs] objectForKey:[NSNumber numberWithInt:job.jobId]];
        
        if (dtj.cityId == _cityId && (dtj.typeOfEnemy == enemy.user.userType || dtj.typeOfEnemy == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide)) {
          [enemy displayCheck];
          job.numCompleted++;
        }
      }
    }
    [self updateEnemyQuestArrows];
  }
}

- (void) displayArrowsOnEnemies:(DefeatTypeJobProto_DefeatTypeJobEnemyType)enemyType {
  for (CCNode *child in children_) {
    if ([child isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)child;
      if (enemy.user.userType == enemyType || enemyType == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide) {
        // Make sure this enemy wasn't just defeated
        if (enemy.isAlive) {
          [enemy displayArrow];
        }
      }
    }
  }
}

- (void) updateEnemyQuestArrows {
  for (CCNode *node in children_) {
    if ([node isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)node;
      [enemy removeArrowAnimated:NO];
    }
  }
  
  for (UserJob *job in _jobs) {
    if (job.jobType == kDefeatTypeJob && job.numCompleted < job.total) {
      DefeatTypeJobProto *dtj = [[[GameState sharedGameState] staticDefeatTypeJobs] objectForKey:[NSNumber numberWithInt:job.jobId]];
      
      if (dtj.cityId == _cityId) {
        [self displayArrowsOnEnemies:dtj.typeOfEnemy];
      }
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

- (void) moveToAssetId:(int)a animated:(BOOL)animated {
  [self moveToSprite:[self assetWithId:a] animated:animated];
}

- (void) updateMissionBuildingMenu {
  if (_selected && [_selected conformsToProtocol:@protocol(TaskElement)]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    [Globals setFrameForView:obMenu forPoint:pt];
    obMenu.hidden = NO;
  } else {
    obMenu.hidden = YES;
  }
}

- (void) updateBossSprite {
  if (_selected && [_selected isKindOfClass:[BossSprite class]]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    [Globals setFrameForView:self.bossView forPoint:pt];
    self.bossView.hidden = NO;
  } else {
    self.bossView.hidden = YES;
  }
}

- (void) performCurrentTask {
  if ([_selected conformsToProtocol:@protocol(TaskElement)]) {
    id<TaskElement> te = (id<TaskElement>)_selected;
    FullTaskProto *ftp = te.ftp;
    GameState *gs = [GameState sharedGameState];
    
    // Perform checks
    if (gs.currentEnergy < ftp.energyCost) {
      // Not enough energy
      [[RefillMenuController sharedRefillMenuController] displayEnstView:YES];
      [Analytics notEnoughEnergyForTasks:ftp.taskId];
      self.selected = nil;
    } else {
      NSMutableArray *arr = [NSMutableArray array];
      BOOL satisfiesReqs = YES;
      for (FullTaskProto_FullTaskEquipReqProto *equipReq in ftp.equipReqsList) {
        NSArray *myEquips = [gs myEquipsWithEquipId:equipReq.equipId];
        int i = 0;
        for (UserEquip *ue in myEquips) {
          [arr addObject:[NSNumber numberWithInt:ue.equipId]];
          [arr addObject:[NSNumber numberWithInt:ue.level]];
          [arr addObject:[NSNumber numberWithBool:YES]];
          i += pow(2, ue.level-1);
          
          if (i >= equipReq.quantity) {
            break;
          }
        }
        for (; i < equipReq.quantity; i++) {
          [arr addObject:[NSNumber numberWithInt:equipReq.equipId]];
          [arr addObject:[NSNumber numberWithInt:1]];
          [arr addObject:[NSNumber numberWithBool:NO]];
          satisfiesReqs = NO;
        }
      }
      
      if (!satisfiesReqs) {
        [[RefillMenuController sharedRefillMenuController] displayEquipsView:arr];
        [Analytics notEnoughEquipsForTasks:ftp.taskId equipReqs:arr];
        self.selected = nil;
      } else {
        BOOL success = [[OutgoingEventController sharedOutgoingEventController] taskAction:ftp.taskId curTimesActed:te.numTimesActedForTask];
        
        if (success) {
          CGPoint pt = ccp(ftp.spriteLandingCoords.x, ftp.spriteLandingCoords.y);
          CGPoint ccPt = pt;
          // Angle should be relevant to entire building, not origin
          if (ccPt.x < 0) {
            ccPt.x = -1;
          } else if (ccPt.x >= te.location.size.width) {
            ccPt.x = 1;
          } else {
            ccPt.x = 0;
          }
          
          if (ccPt.y < 0) {
            ccPt.y = -1;
          } else if (ccPt.y >= te.location.size.height) {
            ccPt.y = 1;
          } else {
            ccPt.y = 0;
          }
          ccPt = ccpSub([self convertTilePointToCCPoint:ccp(0, 0)], [self convertTilePointToCCPoint:ccPt]);
          float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccPt));
          
          _taskProgBar.position = ccp(te.position.x, te.position.y+te.contentSize.height);
          [_taskProgBar animateBarWithText:ftp.processingText];
          _taskProgBar.visible = YES;
          _receivedTaskActionResponse = NO;
          _performingTask = YES;
          
          if (ftp.animationType == AnimationTypeDragon) {
            CGRect loc = te.location;
            loc.origin.x += 6;
            loc.origin.y += 2;
            MapSprite *ms = [[MapSprite alloc] initWithFile:@"dragon.png" location:loc map:self];
            ms.isFlying = YES;
            [self addChild:ms z:1 tag:DRAGON_TAG];
            [ms release];
            
            loc = te.location;
            loc.origin.x += 6;
            loc.origin.y += 3;
            
            CGRect newLoc = te.location;
            newLoc.origin.x -= 2;
            newLoc.origin.y += 3;
            self.isTouchEnabled = NO;
            [ms runAction:[CCSequence actions:
                           [CCSpawn actions:
                            [CCFadeIn actionWithDuration:0.3f],
                            //                            [MoveToLocation actionWithDuration:1.f location:loc],
                            nil],
                           [CCCallBlock actionWithBlock:
                            ^{
                              CCParticleSystemQuad *ps = [[CCParticleSystemQuad alloc] initWithFile:@"fire.plist"];
                              [ms addChild:ps z:2];
                              ps.position = ccp(3, 7);
                              [ps release];
                            }],
                           //                           [MoveToLocation actionWithDuration:2.f location:newLoc],
                           [CCDelayTime actionWithDuration:2.f],
                           [CCFadeOut actionWithDuration:0.3f],
                           [CCCallBlock actionWithBlock:
                            ^{
                              [ms removeFromParentAndCleanup:YES];
                              self.isTouchEnabled = YES;
                            }],
                           nil]];
          } else {
            [_myPlayer stopWalking];
            [_myPlayer performAnimation:ftp.animationType atLocation:ccpAdd(te.location.origin, pt) inDirection:angle];
          }
          
          [Analytics taskExecuted:ftp.taskId];
        }
      }
    }
    [self closeMenus:_selected];
  }
}

- (void) receivedTaskResponse:(TaskActionResponseProto *)tarp {
  if (![_selected conformsToProtocol:@protocol(TaskElement)]) {
    return;
  }
  GameState *gs = [GameState sharedGameState];
  
  id<TaskElement> te = (id<TaskElement>)_selected;
  FullTaskProto *ftp = te.ftp;
  
  CCLabelTTF *expLabel =  [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d Exp.", ftp.expGained] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:expLabel z:1003];
  expLabel.position = ccp(te.position.x+te.contentSize.width/2+expLabel.contentSize.width/2, te.position.y+te.contentSize.height/2+expLabel.contentSize.height/2);
  expLabel.color = ccc3(255,200,0);
  [expLabel runAction:[CCSequence actions:
                       [CCSpawn actions:
                        [CCFadeOut actionWithDuration:EXP_LABEL_DURATION],
                        [CCMoveBy actionWithDuration:EXP_LABEL_DURATION position:ccp(0,40)],nil],
                       [CCCallBlock actionWithBlock:^{[expLabel removeFromParentAndCleanup:YES];}], nil]];
  
  CCLabelTTF *successLabel =  [CCLabelFX labelWithString:[NSString stringWithFormat:@"Success!"] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:successLabel z:1003];
  successLabel.position = ccp(expLabel.position.x, expLabel.position.y+expLabel.contentSize.height/2+successLabel.contentSize.height/2);
  successLabel.color = ccc3(255,255,255);
  [successLabel runAction:[CCSequence actions:
                           [CCSpawn actions:
                            [CCFadeOut actionWithDuration:EXP_LABEL_DURATION],
                            [CCMoveBy actionWithDuration:EXP_LABEL_DURATION position:ccp(0,40)],nil],
                           [CCCallBlock actionWithBlock:^{[successLabel removeFromParentAndCleanup:YES];}], nil]];
  
  if (tarp.hasCoinsGained) {
    [self addSilverDrop:tarp.coinsGained fromSprite:_selected toPosition:CGPointZero secondsToPickup:0];
  }
  
  if (tarp.hasEventIdOfLockBoxGained) {
    [self addLockBoxDrop:tarp.eventIdOfLockBoxGained fromSprite:_selected secondsToPickup:0];
  }
  
  if (tarp.hasLootUserEquip) {
    [self addEquipDrop:tarp.lootUserEquip.equipId fromSprite:_selected toPosition:CGPointZero secondsToPickup:0];
  }
  
  if (tarp.hasGem) {
    
    UserCityGemProto *toReplace = nil;
    for (UserCityGemProto *ug in self.userGems) {
      if (ug.gemId == tarp.gem.gemId) {
        toReplace = ug;
      }
    }
    
    if (toReplace) {
      [self.userGems replaceObjectAtIndex:[self.userGems indexOfObject:toReplace] withObject:tarp.gem];
    } else {
      [self.userGems addObject:tarp.gem];
    }
    
    if (tarp.isFirstGem) {
      [self addGemDrop:tarp.gem.gemId fromSprite:_selected toPosition:CGPointZero secondsToPickup:-1];
      [self.tutView beginGemTutorial];
    } else {
      [self addGemDrop:tarp.gem.gemId fromSprite:_selected toPosition:CGPointZero secondsToPickup:0];
    }
  }
  
  if (tarp.hasBoss) {
    GameState *gs = [GameState sharedGameState];
    FullBossProto *fbp = [gs bossWithId:tarp.boss.bossId];
    [self.bossUnlockedView displayForBoss:fbp];
    [(BossSprite *)[self assetWithId:fbp.assetNumWithinCity] setUb:[UserBoss userBossWithFullUserBossProto:tarp.boss]];
  }
  
  _receivedTaskActionResponse = YES;
  
  if (!_taskProgBar.isAnimating) {
    [self taskComplete];
  } else if (tarp.cityRankedUp) {
    [self taskComplete];
    
    UserCity *city = [gs myCityWithId:tarp.cityId];
    
    // This will be released after the view closes
    CityRankupViewController *vc = [[CityRankupViewController alloc] initWithRank:city.curRank coins:tarp.coinBonusIfCityRankup exp:tarp.expBonusIfCityRankup];
    [Globals displayUIView:vc.view];
    
    if (_cityId == 1 && city.curRank == 2) {
      [self.tutView beginRankupTutorial];
      [(UIButton *)[vc.mainView viewWithTag:30] addTarget:self.tutView action:@selector(beginBossTutorial) forControlEvents:UIControlEventTouchUpInside];
    }
  }
}

- (void) taskBarAnimDone {
  if (_receivedTaskActionResponse) {
    [self taskComplete];
  }
}

- (void) taskComplete {
  _taskProgBar.visible = NO;
  
  if ([_selected conformsToProtocol:@protocol(TaskElement)]) {
    id<TaskElement> te = (id<TaskElement>)_selected;
    FullTaskProto *ftp = te.ftp;
    if (te.partOfQuest && te.numTimesActedForQuest == ftp.numRequiredForCompletion-1) {
      [te displayCheck];
    }
    te.numTimesActedForTask = MIN(te.numTimesActedForTask+1, ftp.numRequiredForCompletion);
    te.numTimesActedForQuest = MIN(te.numTimesActedForQuest+1, ftp.numRequiredForCompletion);
    _performingTask = NO;
    
    self.selected = nil;
  } else if ([_selected isKindOfClass:[BossSprite class]]) {
    BossSprite *bs = (BossSprite *)_selected;
    _performingTask = NO;
    
    [self doMenuAnimations];
    
    if (![bs.ub isAlive]) {
      self.selected = nil;
      
      [bs runAction:
       [CCSequence actions:
        [CCFadeOut actionWithDuration:0.3f],
        [CCCallBlock actionWithBlock:
         ^{
           CGRect r = CGRectZero;
           r.origin = [self randomWalkablePosition];
           r.size = CGSizeMake(1, 1);
           bs.location = r;
           [bs walk];
         }],
        [CCFadeIn actionWithDuration:0.3f],
        nil]];
      
    }
  }
  
  [_myPlayer stopPerformingAnimation];
}

- (void) performCurrentBossAction:(BOOL)isSuperAttack {
  if ([_selected isKindOfClass:[BossSprite class]]) {
    BossSprite *bs = (BossSprite *)_selected;
    GameState *gs = [GameState sharedGameState];
    FullBossProto *fbp = [gs bossWithId:bs.ub.bossId];
    
    // Perform checks
    int energyCost = !isSuperAttack ? fbp.regularAttackEnergyCost : fbp.superAttackEnergyCost;
    if (gs.currentEnergy < energyCost) {
      // Not enough energy
      [[RefillMenuController sharedRefillMenuController] displayEnstView:YES];
      self.selected = nil;
      return;
    }
    
    [[OutgoingEventController sharedOutgoingEventController] bossAction:bs.ub isSuperAttack:isSuperAttack];
    
    CGPoint pt = arc4random() % 2 == 0 ? ccp(0, -1) : ccp(-1, 0);
    CGPoint ccPt = pt;
    // Angle should be relevant to entire building, not origin
    if (ccPt.x < 0) {
      ccPt.x = -1;
    } else if (ccPt.x >= bs.location.size.width) {
      ccPt.x = 1;
    } else {
      ccPt.x = 0;
    }
    
    if (ccPt.y < 0) {
      ccPt.y = -1;
    } else if (ccPt.y >= bs.location.size.height) {
      ccPt.y = 1;
    } else {
      ccPt.y = 0;
    }
    
    _taskProgBar.position = ccp(bs.position.x, bs.position.y+bs.contentSize.height+10);
    [_taskProgBar animateBarWithText:@"ATTACKING"];
    _taskProgBar.visible = YES;
    _receivedTaskActionResponse = NO;
    _performingTask = YES;
    
    [self closeMenus:bs];
    
    ccPt = ccpSub([self convertTilePointToCCPoint:ccp(0, 0)], [self convertTilePointToCCPoint:ccPt]);
    float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccPt));
    [_myPlayer stopWalking];
    [_myPlayer performAnimation:AnimationTypeAttack atLocation:ccpAdd(bs.location.origin, pt) inDirection:angle];
  }
}

- (void) receivedBossResponse:(BossActionResponseProto *)barp {
  if (![_selected isKindOfClass:[BossSprite class]]) {
    return;
  }
  
  BossSprite *bs = (BossSprite *)_selected;
  UserBoss *ub = bs.ub;
  
  ub.curHealth = MAX(0, ub.curHealth-barp.damageDone);
  
  GameState *gs = [GameState sharedGameState];
  [gs addToMyBosses:[NSArray arrayWithObject:ub]];
  
  CCLabelTTF *expLabel =  [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d Exp.", barp.expGained] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  expLabel.position = ccp(bs.position.x+bs.contentSize.width/2+expLabel.contentSize.width/2, bs.position.y+bs.contentSize.height/2+expLabel.contentSize.height/2);
  if (barp.expGained > 0) {
    [self addChild:expLabel z:1003];
    expLabel.color = ccc3(255,200,0);
    [expLabel runAction:[CCSequence actions:
                         [CCSpawn actions:
                          [CCFadeOut actionWithDuration:EXP_LABEL_DURATION],
                          [CCMoveBy actionWithDuration:EXP_LABEL_DURATION position:ccp(0,40)],nil],
                         [CCCallBlock actionWithBlock:^{[expLabel removeFromParentAndCleanup:YES];}], nil]];
  }
  
  CCLabelTTF *successLabel =  [CCLabelFX labelWithString:[NSString stringWithFormat:@"Success!"] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:successLabel z:1003];
  successLabel.position = ccp(expLabel.position.x, expLabel.position.y+expLabel.contentSize.height/2+successLabel.contentSize.height/2);
  successLabel.color = ccc3(255,255,255);
  [successLabel runAction:[CCSequence actions:
                           [CCSpawn actions:
                            [CCFadeOut actionWithDuration:EXP_LABEL_DURATION],
                            [CCMoveBy actionWithDuration:EXP_LABEL_DURATION position:ccp(0,40)],nil],
                           [CCCallBlock actionWithBlock:^{[successLabel removeFromParentAndCleanup:YES];}], nil]];
  
  CCLabelTTF *dmgLabel =  [CCLabelFX labelWithString:[NSString stringWithFormat:@"-%d HP", barp.damageDone] fontName:@"DINCond-Black" fontSize:30 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:dmgLabel z:1003];
  dmgLabel.position = ccp(bs.position.x, bs.position.y+bs.contentSize.height+dmgLabel.contentSize.height/2+20);
  dmgLabel.color = ccc3(255,0,0);
  dmgLabel.scale = 0.2f;
  [dmgLabel runAction:[CCSequence actions:
                       [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.3f scale:1.f]],
                       [CCSpawn actions:
                        [CCFadeOut actionWithDuration:EXP_LABEL_DURATION],
                        [CCMoveBy actionWithDuration:EXP_LABEL_DURATION position:ccp(0,40)],nil],
                       [CCCallBlock actionWithBlock:^{[dmgLabel removeFromParentAndCleanup:YES];}], nil]];
  
  for (NSNumber *n in barp.coinsGainedList) {
    self.silverOnMap += n.intValue;
  }
  for (NSNumber *n in barp.diamondsGainedList) {
    self.goldOnMap += n.intValue;
  }
  
  if (barp.isCriticalAttack) {
    CCLabelTTF *critLabel =  [CCLabelFX labelWithString:[NSString stringWithFormat:@"CRITICAL HIT!"] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
    [self addChild:critLabel z:1003];
    critLabel.position = ccp(successLabel.position.x+21, successLabel.position.y-successLabel.contentSize.height/2-critLabel.contentSize.height/2);
    critLabel.color = ccc3(156, 202, 16);
    [critLabel runAction:[CCSequence actions:
                          [CCSpawn actions:
                           [CCFadeOut actionWithDuration:EXP_LABEL_DURATION],
                           [CCMoveBy actionWithDuration:EXP_LABEL_DURATION position:ccp(0,40)],nil],
                          [CCCallBlock actionWithBlock:^{[critLabel removeFromParentAndCleanup:YES];}], nil]];
    
    [self shakeScreen];
  }

  _receivedTaskActionResponse = YES;
  
  if (!_taskProgBar.isAnimating) {
    [self taskComplete];
  }
  
  [self dropItems:barp fromSprite:bs];
  
  [self.bossView updateForUserBoss:bs.ub];
  
  //  NSMethodSignature* sig = [[self class]
  //                            instanceMethodSignatureForSelector:@selector(bossActionComplete:)];
  //  NSInvocation* invocation = [NSInvocation
  //                              invocationWithMethodSignature:sig];
  //  [invocation setTarget:self];
  //  [invocation setSelector:@selector(bossActionComplete:)];
  //  [invocation setArgument:&barp atIndex:2];
  //  [invocation retainArguments];
  //  [bs animateBarWithCallback:invocation];
}

- (void) bossTimeUp:(UserBoss *)boss {
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:boss.bossId];
  BossSprite *bs = (BossSprite *)[self assetWithId:fbp.assetNumWithinCity];
  
  if ([bs isKindOfClass:[BossSprite class]]) {
    if (bs == _selected) {
      self.selected = nil;
    }
    
    [self resetPowerAttack];
  }
}

- (void) bossRespawned:(UserBoss *)boss {
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:boss.bossId];
  BossSprite *bs = (BossSprite *)[self assetWithId:fbp.assetNumWithinCity];
  
  CGRect r = CGRectZero;
  r.origin = [self randomWalkablePosition];
  r.size = CGSizeMake(1, 1);
  bs.location = r;
  
  // Update the health bar
  bs.ub = boss;
  
  [bs runAction:[CCFadeIn actionWithDuration:0.3f]];
  
  [self resetPowerAttack];
}

- (void) bossActionComplete:(BossActionResponseProto *)barp {
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:barp.bossId];
  BossSprite *bs = (BossSprite *)[self assetWithId:fbp.assetNumWithinCity];
  UserBoss *ub = bs.ub;
  
  [self stopActionByTag:SHAKE_SCREEN_ACTION_TAG];
  
  if (ub.curHealth == 0) {
    [ub createTimer];
    
    [self dropItems:barp fromSprite:bs];
    
    [self resetPowerAttack];
  } else {
    [self incrementPowerAttack];
  }
}

- (void) shakeScreen {
  int x = (arc4random_uniform(4)+4)*(arc4random_uniform(2)?-1:1);
  int y = (arc4random_uniform(2)+2)*(arc4random_uniform(2)?-1:1);
  CCMoveBy *m = [CCMoveBy actionWithDuration:0.01 position:ccp(x,y)];
  CCRepeat *a = [CCRepeat actionWithAction:[CCSequence actions:m.copy, m.reverse, m.reverse, m.copy, nil] times:10];
  a.tag = SHAKE_SCREEN_ACTION_TAG;
  [self runAction:a];
  
//  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void) dropItems:(BossActionResponseProto *)barp fromSprite:(MapSprite *)sprite {
  NSMutableArray *allItems = [NSMutableArray array];
  for (NSNumber *num in barp.coinsGainedList) {
    BossReward *r = [[BossReward alloc] init];
    r.type = kSilverDrop;
    r.value = num.intValue;
    [allItems addObject:r];
    [r release];
  }
  for (NSNumber *num in barp.diamondsGainedList) {
    BossReward *r = [[BossReward alloc] init];
    r.type = kGoldDrop;
    r.value = num.intValue;
    [allItems addObject:r];
    [r release];
  }
  for (FullUserEquipProto *fuep in barp.lootUserEquipList) {
    BossReward *r = [[BossReward alloc] init];
    r.type = kEquipDrop;
    r.value = fuep.equipId;
    [allItems addObject:r];
    [r release];
  }
  
  //Randomize array
  for(int i = allItems.count; i > 1; i--) {
    NSUInteger j = arc4random_uniform(i);
    [allItems exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
  }
  
  NSMutableArray *actions = [NSMutableArray array];
  [actions addObject:[CCDelayTime actionWithDuration:0.01f]];
  
  float y = sprite.position.y+30.f;
  float x = sprite.position.x-allItems.count/2.f*DROP_SPACE;
  int secondsToPickup = 5;
  for (BossReward *r in allItems) {
    CCCallBlock *c = [CCCallBlock actionWithBlock:^{
      // Must decrement silver/gold on map because it was already added
      if (r.type == kSilverDrop) {
        [self addSilverDrop:r.value fromSprite:sprite toPosition:ccp(x,y) secondsToPickup:secondsToPickup];
        self.silverOnMap -= r.value;
      } else if (r.type == kGoldDrop) {
        [self addGoldDrop:r.value fromSprite:sprite toPosition:ccp(x,y) secondsToPickup:secondsToPickup];
        self.goldOnMap -= r.value;
      } else {
        [self addEquipDrop:r.value fromSprite:sprite toPosition:ccp(x,y) secondsToPickup:secondsToPickup];
      }
    }];
    [actions addObject:c];
    [actions addObject:[CCDelayTime actionWithDuration:0.1f]];
    
    x += DROP_SPACE;
  }
  
  if (barp.hasGemDropped) {
    CCCallBlock *c = [CCCallBlock actionWithBlock:^{
      if (barp.isFirstGem) {
        [self addGemDrop:barp.gemDropped.gemId fromSprite:sprite toPosition:ccp(x,y) secondsToPickup:-1];
        [self.tutView beginGemTutorial];
      } else {
        [self addGemDrop:barp.gemDropped.gemId fromSprite:sprite toPosition:ccp(x,y) secondsToPickup:secondsToPickup];
      }
    }];
    [actions addObject:c];
    [actions addObject:[CCDelayTime actionWithDuration:0.1f]];
    
    UserCityGemProto *toReplace = nil;
    for (UserCityGemProto *ug in self.userGems) {
      if (ug.gemId == barp.gemDropped.gemId) {
        toReplace = ug;
      }
    }
    
    if (toReplace) {
      [self.userGems replaceObjectAtIndex:[self.userGems indexOfObject:toReplace] withObject:barp.gemDropped];
    } else {
      [self.userGems addObject:barp.gemDropped];
    }
  }
  
  [self runAction:[CCSequence actionsWithArray:actions]];
}

- (void) incrementPowerAttack {
  _curPowerAttack++;
  
  Globals *gl = [Globals sharedGlobals];
  if (_curPowerAttack > gl.bossNumAttacksTillSuperAttack) {
    _curPowerAttack = 0;
  }
  
  [_powerAttackBar runAction:[CCProgressTo actionWithDuration:0.5f percent:(float)_curPowerAttack/gl.bossNumAttacksTillSuperAttack*100]];
  
  _powerAttackLabel.string = [NSString stringWithFormat:@"%d/%d", _curPowerAttack, gl.bossNumAttacksTillSuperAttack];
}

- (void) resetPowerAttack {
  _curPowerAttack = -1;
  [self incrementPowerAttack];
}

- (void) setSelected:(SelectableSprite *)selected {
  SelectableSprite *oldSelected = _selected;
  if ([_selected conformsToProtocol:@protocol(TaskElement)] && selected == nil) {
    [[TopBar sharedTopBar] fadeOutToolTip:NO];
  } else if ([_selected isKindOfClass:[BossSprite class]]) {
    [[TopBar sharedTopBar] fadeOutToolTip:NO];
  }
  [super setSelected:selected];
  if (_selected) {
    if ([_selected conformsToProtocol:@protocol(TaskElement)]) {
      
      id<TaskElement> te = (id<TaskElement>)_selected;
      [summaryMenu updateLabelsForTask:te.ftp name:te.name];
      
      int numTimesActed = te.partOfQuest ? te.numTimesActedForQuest : te.numTimesActedForTask;
      [obMenu updateMenuForTotal:te.ftp.numRequiredForCompletion numTimesActed:numTimesActed isForQuest:te.partOfQuest];
      
      [self doMenuAnimations];
      [[TopBar sharedTopBar] fadeInLittleToolTip:YES];
    } else if ([_selected isKindOfClass:[BossSprite class]]) {
      float dur = [self moveToSprite:_selected animated:YES withOffset:ccp(0, -50)];
      
      [self performSelector:@selector(doMenuAnimations) withObject:nil afterDelay:dur+0.2f];
      [[TopBar sharedTopBar] fadeInLittleToolTip:YES];
      
      BossSprite *bs = (BossSprite *)_selected;
      [self.bossView updateForUserBoss:bs.ub];
    }
  } else {
    [self closeMenus:oldSelected];
  }
}

- (void) doMenuAnimations {
  if ([_selected conformsToProtocol:@protocol(TaskElement)]) {
    [self updateMissionBuildingMenu];
    
    [[TopBar sharedTopBar] fadeInMenuOverChatView:summaryMenu];
    
    [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
      obMenu.alpha = 1.f;
    }];
  } else if ([_selected isKindOfClass:[BossSprite class]]) {
    [self updateBossSprite];
    
    [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
      self.bossView.alpha = 1.f;
    }];
    
    BossSprite *bs = (BossSprite *)_selected;
    [bs.bossMenu runAction:[RecursiveFadeTo actionWithDuration:SUMMARY_MENU_ANIMATION_DURATION opacity:0]];
  }
}

- (void) closeMenus:(SelectableSprite *)selected {
  if ([selected conformsToProtocol:@protocol(TaskElement)]) {
    [[TopBar sharedTopBar] fadeOutMenuOverChatView:summaryMenu];
    [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
      obMenu.alpha = 0.f;
    } completion:^(BOOL finished) {
      if (finished) {
        [self updateMissionBuildingMenu];
      }
    }];
  } else if ([selected isKindOfClass:[BossSprite class]]) {
    [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
      self.bossView.alpha = 0.f;
    } completion:^(BOOL finished) {
      if (finished) {
        [self updateBossSprite];
      }
    }];
    
    // If currently, nothing is selected, put the boss menu back up
    if (!_selected) {
      BossSprite *bs = (BossSprite *)selected;
      [bs.bossMenu runAction:[RecursiveFadeTo actionWithDuration:SUMMARY_MENU_ANIMATION_DURATION opacity:255]];
    }
  }
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  SelectableSprite *ss = [super selectableForPt:pt];
  if ([ss isKindOfClass:[BossSprite class]]) {
    BossSprite *bs = (BossSprite *)ss;
    
    if (![bs.ub isAlive]) {
      [Globals popupMessage:@"Complete all the city tasks to unlock the boss."];
      return nil;
    }
  }
  return ss;
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  if (_performingTask) {
    return;
  }
  
  SelectableSprite *oldSelected = _selected;
  [super tap:recognizer node:node];
  if (oldSelected == _selected && [_selected conformsToProtocol:@protocol(TaskElement)]) {
    [self performCurrentTask];
    return;
  }
}

- (IBAction)bossAttackClicked:(UIView *)sender {
  if (!_performingTask && [_selected isKindOfClass:[BossSprite class]]) {
    BOOL isSuperAttack = sender.tag == 2;
    [self performCurrentBossAction:isSuperAttack];
  }
}

- (void) drag:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  // During drag, take out menus
  if([recognizer state] == UIGestureRecognizerStateBegan ) {
    self.obMenu.hidden = YES;
    self.bossView.hidden = YES;
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    [self updateMissionBuildingMenu];
    [self updateBossSprite];
  }
  
  if (!_performingTask) {
    self.selected = nil;
  }
  [super drag:recognizer node:node];
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
  [self updateMissionBuildingMenu];
  [self updateBossSprite];
}

- (void) questAccepted:(FullQuestProto *)fqp {
  QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
  if ([qg isKindOfClass:[QuestGiver class]]) {
    qg.quest = fqp;
    qg.questGiverState = kInProgress;
  }
  
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *num in fqp.taskReqsList) {
    FullTaskProto *task = [gs taskWithId:num.intValue];
    id<TaskElement> te = (id<TaskElement>)[self assetWithId:task.assetNumWithinCity];
    te.numTimesActedForQuest = 0;
    te.partOfQuest = YES;
    [te displayArrow];
  }
  
  for (NSNumber *num in fqp.defeatTypeReqsList) {
    DefeatTypeJobProto *dtj = [gs.staticDefeatTypeJobs objectForKey:num];
    UserJob *job = [[UserJob alloc] initWithDefeatTypeJob:dtj];
    job.numCompleted = 0;
    
    [_jobs addObject:job];
    [job release];
  }
  [self updateEnemyQuestArrows];
}

- (void) questRedeemed:(FullQuestProto *)fqp {
  QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
  if ([qg isKindOfClass:[QuestGiver class]]) {
    qg.quest = nil;
    qg.questGiverState = kNoQuest;
  }
  
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *num in fqp.taskReqsList) {
    FullTaskProto *task = [gs taskWithId:num.intValue];
    id<TaskElement> te = (id<TaskElement>)[self assetWithId:task.assetNumWithinCity];
    [te removeArrowAnimated:NO];
    te.partOfQuest = NO;
  }
  
  for (NSNumber *num in fqp.defeatTypeReqsList) {
    UserJob *toDel = nil;
    for (UserJob *job in _jobs) {
      if (job.jobType == kDefeatTypeJob && job.jobId == num.intValue) {
        toDel = job;
      }
    }
    [_jobs removeObject:toDel];
  }
  
  [self updateEnemyQuestArrows];
}

- (void) reloadQuestGivers {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  
  for (FullQuestProto *fqp in [gs.availableQuests allValues]) {
    if (fqp.cityId == _cityId) {
      CCNode *node = [self assetWithId:fqp.assetNumWithinCity];
      if ([node isKindOfClass:[QuestGiver class]]) {
        QuestGiver *qg = (QuestGiver *)node;
        qg.quest = fqp;
        qg.questGiverState = kAvailable;
        [arr addObject:qg];
      } else {
        LNLog(@"Asset num %d for quest %d is not a quest giver", fqp.assetNumWithinCity, fqp.questId);
      }
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressIncompleteQuests allValues]) {
    if (fqp.cityId == _cityId) {
      CCNode *node = [self assetWithId:fqp.assetNumWithinCity];
      if ([node isKindOfClass:[QuestGiver class]]) {
        QuestGiver *qg = (QuestGiver *)node;
        qg.quest = fqp;
        qg.questGiverState = kInProgress;
        [arr addObject:qg];
      } else {
        LNLog(@"Asset num %d for quest %d is not a quest giver", fqp.assetNumWithinCity, fqp.questId);
      }
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressCompleteQuests allValues]) {
    if (fqp.cityId == _cityId) {
      CCNode *node = [self assetWithId:fqp.assetNumWithinCity];
      if ([node isKindOfClass:[QuestGiver class]]) {
        QuestGiver *qg = (QuestGiver *)node;
        qg.quest = fqp;
        qg.questGiverState = kCompleted;
        [arr addObject:qg];
      } else {
        LNLog(@"Asset num %d for quest %d is not a quest giver", fqp.assetNumWithinCity, fqp.questId);
      }
    }
  }
  
  for (CCNode *node in children_) {
    if ([node isKindOfClass:[QuestGiver class]]) {
      QuestGiver *qg = (QuestGiver *)node;
      if (![arr containsObject:qg]) {
        qg.quest = nil;
        qg.questGiverState = kNoQuest;
      }
    }
  }
  
  [arr release];
}

- (void) receivedRedeemGemsResponse:(RedeemUserCityGemsResponseProto *)proto {
  if (proto.status == RedeemUserCityGemsResponseProto_RedeemUserCityGemsStatusSuccess) {
    for (int i = 0; i < self.userGems.count; i++) {
      UserCityGemProto_Builder *b = [UserCityGemProto builderWithPrototype:[self.userGems objectAtIndex:i]];
      b.quantity--;
      [self.userGems replaceObjectAtIndex:i withObject:b.build];
    }
    
    [self.gemsView receivedRedeemGemsResponse:proto withUpdatedGems:self.userGems];
  }
}

- (void) onEnter {
  [super onEnter];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (!gs.isTutorial) {
    FullCityProto *fcp = [gs cityWithId:_cityId];
    // Schedule timer if there is a boss
    if (fcp.bossIdsList.count > 0) {
      //      _bossTimeLabel = [CCLabelFX labelWithString:@"" fontName:@"Trajan Pro" fontSize:16.f shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
      //      _bossTimeLabel.color = ccc3(236, 230, 195);
      //      [self.parent addChild:_bossTimeLabel z:1000];
      //      _bossTimeLabel.position = ccp(self.parent.contentSize.width/2, 63.f);
      //
      //      CCMenuItem *m = [CCMenuItemImage itemFromNormalImage:@"bossinfo.png" selectedImage:nil target:self selector:@selector(bossInfoClicked)];
      //      _infoMenu = [CCMenu menuWithItems:m, nil];
      //      [_bossTimeLabel addChild:_infoMenu];
      //      [self updateBossLabel];
      //      [self schedule:@selector(updateBossLabel) interval:1];
      //
      //      _powerAttackBgd = [CCSprite spriteWithFile:@"superattackbg.png"];
      //      [self.parent addChild:_powerAttackBgd z:1];
      //      _powerAttackBgd.position = ccp(5+_powerAttackBgd.contentSize.width/2, _bossTimeLabel.position.y+3.f);
      //
      //      _powerAttackBar = [CCProgressTimer progressWithFile:@"superattackpurple.png"];
      //      _powerAttackBar.type = kCCProgressTimerTypeHorizontalBarLR;
      //      _powerAttackBar.percentage = 0;
      //      [_powerAttackBgd addChild:_powerAttackBar];
      //      _powerAttackBar.position = ccp(_powerAttackBgd.contentSize.width/2, _powerAttackBgd.contentSize.height/2);
      //
      //      _powerAttackLabel = [CCLabelFX labelWithString:@"0/5" fontName:[Globals font] fontSize:13.f shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f shadowColor:ccc4(0,0,0,50) fillColor:ccc4(236, 230, 195, 255)];
      //      [_powerAttackBgd addChild:_powerAttackLabel];
      //      _powerAttackLabel.position = ccpAdd(_powerAttackBar.position, ccp(0,-3));
      //
      //      CCLabelFX *superAttackLabel = [CCLabelFX labelWithString:@"Power Attack" fontName:@"Trajan Pro" fontSize:13.f shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
      //      superAttackLabel.color = ccc3(236, 230, 195);
      //      [_powerAttackBgd addChild:superAttackLabel z:1000];
      //      superAttackLabel.position = ccp(_powerAttackBgd.contentSize.width/2, _powerAttackBgd.contentSize.height/2+superAttackLabel.contentSize.height/2+5);
      
      // So we can increment it
      [self resetPowerAttack];
      
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSDate *curDate = [NSDate date];
      NSDate *date = [defaults objectForKey:LAST_BOSS_RESET_STAMINA_TIME_KEY];
      NSDate *nextShowDate = [date dateByAddingTimeInterval:3600*24];
      if (!date || [nextShowDate compare:curDate] == NSOrderedAscending) {
        int percent = [gl percentOfSkillPointsInStamina];
        if (percent < 75) {
          //          [self.resetStaminaView display];
          [defaults setObject:curDate forKey:LAST_BOSS_RESET_STAMINA_TIME_KEY];
        }
      }
    }
  }
}

- (void) bossInfoClicked {
  [BossEventMenuController displayView];
}

- (void) onExit {
  [super onExit];
  [_bossTimeLabel removeFromParentAndCleanup:YES];
  _bossTimeLabel = nil;
  [_powerAttackBgd removeFromParentAndCleanup:YES];
  _powerAttackBgd = nil;
  _powerAttackBar = nil;
  _powerAttackLabel = nil;
  _infoMenu = nil;
}

- (void) dealloc {
  [_jobs release];
  [summaryMenu removeFromSuperview];
  self.summaryMenu = nil;
  [obMenu removeFromSuperview];
  self.obMenu = nil;
  [self.bossUnlockedView removeFromSuperview];
  self.bossUnlockedView = nil;
  [self.gemsView removeFromSuperview];
  self.gemsView = nil;
  [self.bossView removeFromSuperview];
  self.bossView = nil;
  self.resetStaminaView = nil;
  [super dealloc];
}

@end
