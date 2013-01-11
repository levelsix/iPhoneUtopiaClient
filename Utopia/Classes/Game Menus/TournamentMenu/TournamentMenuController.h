//
//  TournamentMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "TournamentViews.h"
#import "PullRefreshTableViewController.h"

@interface TournamentMenuController : PullRefreshTableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *prizeViews;
@property (nonatomic, retain) IBOutlet TournamentPrizeView *nibView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *eventTimeLabel;

@property (nonatomic, retain) IBOutlet UIView *prizeView;
@property (nonatomic, retain) IBOutlet TournamentLeaderboardView *leaderboardView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSTimer *timer;

- (void) receivedLeaderboardResponse:(RetrieveLeaderboardRankingsResponseProto *)proto;

- (IBAction)closeClicked:(id)sender;
- (IBAction)rulesClicked:(id)sender;

+ (TournamentMenuController *) sharedTournamentMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

@end
