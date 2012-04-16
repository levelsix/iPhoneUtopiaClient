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

@implementation BuildUpgradePopupController

@synthesize titleLabel, descriptionLabel, structIcon;
@synthesize star1, star2, star3, star4, star5;
@synthesize critStructLabel, normStructView;
@synthesize mainView, bgdView;

- (id) initWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    _userStruct = [us retain];
    _critStruct = nil;
  }
  return self;
}

- (id) initWithCritStruct:(NSString *)cs {
  if ((self = [super init])) {
    _critStruct = [cs retain];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  if (_critStruct) {
    self.titleLabel.text = @"Special Building!";
    self.descriptionLabel.text = [NSString stringWithFormat:@"The %@ has been unlocked! You have 1 available. Visit the carpenter to build it now!", _critStruct];
    self.structIcon.image = [Globals imageNamed:[_critStruct stringByAppendingString:@".png"]];
    self.critStructLabel.text = _critStruct;
    
    self.critStructLabel.hidden = NO;
    self.normStructView.hidden = YES;
  } else {
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
    
    self.star1.highlighted = _userStruct.level >= 1;
    self.star2.highlighted = _userStruct.level >= 2;
    self.star3.highlighted = _userStruct.level >= 3;
    self.star4.highlighted = _userStruct.level >= 4;
    self.star5.highlighted = _userStruct.level >= 5;
    
    self.critStructLabel.hidden = YES;
    self.normStructView.hidden = NO;
  }
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction)okayClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self didReceiveMemoryWarning];
    [self release];
  }];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [_userStruct release];
  [_critStruct release];
  self.titleLabel = nil;
  self.descriptionLabel = nil;
  self.critStructLabel = nil;
  self.normStructView = nil;
  self.structIcon = nil;
  self.star1 = nil;
  self.star2 = nil;
  self.star3 = nil;
  self.star4 = nil;
  self.star5 = nil;
}

@end
