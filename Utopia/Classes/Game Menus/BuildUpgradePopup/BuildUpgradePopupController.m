//
//  BuildUpgradePopupController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BuildUpgradePopupController.h"
#import "UserData.h"
#import "GameState.h"
#import "Globals.h"
#import "SoundEngine.h"

@implementation BuildUpgradePopupController

@synthesize titleLabel, descriptionLabel, structIcon;
@synthesize rankLabel;
@synthesize mainView, bgdView;

- (id) initWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    _userStruct = [us retain];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:_userStruct.structId];
  BOOL upgrade = _userStruct.level > 1;
  
  if (upgrade) {
    self.titleLabel.text = @"Upgrade Complete!";
    self.descriptionLabel.text = [NSString stringWithFormat:@"The carpenter has finished upgrading your %@ to Rank %d!", fsp.name, _userStruct.level];
  } else {
    self.titleLabel.text = @"Build Complete!";
    self.descriptionLabel.text = [NSString stringWithFormat:@"The carpenter has finished building your %@!", fsp.name];
  }
  self.structIcon.image = [Globals imageForStruct:_userStruct.structId];
  
  self.rankLabel.text = [NSString stringWithFormat:@"rank: %d", _userStruct.level];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [[SoundEngine sharedSoundEngine] carpenterComplete];
}

- (IBAction)okayClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self didReceiveMemoryWarning];
  [self release];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (!self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_userStruct release];
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    self.structIcon = nil;
    self.mainView = nil;
    self.bgdView = nil;
  }
}

@end
