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

@interface QuestCompleteView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *questNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *visitDescLabel;

@end

@interface QuestCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIView *availableView;
@property (nonatomic, retain) IBOutlet UIView *inProgressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

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
}

@property (nonatomic, retain) IBOutlet JobCell *jobCell;
@property (nonatomic, retain) FullQuestProto *quest;
@property (nonatomic, retain) NSArray *jobs;

@end

@interface QuestLogController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *questListView;
@property (nonatomic, retain) IBOutlet UIView *taskListView;
@property (nonatomic, retain) IBOutlet UITableView *questListTable;
@property (nonatomic, retain) IBOutlet UITableView *taskListTable;

@property (nonatomic, retain) IBOutlet UILabel *taskListTitleLabel;

@property (nonatomic, retain) IBOutlet QuestCompleteView *qcView;

@property (nonatomic, retain) QuestListTableDelegate *questListDelegate;
@property (nonatomic, retain) TaskListTableDelegate *taskListDelegate;

@property (nonatomic, retain) NSArray *userLogData;

- (void) questSelected:(FullQuestProto *)fqp;
- (void) showQuestListViewAnimated:(BOOL)animated;
- (void) showTaskListViewAnimated:(BOOL)animated;

- (IBAction)closeClicked:(id)sender;

- (void) loadQuestData:(NSArray *)quests;
- (void) loadFakeQuest:(FullQuestProto *)fqp;

- (QuestCompleteView *) createQuestCompleteView;

+ (QuestLogController *) sharedQuestLogController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
