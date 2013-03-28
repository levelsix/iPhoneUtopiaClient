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
    bldr.equipIdGained = tq.equipReward.equipId;
    [bldr addTaskReqs: isGood ? tq.taskGood.taskId : tq.taskBad.taskId];
    bldr.numComponentsForBad = 1;
    bldr.numComponentsForGood = 1;
    bldr.questGiverImageSuffix = [Globals userTypeIsGood:gs.type] ? @"ruby.png" : @"adriana.png";
    
    _fqp = [[bldr build] retain];
    
    [gs.availableQuests setObject:_fqp forKey:[NSNumber numberWithInt:_fqp.questId]];
    
    FullTaskProto *ftp = isGood ? tq.taskGood : tq.taskBad;
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

- (void) loadQuestLog {
  [self showQuestListViewAnimated:NO];
  [self.questListTable reloadData];
  [QuestLogController displayView];
  
  [[SoundEngine sharedSoundEngine] questLogOpened];
  
  GameState *gs = [GameState sharedGameState];
  self.questGiverImageView.image = [Globals userTypeIsGood:gs.type] ? [Globals imageNamed:@"bigruby2.png"] : [Globals imageNamed:@"bigadriana2.png"];
  
  QuestCell *jc = (QuestCell *)[self.questListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
  UIView *prog = jc.inProgressView;
  
  RewardCell *rc = (RewardCell *)[self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
  rc.equipIcon.userInteractionEnabled = NO;
  
  _arrow.center = ccpAdd(prog.center, ccp(-12, prog.frame.size.height/2+prog.frame.origin.y+_arrow.frame.size.height/2+10));
  [self.questListTable addSubview:_arrow];
  [Globals animateUIArrow:_arrow atAngle:M_PI_2];
}

- (void) loadQuestAcceptScreen {
  [super loadQuestAcceptScreen:_fqp];
  
  RewardCell *jc = (RewardCell *)[self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
  jc.equipIcon.userInteractionEnabled = NO;
  
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
  jc.equipIcon.userInteractionEnabled = NO;
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
  GameState *gs = [GameState sharedGameState];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  gs.experience += tc.tutorialQuest.expGained;
  gs.silver += tc.tutorialQuest.coinsGained;
  
  UserEquip *ue = [[UserEquip alloc] init];
  ue.equipId = tc.tutorialQuest.equipReward.equipId;
  ue.userId = gs.userId;
  ue.level = 1;
  ue.userEquipId = 3;
  [gs.myEquips addObject:ue];
  [ue release];
  	
  [[TutorialMissionMap sharedTutorialMissionMap] questRedeemed:_fqp];
  [[TutorialMissionMap sharedTutorialMissionMap] redeemComplete];
  
  [TutorialQuestLogController removeView];
  [TutorialQuestLogController purgeSingleton];
  
  [Analytics tutorialQuestRedeem];
}

- (void) questSelected:(FullQuestProto *)fqp {
  FullUserQuestDataLargeProto *questData = [self loadFakeQuest:fqp];
  
  self.taskListDelegate.quest = fqp;
  [self.taskListDelegate updateTasksForUserData:[NSArray arrayWithObject:questData]];
  [self.taskListTable reloadData];
  
  self.taskListTitleLabel.text = fqp.name;
  [self showTaskListViewAnimated:YES];
  
  JobCell *jc = (JobCell *)[self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1 ]];
  UIView *claim = jc.inProgressView;
  
  _arrow.center = ccpAdd(jc.frame.origin, ccp(CGRectGetMidX(claim.frame), CGRectGetMinY(claim.frame)-15.f));
  [self.taskListTable addSubview:_arrow];
  [Globals animateUIArrow:_arrow atAngle:-M_PI_2];
}

- (IBAction)backClicked:(id)sender {
  return;
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
