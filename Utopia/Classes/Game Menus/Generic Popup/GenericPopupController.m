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
#import "Globals.h"

#define DISAPPEAR_ROTATION_ANGLE M_PI/3

@implementation GenericPopupController

@synthesize descriptionLabel;
@synthesize toAppStore;
@synthesize mainView, bgdColorView;
@synthesize link;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GenericPopupController);

- (void) viewWillAppear:(BOOL)animated {
  self.mainView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdColorView];
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
    [UIView animateWithDuration:0.7f delay:0.f options:UIViewAnimationCurveEaseOut animations:^{
      CGAffineTransform t = CGAffineTransformIdentity;
      t = CGAffineTransformScale(t, 0.5f, 0.5f);
      t = CGAffineTransformRotate(t, DISAPPEAR_ROTATION_ANGLE);
      self.mainView.transform = t;
      self.mainView.center = CGPointMake(self.mainView.center.x-70, self.mainView.center.y+250);
      self.bgdColorView.alpha = 0.f;
    } completion:^(BOOL finished) {
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
  self.link = nil;
  self.mainView = nil;
  self.bgdColorView = nil;
}

@end
