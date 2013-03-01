//
//  ArmoryCarouselView.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/7/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ArmoryCarouselView.h"
#import "Globals.h"
#import "GameState.h"

@implementation ArmoryListing

- (void) updateForEquip:(FullEquipProto *)fep numCollected:(int)collected total:(int)total {
  Globals *gl = [Globals sharedGlobals];
  
  self.titleLabel.text = fep.name;
  self.titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  self.attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:fep.equipId level:1 enhancePercent:0]];
  self.defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:fep.equipId level:1 enhancePercent:0]];
  self.typeLabel.text = [Globals shortenedStringForEquipType:fep.equipType];
  self.typeLabel.textColor = [Globals colorForRarity:fep.rarity];
  [Globals loadImageForEquip:fep.equipId toView:self.equipIcon maskedView:nil];
  
  NSString *base = [[[Globals stringForRarity:fep.rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  NSString *dotFile = [base stringByAppendingString:@"dot.png"];
  [Globals imageNamed:dotFile withImageView:self.dotIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  NSString *bgdFile = [base stringByAppendingString:@"card.png"];
  [Globals imageNamed:bgdFile withImageView:self.bgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.amtCollectedLabel.text = [NSString stringWithFormat:@"%d / %d", total-collected, total];
  
  [self.overlay removeFromSuperview];
  self.overlay = [[UIImageView alloc] initWithFrame:self.bgdView.frame];
  [self addSubview:self.overlay];
  [self.overlay release];
  
  UIImage *overlayImg = [Globals maskImage:self.bgdView.image withColor:[UIColor colorWithWhite:0.f alpha:0.4f]];
  self.overlay.image = overlayImg;
  self.overlay.alpha = 0.f;
}

- (void) dealloc {
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.titleLabel = nil;
  self.bgdView = nil;
  self.equipIcon = nil;
  self.amtCollectedLabel = nil;
  self.amtCollectedView = nil;
  self.typeLabel = nil;
  self.dotIcon = nil;
  self.overlay = nil;
  [super dealloc];
}

@end

@implementation ArmoryCardDisplayView

- (void) awakeFromNib {
  UIImageView *secondGlow = [[[UIImageView alloc] initWithImage:self.bgdView.image] autorelease];
  secondGlow.contentMode = self.bgdView.contentMode;
  secondGlow.autoresizingMask = self.bgdView.autoresizingMask;
  secondGlow.frame = self.bgdView.bounds;
  [self.bgdView addSubview:secondGlow];
  
  [Globals imageNamed:@"spinner.png" withImageView:self.spinnerView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  [Globals imageNamed:@"bpcardback.png" withImageView:self.cardBackImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (ArmoryListing *) armoryListing {
  if (!_armoryListing) {
    [[NSBundle mainBundle] loadNibNamed:@"ArmoryListing" owner:self options:nil];
    _armoryListing.amtCollectedView.hidden = YES;
  }
  return _armoryListing;
}

- (void) beginAnimatingForEquips:(NSArray *)equips {
  if (equips.count <= 0) {
    self.equips = nil;
    [self removeFromSuperview];
    return;
  }
  
  self.equips = equips;
  _currentIndex = 0;
  
  self.bgdView.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    self.bgdView.alpha = 1.f;
  }];
  
  self.spinnerView.alpha = 0.f;
  
  [self showNextEquip];
}

- (void) fadeOutOldEquip {
  [self fadeImageView:self.spinnerView toAlpha:0.f];
  [self insertSubview:self.armoryListing belowSubview:self.cardView];
  self.armoryListing.center = self.cardView.center;
  [Globals popOutView:self.armoryListing fadeOutBgdView:nil completion:nil];
  //  [UIView animateWithDuration:0.3f animations:^{
  //    self.armoryListing.alpha = 0.f;
  //  }];
}

- (IBAction)showNextEquip {
  GameState *gs = [GameState sharedGameState];
  
  self.buttonView.hidden = YES;
  if (_currentIndex > 0) {
    [self fadeOutOldEquip];
  }
  
  if (_currentIndex < self.equips.count) {
    FullUserEquipProto *fuep = [self.equips objectAtIndex:_currentIndex];
    
    [self.cardView addSubview:self.cardBackImageView];
    self.cardView.center = CGPointMake(self.cardView.center.x, -self.cardView.frame.size.height/2);
    [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
      self.cardView.center = CGPointMake(self.cardView.center.x, self.frame.size.height/2);
    } completion:^(BOOL finished) {
      self.armoryListing.center = self.cardBackImageView.center;
      [self.armoryListing updateForEquip:[gs equipWithId:fuep.equipId] numCollected:0 total:0];
      
      [self flipCard];
    }];
    
    _currentIndex++;
  } else {
    [self endAnimatingForEquips];
  }
}

- (void) flipCard {
  self.armoryListing.alpha = 1.f;
  [UIView transitionFromView:self.cardBackImageView toView:self.armoryListing duration:1.8f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
    self.buttonView.hidden = NO;
    [Globals bounceView:self.buttonView];
    
    [self fadeImageView:self.spinnerView toAlpha:1.f];
    [self rotateSpinner];
  }];
}

#define SPINNER_NORMAL_DURATION 6.f
#define SPINNER_SLOWDOWN_DURATION 3.f
#define SPINNER_BEFORE_FADEOUT_DURATION 9.5f

- (void) rotateSpinner {
  CABasicAnimation *fullRotation;
  fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  fullRotation.fromValue = [NSNumber numberWithFloat:0];
  fullRotation.toValue = [NSNumber numberWithFloat:M_PI * 6.f/5.f];
  fullRotation.duration = SPINNER_NORMAL_DURATION;
  [self.spinnerView.layer addAnimation:fullRotation forKey:@"360"];
  
  self.spinnerView.transform = CGAffineTransformMakeRotation([fullRotation.toValue floatValue]);
  
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  [self performSelector:@selector(slowDownSpinner) withObject:nil afterDelay:SPINNER_NORMAL_DURATION];
  [self performSelector:@selector(fadeOutSpinner) withObject:nil afterDelay:SPINNER_BEFORE_FADEOUT_DURATION];
}

- (void) endAnimatingForEquips {
  [UIView animateWithDuration:0.3f animations:^{
    self.bgdView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    self.equips = nil;
  }];
}

- (void) slowDownSpinner {
  CABasicAnimation *fullRotation;
  fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  fullRotation.fromValue = [NSNumber numberWithFloat:M_PI * 6.f/5.f];
  fullRotation.toValue = [NSNumber numberWithFloat:M_PI * 22.f/15.f];
  fullRotation.duration = SPINNER_SLOWDOWN_DURATION;
  fullRotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  [self.spinnerView.layer addAnimation:fullRotation forKey:@"360"];
  
  self.spinnerView.transform = CGAffineTransformMakeRotation([fullRotation.toValue floatValue]);
}

- (void) fadeOutSpinner {
  [self fadeImageView:self.spinnerView toAlpha:0.f];
}

- (void) fadeImageView:(UIImageView *)iv toAlpha:(float)alpha {
  [UIView animateWithDuration:1.f animations:^{
    iv.alpha = alpha;
  }];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!self.buttonView.hidden) {
    [self showNextEquip];
  }
}

- (void) dealloc {
  self.bgdView = nil;
  self.cardBackImageView = nil;
  self.armoryListing = nil;
  self.buttonView = nil;
  self.cardView = nil;
  self.equips = nil;
  self.spinnerView = nil;
  [super dealloc];
}

@end

@implementation ArmoryCarouselView

#pragma mark -
#pragma mark iCarousel methods

- (void) awakeFromNib {
  self.carousel.type = iCarouselTypeCoverFlow;
  [self.carousel scrollToItemAtIndex:3 animated:NO];
  
  Globals *gl = [Globals sharedGlobals];
  self.numEquipsLabel1.text = [NSString stringWithFormat:@"%d EQUIP%@", gl.purchaseOptionOneNumBoosterItems, gl.purchaseOptionOneNumBoosterItems != 1 ? @"S" : @""];
  self.numEquipsLabel2.text = [NSString stringWithFormat:@"%d EQUIP%@", gl.purchaseOptionTwoNumBoosterItems, gl.purchaseOptionTwoNumBoosterItems != 1 ? @"S" : @""];
  
  [Globals imageNamed:@"shelfpackbg.png" withImageView:self.shelfImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) updateBottomLabels {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto_Rarity baseRarity = 0;
  BOOL costsGold = !self.booster.costsCoins;
  if (costsGold) {
    baseRarity = FullEquipProto_RarityRare;
  } else {
    baseRarity = FullEquipProto_RarityCommon;
  }
  
  // Determine totals and collected for each group
  int totalGroup1 = 0;
  int totalGroup2 = 0;
  int totalGroup3 = 0;
  int collectedGroup1 = 0;
  int collectedGroup2 = 0;
  int collectedGroup3 = 0;
  for (BoosterItemProto *item in self.booster.boosterItemsList) {
    UserBoosterItemProto *userItem = nil;
    for (UserBoosterItemProto *ui in self.userBooster.userBoosterItemsList) {
      if (ui.boosterItemId == item.boosterItemId) {
        userItem = ui;
        break;
      }
    }
    
    FullEquipProto *fep = [gs equipWithId:item.equipId];
    if (fep.rarity == baseRarity) {
      totalGroup1 += item.quantity;
      collectedGroup1 += userItem.numReceived;
    } else if (fep.rarity == baseRarity+1) {
      totalGroup2 += item.quantity;
      collectedGroup2 += userItem.numReceived;
    } else if (fep.rarity == baseRarity+2) {
      totalGroup3 += item.quantity;
      collectedGroup3 += userItem.numReceived;
    }
  }
  self.amtLabel1.text = [NSString stringWithFormat:@"%d/%d", totalGroup1-collectedGroup1, totalGroup1];
  self.amtLabel2.text = [NSString stringWithFormat:@"%d/%d", totalGroup2-collectedGroup2, totalGroup2];
  self.amtLabel3.text = [NSString stringWithFormat:@"%d/%d", totalGroup3-collectedGroup3, totalGroup3];
  
  // Fill in the tags
  NSString *fileEnd = @"tag.png";
  NSString *base = [[[Globals stringForRarity:baseRarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  NSString *tagFile = [base stringByAppendingString:fileEnd];
  [Globals imageNamed:tagFile withImageView:self.tagView1 maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  base = [[[Globals stringForRarity:baseRarity+1] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  tagFile = [base stringByAppendingString:fileEnd];
  [Globals imageNamed:tagFile withImageView:self.tagView2 maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  base = [[[Globals stringForRarity:baseRarity+2] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  tagFile = [base stringByAppendingString:fileEnd];
  [Globals imageNamed:tagFile withImageView:self.tagView3 maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (self.booster.salePriceOne > 0) {
    self.saleLabel1.text = [Globals commafyNumber:self.booster.salePriceOne];
    self.retailLabel1.text = [Globals commafyNumber:self.booster.retailPriceOne];
    
    self.saleCoinIcon1.highlighted = costsGold;
    self.retailCoinIcon1.highlighted = costsGold;
    
    self.saleView1.hidden = NO;
    self.noSaleView1.hidden = YES;
  } else {
    self.normalLabel1.text = [Globals commafyNumber:self.booster.retailPriceOne];
    
    self.normalCoinIcon1.highlighted = costsGold;
    
    self.saleView1.hidden = YES;
    self.noSaleView1.hidden = NO;
    
    [Globals adjustViewForCentering:self.noSaleView1 withLabel:self.normalLabel1];
  }
  
  if (self.booster.salePriceTwo > 0) {
    self.saleLabel2.text = [Globals commafyNumber:self.booster.salePriceTwo];
    self.retailLabel2.text = [Globals commafyNumber:self.booster.retailPriceTwo];
    
    self.saleCoinIcon2.highlighted = costsGold;
    self.retailCoinIcon2.highlighted = costsGold;
    
    self.saleView2.hidden = NO;
    self.noSaleView2.hidden = YES;
  } else {
    self.normalLabel2.text = [Globals commafyNumber:self.booster.retailPriceTwo];
    
    self.normalCoinIcon2.highlighted = costsGold;
    
    self.saleView2.hidden = YES;
    self.noSaleView2.hidden = NO;
    
    [Globals adjustViewForCentering:self.noSaleView2 withLabel:self.normalLabel2];
  }
}

- (void) updateForBoosterPack:(BoosterPackProto *)bpp userPack:(UserBoosterPackProto *)ubpp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  self.booster = bpp;
  self.userBooster = ubpp;
  
  NSMutableArray *specials = [NSMutableArray array];
  for (BoosterItemProto *bip in bpp.boosterItemsList) {
    if (bip.isSpecial) {
      [specials addObject:bip];
    }
  }
  
  [specials sortUsingComparator:^NSComparisonResult(BoosterItemProto *obj1, BoosterItemProto *obj2) {
    int attack1 = [gl calculateAttackForEquip:obj1.equipId level:1 enhancePercent:0];
    int defense1 = [gl calculateDefenseForEquip:obj1.equipId level:1 enhancePercent:0];
    int attack2 = [gl calculateAttackForEquip:obj2.equipId level:1 enhancePercent:0];
    int defense2 = [gl calculateDefenseForEquip:obj2.equipId level:1 enhancePercent:0];
    FullEquipProto *fep1 = [gs equipWithId:obj1.equipId];
    FullEquipProto *fep2 = [gs equipWithId:obj2.equipId];
    if (fep1.rarity > fep2.rarity) {
      return NSOrderedAscending;
    } else if (fep1.rarity < fep2.rarity) {
      return NSOrderedDescending;
    } else {
      if (attack1+defense1 < attack2+defense2) {
        return NSOrderedDescending;
      } else if (attack1+defense1 > attack2+defense2) {
        return NSOrderedAscending;
      }
      return NSOrderedSame;
    }
  }];
  
  self.specialItems = specials;
  
  [self updateBottomLabels];
  [self.carousel reloadData];
  [self.carousel scrollToItemAtIndex:self.specialItems.count/2 animated:YES];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
  return self.specialItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(ArmoryListing *)view
{
  //create new view if no view is available for recycling
  if (view == nil)
  {
    [[NSBundle mainBundle] loadNibNamed:@"ArmoryListing" owner:self options:nil];
    view = self.armoryListing;
  }
  
  GameState *gs = [GameState sharedGameState];
  int arrIndex = index-self.specialItems.count/2;
  arrIndex = arrIndex < 0 ? arrIndex*-2-1 : arrIndex*2;
  BoosterItemProto *item = [self.specialItems objectAtIndex:arrIndex];
  FullEquipProto *equip = [gs equipWithId:item.equipId];
  
  UserBoosterItemProto *userItem = nil;
  for (UserBoosterItemProto *ui in self.userBooster.userBoosterItemsList) {
    if (ui.boosterItemId == item.boosterItemId) {
      userItem = ui;
      break;
    }
  }
  
  [view updateForEquip:equip numCollected:userItem.numReceived total:item.quantity];
  
  return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
  switch (option)
  {
    case iCarouselOptionTilt:
      return 0.6;
    case iCarouselOptionSpacing:
      return value * 0.8;
    default:
      return value;
  }
}

- (void) dealloc {
  self.carousel = nil;
  self.booster = nil;
  self.armoryListing = nil;
  self.userBooster = nil;
  self.tagView1 = nil;
  self.tagView2 = nil;
  self.tagView3 = nil;
  self.amtLabel1 = nil;
  self.amtLabel2 = nil;
  self.amtLabel3 = nil;
  self.saleCoinIcon1 = nil;
  self.saleLabel1 = nil;
  self.retailCoinIcon1 = nil;
  self.retailLabel1 = nil;
  self.normalCoinIcon1 = nil;
  self.normalLabel1 = nil;
  self.saleView1 = nil;
  self.noSaleView2 = nil;
  self.saleCoinIcon2 = nil;
  self.saleLabel2 = nil;
  self.retailCoinIcon2 = nil;
  self.retailLabel2 = nil;
  self.normalCoinIcon2 = nil;
  self.normalLabel2 = nil;
  self.saleView2 = nil;
  self.noSaleView2 = nil;
  self.numEquipsLabel1 = nil;
  self.numEquipsLabel2 = nil;
  self.shelfImageView = nil;
  [super dealloc];
}

@end
