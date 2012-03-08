//
//  QuestLogController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"

typedef enum {
  kTask = 1,
  kDefeatTypeJob,
  kBuildStructJob,
  kUpgradeStructJob,
  kPossessEquipJob
} TaskItemType;

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

@property (nonatomic, retain) IBOutlet NSMutableArray *questItemViews;
@property (nonatomic, retain) IBOutlet UILabel *curQuestsLabel;
@property (nonatomic, retain) IBOutlet QuestListScrollView *scrollView;

- (void) viewClicked:(id)sender;

@end

@interface RewardsView : UIView 

@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinRewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *expLabel;
@property (nonatomic, retain) IBOutlet UILabel *expRewardLabel;
@property (nonatomic, retain) IBOutlet UIWebView *rewardWebView;

- (void) updateWebView;

@end

@interface QuestDescriptionView : UIView

@property (nonatomic, retain) IBOutlet UILabel *questNameLabel;
@property (nonatomic, retain) UILabel *questDescLabel;
@property (nonatomic, retain) IBOutlet RewardsView *rewardView;
@property (nonatomic, retain) IBOutlet GradientScrollView *scrollView;

@end

@interface TaskItemView : UIView

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *bgdBar;
@property (nonatomic, retain) UIImageView *taskBar;
@property (nonatomic, retain) UIButton *visitButton;
@property (nonatomic, assign) TaskItemType type;
@property (nonatomic, assign) int jobId;

- (id) initWithFrame:(CGRect)frame text: (NSString *)string taskFinished:(int)completed outOf:(int)total type:(TaskItemType)t jobId:(int)j;

@end

@interface TaskListScrollView : GradientScrollView 
@end

@interface TaskListView : UIView

@property (nonatomic, retain) IBOutlet UILabel *questNameLabel;
@property (nonatomic, retain) IBOutlet TaskListScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *taskItemViews;

@end

@interface QuestLogController : UIViewController {
  UIView *_curView;
}

@property (nonatomic, retain) IBOutlet QuestDescriptionView *questDescView;
@property (nonatomic, retain) IBOutlet TaskListView *taskView;
@property (nonatomic, retain) IBOutlet QuestListView *questListView;
@property (nonatomic, retain) NSArray *userLogData;

- (void) refreshWithQuests:(NSArray *)quests;
+ (QuestLogController *) sharedQuestLogController;
+ (void) displayView;
+ (void) removeView;
- (void) resetToQuestDescView:(FullQuestProto *)fqp;

@end
