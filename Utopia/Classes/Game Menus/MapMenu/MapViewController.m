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

@implementation PinView

static UIImage *pinImage = nil;

- (void) setAnnotation:(id<MKAnnotation>)annotation {
  if (<#condition#>) {
    <#statements#>
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
  [self retrieveAttackListForCurrentBounds];
}

- (void) retrieveAttackListForCurrentBounds {
  MKCoordinateRegion region = _mapView.region;
  
  CGRect mapBounds;
  mapBounds.origin.x = region.center.longitude-region.span.longitudeDelta/2;
  mapBounds.origin.y = region.center.latitude-region.span.latitudeDelta/2;
  mapBounds.size.width = region.span.longitudeDelta;
  mapBounds.size.height = region.span.latitudeDelta;
  
  [[OutgoingEventController sharedOutgoingEventController] generateAttackList:20 bounds:mapBounds];
}

- (void) removeAllPins {
  [_mapView removeAnnotations:_mapView.annotations];
}

- (void) addNewPins {
  NSMutableArray *arr = [[GameState sharedGameState] attackList];
//  for (int i = pins.count; i < arr.count; i++) {
//    PinView *pin = [[PinView alloc] initWithPlayer:[arr objectAtIndex:i]];
//    [pins addObject:pin];
//    [self updatePin:pin];
//  }
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  NSLog(@"Region: %f, %f, %f, %f", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
}

- (IBAction)closeClicked:(id)sender {
  [MapViewController removeView];
} 

- (void) viewDidUnload {
  [super viewDidUnload];
}

@end
