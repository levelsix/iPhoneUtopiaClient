//
//  LimitedEditionViewController.m
//  Utopia
//
//  Created by Danny Huang on 10/1/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LimitedEditionViewController.h"

@interface LimitedEditionViewController ()

@end

@implementation LimitedEditionViewController
SYNTHESIZE_SINGLETON_FOR_CONTROLLER(LimitedEditionViewController)
@synthesize specialCostLabel, specialEquipName, specialEquipImg,specialAttValue,specialDefValue;
@synthesize epicAttValue,epicDefValue,epicEquipImg,epicCostLabel,epicEquipName;
@synthesize legendaryAttValue,legendaryDefValue,legendaryEquipImg,legendaryEqupName,legendaryCostLabel;
@synthesize daysLabelOne,daysLabelTwo,hoursLabelOne,hoursLabelTwo,currentGoldLabel,minsLabelOne,minsLabelTwo,secsLabelOne,secsLabelTwo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)buySpecialWeapon {
  
}

- (IBAction)buyEpicWeapon {
  
}

- (IBAction)buyLegendaryWeapon {
  
}

- (IBAction)closeView {
  [LimitedEditionViewController removeView];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  self.specialEquipImg = nil;
  self.epicEquipImg = nil;
  self.legendaryEquipImg = nil;
}

@end
