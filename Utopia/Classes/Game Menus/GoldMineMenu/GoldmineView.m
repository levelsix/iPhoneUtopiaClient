//
//  GoldMineView.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GoldMineView.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "RefillMenuController.h"

@implementation GoldMineView

@synthesize mainView, bgdView;
@synthesize collectingView, descriptionView, hazardSign;
@synthesize progressBar, timeLeftLabel, timer;
@synthesize buttonLabel;

- (void) awakeFromNib {
  [self.mainView addSubview:descriptionView];
  descriptionView.frame = collectingView.frame;
  
  self.progressBar.percentage = 0.f;
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

- (void) displayForCurrentState {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSTimeInterval timeInterval = -[gs.lastGoldmineRetrieval timeIntervalSinceNow];
  float timeToEndCollect = 3600.f*(gl.numHoursBeforeGoldmineRetrieval+gl.numHoursForGoldminePickup);
  
  if (!gs.lastGoldmineRetrieval) {
    self.timer = nil;
    
    hazardSign.hidden = YES;
    descriptionView.hidden = NO;
    collectingView.hidden = YES;
    
    self.buttonLabel.text = @"START MINING GOLD!";
  } else if (timeInterval < timeToEndCollect) {
    [self updateMenu];
    
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    hazardSign.hidden = YES;
    descriptionView.hidden = YES;
    collectingView.hidden = NO;
    
    self.buttonLabel.text = @"RESET WORKERS!";
  } else {
    hazardSign.hidden = NO;
    descriptionView.hidden = YES;
    collectingView.hidden = NO;
    
    self.buttonLabel.text = @"PAY OFF THE STRIKERS!";
    self.timeLeftLabel.text = @"Never";
    self.progressBar.percentage = 0.f;
  }
  
  if (!self.superview) {
    [Globals displayUIView:self];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  }
}

- (void) updateMenu {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSDate *startTime = nil;
  int secsToCollect = 0;
  
  startTime = gs.lastGoldmineRetrieval;
  secsToCollect = 3600.f*gl.numHoursBeforeGoldmineRetrieval;
  
  NSDate *date = [startTime dateByAddingTimeInterval:secsToCollect];
  if (!date) {
    [self displayForCurrentState];
  } else if ([date compare:[NSDate date]] == NSOrderedAscending) {
    [self closeClicked:nil];
  } else {
    timeLeftLabel.text = [Globals convertTimeToString:date.timeIntervalSinceNow];
    progressBar.percentage = 1.f - date.timeIntervalSinceNow/secsToCollect;
  }
}

- (IBAction)greenButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.lastGoldmineRetrieval) {
    [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Would you like to restart the gold mine timer for %d gold?", gl.goldCostForGoldmineRestart] title:@"Restart Gold Mine?" okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(checkIfEnoughGoldToReset)];
  } else {
    [self sendReset];
  }
}

- (void) checkIfEnoughGoldToReset {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.gold < gl.goldCostForGoldmineRestart) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.goldCostForGoldmineRestart];
  } else {
    [self sendReset];
  }
}

- (void) sendReset {
  [[OutgoingEventController sharedOutgoingEventController] beginGoldmineTimer];
  [self displayForCurrentState];
}

- (IBAction)closeClicked:(id)sender {
  if (self.superview) {
    self.timer = nil;
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self removeFromSuperview];
    }];
  }
}

- (void) dealloc {
  self.mainView = nil;
  self.bgdView = nil;
  self.progressBar = nil;
  self.hazardSign = nil;
  self.timeLeftLabel = nil;
  self.timer = nil;
  self.collectingView = nil;
  self.descriptionView = nil;
  self.buttonLabel = nil;
  [super dealloc];
}

@end