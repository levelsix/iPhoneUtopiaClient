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

#define ZERO_LATITUDE 270/540.f //484/752.f
#define ZERO_LONGITUDE 540/1080.f //485/1000.f

#define SECOND_POINT_LATITUDE 404/540.f//579/752.f
#define SECOND_POINT_LONGITUDE 990/1080.f//870/1000.f

#define LATITUDE_OFFSET -45.f
#define LONGITUDE_OFFSET 150.f

#define PIN_THRESHOLD_IN_BOUNDS 12

@interface PinView : UIImageView

@property (nonatomic, retain) FullUserProto *player;

@end

@implementation PinView

@synthesize player;

static UIImage *pinImage = nil;

- (id) initWithPlayer:(FullUserProto *)fup {
  if ((self = [super initWithImage:[self getPinImage]])) {
    self.player = fup;
  }
  return self;
}
      
- (UIImage *) getPinImage {
  if (!pinImage) {
    pinImage = [[UIImage imageNamed:@"pin.png"] retain];
  }
  return pinImage;
}

@end

@implementation MapViewController

@synthesize scrollView;
@synthesize mapView;
@synthesize pins;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(MapViewController);

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.scrollView.contentSize = self.mapView.frame.size;
  
  self.pins = [NSMutableArray array];
  
//  UIImage *image = [UIImage imageNamed:@"pin.png"];
//  PinView *pin = [[PinView alloc] initWithImage:image];
//  CLLocationCoordinate2D coord;
//  coord.latitude = 40.75;
//  coord.longitude = -74;
//  pin.coordinate = coord;
//  [self.scrollView addSubview:pin];
//  [pins addObject:pin];
//  
//  pin = [[PinView alloc] initWithImage:image];
//  coord.latitude = 37;
//  coord.longitude = 127.5;
//  pin.coordinate = coord;
//  [self.scrollView addSubview:pin];
//  [pins addObject:pin];
//  
//  pin = [[PinView alloc] initWithImage:image];
//  coord.latitude = 51.5;
//  coord.longitude = 0.1666;
//  pin.coordinate = coord;
//  [self.scrollView addSubview:pin];
//  [pins addObject:pin];
//  
//  pin = [[PinView alloc] initWithImage:image];
//  coord.latitude = 0;
//  coord.longitude = 0;
//  pin.coordinate = coord;
//  [self.scrollView addSubview:pin];
//  [pins addObject:pin];
//  
//  pin = [[PinView alloc] initWithImage:image];
//  coord.latitude = -34;
//  coord.longitude = 151;
//  pin.coordinate = coord;
//  [self.scrollView addSubview:pin];
//  [pins addObject:pin];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
  
  [self removeAllPins];
  [self retrieveAttackListForCurrentBounds];
}

- (void) retrieveAttackListForCurrentBounds {
  // Convert current bounds to CGRect
  CGPoint origin = scrollView.contentOffset;
  CGSize size = scrollView.bounds.size;
  origin.x += size.width;
  size.width *= -1;
  CGRect mapBounds;
  
  float xScale = (SECOND_POINT_LONGITUDE-ZERO_LONGITUDE)/LONGITUDE_OFFSET;
  float yScale = (SECOND_POINT_LATITUDE-ZERO_LATITUDE)/LATITUDE_OFFSET;
  
  mapBounds.origin.x = (origin.x / self.mapView.frame.size.width - ZERO_LONGITUDE) / xScale;
  mapBounds.origin.y = (origin.y / self.mapView.frame.size.height - ZERO_LATITUDE) / yScale;
  mapBounds.size.width = size.width / xScale / self.mapView.frame.size.width;
  mapBounds.size.height = size.height / yScale / self.mapView.frame.size.height;
  
  NSLog(@"%@", [NSValue valueWithCGRect:mapBounds]);
  
//  [[OutgoingEventController sharedOutgoingEventController] generateAttackList:20 bounds:mapBounds];
}

- (void) removeAllPins {
  [pins enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj removeFromSuperview];
  }];
  [pins removeAllObjects];
}

- (void) addNewPins {
  NSMutableArray *arr = [[GameState sharedGameState] attackList];
  for (int i = pins.count; i < arr.count; i++) {
    PinView *pin = [[PinView alloc] initWithPlayer:[arr objectAtIndex:i]];
    [pins addObject:pin];
    [self.scrollView addSubview:pin];
    [self updatePin:pin];
  }
}

- (CGPoint) mapPointForCoordinate:(LocationProto *)coord {
  float xScale = (SECOND_POINT_LONGITUDE-ZERO_LONGITUDE)/LONGITUDE_OFFSET;
  float yScale = (SECOND_POINT_LATITUDE-ZERO_LATITUDE)/LATITUDE_OFFSET;
  
  float x = (ZERO_LONGITUDE + coord.longitude * xScale) * self.mapView.frame.size.width;
  float y = (ZERO_LATITUDE + coord.latitude * yScale) * self.mapView.frame.size.height;
  return CGPointMake(x, y);
}

- (void) updatePin:(PinView *)pin {
  UIImage *image = pin.image;
  float width = image.size.width/3;
  float height = image.size.height/3;
  
  LocationProto *coord = pin.player.userLocation;
  
  CGPoint mapPt = [self mapPointForCoordinate:coord];
  
  [pin setFrame:CGRectMake(mapPt.x-width/2, mapPt.y-height, width, height)]; //Adjust X,Y,W,H as needed
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return self.mapView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
  [self retrieveAttackListForCurrentBounds];
  for (PinView *pin in pins) {
    [self updatePin:pin];
  }
}

- (IBAction)closeClicked:(id)sender {
  [MapViewController removeView];
}

- (void) viewDidUnload {
  [super viewDidUnload];
  
  self.pins = nil;
}

@end
