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
#import "TutorialMapViewController.h"
#import "DialogMenuController.h"
#import "GameLayer.h"
#import "TopBar.h"

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
    for (CCNode *node in self.children) {
      if (![node isKindOfClass:[CCTMXLayer class]]) {
        continue;
      }
      CCTMXLayer *layer = (CCTMXLayer *)node;
      
      for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
          NSMutableArray *row = [self.walkableData objectAtIndex:i];
          NSNumber *curVal = [row objectAtIndex:j];
          if (curVal.boolValue == NO) {
            // Convert their coordinates to our coordinate system
            CGPoint tileCoord = ccp(height-j-1, width-i-1);
            int tileGid = [layer tileGIDAt:tileCoord];
            if (tileGid) {
              NSDictionary *properties = [self propertiesForGID:tileGid];
              if (properties) {
                NSString *collision = [properties valueForKey:@"Walkable"];
                if (collision && [collision isEqualToString:@"Yes"]) {
                  [row replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
                }
              }
            }
          }
        }
      }
    }
    
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
    
    // Add aviary
    Globals *gl = [Globals sharedGlobals];
    CGRect avCoords = CGRectMake(3, 13, gl.aviaryXLength, gl.aviaryYLength);
    _aviary = [[Aviary alloc] initWithFile:@"Aviary.png" location:avCoords map:self];
    _aviary.orientation = 1;
    [self addChild:_aviary];
    [_aviary release];
    [self changeTiles:_aviary.location canWalk:NO];
    
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
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    QuestGiver *qg = [[QuestGiver alloc] initWithQuest:nil inProgress:NO file:@"Farmer.png" map:self location:r];
    [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
    _questGiver = qg;
    [qg release];
    qg.name = tc.questGiverName;
    
    [self doReorder];
    
    FullTaskProto *ftp = [Globals userTypeIsGood:gs.type] ? tutQuest.firstTaskGood : tutQuest.firstTaskBad;
    MissionBuilding *asset = (MissionBuilding *)[self getChildByTag:ftp.assetNumWithinCity+ASSET_TAG_BASE];
    asset.ftp = ftp;
    asset.numTimesActed = 0;
    
    [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.obMenu];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.summaryMenu];
    [self.obMenu setMissionMap:self];
    self.obMenu.hidden = YES;
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    
    self.summaryMenu.center = CGPointMake(-self.summaryMenu.frame.size.width, 290);
    
    self.selected = nil;
    
    _acceptQuestPhase = YES;
    _doBattlePhase = NO;
    _doTaskPhase = NO;
    _canUnclick = YES;
    
    _ccArrow = [[CCSprite spriteWithFile:@"green.png"] retain];
    [_questGiver addChild:_ccArrow];
    _ccArrow.position = ccp(_questGiver.contentSize.width/2, _questGiver.contentSize.height+_ccArrow.contentSize.height+10);
    
    CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
    [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                           [upAction reverse], nil]]];
    
    r = CGRectZero;
    r.origin = [self randomWalkablePosition];
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
    Enemy *randEnemy = [[Enemy alloc] initWithFile:[Globals spriteImageNameForUser:type] location:r map:self];
    [self addChild:randEnemy z:1];
    [randEnemy release];
    randEnemy.nameLabel.string = @"Ashton Butcher";
    
    r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    type = [Globals userTypeIsGood:tc.enemyType] ? 2 : 5;
    randEnemy = [[Enemy alloc] initWithFile:[Globals spriteImageNameForUser:type] location:r map:self];
    [self addChild:randEnemy z:1];
    [randEnemy release];
    randEnemy.nameLabel.string = @"Tret Berrill";
    
    [self doReorder];
    
    _taskProgBar = [TaskProgressBar node];
    [self addChild:_taskProgBar z:1002];
    _taskProgBar.visible = NO;
    
    _coinsGiven = 0;
  }
  return self;
}

- (void) removeWithCleanup:(CCNode *)node {
  [node removeFromParentAndCleanup:YES];
}

- (void) doBlink {
  // Must do blink separately b/c layer is added to parent
  CCLayer *bot = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
  bot.contentSize = CGSizeMake(bot.contentSize.width, bot.contentSize.height/2);
  [self.parent addChild:bot z:5];
  
  CCLayer *top = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
  top.contentSize = CGSizeMake(top.contentSize.width, top.contentSize.height/2);
  top.position = ccp(0, bot.contentSize.height);
  [self.parent addChild:top z:5];
  
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
}

- (void) beginAfterBlinkConvo {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  NSString *text = [[GameState sharedGameState] type] < 3 ? tc.afterBlinkTextGood : tc. afterBlinkTextBad;
  [DialogMenuController displayViewForText:text callbackTarget:self action:@selector(centerOnQuestGiver)];
  
  [[TopBar sharedTopBar] start];
}

- (void) centerOnQuestGiver {
  [self moveToSprite:_questGiver];
}

- (void) setSelected:(SelectableSprite *)selected {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  if ((_acceptQuestPhase || _redeemQuestPhase) && [selected isKindOfClass:[QuestGiver class]]) {
    [super setSelected:selected];
    [_ccArrow removeFromParentAndCleanup:YES];
    
    // Add right page here, QuestGiver will still do the job of removing it
//    TutorialQuestLogController *tglc = (TutorialQuestLogController *)[TutorialQuestLogController sharedQuestLogController];
//    // If redeemQuestPhase is true, then this quest has been accepted already
//    [tglc displayRightPageForQuest:tc.tutorialQuest inProgress:_redeemQuestPhase];
  } else if (_doBattlePhase && [selected isKindOfClass:[Enemy class]] && selected.tag == ENEMY_TAG) {
    [super setSelected:selected];
    [_ccArrow removeFromParentAndCleanup:YES];
    _canUnclick = NO;
    
    [[self.enemyMenu nameLabel] setText:tc.enemyName];
    [[self.enemyMenu levelLabel] setText:@"Lvl 1"];
    [[self.enemyMenu imageIcon] setImage:[Globals squareImageForUser:tc.enemyType]];
  } else if (_doTaskPhase && !_pickupSilver && [selected isKindOfClass:[MissionBuilding class]] && 
             [[(MissionBuilding *)selected ftp] assetNumWithinCity] == tc.tutorialQuest.assetNumWithinCity) {
    [super setSelected:selected];
    _canUnclick = NO;
  } else if (_aviaryPhase && [selected isKindOfClass:[Aviary class]]) {
    [super setSelected:selected];
    _canUnclick = NO;
    [_ccArrow removeFromParentAndCleanup:YES];
    
    // release profile from previous step
    [TutorialProfileViewController purgeSingleton];
  } else if (_canUnclick) {
    [super setSelected:nil];
  }
}

- (void) questGiverInProgress {
  // For Tut Quest Log
  _acceptQuestPhase = NO;
  _doBattlePhase = YES;
  _questGiver.isInProgress = YES;
}

- (void) questLogClosed {
  [_ccArrow removeFromParentAndCleanup:YES];
  [_enemy addChild:_ccArrow];
  _ccArrow.position = ccp(_enemy.contentSize.width/2, _enemy.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         [upAction reverse], nil]]];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  self.enemyMenu.nameLabel.text = tc.enemyName;
  self.enemyMenu.levelLabel.text = @"Lvl 1";
  
  NSString *str = [NSString stringWithFormat:tc.afterQuestAcceptClosedText, tc.enemyName];
  [self centerOnEnemy];
  [DialogMenuController displayViewForText:str callbackTarget:nil action:nil];
  
  // Create and add uiArrow to attack screen
  _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"green.png"]];
  [self.enemyMenu addSubview:_uiArrow];
  _uiArrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
  
  UIView *attackButton = [self.enemyMenu viewWithTag:30];
  _uiArrow.center = CGPointMake(CGRectGetMinX(attackButton.frame)-_uiArrow.frame.size.width/2-2, attackButton.center.y);
  
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
    _uiArrow.center = CGPointMake(_uiArrow.center.x-10, _uiArrow.center.y);
  } completion:nil];
}

- (void) centerOnEnemy {
  [self moveToSprite:_enemy];
}

- (void) battleDone {
  _doBattlePhase = NO;
  _doTaskPhase = YES;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [self moveToSprite:[self assetWithId:tc.tutorialQuest.assetNumWithinCity]];
  [_enemy removeFromParentAndCleanup:YES];
  
  // Move arrow to task
  [_ccArrow removeFromParentAndCleanup:YES];
  CCSprite *spr = [self assetWithId:tc.tutorialQuest.firstTaskGood.assetNumWithinCity];
  [spr addChild:_ccArrow];
  _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         [upAction reverse], nil]]];
}

- (void) centerOnTask {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  CCSprite *spr = [self assetWithId:tc.tutorialQuest.firstTaskGood.assetNumWithinCity];
  [self moveToSprite:spr];
}

- (void) performCurrentTask {
  if ([_selected isKindOfClass:[MissionBuilding class]]) {
    [TutorialBattleLayer purgeSingleton];
    
    [_ccArrow removeFromParentAndCleanup:YES];
    
    MissionBuilding *mb = (MissionBuilding *)_selected;
    FullTaskProto *ftp = mb.ftp;
    
    [self closeMenus];
    
    _taskProgBar.position = ccp(mb.position.x, mb.position.y+mb.contentSize.height);
    [_taskProgBar animateBarWithText:ftp.processingText];
    _taskProgBar.visible = YES;
    mb.numTimesActed = MIN(mb.numTimesActed+1, ftp.numRequiredForCompletion);
    _receivedTaskActionResponse = YES;
    
    if (mb.numTimesActed == ftp.numRequiredForCompletion) {
      _doTaskPhase = NO;
      
      [self performSelectorInBackground:@selector(preloadLevelUp) withObject:nil];
    }
    _performingTask = YES;
    
    [self runAction:
     [CCSequence actions:[CCDelayTime actionWithDuration:1.5f], 
      [CCCallBlock actionWithBlock:
       ^{
         GameState *gs = [GameState sharedGameState];
         StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = [[TutorialConstants sharedTutorialConstants] tutorialQuest];
         
         int coins = 0;
         if (_doTaskPhase) {
           int diff = (tutQuest.firstTaskGood.maxCoinsGained-tutQuest.firstTaskGood.minCoinsGained)/2;
           int changeFromMid = arc4random() % diff - diff/2;
           coins = tutQuest.firstTaskGood.minCoinsGained+diff+changeFromMid;
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
    _ccArrow.rotation = -90;
    _ccArrow.position = ccp(-_ccArrow.contentSize.width/2, _ccArrow.contentSize.height/2);
    
    CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(-20, 0)]];
    [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                           [upAction reverse], nil]]];
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
      
      CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
      [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                             [upAction reverse], nil]]];
    } else {
      _redeemQuestPhase = YES;
      
//      GameState *gs = [GameState sharedGameState];
//      StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = [[TutorialConstants sharedTutorialConstants] tutorialQuest];
//      QuestCompleteView *qcv = [[TutorialQuestLogController sharedQuestLogController] createQuestCompleteView];
//      qcv.questNameLabel.text = [Globals userTypeIsGood:gs.type] ? tutQuest.goodName : tutQuest.badName;
//      qcv.visitDescLabel.text = [NSString stringWithFormat:@"Visit %@ in Kirin Village to redeem your reward.", tc.questGiverName];
//      [[[[CCDirector sharedDirector] openGLView] superview] addSubview:qcv];
      
      // Move arrow back to task quest giver
      [_ccArrow removeFromParentAndCleanup:YES];
      _ccArrow.rotation = 0;
      [_questGiver addChild:_ccArrow];
      _ccArrow.position = ccp(_questGiver.contentSize.width/2, _questGiver.contentSize.height+_ccArrow.contentSize.height+10);
      
      CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
      [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                             [upAction reverse], nil]]];
      
      [self moveToSprite:_questGiver];
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
//  [[TutorialQuestLogController sharedQuestLogController] didReceiveMemoryWarning];
//  [TutorialQuestLogController purgeSingleton];
  
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
  
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:luvc.view];
  [_ccArrow removeFromParentAndCleanup:YES];
}

- (void) levelUpComplete {
  [DialogMenuController incrementProgress];
  [DialogMenuController displayViewForText:[TutorialConstants sharedTutorialConstants].beforeAviaryText1 callbackTarget:self action:@selector(levelUpComplete2)];
}

- (void) levelUpComplete2 {
  [DialogMenuController displayViewForText:[TutorialConstants sharedTutorialConstants].beforeAviaryText2 callbackTarget:nil   action:nil];
  // Move arrow to aviary
  [_ccArrow removeFromParentAndCleanup:YES];
  [_aviary addChild:_ccArrow];
  _ccArrow.position = ccp(_aviary.contentSize.width/2, _aviary.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         [upAction reverse], nil]]];
  
  _aviaryPhase = YES;
  
  [self moveToSprite:_aviary];
}

- (IBAction)attackClicked:(id)sender {
  _canUnclick = YES;
  self.selected = nil;
  [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.f scene:[TutorialBattleLayer scene]]];
  
  [_ccArrow removeFromParentAndCleanup:YES];
  
  // Move to the aviary now
  [_uiArrow removeFromSuperview];
  [self.aviaryMenu addSubview:_uiArrow];
  
  UIView *visitButton = [self.aviaryMenu viewWithTag:30];
  _uiArrow.center = CGPointMake(visitButton.frame.origin.x-_uiArrow.frame.size.width/2, visitButton.center.y);
  
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
    _uiArrow.center = CGPointMake(_uiArrow.center.x-10, _uiArrow.center.y);
  } completion:nil];
}

- (void) battleClosed {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  [self centerOnTask];
  NSString *str = [Globals userTypeIsGood:gs.type] ? tc.beforeTaskTextGood : tc.beforeTaskTextBad;
  [DialogMenuController incrementProgress];
  [DialogMenuController displayViewForText:str callbackTarget:nil action:nil];
  [Analytics tutorialBattleComplete];
}

- (IBAction)profileClicked:(id)sender {
  return;
}

- (IBAction)enterAviaryClicked:(id)sender {
  // Preload map so that it becomes the singleton
  [TutorialMapViewController sharedMapViewController];
  [super enterAviaryClicked:sender];
  [_uiArrow removeFromSuperview];
}

- (void) dealloc {
  [_ccArrow release];
  [_uiArrow release];
  [super dealloc];
}

@end
