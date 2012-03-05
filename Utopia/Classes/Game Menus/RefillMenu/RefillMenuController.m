//
//  RefillMenuControler.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "RefillMenuController.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "SynthesizeSingleton.h"
#import "GoldShoppeViewController.h"

#define POPUP_ANIMATION_DURATION 0.2f

@implementation RefillMenuController

@synthesize goldView, itemsView, enstView;
@synthesize curGoldLabel, needGoldLabel;
@synthesize enstImageView, enstGoldCostLabel, fillEnstLabel, enstHintLabel;
@synthesize itemsScrollView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(RefillMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  itemsView.frame = goldView.frame;
  enstView.frame = goldView.frame;
  [self.view addSubview:itemsView];
  [self.view addSubview:enstView];
  itemsView.hidden = YES;
  enstView.hidden = YES;
  goldView.hidden = YES;
  
}

- (void) displayEnstView:(BOOL)isEnergy {
  Globals *gl = [Globals sharedGlobals];
  
  _isEnergy = isEnergy;
  
  if (isEnergy) {
    enstImageView.highlighted = NO;
    enstGoldCostLabel.text = [NSString stringWithFormat:@"%d", gl.energyRefillCost];
    fillEnstLabel.text = @"FILL ENERGY";
    enstHintLabel.text = @"Hint: Energy refills over time.";
  } else {
    enstImageView.highlighted = YES;
    enstGoldCostLabel.text = [NSString stringWithFormat:@"%d", gl.staminaRefillCost];
    fillEnstLabel.text = @"FILL STAMINA";
    enstHintLabel.text = @"Hint: Stamina refills over time.";
  }
  
  [self openView:enstView];
}

- (void) displayBuyGoldView:(int)needsGold {
  GameState *gs = [GameState sharedGameState];
  
  curGoldLabel.text = [NSString stringWithFormat:@"%d", gs.gold];
  needGoldLabel.text = [NSString stringWithFormat:@"%d", needsGold];
  
  [self openView:goldView];
}

- (void) displayEquipsView:(NSArray *)equipIds {
  
  
  [self openView:itemsView];
}

- (void) openView:(UIView *)view {
  [self.view bringSubviewToFront:view];
  [RefillMenuController displayView];
  
  view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
  view.hidden = NO;
  
  [UIView animateWithDuration:POPUP_ANIMATION_DURATION animations:^{
    view.transform = CGAffineTransformMakeScale(1, 1);
  }];
}

- (void) closeView:(UIView *)view {
  [UIView animateWithDuration:POPUP_ANIMATION_DURATION animations:^{
    view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
  } completion:^(BOOL finished) {
    view.hidden = YES;
    if (goldView.hidden && enstView.hidden && itemsView.hidden) {
      [RefillMenuController removeView];
    }
  }];
}

- (IBAction) refillGoldClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int goldCost = _isEnergy ? gl.energyRefillCost : gl.staminaRefillCost;
  
  if (goldCost > gs.gold) {
    [self displayBuyGoldView:goldCost];
  } else {
    if (_isEnergy) {
      [[OutgoingEventController sharedOutgoingEventController] refillEnergy];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] refillStamina];
    }
    
    [self closeView:enstView];
  }
}

- (IBAction) getMoreGoldClicked:(id)sender {
  [self closeView:goldView];
  [GoldShoppeViewController displayView]; 
}

- (IBAction) closeClicked:(id)sender {
  int tag = [(UIView *)sender tag];
  
  UIView *view;
  if (tag == 1) {
    view = goldView;
  } else if (tag == 2) {
    view = enstView;
  } else if (tag == 3) {
    view = itemsView;
  }
  [self closeView:view];
}

@end
