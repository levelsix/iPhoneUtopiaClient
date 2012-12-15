//
//  TournamentMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TournamentMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "Globals.h"
#import "GameState.h"

@implementation TournamentMenuController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(TournamentMenuController);

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
}

@end
