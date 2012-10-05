//
//  MapViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <MapKit/Mapkit.h>
#import "cocos2d.h"
#import "Protocols.pb.h"
#import "TravellingMissionMap.h"

typedef enum {
  kMissionButton = 1,
  kEnemyButton = 1 << 1
} MapBarButton;

@interface MapLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end

@interface MapViewController : UIViewController {
  BOOL _isDisplayingLoadingView;
}

@property (nonatomic, retain) IBOutlet TravellingMissionMap *missionMap;
@property (nonatomic, retain) IBOutlet MapLoadingView *loadingView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet ProgressBar *enstBar;
@property (nonatomic, retain) IBOutlet UIImageView *enstIcon;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

+ (MapViewController *) sharedMapViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (void) cleanupAndPurgeSingleton;

+ (void) displayMissionMap;

- (IBAction)closeClicked:(id)sender;

- (void) close;
- (void) startLoadingWithText:(NSString *)str;
- (void) stopLoading;

@end
