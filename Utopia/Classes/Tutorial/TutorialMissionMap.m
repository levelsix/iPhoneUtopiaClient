//
//  TutorialMissionMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialMissionMap.h"
#import "GameState.h"
#import "Globals.h"
#import "TutorialConstants.h"
#import "AnimatedSprite.h"
#import "TutorialQuestLogController.h"
#import "TutorialBattleLayer.h"
#import "LNSynthesizeSingleton.h"
#import "LevelUpViewController.h"
#import "TutorialProfileViewController.h"
#import "DialogMenuController.h"
#import "GameLayer.h"
#import "TutorialTopBar.h"
#import "TutorialMyPlayer.h"

#define ENEMY_TAG 100

@implementation TutorialMissionMap

SYNTHESIZE_SINGLETON_FOR_CLASS(TutorialMissionMap);

- (id) init {
  if ((self = [super initWithTMXFile:@"KirinVillage.tmx"])) {
    GameState *gs = [GameState sharedGameState];
    
    _cityId = 1;
    
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
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    NSArray *elems = [Globals userTypeIsGood:gs.type] ? tc.firstCityElementsForGood : tc.firstCityElementsForBad;
    NSMutableArray *peopleElems = [NSMutableArray array];
    for (NeutralCityElementProto *ncep in elems) {
      if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBuilding) {
        // Add a mission building
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MissionBuilding *mb = [[MissionBuilding alloc] initWithFile:ncep.imgId location:loc map:self];
        mb.name = ncep.name;
        mb.orientation = ncep.orientation;
        mb.partOfQuest = YES;
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
      }
    }
    
    // Now add people, first add quest givers
    StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = tc.tutorialQuest;
    NeutralCityElementProto *ncep = nil;
    for (NeutralCityElementProto *n in peopleElems) {
      if (n.assetId == tutQuest.assetNumWithinCity) {
        ncep = n;
        break;
      }
    }
    [peopleElems removeObject:ncep];
    
    CGRect r = CGRectZero;
    r.origin = ccp(20,18);
    r.size = CGSizeMake(1, 1);
    QuestGiver *qg = [[QuestGiver alloc] initWithQuest:nil questGiverState:kAvailable file:@"FarmerMitch.png" map:self location:r];
    [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
    _questGiver = qg;
    [qg release];
    qg.name = tc.questGiverName;
    
    [self doReorder];
    
    FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tutQuest.taskGood : tutQuest.taskBad;
    MissionBuilding *asset = (MissionBuilding *)[self getChildByTag:ftp.assetNumWithinCity+ASSET_TAG_BASE];
    asset.ftp = ftp;
    asset.numTimesActedForTask = 0;
    
    ftp = [Globals userTypeIsGood:gs.type] ? tc.firstTaskGood : tc.firstTaskBad;
    asset = (MissionBuilding *)[self getChildByTag:ftp.assetNumWithinCity+ASSET_TAG_BASE];
    asset.ftp = ftp;
    asset.numTimesActedForTask = 0;
    
    [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    [Globals displayUIView:self.obMenu];
    [Globals displayUIView:self.summaryMenu];
    [self.obMenu setMissionMap:self];
    self.obMenu.hidden = YES;
    
    self.summaryMenu.center = CGPointMake(self.summaryMenu.frame.size.width/2+5.f, self.summaryMenu.superview.frame.size.height-self.summaryMenu.frame.size.height/2-2.f);
    self.summaryMenu.alpha = 0.f;
    
    self.selected = nil;
    
    _doBattlePhase = NO;
    _doTaskPhase = NO;
    _canUnclick = YES;
    
    _ccArrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
    
    [self doReorder];
    
    _taskProgBar = [TaskProgressBar node];
    [self addChild:_taskProgBar z:1002];
    _taskProgBar.visible = NO;
    
    _coinsGiven = 0;
  }
  return self;
}

- (void) createMyPlayer {
  // Do this so that tutorial classes can override
  _myPlayer = [[TutorialMyPlayer alloc] initWithLocation:CGRectMake(mapSize_.width/2, mapSize_.height/2, 1, 1) map:self];
  [self addChild:_myPlayer];
  [_myPlayer release];
  
  _myPlayer.location = CGRectMake(26, 22, 1, 1);
}

- (void) removeWithCleanup:(CCNode *)node {
  [node removeFromParentAndCleanup:YES];
}

- (void) beginInitialTask {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  _doTaskPhase = YES;
  
  // Move arrow to task
  [_ccArrow removeFromParentAndCleanup:YES];
  CCSprite *spr = [self assetWithId:tc.firstTaskGood.assetNumWithinCity];
  [spr addChild:_ccArrow];
  _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
  [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
  
  NSString *str = tc.firstTaskText;
  [DialogMenuController displayViewForText:str];
  
  [self centerOnTask];
  
  [[TopBar sharedTopBar] start];
}

- (void) moveToAssetId:(int)a animated:(BOOL)animated {
  [super moveToAssetId:a animated:animated];
  
  [_ccArrow removeFromParentAndCleanup:YES];
  CCSprite *spr = [self assetWithId:a];
  [spr addChild:_ccArrow];
  _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
  [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.questTaskText];
  
  _doQuestPhase = YES;
  _doTaskPhase = YES;
}

- (void) setSelected:(SelectableSprite *)selected {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tc.firstTaskGood : tc.firstTaskBad;
  FullTaskProto *questFtp = [Globals userTypeIsGood:gs.type] ? tc.tutorialQuest.taskGood : tc.tutorialQuest.taskBad;
  if (_doBattlePhase && selected == _enemy && selected.tag == ENEMY_TAG) {
    [super setSelected:selected];
    [_ccArrow removeFromParentAndCleanup:YES];
    _canUnclick = NO;
    
    _doBattlePhase = NO;
    
    [[self.enemyMenu nameLabel] setText:tc.enemyName];
    [[self.enemyMenu levelLabel] setText:@"Lvl 1"];
    [[self.enemyMenu imageIcon] setImage:[Globals squareImageForUser:tc.enemyType]];
  } else if (_doTaskPhase && !_pickupSilver && [selected isKindOfClass:[MissionBuilding class]] &&
             [[(MissionBuilding *)selected ftp] assetNumWithinCity] == ftp.assetNumWithinCity) {
    [super setSelected:selected];
    _canUnclick = NO;
    
    [_ccArrow removeFromParentAndCleanup:YES];
    [self.selected addChild:_ccArrow];
    _ccArrow.position = ccp(-_ccArrow.contentSize.width/2, _selected.contentSize.height/2);
    [Globals animateCCArrow:_ccArrow atAngle:0];
    
    [DialogMenuController closeView];
  } else if (_doTaskPhase && !_pickupSilver && [selected isKindOfClass:[NeutralEnemy class]] &&
             [[(NeutralEnemy *)selected ftp] assetNumWithinCity] == questFtp.assetNumWithinCity) {
    [super setSelected:selected];
    _canUnclick = NO;
    
    [_ccArrow removeFromParentAndCleanup:YES];
    [self.selected addChild:_ccArrow];
    _ccArrow.position = ccp(-_ccArrow.contentSize.width/2-15, _selected.contentSize.height/2);
    [Globals animateCCArrow:_ccArrow atAngle:0];
    
    [DialogMenuController closeView];
  } else if (_canUnclick) {
    [super setSelected:nil];
  }
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  // Find sprite that has center closest to pt
  SelectableSprite *node = nil;
  if (_doBattlePhase) {
    node = _enemy;
  } else if (_doTaskPhase) {
    if (_doQuestPhase) {
      GameState *gs = [GameState sharedGameState];
      TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
      FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tc.tutorialQuest.taskGood : tc.tutorialQuest.taskBad;
      node = [self assetWithId:ftp.assetNumWithinCity];
    } else {
      GameState *gs = [GameState sharedGameState];
      TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
      FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tc.firstTaskGood : tc.firstTaskBad;
      node = [self assetWithId:ftp.assetNumWithinCity];
    }
  }
  CGRect r = CGRectZero;
  r.origin = CGPointMake(-20, -5);
  pt = [node convertToNodeSpace:pt];
  r.size = CGSizeMake(node.contentSize.width+40, node.contentSize.height+150);
  if (CGRectContainsPoint(r, pt)) {
    return node;
  }
  return nil;
}

- (void) moveToEnemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type animated:(BOOL)animated {
  [self moveToSprite:_enemy animated:NO];
  self.position = ccpAdd(self.position, ccp(120, 0));
  [_ccArrow removeFromParentAndCleanup:YES];
  [_enemy addChild:_ccArrow];
  _ccArrow.position = ccp(_enemy.contentSize.width/2, _enemy.contentSize.height+_ccArrow.contentSize.height/2+10.f);
  [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  self.enemyMenu.nameLabel.text = tc.enemyName;
  self.enemyMenu.levelLabel.text = @"Lvl 1";
  
  // Create and add uiArrow to attack screen
  _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [self.enemyMenu addSubview:_uiArrow];
  
  UIView *attackButton = [self.enemyMenu viewWithTag:30];
  _uiArrow.center = CGPointMake(CGRectGetMinX(attackButton.frame)-_uiArrow.frame.size.width/2-2, attackButton.center.y);
  [Globals animateUIArrow:_uiArrow atAngle:0];
}

- (void) battleDone {
  _inBattlePhase = NO;
  
  [(TutorialTopBar *)[TopBar sharedTopBar] beginMyCityPhase];
  [TutorialBattleLayer purgeSingleton];
}

- (void) centerOnTask {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  CCSprite *spr = [self assetWithId:tc.firstTaskGood.assetNumWithinCity];
  [self moveToSprite:spr animated:YES withOffset:ccp(45,-15)];
}

- (void) performCurrentTask {
  if ([_selected conformsToProtocol:@protocol(TaskElement)]) {
    [_ccArrow removeFromParentAndCleanup:YES];
    
    id<TaskElement> te = (id<TaskElement>)_selected;
    FullTaskProto *ftp = te.ftp;
    
    [self closeMenus];
    
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
    
    _taskProgBar.position = ccp(te.position.x, te.position.y+te.contentSize.height);
    [_taskProgBar animateBarWithText:ftp.processingText];
    _taskProgBar.visible = YES;
    _receivedTaskActionResponse = YES;
    
    // Use total-1 because we add the num at the end
    if (te.numTimesActedForQuest == ftp.numRequiredForCompletion-1) {
      _doTaskPhase = NO;
      
      [self performSelectorInBackground:@selector(preloadLevelUp) withObject:nil];
    }
    _performingTask = YES;
    
    [self runAction:
     [CCSequence actions:[CCDelayTime actionWithDuration:1.5f],
      [CCCallBlock actionWithBlock:
       ^{
         GameState *gs = [GameState sharedGameState];
         TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
         StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = tc.tutorialQuest;
         FullTaskProto *ftp = nil;
         
         if (_doQuestPhase) {
           ftp = [Globals userTypeIsGood:gs.type] ? tutQuest.taskGood : tutQuest.taskBad;
           [Analytics tutCompleteQuestTask];
         } else {
           ftp = [Globals userTypeIsGood:gs.type] ? tc.firstTaskGood : tc.firstTaskBad;
           [Analytics tutCompleteTask1];
         }
         
         int coins = 0;
         if (_doTaskPhase) {
           coins = ftp.minCoinsGained;
         } else {
           coins = tutQuest.taskCompleteCoinGain;
         }
         
         // Fake a task action response
         TaskActionResponseProto *tarp = [[[[[TaskActionResponseProto builder]
                                             setSender:[[[MinimumUserProto builder] setUserId:0] build]]
                                            setStatus:TaskActionResponseProto_TaskActionStatusSuccess]
                                           setCoinsGained:coins]
                                          build];
         [self receivedTaskResponse:tarp];
         _canUnclick = YES;
         
         gs.currentEnergy -= ftp.energyCost;
         gs.silver += coins;
         _coinsGiven += coins;
         // Exp will be same for either task
         gs.experience += ftp.expGained;
       }], nil]];
    
    _pickupSilver = YES;
  }
}

- (void) addSilverDrop:(int)amount fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup {
  [super addSilverDrop:amount fromSprite:sprite toPosition:pt secondsToPickup:-1];
}

- (void) questAccepted:(FullQuestProto *)fqp {
  return;
}

- (void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
  [super addChild:node z:z tag:tag];
  if ([node isKindOfClass:[SilverStack class]]) {
    [_ccArrow removeFromParentAndCleanup:YES];
    [node addChild:_ccArrow];
    _ccArrow.position = ccp(-_ccArrow.contentSize.width/2, node.contentSize.height/2);
    [Globals animateCCArrow:_ccArrow atAngle:0];
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.lootText];
  }
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
  if ([node isKindOfClass:[SilverStack class]]) {
    [DialogMenuController closeView];
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    if (_doQuestPhase) {
      [Analytics tutQuestCoin];
      if (_doTaskPhase) {
        // Move arrow to task
        [_ccArrow removeFromParentAndCleanup:YES];
        CCSprite *spr = [self assetWithId:tc.tutorialQuest.taskGood.assetNumWithinCity];
        [spr addChild:_ccArrow];
        _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
        [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
      } else {
        [(TutorialQuestLogController *)[TutorialQuestLogController sharedQuestLogController] loadQuestRedeemScreen];
      }
    } else {
      [Analytics tutTaskCoin];
      if (_doTaskPhase) {
        // Move arrow to task
        [_ccArrow removeFromParentAndCleanup:YES];
        _ccArrow.rotation = 0;
        CCSprite *spr = [self assetWithId:tc.firstTaskGood.assetNumWithinCity];
        [spr addChild:_ccArrow];
        _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
        [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
      } else {
        [TutorialQuestLogController sharedQuestLogController];
        [(TutorialTopBar *)[TutorialTopBar sharedTopBar] beginQuestsPhase];
      }
    }
  }
  _pickupSilver = NO;
  [super removeChild:node cleanup:cleanup];
}

- (void) redeemComplete {
  self.selected = nil;
  [self levelUp];
}

- (void) preloadLevelUp {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  // Create a fake level up proto so we can send it in to the controller
  LevelUpResponseProto_Builder *lurpb = [LevelUpResponseProto builder];
  lurpb.sender = [[[MinimumUserProto builder] setUserId:0] build];
  lurpb.status = LevelUpResponseProto_LevelUpStatusSuccess;
  lurpb.newLevel = 2;
  lurpb.newNextLevel = 3;
  lurpb.experienceRequiredForNewNextLevel = tc.expForLevelThree;
  [lurpb addAllCitiesNewlyAvailableToUser:tc.levelTwoCities];
  [lurpb addAllNewlyAvailableStructs:tc.levelTwoStructs];
  [lurpb addAllNewlyEquippableEpicsAndLegendaries:tc.levelTwoEquips];
  
  // This will be released after the level up controller closes
  luvc = [[LevelUpViewController alloc] initWithLevelUpResponse:[lurpb build]];
  [luvc view];
}

- (void) levelUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  gs.skillPoints = gl.skillPointsGainedOnLevelup;
  gs.level = 2;
  gs.currentEnergy = gs.maxEnergy;
  gs.currentStamina = gs.maxStamina;
  gs.expRequiredForCurrentLevel = gs.expRequiredForNextLevel;
  gs.expRequiredForNextLevel = tc.expForLevelThree;
  
  [TutorialProfileViewController sharedProfileViewController];
  
  [Globals displayUIView:luvc.view];
  [_ccArrow removeFromParentAndCleanup:YES];
  
  UIImageView *arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [luvc.mainView addSubview:arrow];
  [arrow release];
  
  UIView *okayButton = [luvc.mainView viewWithTag:50];
  arrow.center = ccp(CGRectGetMaxX(okayButton.frame)+3, okayButton.center.y);
  [Globals animateUIArrow:arrow atAngle:M_PI];
}

- (void) levelUpComplete {
  _inBattlePhase = YES;
  [(TutorialTopBar *)[TopBar sharedTopBar] beginAttackPhase];
}

- (IBAction)attackClicked:(id)sender {
  if (self.selected == _enemy) {
    _canUnclick = YES;
    self.selected = nil;
    _inBattlePhase = YES;
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.f scene:[TutorialBattleLayer scene]]];
    
    [DialogMenuController closeView];
    
    [_ccArrow removeFromParentAndCleanup:YES];
  }
}

- (IBAction)enemyProfileClicked:(id)sender {
  return;
}

- (void) onEnter {
  [super onEnter];
  if (_inBattlePhase) {
    [_enemy runAction:[CCSequence actions:
                       [CCFadeOut actionWithDuration:1.5f],
                       [CCDelayTime actionWithDuration:1.5f],
                       [CCCallBlock actionWithBlock:
                        ^{
                          [_enemy removeFromParentAndCleanup:YES];
                        }], nil]];
    [_enemy displayCheck];
  }
}

- (void) onEnterTransitionDidFinish {
  if (_inBattlePhase) {
    [self battleDone];
  }
}

- (void) dealloc {
  [_ccArrow release];
  [_uiArrow release];
  [super dealloc];
}

@end
