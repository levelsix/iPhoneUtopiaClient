//
//  TravellingMissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/1/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Info.pb.h"
#import "NibUtils.h"

@interface ContinentView : ServerButton

@property (nonatomic, retain) IBOutlet UIImageView *lock;

@end

@interface CityView : UIButton

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, retain) FullCityProto *fcp;

@end

@interface CloseUpContinentView : UIView {
  FullCityProto *_fcp;
}

@property (nonatomic, retain) IBOutlet UIView *cityPopup;
@property (nonatomic, retain) IBOutlet UILabel *cityNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityRankLabel;
@property (nonatomic, retain) IBOutlet UIImageView *progressBar;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;

@end

@interface TravellingMissionMap : UIView

@property (nonatomic, retain) IBOutlet CloseUpContinentView *lumoriaView;

- (IBAction) continentClicked:(ContinentView *)cv;

@end
