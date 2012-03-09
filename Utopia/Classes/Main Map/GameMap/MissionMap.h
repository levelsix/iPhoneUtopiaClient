//
//  MissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "Protocols.pb.h"

@class MissionMap;

@interface MissionBuildingSummaryMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *energyLabel;
@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *experienceLabel;

@end

@interface MissionOverBuildingMenu : UIView {
  NSMutableArray *_separators;
  MissionMap *missionMap;
}

@property (nonatomic, retain) IBOutlet UIImageView *progressBar;

- (void) setMissionMap:(MissionMap *)m;

@end

@interface MissionMap : GameMap {
  NSMutableArray *_walkableData;
}

@property (nonatomic, retain) IBOutlet MissionBuildingSummaryMenu *summaryMenu;
@property (nonatomic, retain) IBOutlet MissionOverBuildingMenu *obMenu;

@property (nonatomic, retain) NSMutableArray *walkableData;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto;
- (id) assetWithId:(int)assetId;
- (void) performCurrentTask;
- (CGPoint) randomWalkablePosition;
- (CGPoint) nextWalkablePositionFromPoint:(CGPoint) point;

@end
