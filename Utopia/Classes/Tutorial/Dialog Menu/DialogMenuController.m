//
//  DialogMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "DialogMenuController.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"

@implementation DialogMenuController

#define ANIMATION_DURATION 0.5f
#define ANIMATION_VERTICAL_MOVEMENT 124

@synthesize label, progressBar;
@synthesize target = _target;
@synthesize selector = _selector;
@synthesize progress = _progress;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(DialogMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) registerCallback:(id)t action:(SEL)s {
  self.target = t;
  self.selector = s;
}

- (void) performCallback {
  // release before performing selector to ensure that if selector sets this,
  // we don't lose information about the new target
  id target = [_target retain];
  SEL selector = _selector;
  self.target = nil;
  self.selector = nil;
  
  [target performSelector:selector];
  
  [target release];
}

+ (void) displayViewForText:(NSString *)str callbackTarget:(id)t action:(SEL)s {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  dmc.label.text = str;
  
  [dmc registerCallback:t action:s];
  
  CGRect r = dmc.progressBar.frame;
  r.size.width = 10+43*dmc.progress;
  dmc.progressBar.frame = r;
  
  if (!dmc.view.superview) {
    r = dmc.view.frame;
    r.origin.y = ANIMATION_VERTICAL_MOVEMENT;
    dmc.view.frame = r;
    
    [DialogMenuController displayView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
      CGRect r = dmc.view.frame;
      r.origin.y = 0;
      dmc.view.frame = r;
    }];
  }
}

+ (void) closeView {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  
  [UIView animateWithDuration:ANIMATION_DURATION animations:^{
    CGRect r = dmc.view.frame;
    r.origin.y = ANIMATION_VERTICAL_MOVEMENT;
    dmc.view.frame = r;
  } completion:^(BOOL finished) {
    [dmc.view removeFromSuperview];
    [dmc performCallback];
  }];
}

+ (void) incrementProgress {
  [self sharedDialogMenuController].progress++;
}

- (void) didReceiveMemoryWarning {
  return;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [DialogMenuController closeView];
  [[CCTouchDispatcher sharedDispatcher] touchesEnded:touches withEvent:event];
}

- (void) viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  self.target = nil;
  self.selector = nil;
  self.label = nil;
  self.progressBar = nil;
}

@end
