//
//  DailyBonusMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface DailyBonusMenuController : UIViewController {
  int _day;
  int _silver;
  FullUserEquipProto *_fuep;
}

@property (nonatomic, retain) IBOutlet UIView *day1Done;
@property (nonatomic, retain) IBOutlet UIView *day2Done;
@property (nonatomic, retain) IBOutlet UIView *day3Done;
@property (nonatomic, retain) IBOutlet UIView *day4Done;
@property (nonatomic, retain) IBOutlet UIView *day5Done;

@property (nonatomic, retain) IBOutlet UIView *day1NotDone;
@property (nonatomic, retain) IBOutlet UIView *day2NotDone;
@property (nonatomic, retain) IBOutlet UIView *day3NotDone;
@property (nonatomic, retain) IBOutlet UIView *day4NotDone;
@property (nonatomic, retain) IBOutlet UIView *day5NotDone;

@property (nonatomic, retain) IBOutlet UIView *day1Active;
@property (nonatomic, retain) IBOutlet UIView *day2Active;
@property (nonatomic, retain) IBOutlet UIView *day3Active;
@property (nonatomic, retain) IBOutlet UIView *day4Active;
@property (nonatomic, retain) IBOutlet UIView *day5Active;

@property (nonatomic, retain) IBOutlet UIImageView *tutorialGirlIcon;
@property (nonatomic, retain) IBOutlet UIImageView *rewardIcon;
@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;

- (void)loadForDay:(int)day silver:(int)silver equip:(FullUserEquipProto *)fuep;

@end
