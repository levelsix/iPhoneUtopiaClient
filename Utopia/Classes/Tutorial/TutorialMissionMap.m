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
    
    FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tutQuest.firstTaskGood : tutQuest.firstTaskBad;
    MissionBuilding *asset = (MissionBuilding *)[self getChildByTag:ftp.assetNumWithinCity+ASSET_TAG_BASE];
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
    
    _acceptQuestPhase = YES;
    _doBattlePhase = NO;
    _doTaskPhase = NO;
    _canUnclick = YES;
    
    _ccArrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
    [_questGiver addChild:_ccArrow];
    _ccArrow.position = ccp(_questGiver.contentSize.width/2, _questGiver.contentSize.height+_ccArrow.contentSize.height+20);
    
    [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
    
    r = CGRectZero;
    r.origin = ccp(29,25);
    r.size = CGSizeMake(1, 1);
    UserType type = tc.enemyType;
    _enemy = [[Enemy alloc] initWithFile:[Globals spriteImageNameForUser:type] location:r map:self];
    [self addChild:_enemy z:1];
    [_enemy release];
    _enemy.nameLabel.string = tc.enemyName;
    _enemy.tag = ENEMY_TAG;
    
    r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    type = [Globals userTypeIsGood:tc.enemyType] ? 1 : 4;
    Enemy *randEnemy = [[Enemy alloc] initWithFile:[Globals animatedSpritePrefix:type] location:r map:self];
    [self addChild:randEnemy z:1];
    [randEnemy release];
    randEnemy.nameLabel.string = @"Ashton Butcher";
    
    r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    type = [Globals userTypeIsGood:tc.enemyType] ? 2 : 5;
    randEnemy = [[Enemy alloc] initWithFile:[Globals animatedSpritePrefix:type] location:r map:self];
    [self addChild:randEnemy z:1];
    [randEnemy release];
    randEnemy.nameLabel.string = @"Tret Berrill";
    
    [self doReorder];
    
    _taskProgBar = [TaskProgressBar node];
    [self addChild:_taskProgBar z:1002];
    _taskProgBar.visible = NO;
    
    _coinsGiven = 0;
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
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

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  if (_beforeBlinkPhase) {
    _beforeBlinkPhase = NO;
    [self doBlink];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
  }
  return YES;
}

- (void) allowBlink {
  _beforeBlinkPhase = YES;
  
  GameState *gs = [GameState sharedGameState];
  NSString *str = [NSString stringWithFormat:[[TutorialConstants sharedTutorialConstants] beforeBlinkText], gs.name];
  _label = [CCLabelTTF labelWithString:str fontName:@"Trajan Pro" fontSize:15.f];
  [self.parent addChild:_label z:6];
  _label.position = ccp(self.parent.contentSize.width/2, 40);
  [_label runAction:[CCFadeIn actionWithDuration:0.3f]];
  
  [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.f], [CCCallFunc actionWithTarget:self selector:@selector(showTapToContinue)], nil]];
  
  // Must do blink separately b/c layer is added to parent
  CCLayer *bot = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
  bot.contentSize = CGSizeMake(bot.contentSize.width, bot.contentSize.height/2);
  [self.parent addChild:bot z:5 tag:10];
  
  CCLayer *top = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
  top.contentSize = CGSizeMake(top.contentSize.width, top.contentSize.height/2);
  top.position = ccp(0, bot.contentSize.height);
  [self.parent addChild:top z:5 tag:11];
}

- (void) showTapToContinue {
  if (_label.opacity == 255) {
    CCLabelTTF *tap = [CCLabelTTF labelWithString:@"Tap to continue..." fontName:@"Trajan Pro" fontSize:15.f];
    tap.color = ccc3(255, 200, 0);
    [self.parent addChild:tap z:6 tag:30];
    tap.position = _label.position;
    
    tap.opacity = 0;
    [tap runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.6f opacity:255], [CCFadeTo actionWithDuration:0.6f opacity:120], nil]]];
    [_label runAction:[CCMoveBy actionWithDuration:0.2f position:ccp(0, 30)]];
  }
}

- (void) doBlink {
  CCLayer *bot = (CCLayer *)[self.parent getChildByTag:10];
  CCLayer *top = (CCLayer *)[self.parent getChildByTag:11];
  
  ccTime dur = 2.5f;
  [bot runAction:[CCEaseBounceIn actionWithAction:
                  [CCSequence actions:
                   [CCMoveBy actionWithDuration:dur position:ccp(0, -bot.contentSize.height)],
                   [CCCallFuncN actionWithTarget:self selector:@selector(removeWithCleanup:)],
                   [CCCallFunc actionWithTarget:self selector:@selector(beginAfterBlinkConvo)],
                   nil]]];
  [top runAction:[CCEaseBounceIn actionWithAction:
                  [CCSequence actions:
                   [CCMoveBy actionWithDuration:dur position:ccp(0, top.contentSize.height)],
                   [CCCallFuncN actionWithTarget:self selector:@selector(removeWithCleanup:)],
                   nil]]];
  
  _label.opacity = 254;
  [_label runAction:[CCFadeTo actionWithDuration:0.3f opacity:0]];
  
  CCNode *node = [self.parent getChildByTag:30];
  [node stopAllActions];
  [node runAction:[CCFadeOut actionWithDuration:0.3f]];
}

- (void) beginAfterBlinkConvo {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  NSString *text = [[GameState sharedGameState] type] < 3 ? tc.afterBlinkTextGood : tc. afterBlinkTextBad;
  [DialogMenuController displayViewForText:text];
  
  [self centerOnQuestGiver];
  
  [[TopBar sharedTopBar] start];
}

- (void) centerOnQuestGiver {
  [self moveToSprite:_questGiver];
  self.position = ccpAdd(self.position, ccp(120, 0));
}

- (void) moveToAssetId:(int)a {
  if (a == _questGiver.tag-ASSET_TAG_BASE) {
    [self centerOnQuestGiver];
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.beforeRedeemText];
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tc.tutorialQuest.firstTaskGood : tc.tutorialQuest.firstTaskBad;
  if ((_acceptQuestPhase || _redeemQuestPhase) && selected == _questGiver) {
    [super setSelected:selected];
    [_ccArrow removeFromParentAndCleanup:YES];
    
    [DialogMenuController closeView];
    
    TutorialQuestLogController *tglc = (TutorialQuestLogController *)[TutorialQuestLogController sharedQuestLogController];
    if (_acceptQuestPhase) {
      [tglc loadQuestAcceptScreen];
      [self questGiverInProgress]; 
    } else {
      [tglc loadQuestRedeemScreen];
    }
  } else if (_doBattlePhase && selected == _enemy && selected.tag == ENEMY_TAG) {
    [super setSelected:selected];
    [_ccArrow removeFromParentAndCleanup:YES];
    _canUnclick = NO;
    
    _doBattlePhase = NO;
    
    [DialogMenuController displayViewForText:tc.beforeAttackClickedText];
    
    [[self.enemyMenu nameLabel] setText:tc.enemyName];
    [[self.enemyMenu levelLabel] setText:@"Lvl 1"];
    [[self.enemyMenu imageIcon] setImage:[Globals squareImageForUser:tc.enemyType]];
  } else if (_doTaskPhase && !_pickupSilver && [selected isKindOfClass:[MissionBuilding class]] && 
             [[(MissionBuilding *)selected ftp] assetNumWithinCity] == ftp.assetNumWithinCity) {
    [super setSelected:selected];
    _canUnclick = NO;
    
    [DialogMenuController closeView];
  } else if (_canUnclick) {
    [super setSelected:nil];
  }
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  // Find sprite that has center closest to pt
  SelectableSprite *node = nil;
  if (_acceptQuestPhase || _redeemQuestPhase) {
    node = _questGiver;
  } else if (_doBattlePhase) {
    node = _enemy;
  } else if (_doTaskPhase) {
    GameState *gs = [GameState sharedGameState];
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tc.tutorialQuest.firstTaskGood : tc.tutorialQuest.firstTaskBad;
    node = [self assetWithId:ftp.assetNumWithinCity];
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

- (void) questGiverInProgress {
  // For Tut Quest Log
  _acceptQuestPhase = NO;
  _doBattlePhase = YES;
  _questGiver.questGiverState = kInProgress;
}

- (void) moveToEnemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type {
  [self moveToSprite:_enemy];
  self.position = ccpAdd(self.position, ccp(120, 0));
  [_ccArrow removeFromParentAndCleanup:YES];
  [_enemy addChild:_ccArrow];
  _ccArrow.position = ccp(_enemy.contentSize.width/2, _enemy.contentSize.height+_ccArrow.contentSize.height/2+10.f);
  [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  self.enemyMenu.nameLabel.text = tc.enemyName;
  self.enemyMenu.levelLabel.text = @"Lvl 1";
  
  [DialogMenuController displayViewForText:tc.beforeEnemyClickedText];
  
  // Create and add uiArrow to attack screen
  _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [self.enemyMenu addSubview:_uiArrow];
  
  UIView *attackButton = [self.enemyMenu viewWithTag:30];
  _uiArrow.center = CGPointMake(CGRectGetMinX(attackButton.frame)-_uiArrow.frame.size.width/2-2, attackButton.center.y);
  [Globals animateUIArrow:_uiArrow atAngle:0];
}

- (void) battleDone {
  _inBattlePhase = NO;
  _doTaskPhase = YES;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [self moveToSprite:[self assetWithId:tc.tutorialQuest.assetNumWithinCity]];
  [_enemy removeFromParentAndCleanup:YES];
  
  // Move arrow to task
  [_ccArrow removeFromParentAndCleanup:YES];
  CCSprite *spr = [self assetWithId:tc.tutorialQuest.firstTaskGood.assetNumWithinCity];
  [spr addChild:_ccArrow];
  _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
  [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
  
  GameState *gs = [GameState sharedGameState];
  NSString *str = [Globals userTypeIsGood:gs.type] ? tc.beforeTaskTextGood : tc.beforeTaskTextBad;
  [DialogMenuController displayViewForText:str];
  
  [self centerOnTask];
}

- (void) centerOnTask {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  CCSprite *spr = [self assetWithId:tc.tutorialQuest.firstTaskGood.assetNumWithinCity];
  [self moveToSprite:spr];
  self.position = ccpAdd(self.position, ccp(120, 0));
}

- (void) performCurrentTask {
  if ([_selected isKindOfClass:[MissionBuilding class]]) {
    [TutorialBattleLayer purgeSingleton];
    
    [_ccArrow removeFromParentAndCleanup:YES];
    
    MissionBuilding *mb = (MissionBuilding *)_selected;
    FullTaskProto *ftp = mb.ftp;
    
    [self closeMenus];
    
    CGPoint pt = ccp(ftp.spriteLandingCoords.x, ftp.spriteLandingCoords.y);
    CGPoint ccPt = pt;
    // Angle should be relevant to entire building, not origin
    if (ccPt.x < 0) {
      ccPt.x = -1;
    } else if (ccPt.x >= mb.location.size.width) {
      ccPt.x = 1;
    } else {
      ccPt.x = 0;
    }
    
    if (ccPt.y < 0) {
      ccPt.y = -1;
    } else if (ccPt.y >= mb.location.size.height) {
      ccPt.y = 1;
    } else {
      ccPt.y = 0;
    }
    
    ccPt = ccpSub([self convertTilePointToCCPoint:ccp(0, 0)], [self convertTilePointToCCPoint:ccPt]);
    float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccPt));
    [_myPlayer stopWalking];
    [_myPlayer performAnimation:ftp.animationType atLocation:ccpAdd(mb.location.origin, pt) inDirection:angle];
    
    _taskProgBar.position = ccp(mb.position.x, mb.position.y+mb.contentSize.height);
    [_taskProgBar animateBarWithText:ftp.processingText];
    _taskProgBar.visible = YES;
    _receivedTaskActionResponse = YES;
    
    // Use total-1 because we add the num at the end
    if (mb.numTimesActedForQuest == ftp.numRequiredForCompletion-1) {
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
         FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tutQuest.firstTaskGood : tutQuest.firstTaskBad;
         
         int coins = 0;
         if (_doTaskPhase) {
           int diff = (ftp.maxCoinsGained-ftp.minCoinsGained+1);
           int changeFromMin = arc4random() % diff;
           coins = ftp.minCoinsGained+changeFromMin;
         } else {
           coins = tutQuest.firstTaskCompleteCoinGain-_coinsGiven;
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
         gs.experience += tutQuest.firstTaskGood.expGained;
       }], nil]];
    
    _pickupSilver = YES;
  }
}

- (void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
  [super addChild:node z:z tag:tag];
  if ([node isKindOfClass:[SilverStack class]]) {
    [_ccArrow removeFromParentAndCleanup:YES];
    [node addChild:_ccArrow];
    _ccArrow.position = ccp(-_ccArrow.contentSize.width/2, node.contentSize.height/2);
    [Globals animateCCArrow:_ccArrow atAngle:0];
  }
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
  if ([node isKindOfClass:[SilverStack class]]) {
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    if (_doTaskPhase) {
      // Move arrow to task
      [_ccArrow removeFromParentAndCleanup:YES];
      _ccArrow.rotation = 0;
      CCSprite *spr = [self assetWithId:tc.tutorialQuest.firstTaskGood.assetNumWithinCity];
      [spr addChild:_ccArrow];
      _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
      [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
    } else {
      _redeemQuestPhase = YES;
      
      [(TutorialQuestLogController *)[QuestLogController sharedQuestLogController] loadQuestCompleteScreen];
      
      // Move arrow back to task quest giver
      [_ccArrow removeFromParentAndCleanup:YES];
      _questGiver.questGiverState = kCompleted;
      [_questGiver addChild:_ccArrow];
      _ccArrow.position = ccp(_questGiver.contentSize.width/2, _questGiver.contentSize.height+_ccArrow.contentSize.height+20);
      [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
      
      [Analytics tutorialTaskComplete];
    }
    _pickupSilver = NO;
  }
  [super removeChild:node cleanup:cleanup];
}

- (void) redeemComplete {
  _redeemQuestPhase = NO;
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
  gs.skillPoints += gl.skillPointsGainedOnLevelup;
  gs.level += 1;
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
  [(TutorialTopBar *)[TopBar sharedTopBar] beginMyCityPhase];
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
