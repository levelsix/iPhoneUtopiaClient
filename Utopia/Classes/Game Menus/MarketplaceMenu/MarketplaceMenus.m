//
//  MarketplaceMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/30/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MarketplaceMenus.h"
#import "GameState.h"
#import "Globals.h"
#import "RefillMenuController.h"
#import "MarketplaceViewController.h"
#import "ProfileViewController.h"
#import "OutgoingEventController.h"
#import "SoundEngine.h"
#import "EquipDeltaView.h"

@implementation ItemPostView

@synthesize postTitle;
@synthesize itemImageView;
@synthesize statsView;
@synthesize submitView, submitPriceIcon;
@synthesize submitButton;
@synthesize buyButton;
@synthesize listButton;
@synthesize removeButton;
@synthesize priceField;
@synthesize priceLabel, priceIcon;
@synthesize attStatLabel, defStatLabel;
@synthesize state = _state;
@synthesize mktProto, equip;
@synthesize leatherBackground;
@synthesize equipTypeLabel;
@synthesize levelIcon;

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.buyButton.frame = self.listButton.frame;
  self.removeButton.frame = self.listButton.frame;
  self.submitButton.frame = self.listButton.frame;
  [self addSubview:buyButton];
  [self addSubview:removeButton];
  [self addSubview:submitButton];
  
  self.submitView.frame = self.statsView.frame;
  [self addSubview:submitView];
  
  [self setState:kSellingState];
}

- (void) setState:(MarketCellState)state {
  if (_state != state) {
    _state = state;
    switch (state) {
      case kListState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = NO;
        removeButton.hidden = YES;
        buyButton.hidden = YES;
        submitButton.hidden = YES;
        break;
        
      case kSellingState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = YES;
        buyButton.hidden = NO;
        submitButton.hidden = YES;
        break;
        
      case kMySellingState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = NO;
        buyButton.hidden = YES;
        submitButton.hidden = YES;
        break;
        
      case kSubmitState:
        statsView.hidden = YES;
        submitView.hidden = NO;
        priceField.text = @"0";
        listButton.hidden = YES;
        removeButton.hidden = YES;
        buyButton.hidden = YES;
        submitButton.hidden = NO;
        
        self.priceField.label.textColor = [UIColor whiteColor];
        break;
        
      default:
        break;
    }
  }
}

- (void) showEquipPost: (FullMarketplacePostProto *)proto {
  Globals *gl = [Globals sharedGlobals];
  if (proto.poster.userId == [[GameState sharedGameState] userId]) {
    self.state = kMySellingState;
  } else {
    self.state = kSellingState;
  }
  if (proto.coinCost) {
    self.priceIcon.highlighted = NO;
    self.priceLabel.text = [Globals commafyNumber:proto.coinCost];
  } else {
    self.priceIcon.highlighted = YES;
    self.priceLabel.text = [Globals commafyNumber:proto.diamondCost];
  }
  self.attStatLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:proto.postedEquip.equipId level:proto.equipLevel]];
  self.defStatLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:proto.postedEquip.equipId level:proto.equipLevel]];
  self.postTitle.text = proto.postedEquip.name;
  self.postTitle.textColor = [Globals colorForRarity:proto.postedEquip.rarity];
  self.equipTypeLabel.text = [Globals stringForEquipType:proto.postedEquip.equipType];
  [Globals loadImageForEquip:proto.postedEquip.equipId toView:self.itemImageView maskedView:nil];
  self.mktProto = proto;
  self.equip = nil;
  self.levelIcon.level = proto.equipLevel;
  
  if ([Globals canEquip:proto.postedEquip]) {
    self.leatherBackground.highlighted = NO;
  } else {
    self.leatherBackground.highlighted = YES;
  }
}

- (void) showEquipListing:(UserEquip *)eq {
  Globals *gl = [Globals sharedGlobals];
  self.state = kListState;
  
  FullEquipProto *fullEq = [[GameState sharedGameState] equipWithId:eq.equipId];
  self.postTitle.text = fullEq.name;
  self.postTitle.textColor = [Globals colorForRarity:fullEq.rarity];
  self.equipTypeLabel.text = [Globals stringForEquipType:fullEq.equipType];
  [Globals loadImageForEquip:fullEq.equipId toView:self.itemImageView maskedView:nil];
  self.mktProto = nil;
  self.equip = eq;
  self.attStatLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:eq.equipId level:eq.level]];
  self.defStatLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:eq.equipId level:eq.level]];
  self.levelIcon.level = eq.level;
  
  if ([Globals canEquip:fullEq]) {
    self.leatherBackground.highlighted = NO;
  } else {
    self.leatherBackground.highlighted = YES;
  }
}

- (void) dealloc {
  self.postTitle = nil;
  self.itemImageView = nil;
  self.statsView = nil;
  self.submitView = nil;
  self.submitPriceIcon = nil;
  self.submitButton = nil;
  self.buyButton = nil;
  self.listButton = nil;
  self.levelIcon = nil;
  self.removeButton = nil;
  self.priceField = nil;
  self.priceLabel = nil;
  self.priceIcon = nil;
  self.attStatLabel = nil;
  self.defStatLabel = nil;
  self.mktProto = nil;
  self.equip = nil;
  self.leatherBackground = nil;
  self.equipTypeLabel = nil;
  [super dealloc];
}

@end

@implementation MarketPurchaseView

@synthesize titleLabel, crossOutView, classLabel, attackLabel, defenseLabel;
@synthesize typeLabel, levelLabel, playerNameButton, levelIcon;
@synthesize equipIcon, wrongClassView, tooLowLevelView;
@synthesize armoryPriceIcon, armoryPriceLabel;
@synthesize postedPriceIcon, postedPriceLabel;
@synthesize savePriceIcon, savePriceLabel;
@synthesize mainView, bgdView;
@synthesize mktPost;

- (void) updateForMarketPost:(FullMarketplacePostProto *)m {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.mktPost = m;
  
  FullEquipProto *fep = mktPost.postedEquip;
  
  titleLabel.text = fep.name;
  titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  classLabel.text = [Globals stringForEquipClassType:fep.classType];
  typeLabel.text = [Globals stringForEquipType:fep.equipType];
  attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:fep.equipId level:m.equipLevel]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:fep.equipId level:m.equipLevel]];
  levelLabel.text = [NSString stringWithFormat:@"%d", fep.minLevel];
  levelIcon.level = m.equipLevel;
  [playerNameButton setTitle:m.poster.name forState:UIControlStateNormal];
  
  if ([Globals sellsForGoldInMarketplace:fep]) {
    armoryPriceIcon.highlighted = YES;
    postedPriceIcon.highlighted = YES;
    savePriceIcon.highlighted = YES;
    postedPriceLabel.text = [Globals commafyNumber:mktPost.diamondCost];
    
    if (fep.diamondPrice > 0) {
      crossOutView.hidden = NO;
      int retailPrice = [gl calculateRetailValueForEquip:m.postedEquip.equipId level:m.equipLevel];
      armoryPriceLabel.text = [Globals commafyNumber:retailPrice];
      savePriceLabel.text = [NSString stringWithFormat:@"%@ (%@%%)", 
                             [Globals commafyNumber:retailPrice-mktPost.diamondCost], 
                             [Globals commafyNumber:(int)roundf((retailPrice-mktPost.diamondCost)/((float)retailPrice)*100)]];
      
      if (mktPost.diamondCost < retailPrice) {
        postedPriceLabel.textColor = [Globals greenColor];
        savePriceLabel.textColor = [Globals greenColor];
      } else {
        postedPriceLabel.textColor = [Globals redColor];
        savePriceLabel.textColor = [Globals redColor];
      }
      
    } else {
      armoryPriceLabel.text = @"N/A";
      savePriceLabel.text = @"N/A";
      postedPriceLabel.textColor = [Globals creamColor];
      savePriceLabel.textColor = [Globals creamColor];
      crossOutView.hidden = YES;
    }
  } else {
    armoryPriceIcon.highlighted = NO;
    postedPriceIcon.highlighted = NO;
    savePriceIcon.highlighted = NO;
    postedPriceLabel.text = [Globals commafyNumber:mktPost.coinCost];
    
    if (fep.coinPrice > 0) {
      crossOutView.hidden = NO;
      int retailPrice = [gl calculateRetailValueForEquip:m.postedEquip.equipId level:m.equipLevel];
      armoryPriceLabel.text = [Globals commafyNumber:retailPrice];
      savePriceLabel.text = [NSString stringWithFormat:@"%@ (%@%%)", 
                             [Globals commafyNumber:retailPrice-mktPost.coinCost], 
                             [Globals commafyNumber:(int)roundf((retailPrice-mktPost.coinCost)/((float)retailPrice)*100)]];
      
      if (mktPost.coinCost < retailPrice) {
        postedPriceLabel.textColor = [Globals greenColor];
        savePriceLabel.textColor = [Globals greenColor];
      } else {
        postedPriceLabel.textColor = [Globals redColor];
        savePriceLabel.textColor = [Globals redColor];
      }
    } else {
      armoryPriceLabel.text = @"N/A";
      savePriceLabel.text = @"N/A";
      postedPriceLabel.textColor = [Globals creamColor];
      savePriceLabel.textColor = [Globals creamColor];
      crossOutView.hidden = YES;
    }
  }
  
  equipIcon.equipId = fep.equipId;
  
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
  
  CGSize size = [armoryPriceLabel.text sizeWithFont:armoryPriceLabel.font];
  CGRect r = crossOutView.frame;
  r.size.width = size.width;
  crossOutView.frame = r;
}

- (IBAction)wrongClassClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable by %@s.", titleLabel.text, classLabel.text]];
}

- (IBAction)profileButtonClicked:(id)sender {
  [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:mktPost.poster withState:kProfileState];
}

- (IBAction)tooLowLevelClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable at Level %@.", titleLabel.text, levelLabel.text]];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
    [self removeFromSuperview];
  }];
}

- (IBAction)buyClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  
  [Analytics attemptedPurchase];
  
  if (gs.userId == mktPost.poster.userId) {
    [Globals popupMessage:@"You can't purchase your own item!"];
    [self closeClicked:nil];
    [mvc.coinBar updateLabels];
  } else if (mktPost.coinCost > gs.silver) {
    [[RefillMenuController sharedRefillMenuController] displayBuySilverView];
    [Analytics notEnoughSilverForMarketplaceBuy:mktPost.postedEquip.equipId
                                           cost:mktPost.coinCost];
    [self closeClicked:nil];
    [mvc.coinBar updateLabels];
  } else if (mktPost.diamondCost > gs.gold) {
    [[RefillMenuController sharedRefillMenuController] 
     displayBuyGoldView:mktPost.diamondCost];
    [Analytics notEnoughGoldForMarketplaceBuy:mktPost.postedEquip.equipId
                                         cost:mktPost.diamondCost];
    [self closeClicked:nil];
    [mvc.coinBar updateLabels];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] 
     purchaseFromMarketplace:mktPost.marketplacePostId];
    [Analytics successfulPurchase:mktPost.postedEquip.equipId];
    
    int price = ([Globals sellsForGoldInMarketplace:mktPost.postedEquip]) ? mktPost.diamondCost : mktPost.coinCost;
    CGPoint startLoc = ccp(80, self.superview.center.y);;
    UIView *testView = [EquipDeltaView 
                        createForUpperString:[NSString stringWithFormat:@"- %d", 
                                              price] 
                        andLowerString:[NSString stringWithFormat:@"+1 %@", mktPost.postedEquip.name] 
                        andCenter:startLoc
                        topColor:[Globals redColor]
                        botColor:[Globals colorForRarity:mktPost.postedEquip.rarity]];
    
    [Globals popupView:testView 
           onSuperView:self.superview
               atPoint:startLoc
   withCompletionBlock:nil];
    
    [mvc.loadingView display:mvc.view];
    [self closeClicked:nil];
    [mvc.coinBar updateLabels];
    
    [[SoundEngine sharedSoundEngine] marketplaceBuy];
  }
}

- (void) dealloc {
  self.titleLabel = nil;
  self.crossOutView = nil;
  self.classLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.typeLabel = nil;
  self.levelLabel = nil;
  self.playerNameButton = nil;
  self.equipIcon = nil;
  self.armoryPriceLabel = nil;
  self.armoryPriceIcon = nil;
  self.postedPriceLabel = nil;
  self.postedPriceIcon = nil;
  self.savePriceLabel = nil;
  self.savePriceIcon = nil;
  self.wrongClassView = nil;
  self.tooLowLevelView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.levelIcon = nil;
  [super dealloc];
}

@end

#define OPEN_CLOSE_BAR_DURATION 1.f
#define ROTATION_DEGREES M_PI_4 * 11.f

@implementation MarketplaceBottomBar

@synthesize weaponIcon, weaponAttackLabel, weaponDefenseLabel;
@synthesize armorIcon, armorAttackLabel, armorDefenseLabel;
@synthesize amuletIcon, amuletAttackLabel, amuletDefenseLabel;
@synthesize openCloseButton;

- (void) awakeFromNib {
  isOpen = YES;
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  UserEquip *ue = [gs myEquipWithUserEquipId:gs.weaponEquipped];
  if (ue) {
    [Globals loadImageForEquip:ue.equipId toView:weaponIcon maskedView:nil];
    weaponAttackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:ue.equipId level:ue.level]];
    weaponDefenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:ue.equipId level:ue.level]];
  } else {
    weaponIcon.image = nil;
    weaponAttackLabel.text = @"0";
    weaponDefenseLabel.text = @"0";
  }
  
  ue = [gs myEquipWithUserEquipId:gs.armorEquipped];
  if (ue) {
    [Globals loadImageForEquip:ue.equipId toView:armorIcon maskedView:nil];
    armorAttackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:ue.equipId level:ue.level]];
    armorDefenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:ue.equipId level:ue.level]];
  } else {
    armorIcon.image = nil;
    armorAttackLabel.text = @"0";
    armorDefenseLabel.text = @"0";
  }
  
  ue = [gs myEquipWithUserEquipId:gs.amuletEquipped];
  if (ue) {
    [Globals loadImageForEquip:ue.equipId toView:amuletIcon maskedView:nil];
    amuletAttackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:ue.equipId level:ue.level]];
    amuletDefenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:ue.equipId level:ue.level]];
  } else {
    amuletIcon.image = nil;
    amuletAttackLabel.text = @"0";
    amuletDefenseLabel.text = @"0";
  }
}

- (IBAction)openCloseButtonClicked:(id)sender {
  if (isOpen) {
    [self doClose];
  } else {
    [self doOpen];
  }
}

- (void) doClose {
  isOpen = NO;
  
  CABasicAnimation* rotationAnimation;
  rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.fromValue = [NSNumber numberWithFloat: 0];
  rotationAnimation.toValue = [NSNumber numberWithFloat:ROTATION_DEGREES];
  rotationAnimation.duration = OPEN_CLOSE_BAR_DURATION;
  rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  
  [openCloseButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
  openCloseButton.layer.transform = CATransform3DMakeRotation(ROTATION_DEGREES, 0.f, 0.f, 1.f);
  
  [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    CGRect r = self.frame;
    r.origin.x = self.superview.frame.size.width - 30;
    self.frame = r;
  } completion:nil];
}

- (void) doOpen {
  isOpen = YES;
  
  CABasicAnimation* rotationAnimation;
  rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.fromValue = [NSNumber numberWithFloat:ROTATION_DEGREES];
  rotationAnimation.toValue = [NSNumber numberWithFloat:0];
  rotationAnimation.duration = OPEN_CLOSE_BAR_DURATION;
  rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  
  [openCloseButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
  openCloseButton.layer.transform = CATransform3DIdentity;
  
  [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    CGRect r = self.frame;
    r.origin.x = 0;
    self.frame = r;
  } completion:nil];
}

- (void) dealloc {
  self.weaponIcon = nil;
  self.weaponAttackLabel = nil;
  self.weaponDefenseLabel = nil;
  self.armorIcon = nil;
  self.armorAttackLabel = nil;
  self.armorDefenseLabel = nil;
  self.amuletIcon = nil;
  self.amuletAttackLabel = nil;
  self.amuletDefenseLabel = nil;
  self.openCloseButton = nil;
  [super dealloc];
}

@end
