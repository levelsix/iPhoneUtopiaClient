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

@interface EnemyAnnotation : MKUserLocation

@property (nonatomic, retain) FullUserProto *fup;

@end

@interface PinView : MKAnnotationView {
  UILabel *_label;
}
@end

@interface MapViewController : UIViewController <MKMapViewDelegate> {
  MKMapView *_mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void) retrieveAttackListForCurrentBounds;
- (void) removeAllPins;
- (void) addNewPins;

+ (MapViewController *) sharedMapViewController;
+ (void) displayView;
+ (void) removeView;

@end
