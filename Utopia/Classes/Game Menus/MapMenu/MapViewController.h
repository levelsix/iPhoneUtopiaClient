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

@interface MapViewController : UIViewController

@property (nonatomic, retain) IBOutlet TravellingMissionMap *missionMap;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet ProgressBar *enstBar;
@property (nonatomic, retain) IBOutlet UIImageView *enstIcon;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

+ (MapViewController *) sharedMapViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;
+ (void) cleanupAndPurgeSingleton;

+ (void) displayMissionMap;

- (IBAction)closeClicked:(id)sender;

- (void) close;

@end
