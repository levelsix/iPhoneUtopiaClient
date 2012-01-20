//
//  DoorViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/28/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "DoorViewController.h"

#import "GameViewController.h"
#import "ShopMenuController.h"
#import "MapViewController.h"
#import "IAPHelper.h"
#import "DiamondShopViewController.h"

@implementation DoorViewController

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

- (void) viewDidLoad {
  [super viewDidLoad];
  [[GameViewController sharedGameViewController] view];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  // Open the door
//  MapViewController *mvc = [[MapViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:[GameViewController sharedGameViewController] animated:NO];
  
//  [[IAPHelper sharedIAPHelper] buyProductIdentifier:[[IAPHelper sharedIAPHelper].products objectAtIndex:0]];
}

@end
