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
@synthesize progress = _progress;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(DialogMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) registerCallback:(id)t action:(SEL)s {
  [_target release];
  _target = [t retain];
  _selector = s;
}

- (void) performCallback {
  [_target performSelector:_selector];
  [_target release];
  _target = nil;
  _selector = nil;
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

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [DialogMenuController closeView];
}

- (void) viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  self.label = nil;
  self.progressBar = nil;
}

@end
