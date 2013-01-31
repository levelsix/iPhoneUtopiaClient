//
//  ForgeMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ForgeMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "GameMap.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "RefillMenuController.h"
#import "MarketplaceViewController.h"
#import "EquipDeltaView.h"
#import "SoundEngine.h"

@implementation ForgeTopBar

@synthesize button1, button2;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
}

- (void) loadForForge:(BOOL)isGlobal {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  [self clickButton:isGlobal ? kButton1 : kButton2];
}

- (void) clickButton:(LeaderboardBarButton)button {
  switch (button) {
    case kButton1:
      button1.hidden = NO;
      _clickedButtons |= kButton1;
      break;
      
    case kButton2:
      button2.hidden = NO;
      _clickedButtons |= kButton2;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(LeaderboardBarButton)button {
  switch (button) {
    case kButton1:
      button1.hidden = YES;
      _clickedButtons &= ~kButton1;
      break;
      
    case kButton2:
      button2.hidden = YES;
      _clickedButtons &= ~kButton2;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (!(_clickedButtons & kButton1) && [button1 pointInside:pt withEvent:nil]) {
    _trackingButton1 = YES;
    [self clickButton:kButton1];
  }
  
  pt = [touch locationInView:button2];
  if (!(_clickedButtons & kButton2) && [button2 pointInside:pt withEvent:nil]) {
    _trackingButton2 = YES;
    [self clickButton:kButton2];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
    } else {
      [self unclickButton:kButton2];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
      [self unclickButton:kButton2];
      
      [[ForgeMenuController sharedForgeMenuController] displayForgeMenu];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton1];
      
      [[ForgeMenuController sharedForgeMenuController] displayEnhanceMenu];
    } else {
      [self unclickButton:kButton2];
    }
  }
  
  _trackingButton1 = NO;
  _trackingButton2 = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  _trackingButton1 = NO;
  _trackingButton2 = NO;
}

- (void) dealloc {
  self.button2 = nil;
  self.button1 = nil;
  [super dealloc];
}

@end

@implementation ForgeMenuController

@synthesize topBar, mainView, bgdView;
@synthesize forgeTableView;
@synthesize itemView;
@synthesize forgeItems;
@synthesize backOldItemView, backOldEquipIcon, backOldAttackLabel, backOldDefenseLabel, backOldStatsView;
@synthesize frontOldItemView, frontOldEquipIcon, frontOldAttackLabel, frontOldDefenseLabel, frontOldStatsView;
@synthesize upgrItemView, upgrEquipIcon, upgrAttackLabel, upgrDefenseLabel;
@synthesize chanceOfSuccessLabel, forgeTimeLabel, bottomLabel;
@synthesize backMovingView, frontMovingView;
@synthesize notForgingMiddleView, coinBar;
@synthesize progressView, statusView, notEnoughQuantityView;
@synthesize forgeButton, finishNowButton, collectButton, okayButton, goToMarketplaceButton, buyOneView;
@synthesize buyOneCoinIcon, buyOneLabel;
@synthesize frontOldForgingPlacerView, backOldForgingPlacerView;
@synthesize backOldLevelIcon, frontOldLevelIcon, upgrLevelIcon;
@synthesize equalPlusSign, twinkleIcon;
@synthesize loadingView;
@synthesize curItem;
@synthesize forgingView, enhancingView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ForgeMenuController);

//- (id) init {
//  Globals *gl = [Globals sharedGlobals];
//  return [self initWithNibName:@"ForgeMenuController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.blacksmithNibName]];
//}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.backMovingView = [[[UIImageView alloc] init] autorelease];
  self.frontMovingView = [[[UIImageView alloc] init] autorelease];
  self.backMovingView.contentMode = UIViewContentModeScaleAspectFit;
  self.frontMovingView.contentMode = UIViewContentModeScaleAspectFit;
  self.backMovingView.hidden = YES;
  self.frontMovingView.hidden = YES;
  
  [self.forgingView insertSubview:self.frontMovingView aboveSubview:self.frontOldItemView];
  [self.forgingView insertSubview:self.backMovingView aboveSubview:self.backOldItemView];
  
  progressView.frame = notForgingMiddleView.frame;
  [self.forgingView addSubview:progressView];
  
  statusView.frame = notForgingMiddleView.frame;
  [self.forgingView addSubview:statusView];
  
  notEnoughQuantityView.frame = notForgingMiddleView.frame;
  [self.forgingView addSubview:notEnoughQuantityView];
  
  buyOneView.frame = forgeButton.frame;
  [self.forgingView addSubview:buyOneView];
  
  self.enhancingView.frame = self.forgingView.frame;
  [self.mainView addSubview:self.enhancingView];
  
  backOldFrame = self.backOldItemView.frame;
  frontOldFrame = self.frontOldItemView.frame;
  upgrFrame = self.upgrItemView.frame;
  
  [self displayForgeMenu];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.topBar = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.itemView = nil;
    self.forgeItems = nil;
    self.forgeTableView = nil;
    self.backOldItemView = nil;
    self.backOldEquipIcon = nil;
    self.backOldDefenseLabel = nil;
    self.backOldAttackLabel = nil;
    self.backOldStatsView = nil;
    self.frontOldItemView = nil;
    self.frontOldEquipIcon = nil;
    self.frontOldDefenseLabel = nil;
    self.frontOldAttackLabel = nil;
    self.frontOldStatsView = nil;
    self.upgrDefenseLabel = nil;
    self.upgrAttackLabel = nil;
    self.upgrEquipIcon = nil;
    self.upgrItemView = nil;
    self.chanceOfSuccessLabel = nil;
    self.forgeTimeLabel = nil;
    self.backMovingView = nil;
    self.frontMovingView = nil;
    self.notForgingMiddleView = nil;
    self.progressView = nil;
    self.progressView = nil;
    self.curItem = nil;
    self.forgeButton = nil;
    self.collectButton = nil;
    self.okayButton = nil;
    self.frontOldForgingPlacerView = nil;
    self.backOldForgingPlacerView = nil;
    self.equalPlusSign = nil;
    self.finishNowButton = nil;
    self.loadingView = nil;
    self.statusView = nil;
    self.bottomLabel = nil;
    self.twinkleIcon = nil;
    self.notEnoughQuantityView = nil;
    self.coinBar = nil;
    self.goToMarketplaceButton = nil;
    self.buyOneView = nil;
    self.buyOneCoinIcon = nil;
    self.buyOneLabel = nil;
    self.forgingView = nil;
    self.enhancingView = nil;
    self.navBar = nil;
  }
}

- (void) viewWillAppear:(BOOL)animated {
  self.topBar.center = CGPointMake(self.topBar.center.x, -self.topBar.frame.size.height/2);
  self.mainView.center = CGPointMake(self.mainView.center.x, CGRectGetMaxY(self.view.frame)+self.mainView.frame.size.height/2);
  self.bgdView.alpha = 0.f;
  
  [UIView animateWithDuration:0.4f delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
    self.topBar.center = CGPointMake(self.topBar.center.x, self.topBar.frame.size.height/2);
    self.mainView.center = CGPointMake(self.mainView.center.x, CGRectGetMaxY(self.view.frame)-self.mainView.frame.size.height/2);
    self.bgdView.alpha = 1.f;
  } completion:nil];
  
  [self loadForgeItems];
  
  _collectingEquips = NO;
  _shouldShake = NO;
  _forgedUserEquipId = 0;
  
  [self.coinBar updateLabels];
  
  [self.enhancingView reload];
  
  [[SoundEngine sharedSoundEngine] forgeEnter];
}

- (void) displayForgeMenu {
  [self.navBar loadForForge:YES];
  self.enhancingView.hidden = YES;
  self.forgingView.hidden = NO;
  [self loadForgeItems];
}

- (void) displayEnhanceMenu {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gl.minLevelConstants.enhancingMinLevel > gs.level) {
    [Globals popupMessage:[NSString stringWithFormat:@"Enhancement unlocks at level %d.", gl.minLevelConstants.enhancingMinLevel]];
    [self displayForgeMenu];
  } else {
    [self.navBar loadForForge:NO];
    self.enhancingView.hidden = NO;
    self.forgingView.hidden = YES;
    [self.enhancingView reload];
  }
}

- (void) loadForgeItems {
  NSMutableArray *items = [[NSMutableArray alloc] init];
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  // Create a bunch of forge items
  for (UserEquip *ue in gs.myEquips) {
    ForgeItem *item = nil;
    for (ForgeItem *fi in items) {
      if (fi.equipId == ue.equipId && fi.level == ue.level) {
        item = fi;
        break;
      }
    }
    
    if (item) {
      item.quantity++;
    } else {
      item = [[ForgeItem alloc] init];
      item.equipId = ue.equipId;
      item.level = ue.level;
      item.quantity = 1;
      [items addObject:item];
      [item release];
    }
  }
  
  // Fake 2 items from the forge
  ForgeAttempt *fa = gs.forgeAttempt;
  ForgeItem *forgingItem = nil;
  if (fa) {
    for (ForgeItem *fi in items) {
      if (fi.equipId == fa.equipId && fi.level == fa.level) {
        forgingItem = fi;
        break;
      }
    }
    
    if (forgingItem) {
      forgingItem.quantity += 2;
    } else {
      forgingItem = [[ForgeItem alloc] init];
      forgingItem.equipId = fa.equipId;
      forgingItem.level = fa.level;
      forgingItem.quantity = 2;
      [items addObject:forgingItem];
      [forgingItem release];
    }
  }
  
  // Sort the forge items
  int total = items.count;
  int maxLevel = gl.forgeMaxEquipLevel;
  self.forgeItems = [NSMutableArray arrayWithCapacity:total];
  for (int i = 0; i < total; i++) {
    ForgeItem *best = nil;
    for (ForgeItem *item in items) {
      if (!best) {
        best = item;
      }
      
      // All level 10's go at the end
      else if (best.level >= maxLevel && item.level < maxLevel) {
        best = item;
      } else if (item.level >= maxLevel && best.level < maxLevel) {
        // Keep old best
      }
      
      // First, prioritize items with quantity >= 2
      // Then, priotitize based on attack+defense
      else if (item.quantity >= 2 && best.quantity < 2) {
        best = item;
      } else if (best.quantity >= 2 && item.quantity < 2) {
        // Keep the old best
      } else {
        int bestAttack = [gl calculateAttackForEquip:best.equipId level:best.level enhancePercent:0];
        int bestDefense = [gl calculateDefenseForEquip:best.equipId level:best.level enhancePercent:0];
        int curAttack = [gl calculateAttackForEquip:item.equipId level:item.level enhancePercent:0];
        int curDefense = [gl calculateDefenseForEquip:item.equipId level:item.level enhancePercent:0];
        if (curAttack+curDefense > bestAttack+bestDefense) {
          best = item;
        }
      }
    }
    [self.forgeItems addObject:best];
    [items removeObject:best];
  }
  [items release];
  
  [self.forgeTableView reloadData];
  
  if (!_collectingEquips) {
    if (forgingItem) {
      int index = [self.forgeItems indexOfObject:forgingItem];
      [self selectRow:index animated:NO];
    } else {
      [self selectRow:0 animated:NO];
    }
  } else {
    // Find the new cur item
    ForgeItem *fi = nil;
    for (ForgeItem *f in self.forgeItems) {
      if (f.equipId == self.curItem.equipId && f.level == self.curItem.level) {
        fi = f;
        break;
      }
    }
    
    self.curItem = fi ? fi : [self.forgeItems objectAtIndex:0];
    int index = fi ? [self.forgeItems indexOfObject:fi] : 0;
    [self.forgeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
  }
}

- (void) selectRow:(int)index animated:(BOOL)animated {
  if (index < [self.forgeTableView numberOfRowsInSection:0]) {
    [self.forgeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
    [self loadRightViewForForgeItem:[self.forgeItems objectAtIndex:index] fromItemView:nil];
  } else {
    [self loadRightViewForForgeItem:nil fromItemView:nil];
  }
}

- (void) reloadCurrentItem {
  ForgeItem *f = self.curItem;
  self.curItem = nil;
  [self loadRightViewForForgeItem:f fromItemView:(ForgeItemView *)[self.forgeTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.forgeItems indexOfObject:f] inSection:0]]];
}

- (void) loadRightViewForCurrentForgingItem:(ForgeItem *)fi {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.forgeButton.hidden = YES;
  self.okayButton.hidden = YES;
  self.goToMarketplaceButton.hidden = YES;
  self.buyOneView.hidden = YES;
  
  self.notForgingMiddleView.hidden = YES;
  self.backMovingView.hidden = YES;
  self.frontMovingView.hidden = YES;
  [self.backMovingView.layer removeAllAnimations];
  [self.frontMovingView.layer removeAllAnimations];
  
  self.equalPlusSign.highlighted = YES;
  
  self.upgrItemView.alpha = 0.f;
  self.backOldItemView.frame = self.backOldForgingPlacerView.frame;
  self.frontOldItemView.frame = self.frontOldForgingPlacerView.frame;
  self.backOldItemView.alpha = 1.f;
  self.frontOldItemView.alpha = 1.f;
  
  int oldAttack = [gl calculateAttackForEquip:fi.equipId level:fi.level enhancePercent:0];
  int oldDefense = [gl calculateDefenseForEquip:fi.equipId level:fi.level enhancePercent:0];
  int newAttack = [gl calculateAttackForEquip:fi.equipId level:fi.level+1 enhancePercent:0];
  int newDefense = [gl calculateDefenseForEquip:fi.equipId level:fi.level+1 enhancePercent:0];
  
  self.backOldAttackLabel.text = [NSString stringWithFormat:@"%d", oldAttack];
  self.backOldDefenseLabel.text = [NSString stringWithFormat:@"%d", oldDefense];
  
  self.frontOldAttackLabel.text = [NSString stringWithFormat:@"%d", oldAttack];
  self.frontOldDefenseLabel.text = [NSString stringWithFormat:@"%d", oldDefense];
  
  self.upgrAttackLabel.text = [NSString stringWithFormat:@"%d", newAttack];
  self.upgrDefenseLabel.text = [NSString stringWithFormat:@"%d", newDefense];
  
  [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
  [Globals loadImageForEquip:fi.equipId toView:self.frontOldEquipIcon maskedView:nil];
  [Globals loadImageForEquip:fi.equipId toView:self.upgrEquipIcon maskedView:nil];
  
  self.frontOldStatsView.hidden = NO;
  
  self.backOldLevelIcon.level = fi.level;
  self.frontOldLevelIcon.level = fi.level;
  // Use same level because it will get smashed upon success
  self.frontOldLevelIcon.level = fi.level;
  
  // Set alphas to 1 because animation from before might have set to 0.5
  self.backOldEquipIcon.alpha = 1.f;
  self.frontOldEquipIcon.alpha = 1.f;
  
  if (gs.forgeAttempt.guaranteed) {
    self.bottomLabel.text = @"This forge is guaranteed to succeed.";
  } else {
    float chance = [gl calculateChanceOfSuccess:fi.equipId level:fi.level];
    self.bottomLabel.text = [NSString stringWithFormat:@"This forge will succeed with a %d%% chance.", (int)roundf(chance*100)];
  }
  self.bottomLabel.textColor = [Globals creamColor];
  
  if (gs.forgeAttempt.isComplete) {
    self.progressView.hidden = YES;
    self.statusView.hidden = NO;
    self.notEnoughQuantityView.hidden = YES;
    self.finishNowButton.hidden = YES;
    self.collectButton.hidden = NO;
    [self.statusView displayAttemptComplete];
  } else {
    self.progressView.hidden = NO;
    self.statusView.hidden = YES;
    self.notEnoughQuantityView.hidden = YES;
    self.finishNowButton.hidden = NO;
    self.collectButton.hidden = YES;
    [self.progressView beginAnimating];
  }
}

- (void) loadRightViewForNotEnoughQuantity:(ForgeItem *)fi fromItemView:(ForgeItemView *)fiv {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  //  FullEquipProto *fep = [gs equipWithId:fi.equipId];
  
  int oldAttack = [gl calculateAttackForEquip:fi.equipId level:fi.level enhancePercent:0];
  int oldDefense = [gl calculateDefenseForEquip:fi.equipId level:fi.level enhancePercent:0];
  int newAttack = [gl calculateAttackForEquip:fi.equipId level:fi.level+1 enhancePercent:0];
  int newDefense = [gl calculateDefenseForEquip:fi.equipId level:fi.level+1 enhancePercent:0];
  
  self.backOldAttackLabel.text = [NSString stringWithFormat:@"%d", oldAttack];
  self.backOldDefenseLabel.text = [NSString stringWithFormat:@"%d", oldDefense];
  
  self.upgrAttackLabel.text = [NSString stringWithFormat:@"%d", newAttack];
  self.upgrDefenseLabel.text = [NSString stringWithFormat:@"%d", newDefense];
  [Globals loadImageForEquip:fi.equipId toView:self.upgrEquipIcon maskedView:nil];
  
  self.notForgingMiddleView.hidden = YES;
  self.progressView.hidden = YES;
  self.statusView.hidden = YES;
  self.notEnoughQuantityView.hidden = NO;
  
  self.frontOldStatsView.hidden = YES;
  
  self.upgrItemView.frame = upgrFrame;
  self.backOldItemView.frame = backOldFrame;
  self.frontOldItemView.frame = frontOldFrame;
  self.backOldItemView.alpha = 1.f;
  self.frontOldItemView.alpha = 1.f;
  self.upgrItemView.alpha = 1.f;
  
  self.equalPlusSign.alpha = 1.f;
  self.equalPlusSign.highlighted = NO;
  
  self.backOldLevelIcon.level = fi.level;
  self.frontOldLevelIcon.level = 0;
  self.upgrLevelIcon.level = fi.level+1;
  
  [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
  [Globals imageNamed:[Globals imageNameForEquip:fi.equipId] withImageView:self.frontOldEquipIcon maskedColor:[UIColor colorWithWhite:0.15f alpha:1.f] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.forgeButton.hidden = YES;
  self.okayButton.hidden = YES;
  self.collectButton.hidden = YES;
  self.finishNowButton.hidden = YES;
  
  // Removing forge penalty
  //  if (fep.diamondPrice > 0 || fi.level == 1) {
  if (true) {
    self.bottomLabel.text = @"Equips will be returned if forge fails.";
    self.bottomLabel.textColor = [Globals creamColor];
  } else {
    self.bottomLabel.text = @"One equip will drop a level if forge fails.";
    self.bottomLabel.textColor = [Globals goldColor];
  }
  
  if (fiv) {
    self.backMovingView.frame = [self.forgingView convertRect:fiv.equipIcon.frame fromView:fiv.equipIcon.superview];
    
    [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
    self.backOldEquipIcon.alpha = 0.5f;
    
    [Globals loadImageForEquip:fi.equipId toView:self.backMovingView maskedView:nil];
    
    self.upgrEquipIcon.alpha = 0.f;
    self.backOldAttackLabel.alpha = 0.f;
    self.backOldDefenseLabel.alpha = 0.f;
    self.upgrAttackLabel.alpha = 0.f;
    self.upgrDefenseLabel.alpha = 0.f;
    
    [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
      self.backMovingView.frame = [self.forgingView convertRect:self.backOldEquipIcon.frame fromView:self.backOldEquipIcon.superview];
      self.upgrEquipIcon.alpha = 1.f;
      self.backOldAttackLabel.alpha = 1.f;
      self.backOldDefenseLabel.alpha = 1.f;
      self.upgrAttackLabel.alpha = 1.f;
      self.upgrDefenseLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
      if (finished && self.curItem == fi) {
        [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
        self.backMovingView.hidden = YES;
        self.backOldEquipIcon.alpha = 1.f;
      }
    }];
  } else {
    [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
    self.backOldEquipIcon.alpha = 1.f;
  }
  
  FullEquipProto *fep = [gs equipWithId:fi.equipId];
  if (fi.level == 1 && fep.isBuyableInArmory) {
    self.buyOneView.hidden = NO;
    self.goToMarketplaceButton.hidden = YES;
    
    if (fep.hasCoinPrice) {
      self.buyOneCoinIcon.highlighted = NO;
      self.buyOneLabel.text = [Globals commafyNumber:fep.coinPrice];
    } else {
      self.buyOneCoinIcon.highlighted = YES;
      self.buyOneLabel.text = [Globals commafyNumber:fep.diamondPrice];
    }
  } else {
    self.buyOneView.hidden = YES;
    self.goToMarketplaceButton.hidden = NO;
  }
}

- (void) loadRightViewForForgeItem:(ForgeItem *)fi fromItemView:(ForgeItemView *)fiv {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  //  FullEquipProto *fep = [gs equipWithId:fi.equipId];
  if (self.curItem != fi) {
    self.curItem = fi;
    
    // If this is the one being currently forged, use loadRightViewForCurrentForgingItem
    if (fi.equipId == gs.forgeAttempt.equipId && fi.level == gs.forgeAttempt.level) {
      [self loadRightViewForCurrentForgingItem:fi];
      return;
    } else {
      [self.progressView stopAnimating];
      
      if (fi.quantity < 2) {
        [self loadRightViewForNotEnoughQuantity:fi fromItemView:fiv];
        return;
      }
    }
    
    int oldAttack = [gl calculateAttackForEquip:fi.equipId level:fi.level enhancePercent:0];
    int oldDefense = [gl calculateDefenseForEquip:fi.equipId level:fi.level enhancePercent:0];
    int newAttack = [gl calculateAttackForEquip:fi.equipId level:fi.level+1 enhancePercent:0];
    int newDefense = [gl calculateDefenseForEquip:fi.equipId level:fi.level+1 enhancePercent:0];
    
    self.backOldAttackLabel.text = [NSString stringWithFormat:@"%d", oldAttack];
    self.backOldDefenseLabel.text = [NSString stringWithFormat:@"%d", oldDefense];
    
    self.frontOldAttackLabel.text = [NSString stringWithFormat:@"%d", oldAttack];
    self.frontOldDefenseLabel.text = [NSString stringWithFormat:@"%d", oldDefense];
    
    self.upgrAttackLabel.text = [NSString stringWithFormat:@"%d", newAttack];
    self.upgrDefenseLabel.text = [NSString stringWithFormat:@"%d", newDefense];
    [Globals loadImageForEquip:fi.equipId toView:self.upgrEquipIcon maskedView:nil];
    
    self.frontOldStatsView.hidden = NO;
    
    self.backOldLevelIcon.level = fi.level;
    self.frontOldLevelIcon.level = fi.level;
    self.upgrLevelIcon.level = fi.level+1;
    
    self.chanceOfSuccessLabel.text = [NSString stringWithFormat:@"%d%%", (int)roundf([gl calculateChanceOfSuccess:fi.equipId level:fi.level]*100)];
    self.forgeTimeLabel.text = [NSString stringWithFormat:@"%d minutes", [gl calculateMinutesForForge:fi.equipId level:fi.level]];
    
    self.notForgingMiddleView.hidden = NO;
    self.progressView.hidden = YES;
    self.statusView.hidden = YES;
    self.notEnoughQuantityView.hidden = YES;
    
    // Move these back to their original positions
    self.backOldItemView.frame = backOldFrame;
    self.frontOldItemView.frame = frontOldFrame;
    self.upgrItemView.frame = upgrFrame;
    self.backOldItemView.alpha = 1.f;
    self.frontOldItemView.alpha = 1.f;
    self.upgrItemView.alpha = 1.f;
    
    self.forgeButton.hidden = NO;
    self.finishNowButton.hidden = YES;
    self.collectButton.hidden = YES;
    self.okayButton.hidden = YES;
    self.goToMarketplaceButton.hidden = YES;
    self.buyOneView.hidden = YES;
    
    self.equalPlusSign.alpha = 1.f;
    self.equalPlusSign.highlighted = NO;
    
    self.twinkleIcon.hidden = YES;
    
    // Removing forge penalty
    if (true) {
      self.bottomLabel.text = @"Note: Enhancements will be lost if the forge succeeds.";
      self.bottomLabel.textColor = [Globals creamColor];
    } else {
      self.bottomLabel.text = @"One equip will drop a level if forge fails.";
      self.bottomLabel.textColor = [Globals goldColor];
    }
    
    // If fiv is not nil, then animate it
    if (fiv) {
      self.backMovingView.frame = [self.forgingView convertRect:fiv.equipIcon.frame fromView:fiv.equipIcon.superview];
      self.frontMovingView.frame = [self.forgingView convertRect:fiv.equipIcon.frame fromView:fiv.equipIcon.superview];
      
      [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
      [Globals loadImageForEquip:fi.equipId toView:self.frontOldEquipIcon maskedView:nil];
      self.backOldEquipIcon.alpha = 0.5f;
      self.frontOldEquipIcon.alpha = 0.5f;
      
      [Globals loadImageForEquip:fi.equipId toView:self.backMovingView maskedView:nil];
      [Globals loadImageForEquip:fi.equipId toView:self.frontMovingView maskedView:nil];
      
      self.upgrEquipIcon.alpha = 0.f;
      self.backOldAttackLabel.alpha = 0.f;
      self.backOldDefenseLabel.alpha = 0.f;
      self.frontOldAttackLabel.alpha = 0.f;
      self.frontOldDefenseLabel.alpha = 0.f;
      self.upgrAttackLabel.alpha = 0.f;
      self.upgrDefenseLabel.alpha = 0.f;
      
      [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
        self.backMovingView.frame = [self.forgingView convertRect:self.backOldEquipIcon.frame fromView:self.backOldEquipIcon.superview];
        self.frontMovingView.frame = [self.forgingView convertRect:self.frontOldEquipIcon.frame fromView:self.frontOldEquipIcon.superview];
        self.upgrEquipIcon.alpha = 1.f;
        self.backOldAttackLabel.alpha = 1.f;
        self.backOldDefenseLabel.alpha = 1.f;
        self.frontOldAttackLabel.alpha = 1.f;
        self.frontOldDefenseLabel.alpha = 1.f;
        self.upgrAttackLabel.alpha = 1.f;
        self.upgrDefenseLabel.alpha = 1.f;
      } completion:^(BOOL finished) {
        if (finished && self.curItem == fi) {
          [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
          [Globals loadImageForEquip:fi.equipId toView:self.frontOldEquipIcon maskedView:nil];
          self.backMovingView.hidden = YES;
          self.frontMovingView.hidden = YES;
          self.backOldEquipIcon.alpha = 1.f;
          self.frontOldEquipIcon.alpha = 1.f;
        }
      }];
    } else {
      [Globals loadImageForEquip:fi.equipId toView:self.backOldEquipIcon maskedView:nil];
      [Globals loadImageForEquip:fi.equipId toView:self.frontOldEquipIcon maskedView:nil];
      self.backOldEquipIcon.alpha = 1.f;
      self.frontOldEquipIcon.alpha = 1.f;
    }
  }
}

- (void) beginForgingSelectedItem {
  [UIView animateWithDuration:0.4f animations:^{
    [self loadRightViewForCurrentForgingItem:self.curItem];
  }];
  // Do this outside again because it gets overwritten by the outside animation loop
  [self.progressView beginAnimating];
}

- (IBAction)forgeButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.forgeAttempt) {
    if (gs.forgeAttempt.isComplete) {
      NSString *desc = @"You have a completed forge waiting to be collected. Go there now?";
      [GenericPopupController displayConfirmationWithDescription:desc
                                                           title:nil
                                                      okayButton:@"Yes"
                                                    cancelButton:@"No"
                                                          target:self
                                                        selector:@selector(loadForgeAttempt)];
    } else {
      int gold = [gl calculateGoldCostToSpeedUpForging:gs.forgeAttempt.equipId level:gs.forgeAttempt.level];
      NSString *desc = [NSString stringWithFormat:@"You are already forging an item. Speed it up for %d gold?", gold];
      [GenericPopupController displayConfirmationWithDescription:desc
                                                           title:nil
                                                      okayButton:@"Yes"
                                                    cancelButton:@"No"
                                                          target:self
                                                        selector:@selector(finishNow)];
    }
  } else if ([gs quantityOfEquip:self.curItem.equipId level:self.curItem.level] >= 2) {
    if (self.curItem.level >= gl.forgeMaxEquipLevel) {
      [Globals popupMessage:[NSString stringWithFormat:@"The forge is unable to create weapons above level %d.", gl.forgeMaxEquipLevel]];
    } else {
      
      int gold = [gl calculateGoldCostToGuaranteeForgingSuccess:self.curItem.equipId level:self.curItem.level];
      NSString *desc = [NSString stringWithFormat:@"Would you like to guarantee success for %d gold?", gold];
      [GenericPopupController displayConfirmationWithDescription:desc
                                                           title:nil
                                                      okayButton:@"Yes"
                                                    cancelButton:@"No"
                                                        okTarget:self
                                                      okSelector:@selector(submitWithGuarantee)
                                                    cancelTarget:self
                                                  cancelSelector:@selector(submitWithoutGuarantee)];
    }
    
  }
}

- (void) submitEquips:(BOOL)guaranteed {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSMutableArray *equips = [[[gs myEquipsWithId:self.curItem.equipId level:self.curItem.level] mutableCopy] autorelease];
  
  if (equips.count >= 2) {
    // Prioritize lower percentage ones
    [equips sortUsingComparator:^NSComparisonResult(UserEquip *obj1, UserEquip *obj2) {
      if (obj1.enhancementPercentage < obj2.enhancementPercentage) {
        return NSOrderedAscending;
      } else if (obj1.enhancementPercentage > obj2.enhancementPercentage) {
        return NSOrderedDescending;
      }
      return NSOrderedSame;
    }];
    
    UserEquip *ue1 = [equips objectAtIndex:0];
    UserEquip *ue2 = [equips objectAtIndex:1];
    FullEquipProto *fep = [gs equipWithId:ue1.equipId];
    
    if (equips.count > 2) {
      int equipped = 0;
      if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
        equipped = gs.weaponEquipped;
      } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
        equipped = gs.armorEquipped;
      } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
        equipped = gs.amuletEquipped;
      }
      
      if (ue1.userEquipId == equipped) {
        ue1 = [equips objectAtIndex:2];
      } else if (ue2.userEquipId == equipped) {
        ue2 = [equips objectAtIndex:2];
      }
    }
    
    if (guaranteed) {
      int gold = [gl calculateGoldCostToGuaranteeForgingSuccess:self.curItem.equipId level:self.curItem.level];
      if (gs.gold < gold) {
        [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gold];
        
        [Analytics blacksmithFailedToGuaranteeForgeWithEquipId:curItem.equipId level:curItem.level cost:gold];
        return;
      }
      
      [Analytics blacksmithGuaranteedForgeWithEquipId:curItem.equipId level:curItem.level];
    } else {
      [Analytics blacksmithNotGuaranteedForgeWithEquipId:curItem.equipId level:curItem.level];
    }
    
    BOOL succeeded = [[OutgoingEventController sharedOutgoingEventController] submitEquipsToBlacksmithWithUserEquipId:ue1.userEquipId userEquipId:ue2.userEquipId guaranteed:guaranteed];
    
    [self.coinBar updateLabels];
    
    if (succeeded) {
      [self.loadingView display:self.view];
      
      [[SoundEngine sharedSoundEngine] forgeSubmit];
    }
  }
}

- (void) submitWithGuarantee {
  [self submitEquips:YES];
}

- (void) submitWithoutGuarantee {
  [self submitEquips:NO];
}

- (IBAction)finishNowClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.forgeAttempt.isComplete) {
    return;
  }
  
  int gold = [gl calculateGoldCostToSpeedUpForging:gs.forgeAttempt.equipId level:gs.forgeAttempt.level];
  NSString *desc = [NSString stringWithFormat:@"Would you like to speed up forging for %d gold?", gold];
  [GenericPopupController displayConfirmationWithDescription:desc
                                                       title:nil
                                                  okayButton:@"Yes"
                                                cancelButton:@"No"
                                                      target:self
                                                    selector:@selector(finishNow)];
}

- (IBAction)infoClicked:(id)sender {
  [GenericPopupController displayNotificationViewWithText:@"You need 2 items of the same level to attempt a forge." title:@"Forging Information"];
}

- (void) finishNow {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int gold = [gl calculateGoldCostToSpeedUpForging:gs.forgeAttempt.equipId level:gs.forgeAttempt.level];
  ForgeAttempt *fa = gs.forgeAttempt;
  
  if (fa.isComplete) {
    return;
  }
  
  if (gs.gold < gold) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gold];
    
    [Analytics blacksmithFailedToSpeedUpWithEquipId:fa.equipId level:fa.level cost:gold];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] finishForgeAttemptWaittimeWithDiamonds];
    
    [self.coinBar updateLabels];
    
    int index = 0;
    ForgeItem *fi = nil;
    
    for (; index < self.forgeItems.count; index++) {
      ForgeItem *f = [self.forgeItems objectAtIndex:index];
      if (f.equipId == gs.forgeAttempt.equipId && f.level == gs.forgeAttempt.level) {
        fi = f;
        break;
      }
    }
    
    if (fi) {
      [self selectRow:index animated:YES];
      [self.progressView stopAnimating];
      
      int minutes = [gl calculateMinutesForForge:fa.equipId level:fa.level];
      float timePassed = -[fa.startTime timeIntervalSinceNow];
      self.progressView.progressBar.percentage = timePassed/minutes/60.f;
      float percLeft = 1.f-self.progressView.progressBar.percentage;
      [UIView animateWithDuration:percLeft*1.f animations:^{
        self.progressView.progressBar.percentage = 1.f;
      } completion:^(BOOL finished) {
        [self loadRightViewForCurrentForgingItem:fi];
      }];
    }
    
    [Analytics blacksmithSpeedUpWithEquipId:fa.equipId level:fa.level];
  }
}

- (void) loadForgeAttempt {
  GameState *gs = [GameState sharedGameState];
  int index = 0;
  ForgeItem *fi = nil;
  
  for (; index < self.forgeItems.count; index++) {
    ForgeItem *f = [self.forgeItems objectAtIndex:index];
    if (f.equipId == gs.forgeAttempt.equipId && f.level == gs.forgeAttempt.level) {
      fi = f;
      break;
    }
  }
  
  if (fi) {
    [self selectRow:index animated:YES];
    
    [self loadRightViewForCurrentForgingItem:fi];
  }
}

- (IBAction) checkResultsClicked:(id)sender {
  if (!_collectingEquips) {
    GameState *gs = [GameState sharedGameState];
    ForgeAttempt *fa = gs.forgeAttempt;
    
    if (fa.isComplete) {
      [[OutgoingEventController sharedOutgoingEventController] collectForgeEquips];
      
      [self doLoadingForChecking];
      
      [[SoundEngine sharedSoundEngine] forgeCollect];
      
      [Analytics blacksmithCollectedItemsWithEquipId:self.curItem.equipId level:self.curItem.level];
    }
  }
}

- (IBAction)goToMarketplaceClicked:(id)sender {
  [self closeClicked:nil];
  [[MarketplaceViewController sharedMarketplaceViewController] searchForEquipId:self.curItem.equipId level:self.curItem.level];
  
  [Analytics blacksmithGoToMarketplaceWithEquipId:self.curItem.equipId level:self.curItem.level];
}

- (IBAction)buyOneClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:self.curItem.equipId];
  
  if (fep.coinPrice) {
    if (fep.coinPrice > gs.silver) {
      [[RefillMenuController sharedRefillMenuController] displayBuySilverView:fep.coinPrice];
      return;
    }
  } else {
    if (fep.diamondPrice > gs.gold) {
      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:fep.diamondPrice];
      return;
    }
  }
  
  [[OutgoingEventController sharedOutgoingEventController] buyEquip:self.curItem.equipId];
  [self.loadingView display:self.view];
  
  [Analytics blacksmithBuyOneWithEquipId:self.curItem.equipId level:self.curItem.level];
}

- (void) doLoadingForChecking {
  _collectingEquips = YES;
  _shouldShake = YES;
  
  [self.statusView displayCheckingForge];
  
  [self shakeViews:[NSNumber numberWithFloat:1.5f]];
}

- (void) forgeFailed:(NSArray *)equips {
  [self.statusView displayForgeFailed];
  [[SoundEngine sharedSoundEngine] forgeFailure];
  
  Globals *gl = [Globals sharedGlobals];
  FullUserEquipProto *fuep1 = [equips objectAtIndex:0];
  FullUserEquipProto *fuep2 = [equips objectAtIndex:1];
  int attack1 = [gl calculateAttackForEquip:fuep1.equipId level:fuep1.level enhancePercent:0];
  int defense1 = [gl calculateDefenseForEquip:fuep1.equipId level:fuep1.level enhancePercent:0];
  int attack2 = [gl calculateAttackForEquip:fuep2.equipId level:fuep2.level enhancePercent:0];
  int defense2 = [gl calculateDefenseForEquip:fuep2.equipId level:fuep2.level enhancePercent:0];
  
  self.backOldAttackLabel.text = [NSString stringWithFormat:@"%d", attack1];
  self.backOldDefenseLabel.text = [NSString stringWithFormat:@"%d", defense1];
  
  self.frontOldAttackLabel.text = [NSString stringWithFormat:@"%d", attack2];
  self.frontOldDefenseLabel.text = [NSString stringWithFormat:@"%d", defense2];
  
  self.backOldLevelIcon.level = fuep1.level;
  
  if (self.frontOldLevelIcon.level > fuep2.level) {
    [self doLevelImplode:fuep2.level];
  } else {
    self.frontOldLevelIcon.level = fuep2.level;
  }
  
  [UIView animateWithDuration:0.5f animations:^{
    self.equalPlusSign.alpha = 0.f;
  } completion:^(BOOL finished) {
    _collectingEquips = NO;
  }];
}

- (void) forgeSucceeded:(int)level {
  UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:view];
  view.backgroundColor = [UIColor whiteColor];
  view.alpha = 0.f;
  
  self.upgrLevelIcon.level = level-1;
  
  [[SoundEngine sharedSoundEngine] forgeSuccess];
  
  [UIView animateWithDuration:0.6f animations:^{
    view.alpha = 1.f;
  } completion:^(BOOL finished) {
    [self.statusView displayForgeSuccess];
    
    self.upgrItemView.center = CGPointMake(self.equalPlusSign.center.x, self.upgrItemView.center.y);
    
    self.upgrItemView.alpha = 1.f;
    self.backOldItemView.alpha = 0.f;
    self.frontOldItemView.alpha = 0.f;
    self.equalPlusSign.alpha = 0.f;
    
    [UIView animateWithDuration:0.2f animations:^{
      view.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self doLevelPop:level];
      
      [view removeFromSuperview];
      [view release];
    }];
  }];
}

- (void) doLevelPop:(int)level {
  EquipLevelIcon *newLvlIcon = [[EquipLevelIcon alloc] initWithFrame:self.upgrLevelIcon.frame];
  [self.upgrLevelIcon.superview addSubview:newLvlIcon];
  newLvlIcon.level = level;
  newLvlIcon.alpha = 0.f;
  
  float scale = 3.f;
  newLvlIcon.transform = CGAffineTransformMakeScale(scale, scale);
  [UIView animateWithDuration:0.7f animations:^{
    newLvlIcon.alpha = 1.f;
    newLvlIcon.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    self.upgrLevelIcon.level = level;
    [newLvlIcon removeFromSuperview];
    [newLvlIcon release];
    
    _collectingEquips = NO;
    
    [self performSelector:@selector(askToConfirmWearForgedEquip) withObject:nil afterDelay:0.3f];
  }];
}

- (void) doLevelImplode:(int)level {
  self.frontOldLevelIcon.level = level+1;
  [UIView animateWithDuration:0.7f animations:^{
    frontOldLevelIcon.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    frontOldLevelIcon.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.frontOldLevelIcon.level = level;
    self.frontOldLevelIcon.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.3f animations:^{
      self.frontOldLevelIcon.alpha = 1.f;
    }];
  }];
}

- (void) askToConfirmWearForgedEquip {
  if (_forgedUserEquipId != 0) {
    [[Globals sharedGlobals] confirmWearEquip:_forgedUserEquipId];
    _forgedUserEquipId = 0;
  }
}

- (void) shakeViews:(NSNumber *) duration {
  if (_shouldShake) {
    float dur = duration.floatValue;
    [Globals shakeView:self.backOldItemView duration:dur offset:6.f];
    [Globals shakeView:self.frontOldItemView duration:dur offset:6.f];
    
    [self performSelector:@selector(shakeViews:) withObject:[NSNumber numberWithFloat:1.f] afterDelay:dur];
  }
}

- (IBAction)okayClicked:(id)sender {
  // Undo curItem so we can get past check in loadRightView..
  if (!_collectingEquips) {
    [self reloadCurrentItem];
  }
}

- (IBAction) closeClicked:(id)sender {
  if (self.view.superview && !_collectingEquips) {
    [UIView animateWithDuration:0.4f delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
      self.topBar.center = CGPointMake(self.topBar.center.x, -self.topBar.frame.size.height/2);
      self.mainView.center = CGPointMake(self.mainView.center.x, CGRectGetMaxY(self.view.frame)+self.mainView.frame.size.height/2);
      self.bgdView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self.view removeFromSuperview];
    }];
  }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return forgeItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"ForgeItemView";
  
  ForgeItemView *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    Globals *gl = [Globals sharedGlobals];
    [[Globals bundleNamed:gl.downloadableNibConstants.blacksmithNibName] loadNibNamed:@"ForgeItemView" owner:self options:nil];
    cell = self.itemView;
  }
  
  [cell loadForForgeItem:[self.forgeItems objectAtIndex:indexPath.row]];
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  ForgeItem *fi = [self.forgeItems objectAtIndex:indexPath.row];
  ForgeItemView *fiv = (ForgeItemView *)[tableView cellForRowAtIndexPath:indexPath];
  
  BOOL shouldSelect = YES;
  if (_shouldShake) {
    shouldSelect = NO;
  } else {
    [self loadRightViewForForgeItem:fi fromItemView:fiv];
  }
  
  if (!shouldSelect) {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    int index = [self.forgeItems indexOfObject:self.curItem];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
  }
}

- (void) receivedSubmitEquipResponse:(SubmitEquipsToBlacksmithResponseProto *)proto {
  if (proto.status == SubmitEquipsToBlacksmithResponseProto_SubmitEquipsToBlacksmithStatusSuccess) {
    [self beginForgingSelectedItem];
  }
  [self.loadingView stop];
  [self.forgeTableView reloadData];
  [self.enhancingView.enhanceTableView reloadData];
  [self selectRow:[self.forgeItems indexOfObject:self.curItem] animated:NO];
}

- (void) receivedCollectForgeEquipsResponse:(CollectForgeEquipsResponseProto *)proto {
  if (proto.status == CollectForgeEquipsResponseProto_CollectForgeEquipsStatusSuccess) {
    if (proto.userEquipsList.count == 2) {
      [self forgeFailed:proto.userEquipsList];
    } else if (proto.userEquipsList.count == 1) {
      FullUserEquipProto *fuep = [proto.userEquipsList objectAtIndex:0];
      [self forgeSucceeded:fuep.level];
      _forgedUserEquipId = fuep.userEquipId;
    }
    
    self.okayButton.hidden = NO;
    self.collectButton.hidden = YES;
    
    [self loadForgeItems];
  } else {
    [self loadForgeAttempt];
    _collectingEquips = NO;
  }
  _shouldShake = NO;
}

- (void) receivedArmoryResponse:(BOOL)success {
  if (self.view.superview) {
    [self.loadingView stop];
    
    if (success) {
      GameState *gs = [GameState sharedGameState];
      FullEquipProto *fep = [gs equipWithId:self.curItem.equipId];
      
      int price = fep.diamondPrice > 0 ? fep.diamondPrice : fep.coinPrice;
      CGPoint startLoc = ccp(forgeButton.center.x, CGRectGetMinY(forgeButton.frame));
      
      UIView *testView = [EquipDeltaView
                          createForUpperString:[NSString stringWithFormat:@"- %d %@",
                                                price, fep.diamondPrice ? @"Gold" : @"Silver"]
                          andLowerString:[NSString stringWithFormat:@"+1 %@", fep.name]
                          andCenter:startLoc
                          topColor:[Globals redColor]
                          botColor:[Globals colorForRarity:fep.rarity]];
      
      [Globals popupView:testView
             onSuperView:self.forgingView
                 atPoint:startLoc
     withCompletionBlock:nil];
      
      [coinBar updateLabels];
      
      // Set collecting equips to on so that we can reload same item
      _collectingEquips = YES;
      [self loadForgeItems];
      _collectingEquips = NO;
      
      [self reloadCurrentItem];
    }
  }
}

@end
