//
//  TravellingMissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/1/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Info.pb.h"

@interface ContinentView : UIButton

@property (nonatomic, retain) IBOutlet UIImageView *lock;

@end

@interface CityView : UIButton

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) FullCityProto *fcp;

@end

@interface TravellingMissionMap : UIView

@property (nonatomic, retain) IBOutlet UIView *lumoriaView;

- (IBAction) continentClicked:(ContinentView *)cv;

@end
