//
//  EquipMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "EquipMenuController.h"
#import "cocos2d.h"
#import "GameState.h"
#import "Globals.h"
#import "ProfileViewController.h"
#import "SynthesizeSingleton.h"
#import "RefillMenuController.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

@implementation EquipMenuController

@synthesize titleLabel, classLabel, attackLabel, defenseLabel;
@synthesize typeLabel, levelLabel;
@synthesize equipIcon, wrongClassView, tooLowLevelView;
@synthesize priceIcon, priceLabel;
@synthesize descriptionLabel;
@synthesize mainView, bgdView;
@synthesize buyButton, buyLabel;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(EquipMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

+ (void) displayViewForEquip:(int)equipId {
  [[EquipMenuController sharedEquipMenuController] updateForEquip:equipId];
  [self displayView];
}

- (void) updateForEquip:(int)eq {
  equipId = eq;
  
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  titleLabel.text = fep.name;
  titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  classLabel.text = [Globals stringForEquipClassType:fep.classType];
  typeLabel.text = [Globals stringForEquipType:fep.equipType];
  attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
  levelLabel.text = [NSString stringWithFormat:@"%d", fep.minLevel];
  descriptionLabel.text = fep.description;
  
  if (!fep.isBuyableInArmory) {
    priceIcon.highlighted = NO;
    priceLabel.text = @"Item must be found.";
    buyButton.enabled = NO;
    buyLabel.alpha = 0.75f;
  } else if (![Globals class:gs.type canEquip:fep.classType]) {
    priceIcon.highlighted = NO;
    priceLabel.text = [NSString stringWithFormat:@"Item not available for %@s", [Globals classForUserType:gs.type]];
    buyButton.enabled = NO;
    buyLabel.alpha = 0.75f;
  } else if (fep.diamondPrice > 0) {
    priceIcon.highlighted = YES;
    priceLabel.text = [Globals commafyNumber:fep.diamondPrice];
    buyButton.enabled = YES;
    buyLabel.alpha = 1.f;
  } else if (fep.coinPrice > 0) {
    priceIcon.highlighted = NO;
    priceLabel.text = [Globals commafyNumber:fep.coinPrice];
    buyButton.enabled = YES;
    buyLabel.alpha = 1.f;
  } 
  
  [Globals loadImageForEquip:fep.equipId toView:equipIcon maskedView:nil];
  
  if ([Globals class:gs.type canEquip:fep.classType]) {
    wrongClassView.hidden = YES;
  } else {
    wrongClassView.hidden = NO;
  }
  
  if (gs.level >= fep.minLevel) {
    tooLowLevelView.hidden = YES;
  } else {
    tooLowLevelView.hidden = NO;
  }
}

- (IBAction)wrongClassClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable by %@s.", titleLabel.text, classLabel.text]];
}

- (IBAction)tooLowLevelClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable at Level %@.", titleLabel.text, levelLabel.text]];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
    [self.view removeFromSuperview];
  }];
}

- (IBAction)buyClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  if (fep.coinPrice > gs.silver) {
    [[RefillMenuController sharedRefillMenuController] displayBuySilverView];
  } else if (fep.diamondPrice > gs.gold) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:fep.diamondPrice];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] buyEquip:equipId];
    
    NSString *str = [NSString stringWithFormat:@"You have purchased 1 %@.", fep.name];
    if ([Globals canEquip:fep]) {
      [GenericPopupController displayConfirmationWithDescription:str title:@"Congratulations!" okayButton:@"Equip" cancelButton:nil target:self selector:@selector(equipItem)];
    } else {
      [GenericPopupController displayViewWithText:str title:@"Congratulations!"];
    }
  }
}

- (void) equipItem {
  [[OutgoingEventController sharedOutgoingEventController] wearEquip:equipId];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.titleLabel = nil;
  self.classLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.typeLabel = nil;
  self.levelLabel = nil;
  self.equipIcon = nil;
  self.priceLabel = nil;
  self.priceIcon = nil;
  self.descriptionLabel = nil;
  self.wrongClassView = nil;
  self.tooLowLevelView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.buyButton = nil;
  self.buyLabel = nil;
}

@end