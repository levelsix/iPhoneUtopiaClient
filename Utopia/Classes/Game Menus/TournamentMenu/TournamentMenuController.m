//
//  TournamentMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TournamentMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "Globals.h"
#import "GameState.h"
#import "BattleLayer.h"
#import "GenericPopupController.h"

#define PRIZE_VIEW_SPACING 5.f

@implementation TournamentMenuController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(TournamentMenuController);

- (void) viewDidLoad {
  self.leaderboardView.frame = self.prizeView.frame;
  [self.prizeView.superview addSubview:self.leaderboardView];
  self.leaderboardView.hidden = YES;
  
  [super addPullToRefreshHeader:self.leaderboardView.leaderboardTable];
  [self.leaderboardView.leaderboardTable addSubview:self.refreshHeaderView];
  self.refreshHeaderView.center = ccp(self.leaderboardView.leaderboardTable.frame.size.width/2, -self.refreshHeaderView.frame.size.height/2);
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self loadForCurrentTournament];
  
  [self.leaderboardView refresh];
}

- (void) viewDidDisappear:(BOOL)animated {
  self.timer = nil;
}

- (void) setTimer:(NSTimer *)t {
  if (_timer != t) {
    [_timer invalidate];
    [_timer release];
    _timer = [t retain];
  }
}

- (void) loadForCurrentTournament {
  GameState *gs = [GameState sharedGameState];
  LeaderboardEventProto *t = [gs getCurrentTournament];
  
  if (!t) {
    [self closeClicked:nil];
    self.timer = nil;
    return;
  }
  
  [self loadScrollViewForRewards:t.rewardsList];
  
  [self updateLabels];
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  LeaderboardEventProto *t = [gs getCurrentTournament];
  
  if (!t) {
    [self loadForCurrentTournament];
    return;
  }
  
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:t.endDate/1000.0];
  int secs = endDate.timeIntervalSinceNow;
  NSString *time;
  if (secs > 0) {
    int days = (int)(secs/86400);
    secs %= 86400;
    int hrs = (int)(secs/3600);
    secs %= 3600;
    int mins = (int)(secs/60);
    secs %= 60;
    NSString *daysString = days ? [NSString stringWithFormat:@"%d day%@, ", days, days == 1 ? @"" : @"s"] : @"";
    NSString *hrsString = days || hrs ? [NSString stringWithFormat:@"%d hr%@, ", hrs, hrs == 1 ? @"" : @"s"] : @"";
    NSString *minsString = days || hrs || mins ? [NSString stringWithFormat:@"%d min%@, ", mins, mins == 1 ? @"" : @"s"] : @"";
    NSString *secsString = [NSString stringWithFormat:@"%d sec%@", secs, secs == 1 ? @"" : @"s"];
    time = [NSString stringWithFormat:@"%@%@%@%@", daysString, hrsString, minsString, secsString];
  } else {
    time = @"The tournament has ended.";
  }
  
  self.eventTimeLabel.text = time;
}

- (TournamentPrizeView *) getPrizeViewForIndex:(int)index {
  if (!self.prizeViews) {
    self.prizeViews = [NSMutableArray array];
  }
  
  while (index >= self.prizeViews.count) {
    [[NSBundle mainBundle] loadNibNamed:@"TournamentPrizeView" owner:self options:nil];
    [self.prizeViews addObject:self.nibView];
  }
  
  return [self.prizeViews objectAtIndex:index];
}

- (void) loadScrollViewForRewards:(NSArray *)rewards {
  // Make sure they are sorted first
  rewards = [rewards sortedArrayUsingComparator:^NSComparisonResult(LeaderboardEventRewardProto *obj1, LeaderboardEventRewardProto *obj2) {
    if (obj1.minRank < obj2.minRank) {
      return NSOrderedAscending;
    } else if (obj1.minRank > obj2.minRank) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  
  for (int i = 0; i < rewards.count; i++) {
    TournamentPrizeView *tpv = [self getPrizeViewForIndex:i];
    LeaderboardEventRewardProto *reward = [rewards objectAtIndex:i];
    [tpv loadForTournamentPrize:reward];
    
    [self.scrollView addSubview:tpv];
    
    tpv.center = CGPointMake((PRIZE_VIEW_SPACING+tpv.frame.size.width)*(i+0.5), self.scrollView.frame.size.height/2);
  }
  
  TournamentPrizeView *tv = [self.prizeViews lastObject];
  self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(tv.frame)+PRIZE_VIEW_SPACING/2, self.scrollView.frame.size.height);
  
  if (rewards.count < self.prizeViews.count) {
    [self.prizeViews removeObjectsInRange:NSMakeRange(rewards.count, self.prizeViews.count-rewards.count)];
  }
}

- (IBAction)leaderboardClicked:(id)sender {
  CGPoint lvCenter = self.leaderboardView.center;
  CGPoint pvCenter = self.prizeView.center;
  self.leaderboardView.center = ccpAdd(lvCenter, ccp(self.leaderboardView.frame.size.width, 0));
  self.leaderboardView.hidden = NO;
  [UIView animateWithDuration:0.3f animations:^{
    self.leaderboardView.center = lvCenter;
    self.prizeView.center = ccpAdd(pvCenter, ccp(-self.prizeView.frame.size.width, 0));
  } completion:^(BOOL finished) {
    self.prizeView.center = pvCenter;
    self.prizeView.hidden = YES;
  }];
}

- (IBAction)backClicked:(id)sender {
  CGPoint lvCenter = self.leaderboardView.center;
  CGPoint pvCenter = self.prizeView.center;
  self.prizeView.center = ccpAdd(pvCenter, ccp(-self.prizeView.frame.size.width, 0));
  self.prizeView.hidden = NO;
  [UIView animateWithDuration:0.3f animations:^{
    self.prizeView.center = pvCenter;
    self.leaderboardView.center = ccpAdd(lvCenter, ccp(self.leaderboardView.frame.size.width, 0));
  } completion:^(BOOL finished) {
    self.leaderboardView.center = lvCenter;
    self.leaderboardView.hidden = YES;
  }];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
}

- (IBAction)rulesClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  NSString *desc = [NSString stringWithFormat:@"Every win is %d points, every loss is %d points, and every flee is %d points.", gl.tournamentWinsWeight, gl.tournamentLossesWeight, gl.tournamentFleesWeight];
  [GenericPopupController displayNotificationViewWithText:desc title:@"Tournament Rules"];
}

- (void) refresh {
  [self.leaderboardView refresh];
  [self stopLoading];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.leaderboardView numberOfSectionsInTableView:tableView];
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.leaderboardView tableView:tableView numberOfRowsInSection:section];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return [self.leaderboardView tableView:tableView viewForHeaderInSection:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self.leaderboardView tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.leaderboardView scrollViewDidScroll:scrollView];
  [super scrollViewDidScroll:scrollView];
}

- (void) receivedLeaderboardResponse:(RetrieveLeaderboardRankingsResponseProto *)proto {
  [self.leaderboardView receivedLeaderboardResponse:proto];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (!self.view.superview) {
    self.view = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.prizeViews = nil;
    self.nibView = nil;
    self.scrollView = nil;
    self.eventTimeLabel = nil;
    self.refreshArrow = nil;
    self.refreshHeaderView = nil;
    self.refreshLabel = nil;
    self.refreshSpinner = nil;
  }
}

@end
