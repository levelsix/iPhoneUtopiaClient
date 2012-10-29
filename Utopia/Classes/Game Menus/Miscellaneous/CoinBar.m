//
//  CoinBar.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CoinBar.h"
#import "GameState.h"
#import "Globals.h"
#import "GoldShoppeViewController.h"

@implementation CoinBar

@synthesize goldLabel, silverLabel;

- (void) awakeFromNib {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels) name:IAP_SUCCESS_NOTIFICATION object:nil];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  
  goldLabel.text = [Globals commafyNumber:gs.gold];
  silverLabel.text = [Globals commafyNumber:gs.silver];
}

- (IBAction)barClicked:(id)sender {
  [GoldShoppeViewController displayView];
}

- (void) dealloc {
  self.goldLabel = nil;
  self.silverLabel = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
