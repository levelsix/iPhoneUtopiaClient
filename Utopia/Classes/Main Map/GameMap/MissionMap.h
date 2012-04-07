//
//  MissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "Protocols.pb.h"
#import "CCLabelFX.h"

#define ASSET_TAG_BASE 2555

@class MissionMap;

@interface MissionBuildingSummaryMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *energyLabel;
@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *experienceLabel;
@property (nonatomic, retain) IBOutlet UILabel *itemChanceLabel;

@end

@interface MissionOverBuildingMenu : UIView {
  NSMutableArray *_separators;
  MissionMap *missionMap;
}

@property (nonatomic, retain) IBOutlet UIImageView *progressBar;

- (void) setMissionMap:(MissionMap *)m;

@end

@interface TaskProgressBar : CCSprite {
  CCProgressTimer *_progressBar;
  CCLabelFX *_label;
}

@property (nonatomic, assign) BOOL isAnimating;

- (void) animateBarWithText:(NSString *)str;

@end

@interface MissionMap : GameMap {
  int _cityId;
  
  TaskProgressBar *_taskProgBar;
  
  BOOL _receivedTaskActionResponse;
  BOOL _performingTask;
}

@property (nonatomic, retain) IBOutlet MissionBuildingSummaryMenu *summaryMenu;
@property (nonatomic, retain) IBOutlet MissionOverBuildingMenu *obMenu;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto;
- (id) assetWithId:(int)assetId;
- (void) moveToAssetId:(int)a;
- (void) performCurrentTask;
- (void) receivedTaskResponse:(TaskActionResponseProto *)tarp;
- (void) changeTiles: (CGRect) buildBlock canWalk:(BOOL)canWalk;

- (void) killEnemy:(int)userId;

- (void) closeMenus;
- (void) questAccepted:(FullQuestProto *)fqp;
- (void) reloadQuestGivers;
- (void) receivedQuestAcceptResponse:(QuestAcceptResponseProto *)qarp;

@end
