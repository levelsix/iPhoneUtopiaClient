//
//  MarketplaceViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MarketplaceViewController.h"


@implementation ItemPostView

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [ UIColor clearColor];
  }
  return self;
}

- (void) drawRect:(CGRect)rect {
  NSLog(@"hi");
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	
  CGFloat dashPattern[] = {3.f, 2.f};
	CGContextSetLineDash(context, 0, dashPattern, 2);
	
  CGContextMoveToPoint(context, 0.0, self.frame.size.height);
  CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
  
	// And width 2.0 so they are a bit more visible
  CGContextSetLineWidth(context, 1.f);
	CGContextStrokePath(context);
}

@end

@implementation MarketplaceViewController

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end