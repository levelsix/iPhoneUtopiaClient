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
#import "ArmoryViewController.h"
#import "SoundEngine.h"
#import "TopBar.h"

@implementation DailyBonusMenuController

@synthesize day1Done, day2Done, day3Done, day4Done, day5Done;
@synthesize day1NotDone, day2NotDone, day3NotDone, day4NotDone, day5NotDone;
@synthesize day1Active, day2Active, day3Active, day4Active, day5Active;
@synthesize day1Label, day2Label, day3Label, day4Label, day5Label;
@synthesize tutorialGirlIcon, rewardIcon, rewardLabel, okayLabel;
@synthesize mainView, bgdView;

- (id) init {
  Globals *gl = [Globals sharedGlobals];
  return [self initWithNibName:@"DailyBonusMenuController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.dailyBonusNibName]];
}

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
  NSArray *labels = [NSArray arrayWithObjects:day1Label, day2Label, day3Label, day4Label, day5Label, nil];
  int vals[5] = {self.dbi.dayOneCoins, self.dbi.dayTwoCoins, self.dbi.dayThreeDiamonds, self.dbi.dayFourCoins, 0};
  
  int day = self.dbi.numConsecutiveDaysPlayed;
  int amt = vals[self.dbi.numConsecutiveDaysPlayed-1];
  
  for (int i = 1; i <= 5; i++) {
    UIView *doneView = [doneViews objectAtIndex:i-1];
    UIView *notDoneView = [notDoneViews objectAtIndex:i-1];
    UIView *activeView = [activeViews objectAtIndex:i-1];
    UILabel *label = [labels objectAtIndex:i-1];
    
    BOOL done = i <= day;
    doneView.hidden = !done;
    notDoneView.hidden = done;
    activeView.hidden = i != day;
    
    if (i < 5) {
      label.text = [Globals commafyNumber:vals[i-1]];
    }
  }
  
  if (day < 5) {
    rewardIcon.image = [Globals imageNamed:[NSString stringWithFormat:@"refill%@stack.png", day == 3 ? @"gold" : @"silver"]];
    rewardLabel.text = [Globals commafyNumber:amt];
    okayLabel.text = @"CLAIM REWARD";
  } else {
    [Globals imageNamed:self.dbi.boosterPack.chestImage withView:rewardIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    rewardLabel.text = self.dbi.boosterPack.name;
    okayLabel.text = @"OPEN CHEST";
  }
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void)loadForDailyBonusInfo:(StartupResponseProto_DailyBonusInfo *)dbi {
  self.dbi = dbi;
}

- (IBAction)okayClicked:(id)sender {
  if (self.dbi.numConsecutiveDaysPlayed == 5) {
    ArmoryViewController *amc = [ArmoryViewController sharedArmoryViewController];
    [Globals displayUIViewWithoutAdjustment:amc.cardDisplayView];
    FullEquipProto *fuep = [[[FullEquipProto builder] setEquipId:self.dbi.equipId] build];
    [amc.cardDisplayView beginAnimatingForEquips:[NSArray arrayWithObject:fuep] withTarget:nil andSelector:nil];
  } else {
    [[SoundEngine sharedSoundEngine] coinPickup];
  }
  
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[NSNumber numberWithLong:_dbi.timeAwarded] forKey:LAST_DAILY_BONUS_TIME_KEY];
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
  self.day1Label = nil;
  self.day2Label = nil;
  self.day3Label = nil;
  self.day4Label = nil;
  self.day5Label = nil;
  self.tutorialGirlIcon = nil;
  self.rewardIcon = nil;
  self.rewardLabel = nil;
  self.dbi = nil;
}

@end
