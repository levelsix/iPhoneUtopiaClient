//
//  DoorViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/28/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "DoorViewController.h"
#import "GameViewController.h"
#import "GameState.h"

@implementation DoorViewController

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  // Open the door
  if ([[GameState sharedGameState] connected] && self.navigationController.viewControllers.count == 1) {
    [self.navigationController pushViewController:[GameViewController sharedGameViewController] animated:NO];
  }
}

@end
