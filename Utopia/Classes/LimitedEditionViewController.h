//
//  LimitedEditionViewController.h
//  Utopia
//
//  Created by Danny Huang on 10/1/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "LNSynthesizeSingleton.h"

@interface LimitedEditionViewController : UIViewController

//special properties
@property (nonatomic, retain) IBOutlet UIImageView *specialEquipImg;
@property (nonatomic, assign) IBOutlet UILabel     *specialEquipName;
@property (nonatomic, assign) IBOutlet UILabel     *specialAttValue;
@property (nonatomic, assign) IBOutlet UILabel     *specialDefValue;
@property (nonatomic, assign) IBOutlet UILabel     *specialCostLabel;

//epic properties
@property (nonatomic, retain) IBOutlet UIImageView *epicEquipImg;
@property (nonatomic, assign) IBOutlet UILabel     *epicEquipName;
@property (nonatomic, assign) IBOutlet UILabel     *epicAttValue;
@property (nonatomic, assign) IBOutlet UILabel     *epicDefValue;
@property (nonatomic, assign) IBOutlet UILabel     *epicCostLabel;

//legendary properties
@property (nonatomic, retain) IBOutlet UIImageView *legendaryEquipImg;
@property (nonatomic, assign) IBOutlet UILabel     *legendaryEqupName;
@property (nonatomic, assign) IBOutlet UILabel     *legendaryAttValue;
@property (nonatomic, assign) IBOutlet UILabel     *legendaryDefValue;
@property (nonatomic, assign) IBOutlet UILabel     *legendaryCostLabel;

//etc
@property (nonatomic, assign) IBOutlet UILabel     *daysLabelOne;
@property (nonatomic, assign) IBOutlet UILabel     *daysLabelTwo;
@property (nonatomic, assign) IBOutlet UILabel     *hoursLabelOne;
@property (nonatomic, assign) IBOutlet UILabel     *hoursLabelTwo;
@property (nonatomic, assign) IBOutlet UILabel     *minsLabelOne;
@property (nonatomic, assign) IBOutlet UILabel     *minsLabelTwo;
@property (nonatomic, assign) IBOutlet UILabel     *secsLabelOne;
@property (nonatomic, assign) IBOutlet UILabel     *secsLabelTwo;
@property (nonatomic, assign) IBOutlet UILabel     *currentGoldLabel;

+ (void) displayView;
+ (void) removeView;

- (IBAction)buySpecialWeapon;
- (IBAction)buyEpicWeapon;
- (IBAction)buyLegendaryWeapon;
- (IBAction)closeView;

@end
