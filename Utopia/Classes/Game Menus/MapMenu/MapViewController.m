//
//  MapViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapViewController.h"
#import "GameState.h"

@implementation MapViewController

@synthesize scrollView;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.scrollView.contentSize = self.mapView.frame.size;
  
  UIImage *image = [UIImage imageNamed:@"pin.png"];
  float width = image.size.width/4;
  float height = image.size.height/4;
  
  GameState *gs = [GameState sharedGameState];
  CLLocationCoordinate2D loc = gs.location;
  float x = (loc.longitude + 180)/360 * self.mapView.frame.size.width-width/2;
  float y = (1-(loc.latitude + 90)/180) * self.mapView.frame.size.height-height;
  
  UIImageView *i=[[UIImageView alloc] initWithImage:image];
  [i setFrame:CGRectMake(x,y,width,height)]; //Adjust X,Y,W,H as needed
  [self.mapView addSubview:i];
  [i release];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return self.mapView;
}

@end
