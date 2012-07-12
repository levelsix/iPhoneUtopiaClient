//
//  DailyBonusMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "DailyBonusMenuController.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"

@implementation DailyBonusMenuController

@synthesize day1Done, day2Done, day3Done, day4Done, day5Done;
@synthesize day1NotDone, day2NotDone, day3NotDone, day4NotDone, day5NotDone;
@synthesize day1Active, day2Active, day3Active, day4Active, day5Active;
@synthesize tutorialGirlIcon, rewardIcon, rewardLabel, okayLabel;
@synthesize mainView, bgdView, stolenEquipView;

- (void) viewWillAppear:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  
  if ([Globals userTypeIsGood:gs.type]) {
    tutorialGirlIcon.image = [Globals imageNamed:@"rubyspeech.png"];
  } else {
    tutorialGirlIcon.image = [Globals imageNamed:@"adrianaspeech.png"];
  }
  
  NSArray *doneViews = [NSArray arrayWithObjects:day1Done, day2Done, day3Done, day4Done, day5Done, nil];
  NSArray *notDoneViews = [NSArray arrayWithObjects:day1NotDone, day2NotDone, day3NotDone, day4NotDone, day5NotDone, nil];
  NSArray *activeViews = [NSArray arrayWithObjects:day1Active, day2Active, day3Active, day4Active, day5Active, nil];
  
  for (int i = 1; i <= 5; i++) {
    UIView *doneView = [doneViews objectAtIndex:i-1];
    UIView *notDoneView = [notDoneViews objectAtIndex:i-1];
    UIView *activeView = [activeViews objectAtIndex:i-1];
    
    BOOL done = i <= _day;
    doneView.hidden = !done;
    notDoneView.hidden = done;
    activeView.hidden = i != _day;
    NSLog(@"%d: %d, %d, %d T:%d", i, !done, done, i != _day, activeView.tag);
    
    if (_day < 5) {
      rewardIcon.highlighted = NO;
      rewardLabel.text = [Globals commafyNumber:_silver];
    } else {
      rewardIcon.highlighted = YES;
      rewardLabel.text = @"Loot Box";
      okayLabel.text = @"Open Box";
      
      [[NSBundle mainBundle] loadNibNamed:@"StolenEquipView" owner:self options:nil];
    }
  }
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void)loadForDay:(int)day silver:(int)silver equip:(FullUserEquipProto *)fuep {
  _day = day;
  _silver = silver;
  [_fuep release];
  _fuep = [fuep retain];
}

- (IBAction)okayClicked:(id)sender {
  if (_day == 5) {
    GameState *gs = [GameState sharedGameState];
    [self.stolenEquipView loadForEquip:[gs equipWithId:_fuep.equipId]];
    self.stolenEquipView.titleLabel.text = @"You Found an Item!";
    [Globals displayUIView:self.stolenEquipView];
    [Globals bounceView:self.stolenEquipView.mainView fadeInBgdView:self.stolenEquipView.bgdView];
  }
  
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    if (_day != 5) {
      [self.view removeFromSuperview];
    }
  }];
}

- (IBAction)stolenEquipOkayClicked:(id)sender {
  [Globals popOutView:stolenEquipView.mainView fadeOutBgdView:stolenEquipView.bgdView completion:^{
    [stolenEquipView removeFromSuperview];
    [self.view removeFromSuperview];
  }];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self didReceiveMemoryWarning];
  [self release];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  
  self.day1Done = nil;
  self.day2Done = nil;
  self.day3Done = nil;
  self.day4Done = nil;
  self.day5Done = nil;
  self.day1NotDone = nil;
  self.day2NotDone = nil;
  self.day3NotDone = nil;
  self.day4NotDone = nil;
  self.day5NotDone = nil;
  self.day1Active = nil;
  self.day2Active = nil;
  self.day3Active = nil;
  self.day4Active = nil;
  self.day5Active = nil;
  self.tutorialGirlIcon = nil;
  self.rewardIcon = nil;
  self.rewardLabel = nil;
  
  [_fuep release];
  _fuep = nil;
}

@end
