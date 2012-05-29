//
//  MissionBuildingMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

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