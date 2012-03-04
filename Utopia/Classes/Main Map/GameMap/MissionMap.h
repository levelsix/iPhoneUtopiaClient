//
//  MissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "Protocols.pb.h"

@interface MissionBuildingSummaryMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *energyLabel;
@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *experienceLabel;

@end

@interface MissionOverBuildingMenu : UIView {
  NSMutableArray *_separators;
}

@property (nonatomic, retain) IBOutlet UIImageView *progressBar;

@end

@interface MissionMap : GameMap

@property (nonatomic, retain) IBOutlet MissionBuildingSummaryMenu *summaryMenu;
@property (nonatomic, retain) IBOutlet MissionOverBuildingMenu *obMenu;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto;
- (id) assetWithId:(int)assetId;

@end
