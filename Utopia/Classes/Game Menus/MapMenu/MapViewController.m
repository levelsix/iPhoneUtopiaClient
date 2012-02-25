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

#define ZERO_LATITUDE 270/540.f //484/752.f
#define ZERO_LONGITUDE 540/1080.f //485/1000.f

#define SECOND_POINT_LATITUDE 404/540.f//579/752.f
#define SECOND_POINT_LONGITUDE 990/1080.f//870/1000.f

#define LATITUDE_OFFSET -45.f
#define LONGITUDE_OFFSET 150.f

@interface PinView : UIImageView

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation PinView

@synthesize coordinate;

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
  
  UIImage *image = [UIImage imageNamed:@"pin.png"];
  PinView *pin = [[PinView alloc] initWithImage:image];
  CLLocationCoordinate2D coord;
  coord.latitude = 40.75;
  coord.longitude = -74;
  pin.coordinate = coord;
  [self.scrollView addSubview:pin];
  [pins addObject:pin];
  
  pin = [[PinView alloc] initWithImage:image];
  coord.latitude = 37;
  coord.longitude = 127.5;
  pin.coordinate = coord;
  [self.scrollView addSubview:pin];
  [pins addObject:pin];
  
  pin = [[PinView alloc] initWithImage:image];
  coord.latitude = 51.5;
  coord.longitude = 0.1666;
  pin.coordinate = coord;
  [self.scrollView addSubview:pin];
  [pins addObject:pin];
  
  pin = [[PinView alloc] initWithImage:image];
  coord.latitude = 0;
  coord.longitude = 0;
  pin.coordinate = coord;
  [self.scrollView addSubview:pin];
  [pins addObject:pin];
  
  pin = [[PinView alloc] initWithImage:image];
  coord.latitude = -34;
  coord.longitude = 151;
  pin.coordinate = coord;
  [self.scrollView addSubview:pin];
  [pins addObject:pin];
  
  self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
  
  [self updatePin:pin];
}

- (void) updatePin:(PinView *)pin {
  UIImage *image = pin.image;
  float width = image.size.width/3;
  float height = image.size.height/3;
  
  CLLocationCoordinate2D coord = pin.coordinate;
  
  float xScale = (SECOND_POINT_LONGITUDE-ZERO_LONGITUDE)/LONGITUDE_OFFSET;
  float yScale = (SECOND_POINT_LATITUDE-ZERO_LATITUDE)/LATITUDE_OFFSET;
  float x = (ZERO_LONGITUDE + coord.longitude * xScale) * self.mapView.frame.size.width - width/2;
  float y = (ZERO_LATITUDE + coord.latitude * yScale) * self.mapView.frame.size.height - height;
  
  [pin setFrame:CGRectMake(x,y,width,height)]; //Adjust X,Y,W,H as needed
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return self.mapView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
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
