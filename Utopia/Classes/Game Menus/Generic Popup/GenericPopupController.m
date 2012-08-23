//
//  GenericPopupController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GenericPopupController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"

#define DISAPPEAR_ROTATION_ANGLE M_PI/3

@implementation GenericPopup

@synthesize titleLabel, descriptionLabel;
@synthesize notificationView, confirmationView;
@synthesize mainView, bgdColorView;
@synthesize greenButtonLabel, blackButtonLabel, redButtonLabel;
@synthesize okInvocation, cancelInvocation;
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
    GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
    [gpc openAppStoreLink];
  } else {
    [self.okInvocation invoke];
    [self close];
  }
}

- (IBAction)greenOkayClicked:(id)sender {
  [self.okInvocation invoke];
  [self close];
}

- (IBAction)cancelClicked:(id)sender {
  [self.cancelInvocation invoke];
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
  self.okInvocation = nil;
  self.cancelInvocation = nil;
  
  [super dealloc];
}

@end

@implementation GenericPopupController
@synthesize link;
@synthesize genPopup;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GenericPopupController);

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.genPopup.mainView fadeInBgdView:self.genPopup.bgdColorView];
}

+ (void) displayNotificationViewWithText:(NSString *)string title:(NSString *)title {
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

+ (void) displayNotificationViewWithText:(NSString *)string title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  GenericPopup *gp = [gpc genPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.text = string;
  gp.titleLabel.text = title ? title : @"Notification!";
  gp.redButtonLabel.text = okay ? okay : @"Okay";
  [GenericPopupController displayView];
  gp.toAppStore = NO;
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gp.okInvocation = invocation;
  
  gpc.view = nil;
  gpc.genPopup = nil;
}

+ (void) displayNotificationViewWithMiddleView:(UIView *)view title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  GenericPopup *gp = [gpc genPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.hidden = YES;
  [gp.mainView addSubview:view];
  view.center = gp.descriptionLabel.center;
  gp.titleLabel.text = title ? title : @"Notification!";
  gp.redButtonLabel.text = okay ? okay : @"Okay";
  [GenericPopupController displayView];
  gp.toAppStore = NO;
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gp.okInvocation = invocation;
  
  gpc.view = nil;
  gpc.genPopup = nil;
}

+ (void) displayMajorUpdatePopup:(NSString *)appStoreLink {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  GenericPopup *gp = [gpc genPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.text = @"We've added a slew of new features! Update now to check them out.";
  gp.redButtonLabel.text = @"Update";
  gp.titleLabel.text = @"Update Now";
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
  gp.blackButtonLabel.text = cancel ? cancel : @"Cancel";
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gp.okInvocation = invocation;
  
  [GenericPopupController displayView];
}

+ (void) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector {
  GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
  GenericPopup *gp = [gpc genPopup];
  gp.notificationView.hidden = YES;
  gp.confirmationView.hidden = NO;
  
  gp.titleLabel.text = title ? title : @"Confirmation!";
  gp.descriptionLabel.text = description;
  gp.greenButtonLabel.text = okay ? okay : @"Okay";
  gp.blackButtonLabel.text = cancel ? cancel : @"Cancel";
  
	NSMethodSignature* sig = [[okTarget class]
                            instanceMethodSignatureForSelector:okSelector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:okTarget];
	[invocation setSelector:okSelector];
  gp.okInvocation = invocation;
  
	sig = [[cancelTarget class]
                            instanceMethodSignatureForSelector:cancelSelector];
	invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:cancelTarget];
	[invocation setSelector:cancelSelector];
  gp.cancelInvocation = invocation;
  
  [GenericPopupController displayView];
}

- (void) openAppStoreLink {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link]];
}

- (void) dealloc {
  self.link = nil;
  [super dealloc];
}

@end
