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
#import "SynthesizeSingleton.h"
#import "GameLayer.h"
#import "OutgoingEventController.h"
#import "HomeMap.h"

#define QUEST_LOG_TRANSITION_DURATION 0.4f

@implementation QuestCompleteView

@synthesize questNameLabel, visitDescLabel;

- (IBAction)okayClicked:(id)sender {
  [self removeFromSuperview];
}

- (void) dealloc {
  self.questNameLabel = nil;
  self.visitDescLabel = nil;
  [super dealloc];
}

@end

@implementation QuestCell

@synthesize nameLabel, progressLabel, spinner;
@synthesize inProgressView, availableView;
@synthesize quest;

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
  [[QuestLogController sharedQuestLogController] closeClicked:nil];
  
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
  self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", job.numCompleted, job.total];
  
  inProgressView.alpha = 1.f;
  if (job.numCompleted >= job.total) {
    // Fade out the visit button if we're done
    [UIView animateWithDuration:0.3f animations:^{
      inProgressView.alpha = 0.f;
    }];
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
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:p.cityId enemyType:p.typeOfEnemy];
  } else if (type == kUpgradeStructJob) {
    UpgradeStructJobProto *p = [gs.staticUpgradeStructJobs objectForKey:[NSNumber numberWithInt:jobId]];
    [[GameLayer sharedGameLayer] loadHomeMap];
    [[HomeMap sharedHomeMap] moveToStruct:p.structId];
  } else if (type == kBuildStructJob) {
    [[GameLayer sharedGameLayer] loadHomeMap];
    [[HomeMap sharedHomeMap] moveToCritStruct:CritStructTypeCarpenter];
  }
  [[QuestLogController sharedQuestLogController] closeClicked:nil];
  
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
  return 19.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIImageView *headerView = [[[UIImageView alloc] initWithImage:[Globals imageNamed:@"questheadertop.png"]] autorelease];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 400, headerView.frame.size.height)];
  label.font = [UIFont fontWithName:@"Trajan Pro" size:12];
  label.backgroundColor = [UIColor clearColor];
  [headerView addSubview:label];
  
  if (section == 0) {
    label.text = @"New Quests";
    label.textColor = [Globals greenColor];
  } else if (section == 1) {
    label.text = @"Ongoing Quests";
    label.textColor = [Globals creamColor];
  }
  
  return headerView;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  if (section == 0) {
    return gs.availableQuests.count;
  } else {
    return gs.inProgressQuests.count;
  }
}

- (FullQuestProto *)questForIndexPath:(NSIndexPath *)path {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = nil;
  if (path.section == 0) {
    arr = gs.availableQuests.allValues;
  } else {
    arr = gs.inProgressQuests.allValues;
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
    qc.selectedBackgroundView = [[UIView alloc] initWithFrame:qc.bounds];
    qc.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5f];
  }
  
  qc.nameLabel.text = fqp.name;
  qc.quest = fqp;
  
  if (indexPath.section == 0) {
    qc.availableView.hidden = NO;
    qc.inProgressView.hidden = YES;
  } else {
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
    QuestCell *qc = (QuestCell *)[tableView cellForRowAtIndexPath:indexPath];
    [qc visitClicked:nil];
  } else {
    [[QuestLogController sharedQuestLogController] questSelected:[self questForIndexPath:indexPath]];
  }
}

- (void) dealloc {
  self.questCell = nil;
  [super dealloc];
}

@end

@implementation TaskListTableDelegate

@synthesize jobCell;
@synthesize quest, jobs;

- (void) setQuest:(FullQuestProto *)q {
  if (quest != q) {
    [quest release];
    quest = [q retain];
    
    // Load up jobs
    self.jobs = [UserJob jobsForQuest:quest];
    _receivedData = NO;
    [self updateTasksForUserData:[[QuestLogController sharedQuestLogController] userLogData]];
  }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 19.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIImageView *headerView = [[[UIImageView alloc] initWithImage:[Globals imageNamed:@"questheadertop.png"]] autorelease];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 400, headerView.frame.size.height)];
  label.font = [UIFont fontWithName:@"Trajan Pro" size:12];
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [Globals creamColor];
  [headerView addSubview:label];
  
  if (section == 0) {
    label.text = @"Ashwin Says";
  } else if (section == 1) {
    label.text = @"Tasks";
  }
  
  return headerView;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else {
    return jobs.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
  } else {
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
  }
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
    }
  }
  
  if (questData) {
    for (UserJob *job in jobs) {
      if (job.jobType == kTask) {
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
      }
    }
  }
}

- (void) dealloc {
  self.jobCell = nil;
  self.quest = nil;
  self.jobs = nil;
  [super dealloc];
}

@end

@implementation QuestLogController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(QuestLogController);

@synthesize qcView;
@synthesize mainView, bgdView;
@synthesize questListTable, taskListTable;
@synthesize questListView, taskListView;
@synthesize questListDelegate, taskListDelegate;
@synthesize userLogData;
@synthesize taskListTitleLabel;

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
  [self showQuestListViewAnimated:NO];
  [[OutgoingEventController sharedOutgoingEventController] retrieveQuestLog];
  [questListTable reloadData];
}

- (void) viewDidDisappear:(BOOL)animated {
  self.userLogData = nil;
  taskListDelegate.quest = nil;
}

- (void) loadFakeQuest:(FullQuestProto *)fqp {
  // Lets create a fake FullUserQuestDataLarge for this quest
  GameState *gs = [GameState sharedGameState];
  FullUserQuestDataLargeProto_Builder *bldr = [FullUserQuestDataLargeProto builder];
  bldr.userId = gs.userId;
  bldr.questId = fqp.questId;
  bldr.isRedeemed = NO;
  bldr.isComplete = NO;
  
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
    MinimumUserPossessEquipJobProto_Builder *b = [MinimumUserPossessEquipJobProto builder];
    b.possessEquipJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    b.numEquipUserHas = 0;
    [bldr addRequiredPossessEquipJobProgress:[b build]];
  }
  for (NSNumber *n in fqp.buildStructJobsReqsList) {
    MinimumUserBuildStructJobProto_Builder *b = [MinimumUserBuildStructJobProto builder];
    b.buildStructJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    b.numOfStructUserHas = 0;
    [bldr addRequiredBuildStructJobProgress:[b build]];
  }
  for (NSNumber *n in fqp.upgradeStructJobsReqsList) {
    MinimumUserUpgradeStructJobProto_Builder *b = [MinimumUserUpgradeStructJobProto builder];
    b.upgradeStructJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = fqp.questId;
    b.currentLevel = 0;
    [bldr addRequiredUpgradeStructJobProgress:[b build]];
  }
  
  taskListDelegate.quest = fqp;
  taskListTitleLabel.text = fqp.name;
  [taskListDelegate updateTasksForUserData:[NSArray arrayWithObject:bldr.build]];
  [taskListTable reloadData];
  [QuestLogController displayView];
  [self showTaskListViewAnimated:NO];
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
  self.qcView = nil;
  self.questListTable = nil;
  self.taskListTable = nil;
  self.questListView = nil;
  self.taskListView = nil;
  self.questListDelegate = nil;
  self.taskListDelegate = nil;
  self.userLogData = nil;
  self.taskListTitleLabel = nil;
}

- (QuestCompleteView *) createQuestCompleteView {
  [[NSBundle mainBundle] loadNibNamed:@"QuestCompleteView" owner:self options:nil];
  QuestCompleteView *q = [self.qcView retain];
  self.qcView = nil;
  return [q autorelease];
}

@end
