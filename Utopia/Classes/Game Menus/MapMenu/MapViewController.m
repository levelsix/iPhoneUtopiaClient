//
//  MapViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapViewController.h"
#import "GameState.h"
#import "SynthesizeSingleton.h"
#import "OutgoingEventController.h"

@implementation EnemyAnnotation

@synthesize fup;

- (id) initWithPlayer:(FullUserProto *)player {
  if ((self = [super init])) {
    self.coordinate = CLLocationCoordinate2DMake(player.userLocation.latitude, player.userLocation.longitude);
    self.fup = player;
    self.title = player.name;
    self.subtitle = [NSString stringWithFormat:@"Level %d", player.level];
  }
  return self;
}

@end

@implementation PinView

static UIImage *pinImage = nil;

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
    self.image = [self getPinImage];
    self.canShowCallout = YES;
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:_label];
    _label.text = @"Meep";
    _label.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation {
  [super setAnnotation:annotation];
  
  if ([annotation isKindOfClass:[EnemyAnnotation class]]) {
    NSLog(@"meep");
    _label.text = [NSString stringWithFormat:@"%d", [[(EnemyAnnotation *)annotation fup] level]];
  }
}
      
- (UIImage *) getPinImage {
  if (!pinImage) {
    pinImage = [[UIImage imageNamed:@"pin.png"] retain];
  }
  return pinImage;
}

@end

@implementation MapViewController

@synthesize mapView = _mapView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(MapViewController);

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self removeAllPins];
}

- (void) retrieveAttackListForCurrentBounds {
  MKCoordinateRegion region = _mapView.region;
  NSLog(@"Region: %f, %f, %f, %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
  
  CGRect mapBounds;
  mapBounds.origin.x = region.center.longitude-region.span.longitudeDelta/2;
  mapBounds.origin.y = region.center.latitude-region.span.latitudeDelta/2;
  mapBounds.size.width = region.span.longitudeDelta;
  mapBounds.size.height = region.span.latitudeDelta;
  
  mapBounds.origin.x = -180;
  mapBounds.origin.y = -90;
  mapBounds.size.width = 360;
  mapBounds.size.height = 180;
  NSLog(@"%@", [NSValue valueWithCGRect:mapBounds]);
  
  [[OutgoingEventController sharedOutgoingEventController] generateAttackList:20 bounds:mapBounds];
}

- (void) removeAllPins {
  [_mapView removeAnnotations:_mapView.annotations];
}

- (void) addNewPins {
  NSMutableArray *arr = [[GameState sharedGameState] attackList];
  for (int i = _mapView.annotations.count; i < arr.count; i++) {
    EnemyAnnotation *annotation = [[EnemyAnnotation alloc] initWithPlayer:[arr objectAtIndex:i]];
    [_mapView addAnnotation:annotation];
    [annotation release];
  }
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  NSLog(@"%d", mapView == _mapView);
  NSLog(@"Region: %f, %f, %f, %f", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
  [self retrieveAttackListForCurrentBounds];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  static NSString *reuseId = @"enemyAnnotationView";
  
  MKAnnotationView *mkav = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
  
  if (!mkav) {
    mkav = [[PinView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
  }
  
  return mkav;
}

- (IBAction)closeClicked:(id)sender {
  [MapViewController removeView];
} 

- (void) viewDidUnload {
  [super viewDidUnload];
}

@end
