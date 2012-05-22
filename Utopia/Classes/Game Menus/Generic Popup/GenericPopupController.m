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

@synthesize titleLabel, descriptionLabel;
@synthesize toAppStore;
@synthesize notificationView, confirmationView;
@synthesize mainView, bgdColorView;
@synthesize greenButtonLabel, blackButtonLabel, redButtonLabel;
@synthesize link;
@synthesize invocation;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GenericPopupController);

- (void)viewDidLoad {
  confirmationView.frame = notificationView.frame;
  [self.mainView addSubview:confirmationView];
}

- (void) viewWillAppear:(BOOL)animated {
  self.mainView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdColorView];
}

+ (void) displayViewWithText:(NSString *)string title:(NSString *)title {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.notificationView.hidden = NO;
  gpc.confirmationView.hidden = YES;
  gpc.descriptionLabel.text = string;
  gpc.titleLabel.text = title ? title : @"Notification!";
  [GenericPopupController displayView];
  gpc.toAppStore = NO;
}

+ (void) displayMajorUpdatePopup:(NSString *)appStoreLink {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.notificationView.hidden = NO;
  gpc.confirmationView.hidden = YES;
  gpc.descriptionLabel.text = @"There is a major update available. Click Okay to be taken to the App store.";
  [GenericPopupController displayView];
  gpc.toAppStore = YES;
  gpc.link = appStoreLink;
}

+ (void) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel target:(id)target selector:(SEL)selector {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.notificationView.hidden = YES;
  gpc.confirmationView.hidden = NO;
  
  gpc.titleLabel.text = title ? title : @"Confirmation!";
  gpc.descriptionLabel.text = description;
  gpc.greenButtonLabel.text = okay ? okay : @"Okay";
  gpc.redButtonLabel.text = cancel ? cancel : @"Cancel";
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gpc.invocation = invocation;
  
  [GenericPopupController displayView];
}

- (void) close {
  [UIView animateWithDuration:0.7f delay:0.f options:UIViewAnimationCurveEaseOut animations:^{
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformScale(t, 0.75f, 0.75f);
    t = CGAffineTransformRotate(t, DISAPPEAR_ROTATION_ANGLE);
    self.mainView.transform = t;
    self.mainView.center = CGPointMake(self.mainView.center.x-70, self.mainView.center.y+350);
    self.bgdColorView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
  }];
}

- (IBAction)redOkayClicked:(id)sender {
  if (toAppStore) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
  } else {
    [self close];
  }
}

- (IBAction)greenOkayClicked:(id)sender {
  [self.invocation invoke];
  [self close];
}

- (IBAction)cancelClicked:(id)sender {
  [self close];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.titleLabel = nil;
  self.descriptionLabel = nil;
  self.greenButtonLabel = nil;
  self.blackButtonLabel = nil;
  self.redButtonLabel = nil;
  self.link = nil;
  self.mainView = nil;
  self.bgdColorView = nil;
  self.notificationView = nil;
  self.confirmationView = nil;
  self.invocation = nil;
}

@end
