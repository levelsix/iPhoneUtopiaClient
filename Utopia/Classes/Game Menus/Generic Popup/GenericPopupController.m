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

@implementation GenericPopup

@synthesize titleLabel, descriptionLabel;
@synthesize notificationView, confirmationView;
@synthesize mainView, bgdColorView;
@synthesize greenButtonLabel, blackButtonLabel, redButtonLabel;
@synthesize invocation;
@synthesize toAppStore;

- (void) awakeFromNib {
  confirmationView.frame = notificationView.frame;
  [mainView addSubview:confirmationView];
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
    [self removeFromSuperview];
  }];
}

- (IBAction)redOkayClicked:(id)sender {
  if (toAppStore) {
    [GenericPopupController openAppStoreLink];
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

- (void) dealloc {
  self.titleLabel = nil;
  self.descriptionLabel = nil;
  self.greenButtonLabel = nil;
  self.blackButtonLabel = nil;
  self.redButtonLabel = nil;
  self.mainView = nil;
  self.bgdColorView = nil;
  self.notificationView = nil;
  self.confirmationView = nil;
  self.invocation = nil;
  
  [super dealloc];
}

@end

@implementation GenericPopupController
@synthesize link;
@synthesize genPopup;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GenericPopupController);

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.genPopup.mainView fadeInBgdView:self.genPopup.bgdColorView];
  
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  gpc.view = nil;
  gpc.genPopup = nil;
}

+ (void) displayViewWithText:(NSString *)string title:(NSString *)title {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  GenericPopup *gp = [gpc genPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.text = string;
  gp.titleLabel.text = title ? title : @"Notification!";
  [GenericPopupController displayView];
  gp.toAppStore = NO;
  
  gpc.view = nil;
  gpc.genPopup = nil;
}

+ (void) displayMajorUpdatePopup:(NSString *)appStoreLink {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  GenericPopup *gp = [gpc genPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.text = @"There is a major update available. Click Okay to be taken to the App store.";
  [GenericPopupController displayView];
  gp.toAppStore = YES;
  gpc.link = appStoreLink;
  
  gpc.view = nil;
  gpc.genPopup = nil;
}

+ (void) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel target:(id)target selector:(SEL)selector {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  GenericPopup *gp = [gpc genPopup];
  gp.notificationView.hidden = YES;
  gp.confirmationView.hidden = NO;
  
  gp.titleLabel.text = title ? title : @"Confirmation!";
  gp.descriptionLabel.text = description;
  gp.greenButtonLabel.text = okay ? okay : @"Okay";
  gp.redButtonLabel.text = cancel ? cancel : @"Cancel";
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gp.invocation = invocation;
  
  [GenericPopupController displayView];
}

+ (void) openAppStoreLink {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gpc.link]];
}

- (void) dealloc {
  self.link = nil;
  [super dealloc];
}

@end
