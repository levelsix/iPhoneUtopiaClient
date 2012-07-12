//
//  DailyBonusMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "BattleLayer.h"

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

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIImageView *tutorialGirlIcon;
@property (nonatomic, retain) IBOutlet UIImageView *rewardIcon;
@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;
@property (nonatomic, retain) IBOutlet UILabel *okayLabel;

@property (nonatomic, retain) IBOutlet StolenEquipView *stolenEquipView;

- (void)loadForDay:(int)day silver:(int)silver equip:(FullUserEquipProto *)fuep;

@end
