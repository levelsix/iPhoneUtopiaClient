//
//  MissionBuildingMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"
#import "NibUtils.h"

@class MissionMap;

@interface MissionBuildingSummaryMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *energyLabel;
@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *experienceLabel;
@property (nonatomic, retain) IBOutlet UILabel *itemChanceLabel;

- (void) updateLabelsForTask:(FullTaskProto *)ftp name:(NSString *)name;

@end

@interface MissionOverBuildingMenu : UIView {
  MissionMap *missionMap;
}

@property (nonatomic, retain) IBOutlet ProgressBar *progressBar;

- (void) updateMenuForTotal:(int)total numTimesActed:(int)numTimesActed isForQuest:(BOOL)highlighted;
- (void) setMissionMap:(MissionMap *)m;

@end