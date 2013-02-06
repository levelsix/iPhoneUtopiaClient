//
//  AttackMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <MapKit/Mapkit.h>
#import "cocos2d.h"
#import "Protocols.pb.h"
#import "PullRefreshTableViewController.h"

typedef enum {
  kAttackList = 1,
  kLocationMap
} AttackListState;

@interface AttackMenuBar : UIView {
  BOOL _flipped;
  AttackListState _state;
  
  BOOL _trackingList;
  BOOL _trackingLocation;
}

@property (nonatomic, retain) IBOutlet UIImageView *background;

@end

@interface AttackListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *userIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;

@property (nonatomic, retain) FullUserProto *fup;

@end

@interface EnemyAnnotation : MKUserLocation

@property (nonatomic, retain) FullUserProto *fup;

@end

@interface PinView : MKAnnotationView

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imgView;

@end

@interface AttackMenuController : PullRefreshTableViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource> {
  MKMapView *_mapView;
  BOOL _loaded;
  
  MKMapRect lastGoodMapRect;
  BOOL manuallyChangingMapRect;
  AttackListState _state;
}

@property (nonatomic, retain) IBOutlet UIView *listTabView;
@property (nonatomic, retain) IBOutlet UIView *locationTabView;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *mapSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *listSpinner;
@property (nonatomic, retain) IBOutlet AttackListCell *listCell;
@property (nonatomic, retain) IBOutlet UITableView *attackTableView;
@property (nonatomic, retain) IBOutlet UIImageView *filterImageView;

@property (nonatomic, assign) AttackListState state;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) retrieveAttackListForCurrentBounds;
- (void) removeAllPins;
- (void) addNewPins;

- (void) viewProfile:(FullUserProto *)fup;
- (void) battle:(FullUserProto *)fup;

+ (AttackMenuController *) sharedAttackMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

- (IBAction)closeClicked:(id)sender;
- (void) close;

@end
