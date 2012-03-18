//
//  CityRankupViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CityRankupViewController.h"

@interface CityRankupViewController ()

@end

@implementation CityRankupViewController

@synthesize rankupLabel, expLabel, coinLabel;
@synthesize rank, coins, exp;

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
  
  rankupLabel.text = [NSString stringWithFormat:@"This city has reached rank %d", rank];
  coinLabel.text = [NSString stringWithFormat:@"%d", coins];
  expLabel.text = [NSString stringWithFormat:@"Exp. +%d", exp];
}

- (IBAction)okayClicked:(id)sender {
  [self.view removeFromSuperview];
  [self didReceiveMemoryWarning];
  [self release];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.rankupLabel = nil;
  self.expLabel = nil;
  self.coinLabel = nil;
}

@end
