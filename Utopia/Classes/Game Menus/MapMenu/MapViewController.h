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
  
  MKMapRect lastGoodMapRect;
  BOOL manuallyChangingMapRect;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet TravellingMissionMap *missionMap;
@property (nonatomic, retain) IBOutlet MapLoadingView *loadingView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet ProgressBar *enstBar;
@property (nonatomic, retain) IBOutlet UIImageView *enstIcon;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, assign) MapState state;

- (void) retrieveAttackListForCurrentBounds;
- (void) removeAllPins;
- (void) addNewPins;

+ (MapViewController *) sharedMapViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (void) cleanupAndPurgeSingleton;

+ (void) displayMissionMap;
+ (void) displayAttackMap;

- (IBAction)closeClicked:(id)sender;

- (void) close;
- (void) startLoadingWithText:(NSString *)str;
- (void) stopLoading;

@end
