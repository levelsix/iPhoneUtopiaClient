//
//  QuestLogController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "QuestLogController.h"
#import "GameState.h"
#import "Globals.h"
#import "cocos2d.h"
#import "LNSynthesizeSingleton.h"
#import "GameLayer.h"
#import "OutgoingEventController.h"
#import "HomeMap.h"
#import "SoundEngine.h"
#import "BattleLayer.h"
#import "MapViewController.h"
#import "ProfileViewController.h"
#import "VaultMenuController.h"
#import "MarketplaceViewController.h"
#import "ArmoryViewController.h"
#import "AttackMenuController.h"
#import "ClanMenuController.h"

#define QUEST_LOG_TRANSITION_DURATION 0.4f

#define REWARD_CELL_HEIGHT_WITHOUT_CLAIM_BUTTON 86
#define REWARD_CELL_HEIGHT_WITH_CLAIM_BUTTON 119

@implementation QuestCell

@synthesize nameLabel, progressLabel, spinner;
@synthesize inProgressView, availableView;
@synthesize quest;
@synthesize questGiverImageView;

- (void) awakeFromNib {
  [self addSubview:availableView];
  availableView.frame = inProgressView.frame;
  
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.bounds;
  UIColor *topColor = [UIColor colorWithRed:35/255.f green:35/255.f blue:35/255.f alpha:0.5f];
  UIColor *botColor = [UIColor colorWithRed:12/255.f green:12/255.f blue:12/255.f alpha:0.5f];
  gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[botColor CGColor], nil];
  [self.contentView.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)visitClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:quest.cityId asset:quest.assetNumWithinCity];
  [[QuestLogController sharedQuestLogController] close];
  
  [Analytics clickedVisit];
}

- (void) dealloc {
  self.inProgressView = nil;
  self.availableView = nil;
  self.nameLabel = nil;
  self.progressLabel = nil;
  [spinner stopAnimating];
  self.spinner = nil;
  self.quest = nil;
  self.questGiverImageView = nil;
  [super dealloc];
}

@end

@implementation RewardCell

@synthesize withEquipView, withoutEquipView;
@synthesize equipIcon, attackLabel, defenseLabel;
@synthesize smallExpLabel, bigExpLabel;
@synthesize smallCoinLabel, bigCoinLabel;
@synthesize claimView;

- (void) awakeFromNib {
  [withoutEquipView.superview addSubview:withEquipView];
  withEquipView.frame = withoutEquipView.frame;
}

- (void) updateForQuest:(FullQuestProto *)fqp withClaimButton:(BOOL)claimItActivated {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  if (fqp.equipIdGained > 0) {
    withEquipView.hidden = NO;
    withoutEquipView.hidden = YES;
    
    equipIcon.equipId = fqp.equipIdGained;
    
    FullEquipProto *fep = [gs equipWithId:fqp.equipIdGained];
    attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:fep.equipId level:1]];
    defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:fep.equipId level:1]];
    
    smallExpLabel.text = [NSString stringWithFormat:@"%d", fqp.expGained];
    smallCoinLabel.text = [NSString stringWithFormat:@"%d", fqp.coinsGained];
  } else {
    withEquipView.hidden = YES;
    withoutEquipView.hidden = NO;
    
    bigExpLabel.text = [NSString stringWithFormat:@"%d Exp.", fqp.expGained];
    bigCoinLabel.text = [NSString stringWithFormat:@"%d Silver", fqp.coinsGained];
  }
  
  self.claimView.hidden = !claimItActivated;
}

- (void) dealloc {
  self.withEquipView = nil;
  self.withoutEquipView = nil;
  self.equipIcon = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.smallExpLabel = nil;
  self.bigExpLabel = nil;
  self.smallCoinLabel = nil;
  self.bigCoinLabel = nil;
  self.claimView = nil;
  [super dealloc];
}

@end

@implementation DescriptionCell

@synthesize descriptionLabel, visitView, questGiverImageView;

- (void) updateForQuest:(FullQuestProto *)fqp visitActivated:(BOOL)visitActivated redeeming:(BOOL)redeeming {
  self.descriptionLabel.text = redeeming ? fqp.doneResponse : fqp.description;
  self.visitView.hidden = !visitActivated;
  
  if (visitActivated) {
    CGRect r = self.descriptionLabel.frame;
    r.size.width = CGRectGetMinX(visitView.frame)-CGRectGetMinX(descriptionLabel.frame)-8;
    self.descriptionLabel.frame = r;
  } else {
    CGRect r = self.descriptionLabel.frame;
    r.size.width = CGRectGetMaxX(visitView.frame)-CGRectGetMinX(descriptionLabel.frame);
    self.descriptionLabel.frame = r;
  }
  
  _cityId = fqp.cityId;
  _assetNum = fqp.assetNumWithinCity;
  
  if (fqp.questGiverImageSuffix) {
    NSString *file = [@"dialogue" stringByAppendingString:fqp.questGiverImageSuffix];
    [Globals imageNamed:file withImageView:questGiverImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  }
  
  UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[questGiverImageView viewWithTag:150];
  loadingView.center = CGPointMake(questGiverImageView.frame.size.width/2, questGiverImageView.frame.size.height/2+3);
}

- (IBAction)visitClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:_cityId asset:_assetNum];
  [[QuestLogController sharedQuestLogController] close];
  
  if (_cityId == 0 && _assetNum == 2) {
    [[VaultMenuController sharedVaultMenuController] close];
    [[MarketplaceViewController sharedMarketplaceViewController] close];
    [[ArmoryViewController sharedArmoryViewController] close];
    [[ClanMenuController sharedClanMenuController] close];
  }
  
  if ([BattleLayer isInitialized] && [[BattleLayer sharedBattleLayer] isRunning]) {
    [[BattleLayer sharedBattleLayer] closeSceneFromQuestLog];
  }
}

- (void) dealloc {
  self.descriptionLabel = nil;
  self.visitView = nil;
  self.questGiverImageView = nil;
  [super dealloc];
}

@end

@implementation JobCell

@synthesize job;
@synthesize nameLabel, progressLabel;
@synthesize completedView, inProgressView;
@synthesize spinner;

- (void) awakeFromNib {
  [self insertSubview:completedView atIndex:0];
  completedView.frame = inProgressView.frame;
}

- (void) setJob:(UserJob *)j {
  if (job != j) {
    [job release];
    job = [j retain];
  }
  self.nameLabel.text = job.title;
  
  if (job.jobType == kCoinRetrievalJob) {
    self.progressLabel.text = [NSString stringWithFormat:@"%d", job.numCompleted];
  } else {
    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", job.numCompleted, job.total];
  }
  
  if (job.numCompleted >= job.total) {
    // Fade out the visit button if we're done
    [UIView animateWithDuration:0.3f animations:^{
      inProgressView.alpha = 0.f;
    }];
  } else {
    inProgressView.alpha = 1.f;
  }
}

- (IBAction)visitClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  
  JobItemType type = job.jobType;
  int jobId = job.jobId;
  if (type == kTask) {
    FullTaskProto *ftp = [gs taskWithId:jobId];
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:ftp.cityId asset:ftp.assetNumWithinCity];
  } else if (type == kDefeatTypeJob) {
    DefeatTypeJobProto *p = [gs.staticDefeatTypeJobs objectForKey:[NSNumber numberWithInt:jobId]];
    
    if (p.cityId > 0) {
      [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:p.cityId enemyType:p.typeOfEnemy];
    } else {
      [AttackMenuController displayView];
    }
  } else if (type == kUpgradeStructJob) {
    UpgradeStructJobProto *p = [gs.staticUpgradeStructJobs objectForKey:[NSNumber numberWithInt:jobId]];
    [[GameLayer sharedGameLayer] loadHomeMap];
    [[HomeMap sharedHomeMap] moveToStruct:p.structId];
  } else if (type == kBuildStructJob) {
    [[GameLayer sharedGameLayer] loadHomeMap];
    [[HomeMap sharedHomeMap] moveToCarpenter];
  } else if (type == kCoinRetrievalJob) {
    [[GameLayer sharedGameLayer] loadHomeMap];
  } else if (type == kSpecialJob) {
    FullQuestProto *fqp = [gs questForQuestId:jobId];
    GameLayer *glay = [GameLayer sharedGameLayer];
    BazaarMap *bm = [BazaarMap sharedBazaarMap];
    switch (fqp.specialQuestActionReq) {
      case SpecialQuestActionSellToArmory:
        [glay loadBazaarMap];
        [bm moveToCritStruct:BazaarStructTypeArmory];
        break;
        
      case SpecialQuestActionDepositInVault:
        [glay loadBazaarMap];
        [bm moveToCritStruct:BazaarStructTypeVault];
        break;
        
      case SpecialQuestActionWithdrawFromVault:
        [glay loadBazaarMap];
        [bm moveToCritStruct:BazaarStructTypeVault];
        break;
        
      case SpecialQuestActionPostToMarketplace:
        [glay loadBazaarMap];
        [bm moveToCritStruct:BazaarStructTypeMarketplace];
        break;
        
      case SpecialQuestActionPurchaseFromMarketplace:
        [glay loadBazaarMap];
        [bm moveToCritStruct:BazaarStructTypeMarketplace];
        break;
        
      case SpecialQuestActionPurchaseFromArmory:
        [glay loadBazaarMap];
        [bm moveToCritStruct:BazaarStructTypeArmory];
        break;
        
      case SpecialQuestActionWriteOnEnemyWall:
        [AttackMenuController displayView];
        break;
        
      case SpecialQuestActionRequestJoinClan:
        [glay loadBazaarMap];
        [bm moveToCritStruct:BazaarStructTypeClanHouse];
        
      default:
        break;
    }
  }
  [[QuestLogController sharedQuestLogController] close];
  
  [Analytics clickedVisit];
}

- (void) dealloc {
  self.job = nil;
  self.nameLabel = nil;
  self.progressLabel = nil;
  self.completedView = nil;
  self.inProgressView = nil;
  [spinner stopAnimating];
  self.spinner = nil;
  [super dealloc];
}

@end

@implementation QuestListTableDelegate

@synthesize questCell;

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  if (section == 0) {
    if (gs.inProgressCompleteQuests.count <= 0) {
      return 0;
    }
  } else if (section == 1) {
    if (gs.availableQuests.count <= 0) {
      return 0;
    }
  } else if (section == 2) {
    if (gs.inProgressIncompleteQuests.count <= 0) {
      return 0;
    }
  }
  return 19.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIImageView *headerView = [[[UIImageView alloc] initWithImage:[Globals imageNamed:@"questheadertop.png"]] autorelease];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 400, headerView.frame.size.height)];
  label.font = [UIFont fontWithName:@"Trajan Pro" size:12];
  label.backgroundColor = [UIColor clearColor];
  [headerView addSubview:label];
  [label release];
  
  GameState *gs = [GameState sharedGameState];
  if (section == 0) {
    if (gs.inProgressCompleteQuests.count <= 0) {
      return nil;
    }
    label.text = @"Completed Quests";
    label.textColor = [Globals orangeColor];
  } else if (section == 1) {
    if (gs.availableQuests.count <= 0) {
      return nil;
    }
    label.text = @"New Quests";
    label.textColor = [Globals greenColor];
  } else if (section == 2) {
    if (gs.inProgressIncompleteQuests.count <= 0) {
      return nil;
    }
    label.text = @"Ongoing Quests";
    label.textColor = [Globals creamColor];
  }
  
  return headerView;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  if (section == 0) {
    return gs.inProgressCompleteQuests.count;
  } else if (section == 1) {
    return gs.availableQuests.count;
  } else if (section == 2) {
    return gs.inProgressIncompleteQuests.count;
  }
  return 0;
}

- (FullQuestProto *)questForIndexPath:(NSIndexPath *)path {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = nil;
  if (path.section == 0) {
    arr = gs.inProgressCompleteQuests.allValues;
  } else if (path.section == 1) {
    arr = gs.availableQuests.allValues;
  } else if (path.section == 2) {
    arr = gs.inProgressIncompleteQuests.allValues;
  }
  return arr.count > path.row ? [arr objectAtIndex:path.row] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FullQuestProto *fqp = [self questForIndexPath:indexPath];
  QuestCell *qc = [tableView dequeueReusableCellWithIdentifier:@"QuestCell"];
  GameState *gs = [GameState sharedGameState];
  
  if (!qc) {
    [[NSBundle mainBundle] loadNibNamed:@"QuestCell" owner:self options:nil];
    qc = self.questCell;
    qc.selectedBackgroundView = [[[UIView alloc] initWithFrame:qc.bounds] autorelease];
    qc.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5f];
  }
  
  qc.nameLabel.text = fqp.name;
  qc.quest = fqp;
  
  if (fqp.questGiverImageSuffix) {
    NSString *file = [@"dialogue" stringByAppendingString:fqp.questGiverImageSuffix];
    [Globals imageNamed:file withImageView:qc.questGiverImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  }
  
  UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[qc.questGiverImageView viewWithTag:150];
  loadingView.center = CGPointMake(qc.questGiverImageView.frame.size.width/2, qc.questGiverImageView.frame.size.height/2+3);
  
  if (indexPath.section == 0) {
    qc.availableView.hidden = YES;
    qc.inProgressView.hidden = NO;
    
    qc.spinner.hidden = YES;
    [qc.spinner stopAnimating];
    qc.progressLabel.hidden = NO;
    int total = [Globals userTypeIsGood:gs.type] ? fqp.numComponentsForGood : fqp.numComponentsForBad;
    qc.progressLabel.text = [NSString stringWithFormat:@"%d/%d", total, total];
  } else if (indexPath.section == 1) {
    qc.availableView.hidden = NO;
    qc.inProgressView.hidden = YES;
  } else if (indexPath.section == 2) {
    qc.availableView.hidden = YES;
    qc.inProgressView.hidden = NO;
    
    NSArray *logData = [[QuestLogController sharedQuestLogController] userLogData];
    BOOL foundQuest = NO;
    if (logData) {
      FullUserQuestDataLargeProto *questData = nil;
      for (FullUserQuestDataLargeProto *q in logData) {
        if (q.questId == fqp.questId) {
          questData = q;
          break;
        }
      }
      
      if (questData) {
        foundQuest = YES;
        qc.spinner.hidden = YES;
        [qc.spinner stopAnimating];
        qc.progressLabel.hidden = NO;
        int total = [Globals userTypeIsGood:gs.type] ? fqp.numComponentsForGood : fqp.numComponentsForBad;
        qc.progressLabel.text = [NSString stringWithFormat:@"%d/%d", questData.numComponentsComplete, total];
      }
    }
    
    if (!foundQuest) {
      qc.spinner.hidden = NO;
      [qc.spinner startAnimating];
      qc.progressLabel.hidden = YES;
    }
  }
  
  return qc;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    [[QuestLogController sharedQuestLogController] questSelected:[self questForIndexPath:indexPath]];
  } else if (indexPath.section == 1) {
    QuestCell *qc = (QuestCell *)[tableView cellForRowAtIndexPath:indexPath];
    [qc visitClicked:nil];
  } else if (indexPath.section == 2) {
    [[QuestLogController sharedQuestLogController] questSelected:[self questForIndexPath:indexPath]];
  }
}

- (void) dealloc {
  self.questCell = nil;
  [super dealloc];
}

@end

@implementation TaskListTableDelegate

@synthesize jobCell, rewardCell, descriptionCell;
@synthesize quest, jobs;
@synthesize questRedeem = _questRedeem;

- (void) setQuest:(FullQuestProto *)q {
  if (quest != q) {
    [quest release];
    quest = [q retain];
    
    // Load up jobs
    if (quest) {
      self.jobs = [UserJob jobsForQuest:quest];
      _receivedData = NO;
      [self updateTasksForUserData:[[QuestLogController sharedQuestLogController] userLogData]];
    }
  }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 1 && _questRedeem) {
    return 0.f;
  }
  return 19.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIImageView *headerView = [[[UIImageView alloc] initWithImage:[Globals imageNamed:@"questheadertop.png"]] autorelease];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 400, headerView.frame.size.height)];
  label.font = [UIFont fontWithName:@"Trajan Pro" size:12];
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [Globals creamColor];
  [headerView addSubview:label];
  [label release];
  
  if (section == 0) {
    NSString *name = self.quest.questGiverName;
    if (quest.cityId == 0) {
      if (quest.assetNumWithinCity == 1) {
        name = [Globals homeQuestGiverName];
      } else if (quest.assetNumWithinCity == 2) {
        name = [Globals bazaarQuestGiverName];
      }
    }
    label.text = [NSString stringWithFormat:@"%@ says", name];
  } else if (section == 1) {
    if (_questRedeem) {
      return nil;
    }
    label.text = @"Tasks";
  } else if (section == 2) {
    label.text = @"For your reward";
  }
  
  return headerView;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else if (section == 1) {
    if (_questRedeem) {
      return 0;
    }
    return jobs.count;
  } else if (section == 2) {
    return 1;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    DescriptionCell *dc = [tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];
    
    if (!dc) {
      [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:self options:nil];
      dc = self.descriptionCell;
    }
    
    if (quest) {
      GameState *gs = [GameState sharedGameState];
      BOOL questIsComplete = [gs.inProgressCompleteQuests objectForKey:[NSNumber numberWithInt:quest.questId]] != nil;
      [dc updateForQuest:quest visitActivated:questIsComplete && !_questRedeem redeeming:_questRedeem];
    }
    return dc;
  } else if (indexPath.section == 1) {
    // The tasks required for this quest
    JobCell *jc = [tableView dequeueReusableCellWithIdentifier:@"JobCell"];
    UserJob *job = [jobs objectAtIndex:indexPath.row];
    
    if (!jc) {
      [[NSBundle mainBundle] loadNibNamed:@"JobCell" owner:self options:nil];
      jc = self.jobCell;
    }
    
    jc.job = job;
    
    if (!_receivedData) {
      jc.progressLabel.hidden = YES;
      jc.spinner.hidden = NO;
      [jc.spinner startAnimating];
    } else {
      jc.progressLabel.hidden = NO;
      jc.spinner.hidden = YES;
      [jc.spinner stopAnimating];
    }
    
    return jc;
  } else {
    // The rewards from this quest
    RewardCell *rc = [tableView dequeueReusableCellWithIdentifier:@"RewardCell"];
    
    if (!rc) {
      [[NSBundle mainBundle] loadNibNamed:@"RewardCell" owner:self options:nil];
      rc = self.rewardCell;
    }
    
    if (quest) {
      [rc updateForQuest:self.quest withClaimButton:_questRedeem];
    }
    
    return rc;
  }
  
  return nil;
}

- (void) updateTasksForUserData:(NSArray *)logData {
  if (logData == nil) {
    return;
  }
  
  _receivedData = YES;
  
  FullUserQuestDataLargeProto *questData = nil;
  for (FullUserQuestDataLargeProto *q in logData) {
    if (q.questId == quest.questId) {
      questData = q;
      break;
    }
  }
  
  if (questData) {
    for (UserJob *job in jobs) {
      if (questData.isComplete) {
        job.numCompleted = job.total;
      } else if (job.jobType == kTask) {
        MinimumUserTaskProto *p;
        for (p in questData.requiredTasksProgressList) {
          if (p.taskId == job.jobId) {
            break;
          }
        }
        job.numCompleted = p.numTimesActed;
      } else if (job.jobType == kDefeatTypeJob) {
        MinimumUserDefeatTypeJobProto *p;
        for (p in questData.requiredDefeatTypeJobProgressList) {
          if (p.defeatTypeJobId == job.jobId) {
            break;
          }
        }
        job.numCompleted = p.numDefeated;
      } else if (job.jobType == kPossessEquipJob) {
        MinimumUserPossessEquipJobProto *p;
        for (p in questData.requiredPossessEquipJobProgressList) {
          if (p.possessEquipJobId == job.jobId) {
            break;
          }
        }
        job.numCompleted = p.numEquipUserHas;
      } else if (job.jobType == kBuildStructJob) {
        MinimumUserBuildStructJobProto *p;
        for (p in questData.requiredBuildStructJobProgressList) {
          if (p.buildStructJobId == job.jobId) {
            break;
          }
        }
        job.numCompleted = p.numOfStructUserHas;
      } else if (job.jobType == kUpgradeStructJob) {
        MinimumUserUpgradeStructJobProto *p;
        for (p in questData.requiredUpgradeStructJobProgressList) {
          if (p.upgradeStructJobId == job.jobId) {
            break;
          }
        }
        job.numCompleted = p.currentLevel;
      } else if (job.jobType == kCoinRetrievalJob) {
        job.numCompleted = questData.coinsRetrievedForReq;
      }
    }
  }
}

- (IBAction)claimRewardClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] redeemQuest:quest.questId];
  [[QuestLogController sharedQuestLogController] close];
  
  [[SoundEngine sharedSoundEngine] coinDrop];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 2) {
    if (_questRedeem) {
      return REWARD_CELL_HEIGHT_WITH_CLAIM_BUTTON;
    } else {
      return REWARD_CELL_HEIGHT_WITHOUT_CLAIM_BUTTON;
    }
  }
  return tableView.rowHeight;
}

- (void) dealloc {
  self.jobCell = nil;
  self.rewardCell = nil;
  self.descriptionCell = nil;
  self.quest = nil;
  self.jobs = nil;
  [super dealloc];
}

@end

@implementation QuestLogController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(QuestLogController);

@synthesize mainView, bgdView;
@synthesize questListTable, taskListTable;
@synthesize questListView, taskListView;
@synthesize questListDelegate, taskListDelegate;
@synthesize userLogData;
@synthesize taskListTitleLabel;
@synthesize backButton;
@synthesize questGiverImageView;

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  questListTable.separatorColor = [UIColor colorWithWhite:1.f alpha:0.1f];
  taskListTable.separatorColor = [UIColor colorWithWhite:1.f alpha:0.1f];
  
  [questListView.superview addSubview:taskListView];
  
  questListDelegate = [[QuestListTableDelegate alloc] init];
  questListTable.delegate = questListDelegate;
  questListTable.dataSource = questListDelegate;
  
  taskListDelegate = [[TaskListTableDelegate alloc] init];
  taskListTable.delegate = taskListDelegate;
  taskListTable.dataSource = taskListDelegate;
  
  // This will prevent empty cells from being made when the page is not full..
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
  questListTable.tableFooterView = view;
  [view release];
  
  view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
  taskListTable.tableFooterView = view;
  [view release];
}

- (void)viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewDidDisappear:(BOOL)animated {
  self.userLogData = nil;
  taskListDelegate.quest = nil;
}

- (void) loadQuestLog {
  [self showQuestListViewAnimated:NO];
  [[OutgoingEventController sharedOutgoingEventController] retrieveQuestLog];
  [questListTable reloadData];
  [QuestLogController displayView];
  taskListDelegate.questRedeem = NO;
  taskListDelegate.quest = nil;
  
  self.backButton.hidden = NO;
  
  [[SoundEngine sharedSoundEngine] questLogOpened];
  
  GameState *gs = [GameState sharedGameState];
  questGiverImageView.image = [Globals userTypeIsGood:gs.type] ? [Globals imageNamed:@"bigruby.png"] : [Globals imageNamed:@"bigadriana.png"];
}

- (void) loadQuest:(FullQuestProto *)fqp {
  [[OutgoingEventController sharedOutgoingEventController] retrieveQuestDetails:fqp.questId];
  
  taskListDelegate.quest = fqp;
  taskListTitleLabel.text = fqp.name;
  taskListDelegate.questRedeem = NO;
  [taskListTable reloadData];
  [QuestLogController displayView];
  [self showTaskListViewAnimated:NO];
  self.backButton.hidden = YES;
  
  if (fqp.questGiverImageSuffix) {
    NSString *file = [@"big" stringByAppendingString:fqp.questGiverImageSuffix];
    [Globals imageNamed:file withImageView:questGiverImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  }
}

- (void) loadQuestAcceptScreen:(FullQuestProto *)fqp {
  FullUserQuestDataLargeProto *questData = [self loadFakeQuest:fqp];
  
  taskListDelegate.quest = fqp;
  taskListTitleLabel.text = fqp.name;
  taskListDelegate.questRedeem = NO;
  [taskListTable reloadData];
  [QuestLogController displayView];
  [self showTaskListViewAnimated:NO];
  self.backButton.hidden = YES;
  
  [taskListDelegate updateTasksForUserData:[NSArray arrayWithObject:questData]];
  
  [[SoundEngine sharedSoundEngine] questAccepted];
  
  if (fqp.questGiverImageSuffix) {
    NSString *file = [@"big" stringByAppendingString:fqp.questGiverImageSuffix];
    [Globals imageNamed:file withImageView:questGiverImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  }
}

- (FullUserQuestDataLargeProto *) loadFakeQuest:(FullQuestProto *)fqp {
  // Lets create a fake FullUserQuestDataLarge for this quest
  GameState *gs = [GameState sharedGameState];
  FullUserQuestDataLargeProto_Builder *bldr = [FullUserQuestDataLargeProto builder];
  bldr.userId = gs.userId;
  bldr.questId = fqp.questId;
  bldr.isRedeemed = NO;
  bldr.isComplete = NO;
  bldr.coinsRetrievedForReq = 0;
  
  for (NSNumber *n in fqp.defeatTypeReqsList) {
    MinimumUserDefeatTypeJobProto_Builder *b = [MinimumUserDefeatTypeJobProto builder];
    b.defeatTypeJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    b.numDefeated = 0;
    [bldr addRequiredDefeatTypeJobProgress:[b build]];
  }
  for (NSNumber *n in fqp.taskReqsList) {
    MinimumUserQuestTaskProto_Builder *b = [MinimumUserQuestTaskProto builder];
    b.taskId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    b.numTimesActed = 0;
    [bldr addRequiredTasksProgress:[b build]];
  }
  for (NSNumber *n in fqp.possessEquipJobReqsList) {
    PossessEquipJobProto *p = [gs.staticPossessEquipJobs objectForKey:n];
    MinimumUserPossessEquipJobProto_Builder *b = [MinimumUserPossessEquipJobProto builder];
    b.possessEquipJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    
    b.numEquipUserHas = MIN([gs quantityOfEquip:p.equipId], p.quantityReq);
    [bldr addRequiredPossessEquipJobProgress:[b build]];
  }
  for (NSNumber *n in fqp.buildStructJobsReqsList) {
    BuildStructJobProto *p = [gs.staticBuildStructJobs objectForKey:n];
    MinimumUserBuildStructJobProto_Builder *b = [MinimumUserBuildStructJobProto builder];
    b.buildStructJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    
    b.numOfStructUserHas = 0;
    for (UserStruct *us in gs.myStructs) {
      if (us.structId == p.structId) {
        b.numOfStructUserHas = MIN(b.numOfStructUserHas+1, p.quantityRequired);
      }
    }
    [bldr addRequiredBuildStructJobProgress:[b build]];
  }
  for (NSNumber *n in fqp.upgradeStructJobsReqsList) {
    UpgradeStructJobProto *p = [gs.staticUpgradeStructJobs objectForKey:n];
    MinimumUserUpgradeStructJobProto_Builder *b = [MinimumUserUpgradeStructJobProto builder];
    b.upgradeStructJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    
    b.currentLevel = 0;
    for (UserStruct *us in gs.myStructs) {
      if (us.structId == p.structId) {
        b.currentLevel = MIN(MAX(b.currentLevel, us.level), p.levelReq);
      }
    }
    [bldr addRequiredUpgradeStructJobProgress:[b build]];
  }
  return bldr.build;
}

- (void) loadQuestCompleteScreen:(FullQuestProto *)fqp {
  self.taskListTitleLabel.text = @"Quest Complete!";
  self.backButton.hidden = YES;
  
  taskListDelegate.quest = fqp;
  taskListDelegate.questRedeem = NO;
  [taskListTable reloadData];
  [QuestLogController displayView];
  [self showTaskListViewAnimated:NO];
  
  FullUserQuestDataLargeProto *questData = [[[[FullUserQuestDataLargeProto builder] 
                                              setIsComplete:YES]
                                             setQuestId:fqp.questId]
                                            build];
  
  [taskListDelegate updateTasksForUserData:[NSArray arrayWithObject:questData]];
  
  GameState *gs = [GameState sharedGameState];
  questGiverImageView.image = [Globals userTypeIsGood:gs.type] ? [Globals imageNamed:@"bigruby.png"] : [Globals imageNamed:@"bigadriana.png"];
  
  [[SoundEngine sharedSoundEngine] questComplete];
}

- (void) loadQuestRedeemScreen:(FullQuestProto *)fqp {
  self.taskListTitleLabel.text = @"Collect Your Reward!";
  self.backButton.hidden = YES;
  
  taskListDelegate.quest = fqp;
  taskListDelegate.questRedeem = YES;
  [taskListTable reloadData];
  [QuestLogController displayView];
  [self showTaskListViewAnimated:NO];
  
  if (fqp.questGiverImageSuffix) {
    NSString *file = [@"big" stringByAppendingString:fqp.questGiverImageSuffix];
    [Globals imageNamed:file withImageView:questGiverImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  }
  
  [[SoundEngine sharedSoundEngine] questLogOpened];
}

- (void) questSelected:(FullQuestProto *)fqp {
  taskListDelegate.quest = fqp;
  [taskListTable reloadData];
  taskListTitleLabel.text = fqp.name;
  [self showTaskListViewAnimated:YES];
}

- (void) showQuestListViewAnimated:(BOOL)animated {
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:QUEST_LOG_TRANSITION_DURATION];
    [UIView setAnimationDidStopSelector:@selector(clearSelections)];
  }
  CGRect r = questListView.frame;
  r.origin = CGPointMake(0, 0);
  questListView.frame = r;
  
  r = taskListView.frame;
  r.origin = CGPointMake(CGRectGetMaxX(questListView.frame), 0);
  taskListView.frame = r;
  
  if (animated) {
    [UIView commitAnimations];
  }
}

- (void) showTaskListViewAnimated:(BOOL)animated {
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:QUEST_LOG_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(clearSelections)];
  }
  CGRect r = questListView.frame;
  r.origin = CGPointMake(-questListView.frame.size.width, 0);
  questListView.frame = r;
  
  r = taskListView.frame;
  r.origin = CGPointMake(0, 0);
  taskListView.frame = r;
  
  [taskListTable setContentOffset:ccp(0,0) animated:NO];
  
  if (animated) {
    [UIView commitAnimations];
  }
}

- (void) clearSelections {
  [questListTable deselectRowAtIndexPath:[questListTable indexPathForSelectedRow] animated:NO];
}

- (void) loadQuestData:(NSArray *)quests {
  self.userLogData = quests;
  [taskListDelegate updateTasksForUserData:quests];
  [taskListTable reloadData];
  [questListTable reloadData];
}

- (IBAction)closeClicked:(id)sender {
  // Must replace for tutorial since closeClicked will be overwritten and task visit button uses this
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [QuestLogController removeView];
  }];
}

- (IBAction)backClicked:(id)sender {
  [self showQuestListViewAnimated:YES];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  self.mainView = nil;
  self.bgdView = nil;
  self.questListTable = nil;
  self.taskListTable = nil;
  self.questListView = nil;
  self.taskListView = nil;
  self.questListDelegate = nil;
  self.taskListDelegate = nil;
  self.userLogData = nil;
  self.taskListTitleLabel = nil;
  self.backButton = nil;
  self.questGiverImageView = nil;
}

@end
