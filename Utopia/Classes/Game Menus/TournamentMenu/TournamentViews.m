//
//  TournamentViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TournamentViews.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "BattleLayer.h"

#define REFRESH_ROWS 5

@implementation TournamentPrizeView

- (void) loadForTournamentPrize:(LeaderboardEventRewardProto *)r {
  [Globals imageNamed:r.prizeImageName withImageView:self.prizeIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  [Globals imageNamed:r.backgroundImageName withImageView:self.bgdImage maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  
  self.prizeLabel.text = [NSString stringWithFormat:@"%@ Gold", [Globals commafyNumber:r.goldRewarded]];
  
  NSString *ranks = nil;
  if (r.minRank == r.maxRank) {
    ranks = [NSString stringWithFormat:@"%@ Place", [self convertNumToPlace:r.minRank]];
  } else {
    ranks = [NSString stringWithFormat:@"%@ - %@", [self convertNumToPlace:r.minRank], [self convertNumToPlace:r.maxRank]];
  }
  self.ranksLabel.text = ranks;
}

- (NSString *) convertNumToPlace:(int)num {
  NSString *s = [NSMutableString stringWithFormat:@"%d", num];
  
  int onesDigit = num % 10;
  NSString *end = nil;
  switch (onesDigit) {
    case 1:
      end = @"st";
      break;
    case 2:
      end = @"nd";
      break;
    case 3:
      end = @"rd";
      break;
    default:
      end = @"th";
      break;
  }
  return [NSString stringWithFormat:@"%@%@", s, end];
}

- (void) dealloc {
  self.prizeIcon = nil;
  self.prizeLabel = nil;
  self.ranksLabel = nil;
  self.bgdImage = nil;
  [super dealloc];
}

@end

@implementation TournamentLeaderboardView

@synthesize youHeaderView, topPlayersHeaderView;
@synthesize leaderboardCell, loadingCell;
@synthesize leaderboardList, leaderboardMup;
@synthesize leaderboardTable;
@synthesize spinner;
@synthesize shouldReload;

//- (id) init {
//  Globals *gl = [Globals sharedGlobals];
//  return [self initWithNibName:@"LeaderboardController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.leaderboardNibName]];
//}

- (void) awakeFromNib
{
  self.leaderboardList = [NSMutableArray array];
  self.leaderboardTable.tableFooterView = [[[UIView alloc] init] autorelease];
  
  [(UIActivityIndicatorView *)[self.loadingCell viewWithTag:31] startAnimating];
}

- (IBAction)attackClicked:(id)sender {
  LeaderboardCell *cell = (LeaderboardCell *)[[[sender superview] superview] superview];
  MinimumUserProto *mup = cell.user.minUserProto;
  FullUserProto *fup = [self.userDict objectForKey:[NSNumber numberWithInt:mup.userId]];
  if (fup) {
    [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup];
  }
}

- (void) refresh {
  GameState *gs = [GameState sharedGameState];
  LeaderboardEventProto *e = [gs getCurrentTournament];
  [[OutgoingEventController sharedOutgoingEventController] retrieveTournamentRanking:e.eventId afterRank:0];
  [self.leaderboardTable setContentOffset:ccp(0,0)];
  [self.leaderboardList removeAllObjects];
  [self.leaderboardTable reloadData];
  self.shouldReload = NO;
  
  self.userDict = [NSMutableDictionary dictionary];
}

- (void) receivedLeaderboardResponse:(RetrieveLeaderboardRankingsResponseProto *)proto {
  [self addUsersFrom:proto.resultPlayersList toArray:leaderboardList];
  self.leaderboardMup = proto.retriever;
  
  [self.leaderboardTable reloadData];
  self.shouldReload = YES;
  
  for (FullUserProto *fup in proto.fullUsersList) {
    [self.userDict setObject:fup forKey:[NSNumber numberWithInt:fup.userId]];
  }
}

- (void) addUsersFrom:(NSArray *)arr toArray:(NSMutableArray *)mut {
  for (MinimumUserProtoWithLevelForLeaderboard *usr in arr) {
    MinimumUserProtoWithLevelForLeaderboard *remove = nil;
    for (MinimumUserProtoWithLevelForLeaderboard *chk in mut) {
      if (chk.leaderboardRank == usr.leaderboardRank) {
        remove = chk;
        break;
      }
    }
    if (remove) {
      [mut removeObject:remove];
    }
    [mut addObject:usr];
  }
  
  [mut sortUsingComparator:^NSComparisonResult(MinimumUserProtoWithLevelForLeaderboard *obj1, MinimumUserProtoWithLevelForLeaderboard *obj2) {
    if (obj1.leaderboardRank > obj2.leaderboardRank) {
      return NSOrderedDescending;
    } else if (obj1.leaderboardRank == obj2.leaderboardRank) {
      return NSOrderedSame;
    } else {
      return NSOrderedAscending;
    }
  }];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSMutableArray *arr = self.leaderboardList;
  if (arr.count == 0) {
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
    
    return 0;
  } else {
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
    
    if (section == 0) {
      return 1;
    } else if (section == 1) {
      return arr.count+1;
    }
  }
  return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSMutableArray *arr = self.leaderboardList;
  if (arr.count == 0) {
    // return empty view
  } else if (section == 0) {
    return self.youHeaderView;
  } else if (section == 1) {
    return self.topPlayersHeaderView;
  }
  return [[[UIView alloc] init] autorelease];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSMutableArray *arr = self.leaderboardList;
  if (indexPath.section == 1 && indexPath.row >= arr.count) {
    return self.loadingCell;
  }
  
  LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TournamentCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"TournamentCell" owner:self options:nil];
    cell = self.leaderboardCell;
  }
  
  MinimumUserProtoWithLevelForLeaderboard *u = nil;
  if (indexPath.section == 0) {
    u = self.leaderboardMup;
  } else if (indexPath.section == 1) {
    u = [arr objectAtIndex:indexPath.row];
  }
  [cell updateForUser:u forState:LeaderboardTypeEvent];
  
  cell.rankLabel.textColor = [self colorForRank:u.leaderboardRank];
  
  GameState *gs = [GameState sharedGameState];
  cell.attackButton.hidden = [Globals userType:u.minUserProto.userType isAlliesWith:gs.type];
  
  return cell;
}

- (UIColor *) colorForRank:(int)rank {
  GameState *gs = [GameState sharedGameState];
  LeaderboardEventProto *e = [gs getCurrentTournament];
  
  for (LeaderboardEventRewardProto *r in e.rewardsList) {
    if (rank >= r.minRank && rank <= r.maxRank) {
      return [Globals colorForColorProto:r.titleColor];
    }
  }
  return [Globals creamColor];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Load more rows when we get low enough
  if (scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.frame.size.height-REFRESH_ROWS*self.leaderboardTable.rowHeight) {
    if (shouldReload) {
      NSArray *arr = self.leaderboardList;
      MinimumUserProtoWithLevelForLeaderboard *mup = [arr lastObject];
      [[OutgoingEventController sharedOutgoingEventController] retrieveLeaderboardForType:LeaderboardTypeEvent afterRank:mup.leaderboardRank];
      self.shouldReload = NO;
    }
  }
}

- (void) dealloc
{
  self.youHeaderView = nil;
  self.topPlayersHeaderView = nil;
  self.leaderboardList = nil;
  self.leaderboardMup = nil;
  self.leaderboardTable = nil;
  self.leaderboardCell = nil;
  self.spinner = nil;
  self.loadingCell = nil;
  self.userDict = nil;
  [super dealloc];
}

@end
