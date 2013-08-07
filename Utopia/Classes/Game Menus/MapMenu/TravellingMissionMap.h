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

@interface ContinentView : UIButton

@property (nonatomic, retain) IBOutlet UIImageView *lock;

@end

@interface CityView : UIButton {
  int _bossId;
  CGRect originalRect;
}

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, retain) FullCityProto *fcp;

@property (nonatomic, retain) IBOutlet UILabel *numlabel;

@property (nonatomic, retain) UIButton *bossButton;
@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) NSTimer *timer;

@end

@interface CloseUpContinentView : UIView {
  FullCityProto *_fcp;
}

@property (nonatomic, retain) IBOutlet UIView *cityPopup;
@property (nonatomic, retain) IBOutlet UIView *cityBgdView;
@property (nonatomic, retain) IBOutlet UILabel *cityNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityRankLabel;
@property (nonatomic, retain) IBOutlet UIImageView *progressBar;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;

- (void) reloadCities;

@end

@interface TravellingMissionMap : UIView

@property (nonatomic, retain) IBOutlet CloseUpContinentView *lumoriaView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction) continentClicked:(ContinentView *)cv;

@end
