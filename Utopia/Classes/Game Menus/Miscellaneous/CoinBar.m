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

@implementation CoinBar

@synthesize goldLabel, silverLabel;

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  
  goldLabel.text = [Globals commafyNumber:gs.gold];
  silverLabel.text = [Globals commafyNumber:gs.silver];
}

@end
