//
//  QuestLogController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "UserData.h"
#import "NibUtils.h"

@interface RewardCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView *withEquipView;
@property (nonatomic, retain) IBOutlet UIView *withoutEquipView;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *smallExpLabel;
@property (nonatomic, retain) IBOutlet UILabel *bigExpLabel;
@property (nonatomic, retain) IBOutlet UILabel *smallCoinLabel;
@property (nonatomic, retain) IBOutlet UILabel *bigCoinLabel;
@property (nonatomic, retain) IBOutlet UIView *claimView;

@end

@interface DescriptionCell : UITableViewCell {
  int _cityId;
  int _assetNum;
}

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIView *visitView;
@property (nonatomic, retain) IBOutlet UIImageView *questGiverImageView;

- (void) updateForQuest:(FullQuestProto *)fqp visitActivated:(BOOL)visitActivated redeeming:(BOOL)redeeming;

@end

@interface QuestCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIView *availableView;
@property (nonatomic, retain) IBOutlet UIView *inProgressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIImageView *questGiverImageView;

@property (nonatomic, retain) FullQuestProto *quest;

@end

@interface JobCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIView *completedView;
@property (nonatomic, retain) IBOutlet UIView *inProgressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) UserJob *job;

@end

@interface QuestListTableDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet QuestCell *questCell;

@end

@interface TaskListTableDelegate : NSObject <UITableViewDelegate, UITableViewDataSource> {
  BOOL _receivedData;
  BOOL _questRedeem;
}

@property (nonatomic, retain) IBOutlet JobCell *jobCell;
@property (nonatomic, retain) IBOutlet RewardCell *rewardCell;
@property (nonatomic, retain) IBOutlet DescriptionCell *descriptionCell;
@property (nonatomic, retain) FullQuestProto *quest;
@property (nonatomic, retain) NSArray *jobs;
@property (nonatomic, assign) BOOL questRedeem;

@end

@interface QuestLogController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *questListView;
@property (nonatomic, retain) IBOutlet UIView *taskListView;
@property (nonatomic, retain) IBOutlet UITableView *questListTable;
@property (nonatomic, retain) IBOutlet UITableView *taskListTable;

@property (nonatomic, retain) IBOutlet UILabel *taskListTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *backButton;

@property (nonatomic, retain) IBOutlet UIImageView *questGiverImageView;

@property (nonatomic, retain) QuestListTableDelegate *questListDelegate;
@property (nonatomic, retain) TaskListTableDelegate *taskListDelegate;

@property (nonatomic, retain) NSArray *userLogData;

- (void) questSelected:(FullQuestProto *)fqp;
- (void) showQuestListViewAnimated:(BOOL)animated;
- (void) showTaskListViewAnimated:(BOOL)animated;

- (void) close;

- (void) loadQuestLog;
- (void) loadQuest:(FullQuestProto *)fqp;
- (void) loadQuestAcceptScreen:(FullQuestProto *)fqp;
- (void) loadQuestCompleteScreen:(FullQuestProto *)fqp;
- (void) loadQuestRedeemScreen:(FullQuestProto *)fqp;
- (void) loadQuestData:(NSArray *)quests;
- (FullUserQuestDataLargeProto *) loadFakeQuest:(FullQuestProto *)fqp;

+ (QuestLogController *) sharedQuestLogController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
