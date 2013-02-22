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
#import "LNSynthesizeSingleton.h"
#import "RefillMenuController.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "EquipDeltaView.h"
#import "ArmoryViewController.h"
#import "MarketplaceViewController.h"

@implementation EquipMenuController

@synthesize titleLabel, classLabel, attackLabel, defenseLabel;
@synthesize typeLabel, levelLabel;
@synthesize equipIcon, wrongClassView, tooLowLevelView;
@synthesize priceIcon, priceLabel;
@synthesize descriptionLabel;
@synthesize mainView, bgdView;
@synthesize buyButton;
@synthesize loadingView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(EquipMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  [self.loadingView stop];
}

+ (void) displayViewForEquip:(int)equipId level:(int)level enhancePercent:(int)enhancePercent {
  [[EquipMenuController sharedEquipMenuController] updateForEquip:equipId level:level enhancePercent:enhancePercent];
  [self displayView];
}

- (void) updateForEquip:(int)eq level:(int)level enhancePercent:(int)enhancePercent {
  equipId = eq;
  _level = level;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  titleLabel.text = fep.name;
  titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  classLabel.text = [Globals stringForEquipClassType:fep.classType];
  typeLabel.text = [Globals stringForEquipType:fep.equipType];
  attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:fep.equipId level:level enhancePercent:enhancePercent]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:fep.equipId level:level enhancePercent:enhancePercent]];
  levelLabel.text = [NSString stringWithFormat:@"%d", fep.minLevel];
  descriptionLabel.text = fep.description;
  self.levelIcon.level = level;
  self.enhanceIcon.level = [gl calculateEnhancementLevel:enhancePercent];
  
  priceIcon.highlighted = [Globals sellsForGoldInMarketplace:fep];
  if (fep.rarity == FullEquipProto_RarityLegendary) {
    priceLabel.text = @"Item must be found.";
    buyButton.enabled = NO;
  } else if (![Globals class:gs.type canEquip:fep.classType]) {
    priceLabel.text = [NSString stringWithFormat:@"Item not available for %@s", [Globals classForUserType:gs.type]];
    buyButton.enabled = NO;
  } else {
    priceLabel.text = @"View item in Armory.";
    buyButton.enabled = YES;
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
  [ArmoryViewController displayView];
  [[ArmoryViewController sharedArmoryViewController] loadForLevel:fep.minLevel rarity:fep.rarity];
}

- (IBAction)marketplaceClicked:(id)sender {
  [[MarketplaceViewController sharedMarketplaceViewController] searchForEquipId:equipId level:_level allowAllAbove:YES];
}

- (void) receivedArmoryResponse:(ArmoryResponseProto *)proto {
  if (self.view.superview) {
    [self.loadingView stop];
    
    if (proto.status == ArmoryResponseProto_ArmoryStatusSuccess) {
      GameState *gs = [GameState sharedGameState];
      FullEquipProto *fep = [gs equipWithId:equipId];
      
      int price = fep.diamondPrice > 0 ? fep.diamondPrice : fep.coinPrice;
      CGPoint startLoc = equipIcon.center;
      
      UIView *testView = [EquipDeltaView
                          createForUpperString:[NSString stringWithFormat:@"- %d %@",
                                                price, fep.diamondPrice ? @"Gold" : @"Silver"]
                          andLowerString:[NSString stringWithFormat:@"+1 %@", fep.name]
                          andCenter:startLoc
                          topColor:[Globals redColor]
                          botColor:[Globals colorForRarity:fep.rarity]];
      
      [Globals popupView:testView
             onSuperView:self.mainView
                 atPoint:startLoc
     withCompletionBlock:nil];
      
      [[Globals sharedGlobals] confirmWearEquip:proto.fullUserEquipOfBoughtItem.userEquipId];
    }
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
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
    self.loadingView = nil;
    self.levelIcon = nil;
    self.enhanceIcon = nil;
  }
}

@end
