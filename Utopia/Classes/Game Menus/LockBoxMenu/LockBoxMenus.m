//
//  LockBoxMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/1/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LockBoxMenus.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "LockBoxMenuController.h"

@implementation LockBoxItemView

@synthesize itemIcon, quantityLabel, maskedItemIcon, itemId = _itemId, quantity = _quantity;

- (void) awakeFromNib {
  maskedItemIcon = [[UIImageView alloc] initWithFrame:itemIcon.frame];
  self.maskedItemIcon.contentMode = itemIcon.contentMode;
  [self insertSubview:maskedItemIcon aboveSubview:itemIcon];
}

- (void) loadForImage:(NSString *)img quantity:(int)quantity itemId:(int)itemId {
  [Globals imageNamed:img withView:itemIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  quantityLabel.text = [NSString stringWithFormat:@"x%d", quantity];
  
  if (quantity <= 0) {
    maskedItemIcon.hidden = NO;
    [Globals imageNamed:img withView:maskedItemIcon maskedColor:[UIColor colorWithWhite:0.f alpha:0.7f] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  } else {
    maskedItemIcon.hidden = YES;
  }
  
  _itemId = itemId;
  _quantity = quantity;
}

- (void) dealloc {
  self.itemIcon = nil;
  self.quantityLabel = nil;
  self.maskedItemIcon = nil;
  [super dealloc];
}

@end

@implementation LockBoxPickView

@synthesize chestIcon;
@synthesize freeChanceLabel, freePriceLabel;
@synthesize silverChanceLabel, silverPriceLabel;
@synthesize goldChanceLabel, goldPriceLabel;
@synthesize statusView, middleChestView, pickOptionsView;
@synthesize okayView;
@synthesize mainView, bgdView;

- (void) awakeFromNib {
  _oldChestFrame = chestIcon.frame;
  _middleChestFrame = middleChestView.frame;
  [middleChestView removeFromSuperview];
  self.middleChestView = nil;
}

- (void) loadForView:(UIView *)view chestImage:(NSString *)chestImage reset:(BOOL)reset {
  Globals *gl = [Globals sharedGlobals];
  
  [Globals imageNamed:chestImage withView:chestIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  freeChanceLabel.text = [NSString stringWithFormat:@"%d%% Chance", (int)(gl.freeChanceToPickLockBox*100)];
  silverChanceLabel.text = [NSString stringWithFormat:@"%d%% Chance", (int)(gl.silverChanceToPickLockBox*100)];
  goldChanceLabel.text = gl.goldChanceToPickLockBox >= 1.f ? @"Guaranteed to Open" : [NSString stringWithFormat:@"%d%% Chance", (int)(gl.goldChanceToPickLockBox*100)];
  
  silverPriceLabel.text = [Globals commafyNumber:gl.silverCostToPickLockBox];
  goldPriceLabel.text = [Globals commafyNumber:gl.goldCostToPickLockBox];
  
  _resetPickTimer = reset;
  
  chestIcon.hidden = NO;
  chestIcon.frame = _oldChestFrame;
  pickOptionsView.hidden = NO;
  statusView.hidden = YES;
  okayView.alpha = 0.f;
  
  self.frame = view.bounds;
  
  [view addSubview:self];
  [Globals bounceView:mainView fadeInBgdView:bgdView];
}

- (IBAction)freePickClicked:(id)sender {
  [self sendPickMessage:PickLockBoxRequestProto_PickLockBoxMethodFree];
}

- (IBAction)silverPickClicked:(id)sender {
  [self sendPickMessage:PickLockBoxRequestProto_PickLockBoxMethodSilver];
}

- (IBAction)goldPickClicked:(id)sender {
  [self sendPickMessage:PickLockBoxRequestProto_PickLockBoxMethodGold];
}

- (void) sendPickMessage:(PickLockBoxRequestProto_PickLockBoxMethod)method {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int goldCost = method == PickLockBoxRequestProto_PickLockBoxMethodGold ? gl.goldCostToPickLockBox : 0;
  int silverCost = method == PickLockBoxRequestProto_PickLockBoxMethodSilver ? gl.silverCostToPickLockBox : 0;
  if (_resetPickTimer){
    goldCost += gl.goldCostToResetPickLockBox;
  }
  if (gs.gold < goldCost) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:goldCost];
  } else if (gs.silver < silverCost) {
    [[RefillMenuController sharedRefillMenuController] displayBuySilverView:silverCost];
  } else {
    LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
    [[OutgoingEventController sharedOutgoingEventController] pickLockBox:lbe.lockBoxEventId method:method];
    [[LockBoxMenuController sharedLockBoxMenuController] updateLabels];
    [self doLoadingForChecking];
  }
}


- (void) doLoadingForChecking {
  _pickingLock = YES;
  _shouldShake = YES;
  
  self.statusView.hidden = NO;
  self.pickOptionsView.hidden = YES;
  
  [self.statusView displayCheckingLockBox];
  
  [UIView animateWithDuration:0.1f animations:^{
    chestIcon.frame = _middleChestFrame;
  } completion:^(BOOL finished) {
    [self shakeViews:[NSNumber numberWithFloat:1.5f]];
  }];
}

- (void) pickFailed {
  [self.statusView displayLockBoxFailed];
  
  [UIView animateWithDuration:0.2f animations:^{
    okayView.alpha = 1.f;
  }];
  
  _pickingLock = NO;
}

- (void) pickSucceeded:(LockBoxItemProto *)proto {
  UIView *view = [[UIView alloc] initWithFrame:self.bounds];
  [self addSubview:view];
  view.backgroundColor = [UIColor whiteColor];
  view.alpha = 0.f;
  
  [UIView animateWithDuration:0.6f animations:^{
    view.alpha = 1.f;
  } completion:^(BOOL finished) {
    [self.statusView displayLockBoxSuccess];
    chestIcon.alpha = 0.f;
    
    [Globals imageNamed:proto.imageName withView:chestIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    [UIView animateWithDuration:0.2f animations:^{
      view.alpha = 0.f;
      okayView.alpha = 1.f;
    } completion:^(BOOL finished) {
      [self doItemPop];
      
      [view removeFromSuperview];
      [view release];
    }];
  }];
}

- (void) doItemPop {
  chestIcon.alpha = 0.f;
  
  float scale = 3.f;
  chestIcon.transform = CGAffineTransformMakeScale(scale, scale);
  [UIView animateWithDuration:0.7f animations:^{
    chestIcon.alpha = 1.f;
    chestIcon.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    _pickingLock = NO;
  }];
}

- (void) shakeViews:(NSNumber *) duration {
  if (_shouldShake) {
    float dur = duration.floatValue;
    [Globals shakeView:chestIcon duration:dur offset:6.f];
    
    [self performSelector:@selector(shakeViews:) withObject:[NSNumber numberWithFloat:1.f] afterDelay:dur];
  }
}

- (IBAction)closeClicked:(id)sender {
  if (self.superview && !_pickingLock) {
    if (_toFlyDown) {
      self.chestIcon.hidden = YES;
      
      UIImageView *imgView = [[UIImageView alloc] initWithFrame:[self convertRect:chestIcon.frame fromView:self.mainView]];
      [self addSubview:imgView];
      imgView.contentMode = chestIcon.contentMode;
      [Globals imageNamed:_toFlyDown.imageName withView:imgView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
      
      
      [UIView animateWithDuration:0.1f animations:^{
        self.mainView.alpha = 0.f;
        self.bgdView.alpha = 0.f;
      } completion:^(BOOL finished) {
        [[LockBoxMenuController sharedLockBoxMenuController] flyItemToBottom:_toFlyDown prizeEquip:_prizeEquip];
        
        [_toFlyDown release];
        _toFlyDown = nil;
        [_prizeEquip release];
        _prizeEquip = nil;
        
        [imgView removeFromSuperview];
        [imgView release];
        
        [self removeFromSuperview];
      }];
    } else {
      [Globals popOutView:mainView fadeOutBgdView:bgdView completion:^{
        [self removeFromSuperview];
      }];
    }
  }
}

- (void) receivedPickLockResponse:(PickLockBoxResponseProto *)proto {
  [self.chestIcon.layer removeAllAnimations];
  if (proto.success) {
    [self pickSucceeded:proto.item];
    if (proto.hasItem) _toFlyDown = [proto.item retain];
    if (proto.hasPrizeEquip) _prizeEquip = [proto.prizeEquip retain];
  } else {
    [self pickFailed];
  }
  _shouldShake = NO;
}

- (void) dealloc {
  self.chestIcon = nil;
  self.freeChanceLabel = nil;
  self.freePriceLabel = nil;
  self.silverChanceLabel = nil;
  self.silverPriceLabel = nil;
  self.goldPriceLabel = nil;
  self.goldChanceLabel = nil;
  self.statusView = nil;
  self.middleChestView = nil;
  self.pickOptionsView = nil;
  self.okayView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  [_toFlyDown release];
  _toFlyDown = nil;
  [super dealloc];
}

@end

@implementation LockBoxStatusView

@synthesize statusLabel, checkIcon, xIcon, spinner;

- (void) displayLockBoxSuccess {
  self.statusLabel.text = @"Pick Succeeded";
  self.statusLabel.textColor = [Globals greenColor];
  self.checkIcon.hidden = NO;
  self.xIcon.hidden = YES;
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
}

- (void) displayLockBoxFailed {
  self.statusLabel.text = @"Pick Failed";
  self.statusLabel.textColor = [Globals redColor];
  self.checkIcon.hidden = YES;
  self.xIcon.hidden = NO;
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
}

- (void) displayCheckingLockBox {
  self.statusLabel.text = @"Checking...";
  self.statusLabel.textColor = [Globals creamColor];
  self.checkIcon.hidden = YES;
  self.xIcon.hidden = YES;
  self.spinner.hidden = NO;
  [self.spinner startAnimating];
}

- (void) dealloc {
  self.statusLabel = nil;
  self.checkIcon = nil;
  self.xIcon = nil;
  self.spinner = nil;
  [super dealloc];
}

@end

@implementation LockBoxPrizeView

@synthesize imgView1, imgView2, imgView3, imgView4, imgView5;
@synthesize stolenEquipView;
@synthesize bgdView, mainView;

- (void) awakeFromNib {
  oldRects = [[NSArray arrayWithObjects:[NSValue valueWithCGRect:imgView1.frame], [NSValue valueWithCGRect:imgView2.frame], [NSValue valueWithCGRect:imgView3.frame], [NSValue valueWithCGRect:imgView4.frame], [NSValue valueWithCGRect:imgView5.frame], nil] retain];
}

- (StolenEquipView *) stolenEquipView {
  if (!stolenEquipView) {
    [[NSBundle mainBundle] loadNibNamed:@"StolenEquipView" owner:self options:nil];
  }
  return stolenEquipView;
}

- (void) beginPrizeAnimationForImageView:(NSArray *)startImgViews prize:(FullUserEquipProto *)fuep {
  NSArray *imgViews = [NSArray arrayWithObjects:imgView1, imgView2, imgView3, imgView4, imgView5, nil];
  
  for (int i = 0; i < imgViews.count; i++) {
    UIImageView *origView = [startImgViews objectAtIndex:i];
    UIImageView *newView = [imgViews objectAtIndex:i];
    newView.frame = [origView.superview.superview convertRect:origView.frame fromView:origView.superview];
    newView.image = origView.image;
    newView.hidden = NO;
  }
  
  [[LockBoxMenuController sharedLockBoxMenuController] loadForCurrentEvent];
  
  bgdView.alpha = 0.f;
  mainView.transform = CGAffineTransformIdentity;
  [UIView animateWithDuration:2.f animations:^{
    bgdView.alpha = 1.f;
    
    for (int i = 0; i < imgViews.count; i++) {
      UIImageView *newView = [imgViews objectAtIndex:i];
      newView.frame = [[oldRects objectAtIndex:i] CGRectValue];
    }
  } completion:^(BOOL finished) {
    // Spin the views
    float duration = 5.f;
    float scale = 0.3f;
    CABasicAnimation* spinAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.rotation"];
    spinAnimation.toValue = [NSNumber numberWithFloat:8*2*M_PI];
    spinAnimation.duration = duration;
    spinAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [mainView.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:scale];
    scaleAnimation.duration = duration;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [mainView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
    for (UIImageView *iv in imgViews) {
      CABasicAnimation* newAnim = [CABasicAnimation
                                   animationWithKeyPath:@"transform.rotation"];
      newAnim.toValue = [NSNumber numberWithFloat:-[spinAnimation.toValue floatValue]];
      newAnim.duration = spinAnimation.duration;
      newAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
      [iv.layer addAnimation:newAnim forKey:@"spinAnimation"];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 0.f;
    
    float percentTillWhiteLight = 0.75f;
    [UIView animateWithDuration:(1-percentTillWhiteLight)*duration delay:percentTillWhiteLight*duration options:UIViewAnimationOptionTransitionNone animations:^{
      view.alpha = 1.f;
    } completion:^(BOOL finished) {
      for (UIImageView *iv in imgViews) {
        iv.hidden = YES;
      }
      
      GameState *gs = [GameState sharedGameState];
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      [self.stolenEquipView loadForEquip:fuep];
      stolenEquipView.mainView.alpha = 1.f;
      stolenEquipView.bgdView.alpha = 1.f;
      self.stolenEquipView.titleLabel = [NSString stringWithFormat:@"%@ Created!", fep.name];
      self.stolenEquipView.frame = view.bounds;
      [self insertSubview:self.stolenEquipView belowSubview:view];
      [Globals bounceView:stolenEquipView.mainView fadeInBgdView:stolenEquipView.bgdView];
      self.bgdView.alpha = 0.f;
      
      [UIView animateWithDuration:0.2f animations:^{
        view.alpha = 0.f;
      } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [view release];
      }];
    }];
  }];
}

- (IBAction)stolenEquipOkayClicked:(id)sender {
  [Globals popOutView:stolenEquipView.mainView fadeOutBgdView:stolenEquipView.bgdView completion:^{
    [stolenEquipView removeFromSuperview];
    [self removeFromSuperview];
  }];
}

- (void) dealloc {
  self.imgView1 = nil;
  self.imgView2 = nil;
  self.imgView3 = nil;
  self.imgView4 = nil;
  self.imgView5 = nil;
  self.bgdView = nil;
  self.mainView = nil;
  self.stolenEquipView = nil;
  [oldRects release];
  [super dealloc];
}

@end

@implementation LockBoxUnusedItemsView

- (void) displayForCurrentLockBoxEvent {
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  UserLockBoxEventProto *ulbe = [gs.myLockBoxEvents objectForKey:[NSNumber numberWithInt:lbe.lockBoxEventId]];
  
  int numViews = self.leftItemViews.count;
  int numGoldBoxes = 0;
  int numSilverBoxes = 0;
  for (int i = 0; i < numViews && i < lbe.itemsList.count; i++) {
    LockBoxItemProto *item = [lbe.itemsList objectAtIndex:i];
    LockBoxItemView *liv = [self.leftItemViews objectAtIndex:i];
    LockBoxItemView *riv = [self.rightItemViews objectAtIndex:i];
    UILabel *label = [self.leftLabels objectAtIndex:i];
    
    UserLockBoxItemProto *ui = nil;
    for (UserLockBoxItemProto *userItem in ulbe.itemsList) {
      if (userItem.lockBoxItemId == item.lockBoxItemId) {
        ui = userItem;
        break;
      }
    }

    [liv loadForImage:item.imageName quantity:1 itemId:item.lockBoxItemId];
    label.text = [NSString stringWithFormat:@"= %d %@ Chest%@", item.redeemForNumBoosterItems, item.isGoldBoosterPack ? @"Gold" : @"Silver", item.redeemForNumBoosterItems != 1 ? @"s" : @""];
    [riv loadForImage:item.imageName quantity:ui.quantity itemId:item.lockBoxItemId];
    
    if (item.isGoldBoosterPack) {
      numGoldBoxes += ui.quantity * item.redeemForNumBoosterItems;
    } else {
      numSilverBoxes += ui.quantity * item.redeemForNumBoosterItems;
    }
  }
  
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:lbe.endDate/1000.0];
  NSDate *now = [NSDate date];
  BOOL eventOver = [now compare:endDate] == NSOrderedDescending;
  self.buttonView.hidden = !eventOver;
  self.cantBuyLabel.hidden = eventOver;
  
  self.goldChestsLabel.text = [NSString stringWithFormat:@"%d Equip%@ from Gold Chests", numGoldBoxes, numGoldBoxes != 1 ? @"s" : @""];
  self.silverChestsLabel.text = [NSString stringWithFormat:@"%d Equip%@ from Silver Chests", numSilverBoxes, numSilverBoxes != 1 ? @"s" : @""];
  
  [Globals displayUIView:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction)openChestsClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  [[OutgoingEventController sharedOutgoingEventController] redeemLockBoxItems:lbe.lockBoxEventId];
  
  [self.loadingView display:self];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

- (void) dealloc {
  self.leftItemViews = nil;
  self.leftLabels = nil;
  self.rightItemViews = nil;
  self.silverChestsLabel = nil;
  self.goldChestsLabel = nil;
  self.cantBuyLabel = nil;
  self.buttonView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.loadingView = nil;
  [super dealloc];
}

@end

@implementation LockBoxInfoView

@synthesize topLabel, descriptionLabel, equipNameLabel, attackLabel, defenseLabel;
@synthesize item1Icon, item2Icon, item3Icon, item4Icon, item5Icon, prizeEquipIcon;
@synthesize tagIcon, mainView, bgdView, descriptionImage;

- (void) displayForCurrentLockBoxEvent {
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *lbe = [gs getCurrentLockBoxEvent];
  
  self.topLabel.text = lbe.eventName;
  self.descriptionLabel.text = lbe.descriptionString;
  [Globals imageNamed:lbe.descriptionImageName withView:descriptionImage maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  prizeEquipIcon.equipId = lbe.prizeEquip.equipId;
  [Globals imageNamed:lbe.tagImageName withView:tagIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *imgNames[5];
  for (int i = 0; i < 5; i++) {
    if (lbe.itemsList.count > i) {
      LockBoxItemProto *item = [lbe.itemsList objectAtIndex:i];
      imgNames[i] = item.imageName;
    }
  }
  [Globals imageNamed:imgNames[0] withView:item1Icon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:imgNames[1] withView:item2Icon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:imgNames[2] withView:item3Icon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:imgNames[3] withView:item4Icon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:imgNames[4] withView:item5Icon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.attackLabel.text = [Globals commafyNumber:lbe.prizeEquip.attackBoost];
  self.defenseLabel.text = [Globals commafyNumber:lbe.prizeEquip.defenseBoost];
  self.equipNameLabel.text = lbe.prizeEquip.name;
  self.equipNameLabel.textColor = [Globals colorForRarity:lbe.prizeEquip.rarity];
  
  [Globals displayUIView:self];
  [Globals bounceView:mainView fadeInBgdView:bgdView];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:mainView fadeOutBgdView:bgdView completion:^{
    [self removeFromSuperview];
  }];
}

- (IBAction)infoClicked:(id)sender {
  [self.unusedItemsView displayForCurrentLockBoxEvent];
}

- (void) dealloc {
  self.topLabel = nil;
  self.descriptionLabel = nil;
  self.equipNameLabel = nil;
  self.equipNameLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.item1Icon = nil;
  self.item2Icon = nil;
  self.item3Icon = nil;
  self.item4Icon = nil;
  self.item5Icon = nil;
  self.prizeEquipIcon = nil;
  self.tagIcon = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.unusedItemsView = nil;
  self.descriptionImage = nil;
  [super dealloc];
}

@end