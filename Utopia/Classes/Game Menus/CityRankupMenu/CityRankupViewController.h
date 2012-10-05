//
//  CityRankupViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityRankupViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *rankupLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinLabel;
@property (nonatomic, retain) IBOutlet UILabel *expLabel;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, assign) int rank;
@property (nonatomic, assign) int coins;
@property (nonatomic, assign) int exp;

- (id) initWithRank:(int)r coins:(int)c exp:(int)e;
- (IBAction)okayClicked:(id)sender;

@end
