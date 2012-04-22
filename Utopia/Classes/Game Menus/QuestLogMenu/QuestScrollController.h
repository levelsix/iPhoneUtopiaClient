//
//  QuestLogController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"
#import "UserData.h"

//@interface QuestCompleteView : UIView
//
//@property (nonatomic, retain) IBOutlet UILabel *questNameLabel;
//@property (nonatomic, retain) IBOutlet UILabel *visitDescLabel;
//
//@end

@interface GradientScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *topGradient;
@property (nonatomic, retain) IBOutlet UIImageView *botGradient;
@property (retain) NSTimer *timer;

@end

@interface QuestListScrollView : GradientScrollView

@end

@interface QuestItemView : UIView 

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) FullQuestProto *fqp;

@end

@interface QuestListView : UIView {
  UIView *_clickedView;
}

@property (nonatomic, retain) NSMutableArray *questItemViews;
@property (nonatomic, retain) IBOutlet UILabel *curQuestsLabel;
@property (nonatomic, retain) IBOutlet QuestListScrollView *scrollView;

- (void) viewClicked:(id)sender;

@end

@interface RewardsView : UIView 

@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinRewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *expLabel;
@property (nonatomic, retain) IBOutlet UILabel *expRewardLabel;
@property (nonatomic, retain) IBOutlet UIView *equipView;
@property (nonatomic, retain) IBOutlet UILabel *equipNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipAttLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipDefLabel;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;

@end

@interface QuestDescriptionView : UIView

@property (nonatomic, retain) IBOutlet UILabel *questNameLabel;
@property (nonatomic, retain) UILabel *questDescLabel;
@property (nonatomic, retain) IBOutlet RewardsView *rewardView;
@property (nonatomic, retain) IBOutlet GradientScrollView *scrollView;

- (void) setQuestDescription:(NSString *)description;

@end

@interface TaskItemView : UIView

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *bgdBar;
@property (nonatomic, retain) UIImageView *taskBar;
@property (nonatomic, retain) UIButton *visitButton;
@property (nonatomic, assign) JobItemType type;
@property (nonatomic, assign) int jobId;

- (id) initWithFrame:(CGRect)frame text: (NSString *)string taskFinished:(int)completed outOf:(int)total type:(JobItemType)t jobId:(int)j;

@end

@interface TaskListScrollView : GradientScrollView 
@end

@interface TaskListView : UIView

@property (nonatomic, retain) IBOutlet UILabel *questNameLabel;
@property (nonatomic, retain) IBOutlet TaskListScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *taskItemViews;

- (void) unloadTasks;

@end

@interface QuestScrollController : UIViewController {
  UIView *_curView;
  FullQuestProto *_fqp;
  BOOL _closing;
}

@property (nonatomic, retain) IBOutlet QuestDescriptionView *questDescView;
@property (nonatomic, retain) IBOutlet TaskListView *taskView;
@property (nonatomic, retain) IBOutlet QuestListView *questListView;
@property (nonatomic, retain) IBOutlet UIView *rightPage;
@property (nonatomic, retain) IBOutlet UIView *toTaskButton;
@property (nonatomic, retain) IBOutlet UIView *redeemButton;
@property (nonatomic, retain) IBOutlet UIView *acceptButtons;
@property (nonatomic, retain) NSArray *userLogData;

@property (nonatomic, retain) IBOutlet UILabel *redeemLabel;

+ (QuestScrollController *) sharedQuestScrollController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (void) cleanupAndPurgeSingleton;

- (void) loadQuestData:(NSArray *)quests;
- (void) resetToQuestDescView:(FullQuestProto *)fqp;
- (void) displayRightPageForQuest:(id)fqp inProgress:(BOOL)inProgress;

- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)taskButtonTapped:(id)sender;
- (IBAction)questDescButtonTapped:(id)sender;
- (IBAction)redeemTapped:(id)sender;
- (IBAction)acceptTapped:(id)sender;

@end
