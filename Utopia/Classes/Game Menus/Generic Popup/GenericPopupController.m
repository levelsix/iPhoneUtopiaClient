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

#define POPUP_ANIMATION_DURATION 0.2f

@implementation GenericPopupController

@synthesize descriptionLabel;
@synthesize toAppStore;
@synthesize mainView, bgdColorView;
@synthesize link;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GenericPopupController);

- (void) viewWillAppear:(BOOL)animated {
  self.view.hidden = NO;
  self.mainView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
  self.bgdColorView.alpha = 0.f;
  
  [UIView animateWithDuration:POPUP_ANIMATION_DURATION animations:^{
    self.mainView.transform = CGAffineTransformMakeScale(1, 1);
    self.bgdColorView.alpha = 1.f;
  }];
}

+ (void) displayViewWithText:(NSString *)string {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.descriptionLabel.text = string;
  [GenericPopupController displayView];
  gpc.toAppStore = NO;
}

+ (void) displayMajorUpdatePopup:(NSString *)appStoreLink {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.descriptionLabel.text = @"There is a major update available. Click Okay to be taken to the App store.";
  [GenericPopupController displayView];
  gpc.toAppStore = YES;
  gpc.link = appStoreLink;
}

- (IBAction)okayClicked:(id)sender {
  if (toAppStore) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
  } else {
    [UIView animateWithDuration:POPUP_ANIMATION_DURATION animations:^{
      self.mainView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
      self.bgdColorView.alpha = 0.f;
    } completion:^(BOOL finished) {
      self.view.hidden = YES;
      [self.view removeFromSuperview];
    }];
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
