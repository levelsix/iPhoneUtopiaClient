//
//  CityRankupViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CityRankupViewController.h"
#import "Globals.h"

@interface CityRankupViewController ()

@end

@implementation CityRankupViewController

@synthesize rankupLabel, expLabel, coinLabel;
@synthesize rank, coins, exp;
@synthesize mainView, bgdView;

- (id) initWithRank:(int)r coins:(int)c exp:(int)e {
  if ((self = [super init])) {
    self.rank = r;
    self.coins = c;
    self.exp = e;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  rankupLabel.text = [NSString stringWithFormat:@"This city has reached rank %d!", rank];
  coinLabel.text = [NSString stringWithFormat:@"%d", coins];
  expLabel.text = [NSString stringWithFormat:@"Exp. +%d", exp];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
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

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (!self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.rankupLabel = nil;
    self.expLabel = nil;
    self.coinLabel = nil;
    self.mainView = nil;
    self.bgdView = nil;
  }
}

@end
