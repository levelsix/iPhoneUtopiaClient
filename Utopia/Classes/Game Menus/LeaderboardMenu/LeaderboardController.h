//
//  LeaderboardController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "PullRefreshTableViewController.h"

typedef enum {
  kButton1 = 1,
  kButton2 = 1 << 1,
  kButton3 = 1 << 2,
  kButton4 = 1 << 3,
  kButton5 = 1 << 4
} LeaderboardBarButton;

@interface LeaderboardBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  BOOL _trackingButton3;
  BOOL _trackingButton4;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UILabel *button1Label;
@property (nonatomic, retain) IBOutlet UILabel *button2Label;
@property (nonatomic, retain) IBOutlet UILabel *button3Label;
@property (nonatomic, retain) IBOutlet UILabel *button4Label;

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;
@property (nonatomic, retain) IBOutlet UIImageView *button3;
@property (nonatomic, retain) IBOutlet UIImageView *button4;

@end

@interface LeaderboardCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *userIcon;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UIButton *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightLabel;
@property (nonatomic, retain) IBOutlet UIView *attackButton;

@property (nonatomic, retain) MinimumUserProtoWithLevelForLeaderboard *user;

- (void) updateForUser:(MinimumUserProtoWithLevelForLeaderboard *)u forState:(LeaderboardType)type;

@end

@interface LeaderboardController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) LeaderboardType state;

@property (nonatomic, retain) IBOutlet LeaderboardBar *topBar;

@property (nonatomic, retain) IBOutlet UITableView *leaderboardTable;

@property (nonatomic, retain) IBOutlet UIView *youHeaderView;
@property (nonatomic, retain) IBOutlet UIView *topPlayersHeaderView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet LeaderboardCell *leaderboardCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *loadingCell;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSMutableArray *kdrList;
@property (nonatomic, retain) NSMutableArray *winsList;
@property (nonatomic, retain) NSMutableArray *levelList;
@property (nonatomic, retain) NSMutableArray *silverList;

@property (nonatomic, retain) MinimumUserProtoWithLevelForLeaderboard *kdrMup;
@property (nonatomic, retain) MinimumUserProtoWithLevelForLeaderboard *winsMup;
@property (nonatomic, retain) MinimumUserProtoWithLevelForLeaderboard *levelMup;
@property (nonatomic, retain) MinimumUserProtoWithLevelForLeaderboard *silverMup;

@property (nonatomic, assign) BOOL shouldReload;

- (void) receivedLeaderboardResponse:(RetrieveLeaderboardResponseProto *)proto;

- (IBAction) closeClicked:(id)sender;

+ (LeaderboardController *) sharedLeaderboardController;
+ (void) purgeSingleton;
+ (void) displayView;
+ (void) removeView;
+ (BOOL) isInitialized;

@end
