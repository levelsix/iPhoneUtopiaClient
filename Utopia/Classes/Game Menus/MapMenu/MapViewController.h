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
  kMissionMap = 1,
  kAttackMap
} MapState;

typedef enum {
  kMissionButton = 1,
  kEnemyButton = 1 << 1
} MapBarButton;


@interface MapBar : UIView {
  BOOL _trackingMission;
  BOOL _trackingEnemy;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UILabel *missionLabel;
@property (nonatomic, retain) IBOutlet UILabel *enemyLabel;

@property (nonatomic, retain) IBOutlet UIImageView *missionButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *enemyButtonClicked;

@end

@interface EnemyAnnotation : MKUserLocation

@property (nonatomic, retain) FullUserProto *fup;

@end

@interface PinView : MKAnnotationView

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imgView;

@end

@interface MapLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end

@interface MapViewController : UIViewController <MKMapViewDelegate> {
  MKMapView *_mapView;
  BOOL _loaded;
  MapState _state;
  
  BOOL _isDisplayingLoadingView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet TravellingMissionMap *missionMap;
@property (nonatomic, retain) IBOutlet MapBar *mapBar;
@property (nonatomic, retain) IBOutlet MapLoadingView *loadingView;

@property (nonatomic, assign) MapState state;

- (void) retrieveAttackListForCurrentBounds;
- (void) removeAllPins;
- (void) addNewPins;

+ (MapViewController *) sharedMapViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (IBAction)closeClicked:(id)sender;
- (IBAction)homeClicked:(id)sender;

- (void) fadeOut;
- (void) startLoadingWithText:(NSString *)str;
- (void) stopLoading;

@end
