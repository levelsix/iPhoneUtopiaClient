//
//  RefillMenuControler.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "RefillMenuController.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "LNSynthesizeSingleton.h"
#import "GoldShoppeViewController.h"
#import "VaultMenuController.h"
#import "EquipDeltaView.h"
#import "ChatMenuController.h"
#import "SoundEngine.h"

#define REQUIRES_EQUIP_VIEW_OFFSET 5.f
#define EQUIPS_VIEW_SPACING 5.f

@implementation RequiresEquipView

@synthesize checkIcon, levelIcon, equipIcon;

- (void) loadWithEquipId:(int)eq level:(int)lvl owned:(BOOL)owned {
  equipIcon.equipId = eq;
  levelIcon.level = lvl;
  checkIcon.highlighted = !owned;
}

- (void) dealloc {
  self.checkIcon = nil;
  self.levelIcon = nil;
  self.equipIcon = nil;
  [super dealloc];
}

@end

@implementation RefillMenuController

@synthesize goldView, silverView, itemsView, enstView, spkrView;
@synthesize curGoldLabel, needGoldLabel;
@synthesize enstTitleLabel, enstImageView, enstGoldCostLabel, fillEnstLabel, enstHintLabel;
@synthesize itemsCostView, itemsSilverLabel;
@synthesize silverDescLabel;
@synthesize itemsScrollView, itemsContainerView;
@synthesize bgdView, rev, loadingView;
@synthesize spkrPkgLabel, spkrDescLabel, spkrGoldCostLabel;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(RefillMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  itemsView.frame = goldView.frame;
  enstView.frame = goldView.frame;
  silverView.frame = goldView.frame;
  spkrView.frame = goldView.frame;
  [self.view addSubview:itemsView];
  [self.view addSubview:enstView];
  [self.view addSubview:silverView];
  [self.view addSubview:spkrView];
  itemsView.hidden = YES;
  enstView.hidden = YES;
  goldView.hidden = YES;
  silverView.hidden = YES;
  spkrView.hidden = YES;
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    self.goldView = nil;
    self.silverView = nil;
    self.itemsView = nil;
    self.enstView = nil;
    self.curGoldLabel = nil;
    self.needGoldLabel = nil;
    self.enstTitleLabel = nil;
    self.enstImageView = nil;
    self.enstGoldCostLabel = nil;
    self.fillEnstLabel = nil;
    self.enstHintLabel = nil;
    self.itemsCostView = nil;
    self.itemsSilverLabel = nil;
    self.itemsScrollView = nil;
    self.itemsContainerView = nil;
    self.bgdView = nil;
    self.rev = nil;
    self.loadingView = nil;
    self.silverDescLabel = nil;
    self.spkrPkgLabel = nil;
    self.spkrGoldCostLabel = nil;
    self.spkrDescLabel = nil;
    self.spkrView = nil;
  }
}

- (void) displayEnstView:(BOOL)isEnergy {
  Globals *gl = [Globals sharedGlobals];
  
  _isEnergy = isEnergy;
  
  if (isEnergy) {
    enstImageView.highlighted = NO;
    enstGoldCostLabel.text = [NSString stringWithFormat:@"%d", gl.energyRefillCost];
    enstTitleLabel.text = @"Need Energy!";
    fillEnstLabel.text = @"FILL ENERGY";
    enstHintLabel.text = @"Hint: Energy refills over time.";
  } else {
    enstImageView.highlighted = YES;
    enstGoldCostLabel.text = [NSString stringWithFormat:@"%d", gl.staminaRefillCost];
    enstTitleLabel.text = @"Need Stamina!";
    fillEnstLabel.text = @"FILL STAMINA";
    enstHintLabel.text = @"Hint: Stamina refills over time.";
  }
  
  [self openView:enstView];
}

- (void) displayBuyGoldView:(int)needsGold {
  GameState *gs = [GameState sharedGameState];
  
  curGoldLabel.text = [Globals commafyNumber:gs.gold];
  needGoldLabel.text = [Globals commafyNumber:needsGold];
  
  [self openView:goldView];
}

- (void) displayBuySilverView:(int)needsSilver {
  GameState *gs = [GameState sharedGameState];
  _silverNeeded = needsSilver-gs.silver;
  silverDescLabel.text = [NSString stringWithFormat:@"You have %@ silver in the vault.", [Globals commafyNumber:gs.vaultBalance]];
  if (gs.vaultBalance < _silverNeeded	) {
    self.silverButtonLabel.text = @"Get More!";
  } else {
    self.silverButtonLabel.text = @"Open Vault";
  }
  
  [self openView:silverView];
}

- (void) displayBuySpeakersView {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  spkrDescLabel.text = [NSString stringWithFormat:@"You have %d speakers left.", gs.numGroupChatsRemaining];
  spkrGoldCostLabel.text = [NSString stringWithFormat:@"%d", gl.diamondPriceForGroupChatPurchasePackage];
  spkrPkgLabel.text = [NSString stringWithFormat:@"%d SPEAKERS", gl.numChatsGivenPerGroupChatPurchasePackage];
  
  [self openView:spkrView];
}

- (void) displayEquipsView:(NSArray *)equipIds {
  if (equipIds.count == 0) {
    return;
  }
  GameState *gs = [GameState sharedGameState];
  
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, itemsScrollView.frame.size.height)];
  [self.itemsContainerView removeFromSuperview];
  self.itemsContainerView = view;
  self.itemsContainerView.backgroundColor = [UIColor clearColor];
  [self.itemsScrollView addSubview:self.itemsContainerView];
  [view release];
  
  int totalCost = 0;
  
  // Format of array will be EquipId, Owned repeated
  for (int i = 0; i+2 < equipIds.count; i += 3) {
    [[NSBundle mainBundle] loadNibNamed:@"RequiredEquipView" owner:self options:nil];
    
    CGRect r = rev.frame;
    r.origin.x = i/3*(r.size.width+EQUIPS_VIEW_SPACING);
    r.origin.y = itemsContainerView.frame.size.height/2-r.size.height/2;
    rev.frame = r;
    
    int equipId = [[equipIds objectAtIndex:i] intValue];
    int level = [[equipIds objectAtIndex:i+1] intValue];
    BOOL owned = [[equipIds objectAtIndex:i+2] boolValue];
    [rev loadWithEquipId:equipId level:level owned:owned];
    
    [self.itemsContainerView addSubview:rev];
    
    if (! owned) {
      FullEquipProto *fep = [gs equipWithId:equipId];
      totalCost += fep.coinPrice;
    }
  }
  CGRect r = self.itemsContainerView.frame;
  r.size.width = CGRectGetMaxX(rev.frame);
  self.itemsContainerView.frame = r;
  
  if (itemsContainerView.frame.size.width > itemsScrollView.frame.size.width) {
    self.itemsScrollView.contentSize = CGSizeMake(itemsContainerView.frame.size.width, itemsScrollView.frame.size.height);
  } else {
    CGRect r = self.itemsContainerView.frame;
    r.origin.x = itemsScrollView.frame.size.width/2-itemsContainerView.frame.size.width/2;
    self.itemsContainerView.frame = r;
    
    self.itemsScrollView.contentSize = CGSizeMake(itemsScrollView.frame.size.width, itemsScrollView.frame.size.height);
  }
  
  float center = itemsCostView.center.x;
  NSString *string = [Globals commafyNumber:totalCost];
  itemsSilverLabel.text = string;
  CGSize expectedLabelSize = [string sizeWithFont:itemsSilverLabel.font];
  r = itemsSilverLabel.frame;
  r.size.width = expectedLabelSize.width;
  itemsSilverLabel.frame = r;
  
  r = itemsCostView.frame;
  r.size.width = CGRectGetMaxX(itemsSilverLabel.frame);
  itemsCostView.frame = r;
  
  itemsCostView.center = CGPointMake(center, itemsCostView.center.y);
  
  [self openView:itemsView];
}

- (void) openView:(UIView *)view {
  [self.view bringSubviewToFront:view];
  view.hidden = NO;
  
  if (!self.view.superview) {
    [RefillMenuController displayView];
    [Globals bounceView:view fadeInBgdView:self.bgdView];
  } else {
    [Globals bounceView:view];
    
    // bounceView does not fade in
    view.alpha = 0.f;
    [UIView animateWithDuration:0.3 animations:^{
      view.alpha = 1.f;
    }];
  }
}

- (void) closeView:(UIView *)view {
  if (!view) {
    return;
  }
  [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationCurveEaseIn animations:^{
    view.transform = CGAffineTransformMakeScale(1.15f, 1.15f);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationCurveEaseOut animations:^{
      view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
      view.alpha = 0.f;
      // If this is the last view we must fade out bgd view as well
      if ((view == goldView || goldView.hidden) &&
          (view == enstView || enstView.hidden) &&
          (view == itemsView || itemsView.hidden) &&
          (view == silverView || silverView.hidden)) {
        bgdView.alpha = 0.f;
      }
    } completion:^(BOOL finished) {
      view.hidden = YES;
      if (goldView.hidden && enstView.hidden && itemsView.hidden && silverView.hidden) {
        [RefillMenuController removeView];
      }
    }];
  }];
}

- (IBAction) refillGoldClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int goldCost = _isEnergy ? gl.energyRefillCost : gl.staminaRefillCost;
  
  if (goldCost > gs.gold) {
    [self displayBuyGoldView:goldCost];
    if (_isEnergy) {
      [Analytics notEnoughGoldToRefillEnergyPopup];
    } else {
      [Analytics notEnoughGoldToRefillStaminaPopup];
    }
  } else {
    if (_isEnergy) {
      [[OutgoingEventController sharedOutgoingEventController] refillEnergyWithDiamonds];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] refillStaminaWithDiamonds];
    }
    
    [self closeView:enstView];
  }
}

- (IBAction) getMoreGoldClicked:(id)sender {
  [self closeView:goldView];
  [GoldShoppeViewController displayView];
  [Analytics clickedGetMoreGold:[[needGoldLabel.text stringByReplacingOccurrencesOfString:@"," withString:@""] intValue]];
}

- (IBAction) buySpeakersClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.gold < gl.diamondPriceForGroupChatPurchasePackage) {
    [self displayBuyGoldView:gl.diamondPriceForGroupChatPurchasePackage];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] purchaseGroupChats];
    [[ChatMenuController sharedChatMenuController] updateNumChatsLabel];
    [self closeView:spkrView];
  }
}

- (IBAction) buyItemsClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  int amount = [itemsSilverLabel.text stringByReplacingOccurrencesOfString:@"," withString:@""].intValue;
  
  if (amount > gs.silver) {
    [self displayBuySilverView:amount];
  } else {
    // Buy items
    _numArmoryResponsesExpected = 0;
    for (RequiresEquipView *r in itemsContainerView.subviews) {
      if (r.checkIcon.highlighted) {
        int equipId = r.equipIcon.equipId;
        [[OutgoingEventController sharedOutgoingEventController] buyEquip:equipId];
        _numArmoryResponsesExpected++;
      }
    }
    [self.loadingView display:self.view];
    
    [[SoundEngine sharedSoundEngine] armoryBuy];
  }
}

- (void) receivedArmoryResponse:(BOOL)success equip:(int)equipId {
  if (self.view.superview && !self.itemsView.hidden) {
    _numArmoryResponsesExpected--;
    if (_numArmoryResponsesExpected <= 0) {
      [self.loadingView stop];
      [self closeView:itemsView];
    }
    
    if (success) {
      GameState *gs = [GameState sharedGameState];
      FullEquipProto *fep = [gs equipWithId:equipId];
      
      int price = fep.diamondPrice > 0 ? fep.diamondPrice : fep.coinPrice;
      
      UIView *contView = [[[CCDirector sharedDirector] openGLView] superview];
      CGPoint startLoc = contView.center;
      
      UIView *testView = [EquipDeltaView
                          createForUpperString:[NSString stringWithFormat:@"- %d %@",
                                                price, fep.diamondPrice ? @"Gold" : @"Silver"]
                          andLowerString:[NSString stringWithFormat:@"+1 %@", fep.name]
                          andCenter:startLoc
                          topColor:[Globals redColor]
                          botColor:[Globals colorForRarity:fep.rarity]];
      
      [Globals popupView:testView
             onSuperView:contView
                 atPoint:startLoc
     withCompletionBlock:nil];
    }
  }
}

- (IBAction) goToAviaryClicked:(id)sender {
  [self closeView:silverView];
  [self closeView:itemsView];
  GameState *gs = [GameState sharedGameState];
  if (_silverNeeded > gs.vaultBalance) {
    [GoldShoppeViewController displayView];
  } else {
    [[VaultMenuController sharedVaultMenuController] setDefaultValue:_silverNeeded];
    [VaultMenuController displayView];
  }
  [Analytics clickedGetMoreSilver];
}

- (IBAction) closeClicked:(id)sender {
  int tag = [(UIView *)sender tag];
  
  UIView *view = nil;
  if (tag == 1) {
    view = goldView;
  } else if (tag == 2) {
    view = enstView;
  } else if (tag == 3) {
    view = itemsView;
  } else if (tag == 4) {
    view = silverView;
  } else if (tag == 5) {
    view = spkrView;
  }
  [self closeView:view];
}

@end
