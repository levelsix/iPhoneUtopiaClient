//
//  ClanTowerScoresTab.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/24/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "Protocols.pb.h"
#import "UserData.h"
#import "cocos2d.h"

@interface ClanTowerTickerCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *attackerLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenderLabel;
@property (nonatomic, retain) IBOutlet UILabel *middleLabel;
@property (nonatomic, retain) IBOutlet UILabel *endLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *pointsLabel;

- (void) updateForUserBattle:(ClanTowerUserBattle *)ctub;

@end

@interface ClanTowerTickerDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *userBattles;
@property (nonatomic, retain) IBOutlet ClanTowerTickerCell *tickerCell;

@end

@interface ClanTowerScoresCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *userIcon;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UIButton *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *gainedLabel;
@property (nonatomic, retain) IBOutlet UILabel *slashLabel;
@property (nonatomic, retain) IBOutlet UILabel *lostLabel;

@property (nonatomic, retain) CAGradientLayer *gradientLayer;

@property (nonatomic, retain) MinimumUserProtoForClanTowerScores *user;

- (void) updateForUser:(MinimumUserProtoForClanTowerScores *)u rank:(int)rank;

@end

@interface ClanTowerScoresTab : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) int towerId;
@property (nonatomic, retain) NSArray *ownerMembers;
@property (nonatomic, retain) NSArray *attackerMembers;

@property (nonatomic, retain) IBOutlet UILabel *ownerLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackerLabel;
@property (nonatomic, retain) IBOutlet UITableView *ownerTable;
@property (nonatomic, retain) IBOutlet UITableView *attackerTable;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *ownerSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *attackerSpinner;

@property (nonatomic, retain) IBOutlet UITableView *tickerTable;
@property (nonatomic, retain) IBOutlet ClanTowerTickerDelegate *tickerDelegate;

@property (nonatomic, retain) IBOutlet ClanTowerScoresCell *scoresCell;

- (void) preloadForTowerId:(int)towerId;
- (void) loadForOwnerMembers:(NSArray *)ownerMembers attackerMembers:(NSArray *)attackerMembers;

- (void) addedUserBattle:(ClanTowerUserBattle *)ctub;
- (void) removedUserBattlesForTowerId:(int)towerId;

@end
