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
#import "SynthesizeSingleton.h"
#import "LevelUpViewController.h"
#import "TutorialProfileViewController.h"
#import "TutorialMapViewController.h"

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
    NSArray *elems = gs.type < 3 ? tc.firstCityElementsForGood : tc.firstCityElementsForBad;
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
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypePerson) {
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
    QuestGiver *qg = [[QuestGiver alloc] initWithQuest:nil inProgress:NO map:self location:r];
    [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
    _questGiver = qg;
    [qg release];
    
    [self doReorder];
    
    FullTaskProto *ftp = gs.type < 3 ? tutQuest.firstTaskGood : tutQuest.firstTaskBad;
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
    
    _ccArrow = [[CCSprite spriteWithFile:@"green.png"] retain];
    [_questGiver addChild:_ccArrow];
    _ccArrow.position = ccp(_questGiver.contentSize.width/2, _questGiver.contentSize.height+_ccArrow.contentSize.height+10);
    
    CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
    [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                           [upAction reverse], nil]]];
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
  float rate = 2.f;
  [bot runAction:[CCEaseIn actionWithAction:
                  [CCEaseBounceIn actionWithAction:
                   [CCSequence actions:
                    [CCMoveBy actionWithDuration:dur position:ccp(0, -bot.contentSize.height)],
                    [CCCallFuncN actionWithTarget:self selector:@selector(removeWithCleanup:)],
                    nil]] rate:rate]];
  [top runAction:[CCEaseIn actionWithAction:
                  [CCEaseBounceIn actionWithAction:
                   [CCSequence actions:
                    [CCMoveBy actionWithDuration:dur position:ccp(0, top.contentSize.height)],
                    [CCCallFuncN actionWithTarget:self selector:@selector(removeWithCleanup:)],
                    nil]] rate:rate]];
}

- (void) setSelected:(SelectableSprite *)selected {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  if ((_acceptQuestPhase || _redeemQuestPhase) && [selected isKindOfClass:[QuestGiver class]]) {
    [super setSelected:selected];
    [_ccArrow removeFromParentAndCleanup:YES];
    
    // Add right page here, QuestGiver will still do the job of removing it
    TutorialQuestLogController *tglc = (TutorialQuestLogController *)[TutorialQuestLogController sharedQuestLogController];
    // If redeemQuestPhase is true, then this quest has been accepted already
    [tglc displayRightPageForQuest:tc.tutorialQuest inProgress:_redeemQuestPhase];
  } else if (_doBattlePhase && [selected isKindOfClass:[Enemy class]]) {
    [super setSelected:selected];
  } else if (_doTaskPhase && [selected isKindOfClass:[MissionBuilding class]] && 
             [[(MissionBuilding *)selected ftp] assetNumWithinCity] == tc.tutorialQuest.assetNumWithinCity) {
    [super setSelected:selected];
  } else if (_aviaryPhase && [selected isKindOfClass:[Aviary class]]) {
    [super setSelected:selected];
    [TutorialMapViewController sharedMapViewController];
    [self removeFromParentAndCleanup:YES];
    [TutorialMissionMap purgeSingleton];
  } else {
    [super setSelected:nil];
  }
}

- (void) doneAcceptingQuest {
  // For Tut Quest Log
  _acceptQuestPhase = NO;
  _doBattlePhase = YES;
  _questGiver.isInProgress = YES;
}

- (void) spawnBattleEnemy {
  CGRect r = CGRectZero;
  r.origin = [self randomWalkablePosition];
  r.size = CGSizeMake(1, 1);
  _enemy = [[Enemy alloc] initWithFile:nil location:r map:self];
  [self addChild:_enemy z:1];
  [_enemy release];
  
  [_enemy addChild:_ccArrow];
  _ccArrow.position = ccp(_enemy.contentSize.width/2, _enemy.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         [upAction reverse], nil]]];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  self.enemyMenu.nameLabel.text = tc.enemyName;
  self.enemyMenu.levelLabel.text = @"Lvl 1";
}

- (void) battleDone {
  _doBattlePhase = NO;
  _doTaskPhase = YES;
  [_enemy removeFromParentAndCleanup:YES];
  
  // Move arrow to task
  [_ccArrow removeFromParentAndCleanup:YES];
  CCSprite *spr = [self assetWithId:1];
  [spr addChild:_ccArrow];
  _ccArrow.position = ccp(spr.contentSize.width/2, spr.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         [upAction reverse], nil]]];
  
  [TutorialBattleLayer purgeSingleton];
  
}

- (void) performCurrentTask {
  if ([_selected isKindOfClass:[MissionBuilding class]]) {
    MissionBuilding *mb = (MissionBuilding *)_selected;
    FullTaskProto *ftp = mb.ftp;
    
    mb.numTimesActed = MIN(mb.numTimesActed+1, ftp.numRequiredForCompletion);
    
    self.selected = nil;
    [self closeMenus];
    
    _doTaskPhase = NO;
    _redeemQuestPhase = YES;
    
    StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = [[TutorialConstants sharedTutorialConstants] tutorialQuest];
    GameState *gs = [GameState sharedGameState];
    gs.silver += tutQuest.firstTaskCompleteCoinGain;
    // Exp will be same for either task
    gs.experience += tutQuest.firstTaskGood.expGained;
    
    QuestCompleteView *qcv = [[TutorialQuestLogController sharedQuestLogController] createQuestCompleteView];
    qcv.questNameLabel.text = gs.type < 3 ? tutQuest.goodName : tutQuest.badName;
    qcv.visitDescLabel.text = @"Visit Farmer Mitch Lieu in Kirin Village to redeem your reward.";
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:qcv];
    
    // Move arrow back to task quest giver
    [_ccArrow removeFromParentAndCleanup:YES];
    [_questGiver addChild:_ccArrow];
    _ccArrow.position = ccp(_questGiver.contentSize.width/2, _questGiver.contentSize.height+_ccArrow.contentSize.height+10);
    
    CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
    [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                           [upAction reverse], nil]]];
  }
}

- (void) redeemComplete {
  _redeemQuestPhase = NO;
  self.selected = nil;
  [self levelUp];
}

- (void) levelUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  gs.skillPoints += gl.skillPointsGainedOnLevelup;
  gs.level += 1;
  gs.currentEnergy = gs.maxEnergy;
  gs.currentStamina = gs.maxStamina;
  
  [TutorialProfileViewController sharedProfileViewController];
  
  // This will be released after the level up controller closes
  LevelUpViewController *vc = [[LevelUpViewController alloc] initWithLevelUpResponse:nil];
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:vc.view];
  [_ccArrow removeFromParentAndCleanup:YES];
}

- (void) levelUpComplete {
  // Move arrow to aviary
  [_aviary addChild:_ccArrow];
  _ccArrow.position = ccp(_aviary.contentSize.width/2, _aviary.contentSize.height+_ccArrow.contentSize.height/2);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, 20)]];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         [upAction reverse], nil]]];
  
  _aviaryPhase = YES;
}

- (IBAction)attackClicked:(id)sender {
  self.selected = nil;
  [[CCDirector sharedDirector] pushScene:[TutorialBattleLayer scene]];
}

- (IBAction)profileClicked:(id)sender {
  return;
}

- (void) dealloc {
  [_ccArrow release];
  [super dealloc];
}

@end
