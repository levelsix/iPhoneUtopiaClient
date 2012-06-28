//
//  TutorialQuestLogController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialQuestLogController.h"
#import "GameState.h"
#import "Globals.h"
#import "TutorialMissionMap.h"
#import "DialogMenuController.h"
#import "TutorialConstants.h"
#import "SoundEngine.h"

@implementation TutorialQuestLogController

- (id) init {
  // Need to load it with carpenter's nib
  if ((self = [super initWithNibName:@"QuestLogController" bundle:nil])) {
    GameState *gs = [GameState sharedGameState];
    BOOL isGood = [Globals userTypeIsGood:gs.type];
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tq = tc.tutorialQuest;
    FullQuestProto_Builder *bldr = [FullQuestProto builder];
    bldr.questId = 1;
    bldr.cityId = 1;
    bldr.name = isGood ? tq.goodName : tq.badName;
    bldr.description = isGood ? tq.goodDescription : tq.badDescription;
    bldr.doneResponse = isGood ? tq.goodDoneResponse : tq.badDoneResponse;
    bldr.assetNumWithinCity = tq.assetNumWithinCity;
    bldr.coinsGained = tq.coinsGained;
    bldr.expGained = tq.expGained;
    bldr.questGiverName = tc.questGiverName;
    [bldr addTaskReqs: isGood ? tq.firstTaskGood.taskId : tq.firstTaskBad.taskId];
    [bldr addDefeatTypeReqs:1];
    bldr.numComponentsForBad = 2;
    bldr.numComponentsForGood = 2;
    bldr.questGiverImageSuffix = @"mitch.png";
    
    _fqp = [[bldr build] retain];
    
    // Add the defeat type job to gamestate
    DefeatTypeJobProto_Builder *db = [DefeatTypeJobProto builder];
    db.defeatTypeJobId = 1;
    db.cityId = 1;
    db.numEnemiesToDefeat = 1;
    db.typeOfEnemy = [Globals userTypeIsGood:gs.type] ? UserTypeBadWarrior : UserTypeGoodWarrior;
    [gs.staticDefeatTypeJobs setObject:db.build forKey:[NSNumber numberWithInt:1]];
    
    FullTaskProto *ftp = isGood ? tq.firstTaskGood : tq.firstTaskBad;
    [gs.staticTasks setObject:ftp forKey:[NSNumber numberWithInt:ftp.taskId]];
    
    FullCityProto_Builder *fb = [FullCityProto builder];
    fb.cityId = 1;
    fb.minLevel = 1;
    fb.name = @"Kirin Village";
    [gs.staticCities setObject:fb.build forKey:[NSNumber numberWithInt:1]];
    
    _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  }
  return self;
}

- (void) loadQuestAcceptScreen {
  [super loadQuestAcceptScreen:_fqp];
  
  [Analytics tutorialQuestAccept];
  
  [self visitBattlePhase];
}

- (void) loadQuestCompleteScreen {
  GameState *gs = [GameState sharedGameState];
  [gs.inProgressCompleteQuests setObject:_fqp forKey:[NSNumber numberWithInt:_fqp.questId]];
  [super loadQuestCompleteScreen:_fqp];
  
  [self visitQuestGiverPhase];
  
  [[SoundEngine sharedSoundEngine] questComplete];
}

- (void) loadQuestRedeemScreen {
  [super loadQuestRedeemScreen:_fqp];
  
  [self claimRewardPhase];
}

- (void) visitBattlePhase {
  JobCell *jc = (JobCell *)[self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
  UIView *visit = jc.inProgressView;
  
  _arrow.center = ccpAdd(jc.frame.origin, ccp(CGRectGetMinX(visit.frame)-15.f, CGRectGetMinY(visit.frame)-15.f));
  [self.taskListTable addSubview:_arrow];
  [Globals animateUIArrow:_arrow atAngle:-M_PI_4];
  
  jc = (JobCell *)[self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
  jc.userInteractionEnabled = NO;
}

- (void) visitQuestGiverPhase {
  [_arrow removeFromSuperview];
  
  DescriptionCell *jc = (DescriptionCell *)[self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  UIView *visit = jc.visitView;
  
  _arrow.center = ccpAdd(jc.frame.origin, ccp(CGRectGetMinX(visit.frame)-15.f, CGRectGetMidY(visit.frame)));
  [self.taskListTable addSubview:_arrow];
  [Globals animateUIArrow:_arrow atAngle:0];
}

- (void) claimRewardPhase {
  [_arrow removeFromSuperview];
  
  RewardCell *jc = (RewardCell *)[self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
  UIView *claim = jc.claimView;
  
  _arrow.center = ccpAdd(jc.frame.origin, ccp(CGRectGetMinX(claim.frame)-15.f, CGRectGetMidY(claim.frame)));
  [self.taskListTable addSubview:_arrow];
  [Globals animateUIArrow:_arrow atAngle:0];
  
  UIButton *button = (UIButton *)[jc.claimView viewWithTag:20];
  
  // Remove all selectors for button
  for (id target in button.allTargets) {
    for (NSString *sel in [button actionsForTarget:target forControlEvent:UIControlEventTouchUpInside]) {
      [button removeTarget:target action:NSSelectorFromString(sel) forControlEvents:UIControlEventTouchUpInside];
    }
  }
  
  [button addTarget:self action:@selector(claimItClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) claimItClicked:(id)sender {
  [[TutorialMissionMap sharedTutorialMissionMap] questRedeemed:_fqp];
  [[TutorialMissionMap sharedTutorialMissionMap] redeemComplete];
  
  [TutorialQuestLogController removeView];
  [TutorialQuestLogController purgeSingleton];
  
  [Analytics tutorialQuestRedeem];
}

- (IBAction)closeClicked:(id)sender {
  return;
}

- (void) dealloc {
  [_fqp release];
  [_arrow release];
  [super dealloc];
}

@end
