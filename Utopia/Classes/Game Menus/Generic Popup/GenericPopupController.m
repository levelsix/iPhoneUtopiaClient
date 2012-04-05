//
//  GenericPopupController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GenericPopupController.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"

@implementation GenericPopupController

@synthesize descriptionLabel;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GenericPopupController);

+ (void) displayViewWithText:(NSString *)string {
  [[[GenericPopupController sharedGenericPopupController] descriptionLabel] setText:string];
  [GenericPopupController displayView];
}

- (IBAction)okayClicked:(id)sender {
  [GenericPopupController removeView];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.descriptionLabel = nil;
}

@end
