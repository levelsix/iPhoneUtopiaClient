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

#define APP_STORE_LINK @"itms-apps://itunes.apple.com/us/app/scramble-with-friends/id485078615?mt=8&uo=4"

@implementation GenericPopupController

@synthesize descriptionLabel;
@synthesize toAppStore;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GenericPopupController);

+ (void) displayViewWithText:(NSString *)string {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.descriptionLabel.text = string;
  [GenericPopupController displayView];
  gpc.toAppStore = NO;
}

+ (void) displayMajorUpdatePopup {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.descriptionLabel.text = @"There is a major update available. Click Okay to be taken to the App store.";
  [GenericPopupController displayView];
  gpc.toAppStore = YES;
}

- (IBAction)okayClicked:(id)sender {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  if (gpc.toAppStore) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_LINK]];
  } else {
    [GenericPopupController removeView];
  }
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.descriptionLabel = nil;
}

@end
