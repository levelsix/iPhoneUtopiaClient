//
//  TournamentViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "LeaderboardController.h"

@interface TournamentLeaderboardView : UIView

@property (nonatomic, retain) IBOutlet UITableView *leaderboardTable;

@property (nonatomic, retain) IBOutlet UIView *youHeaderView;
@property (nonatomic, retain) IBOutlet UIView *topPlayersHeaderView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet LeaderboardCell *leaderboardCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *loadingCell;

@property (nonatomic, retain) NSMutableArray *leaderboardList;

@property (nonatomic, retain) MinimumUserProtoWithLevelForLeaderboard *leaderboardMup;

@property (nonatomic, assign) BOOL shouldReload;

- (void) refresh;

- (int) numberOfSectionsInTableView:(UITableView *)tableView;
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void) receivedLeaderboardResponse:(RetrieveLeaderboardRankingsResponseProto *)proto;

@end

@interface TournamentPrizeView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;
@property (nonatomic, retain) IBOutlet UIImageView *prizeIcon;
@property (nonatomic, retain) IBOutlet UILabel *ranksLabel;
@property (nonatomic, retain) IBOutlet UILabel *prizeLabel;

- (void) loadForTournamentPrize:(LeaderboardEventRewardProto *)r;

@end
