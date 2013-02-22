//
//  ArmoryViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ArmoryViewController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "SoundEngine.h"
#import "EquipDeltaView.h"
#import "GenericPopupController.h"

#define HAS_VISITED_ARMORY_KEY @"Has visited armory key"

@implementation ArmoryTopBar

@synthesize button1, button2;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
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
      
      [[ArmoryViewController sharedArmoryViewController] displayBuyChests];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton1];
      
      [[ArmoryViewController sharedArmoryViewController] displayInfo];
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

@implementation ArmoryRow

- (void) updateForBoosterPack:(BoosterPackProto *)bpp {
  GameState *gs = [GameState sharedGameState];
  
  [self.bgdView setImage:[Globals imageNamed:bpp.backgroundImage] forState:UIControlStateNormal];
  [Globals imageNamed:bpp.chestImage withImageView:self.chestIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  [Globals imageNamed:bpp.middleImage withImageView:self.middleImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.levelsLabel.text = [NSString stringWithFormat:@"%d-%d", bpp.minLevel, bpp.maxLevel];
  
  int total = 0, collected = 0;
  UserBoosterPackProto *userPack = [gs myBoosterPackForId:bpp.boosterPackId];
  for (BoosterItemProto *item in bpp.boosterItemsList) {
    UserBoosterItemProto *userItem = nil;
    for (UserBoosterItemProto *ui in userPack.userBoosterItemsList) {
      if (ui.boosterItemId == item.boosterItemId) {
        userItem = ui;
        break;
      }
    }
    
    total += item.quantity;
    collected += userItem.numReceived;
  }
  self.equipsLeftLabel.text = [NSString stringWithFormat:@"%d / %d", total-collected, total];
  
  self.boosterPack = bpp;
}

- (void) dealloc {
  self.bgdView = nil;
  self.chestIcon = nil;
  self.middleImageView = nil;
  self.levelsLabel = nil;
  self.equipsLeftLabel = nil;
  self.boosterPack = nil;
  [super dealloc];
}

@end

@implementation ArmoryViewController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ArmoryViewController);

@synthesize armoryTableView, armoryRow;
@synthesize equipClicked;
@synthesize coinBar;
@synthesize spinner;
@synthesize loadingView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Add rope to the very top
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  UIView *leftRope = [[UIView alloc] initWithFrame:CGRectMake(15, -150, 3, 150)];
  UIView *rightRope = [[UIView alloc] initWithFrame:CGRectMake(463, -150, 3, 150)];
  leftRope.backgroundColor = c;
  rightRope.backgroundColor = c;
  [self.armoryTableView addSubview:leftRope];
  [self.armoryTableView addSubview:rightRope];
  [leftRope release];
  [rightRope release];
  
  self.carouselView.frame = self.armoryTableView.frame;
  [self.armoryTableView.superview addSubview:self.carouselView];
  
  [Globals imageNamed:BOOSTERS_INSTRUCTIONS_IMAGE withImageView:self.infoImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (self.infoImageView.image) {
    CGRect r = self.infoImageView.frame;
    r.size.height = self.infoImageView.image.size.height;
    self.infoImageView.frame = r;
  }
  self.infoScrollView.contentSize = CGSizeMake(self.infoScrollView.frame.size.width, CGRectGetMaxY(self.infoImageView.frame)+self.infoImageView.frame.origin.y);
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    
    self.armoryTableView = nil;
    self.armoryRow = nil;
    self.coinBar = nil;
    self.boosterPacks = nil;
    self.carouselView = nil;
    self.spinner = nil;
    self.loadingView = nil;
    self.cardDisplayView = nil;
    self.infoImageView = nil;
    self.infoScrollView = nil;
    self.topBar = nil;
  }
}

- (void) displayBuyChests {
  self.infoScrollView.hidden = YES;
  self.armoryTableView.hidden = NO;
  self.carouselView.hidden = YES;
  self.coinBar.hidden = YES;
  self.topBar.hidden = NO;
  self.topBar.alpha = 1.f;
  
  [self.topBar unclickButton:kButton2];
  [self.topBar clickButton:kButton1];
  
  [self refresh];
}

- (void) displayInfo {
  self.infoScrollView.hidden = NO;
  self.armoryTableView.hidden = YES;
  self.carouselView.hidden = YES;
  self.coinBar.hidden = YES;
  self.topBar.hidden = NO;
  self.topBar.alpha = 1.f;
  
  [self.topBar unclickButton:kButton1];
  [self.topBar clickButton:kButton2];
  
  self.infoScrollView.contentOffset = ccp(0,0);
}

- (void) viewWillAppear:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  if (gs.boosterPacks.count <= 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveBoosterPacks];
  }
  
  [self refresh];
  [self.loadingView stop];
  [coinBar updateLabels];
  
  self.carouselView.hidden = YES;
  self.armoryTableView.hidden = NO;
  self.backView.alpha = 0.f;
  
  CGRect f = self.view.frame;
  self.view.center = CGPointMake(self.view.center.x, f.size.height*3/2);
  [UIView animateWithDuration:FULL_SCREEN_APPEAR_ANIMATION_DURATION animations:^{
    self.view.center = CGPointMake(self.view.center.x, f.size.height/2);
  }];
  
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  BOOL hasVisited = [def boolForKey:HAS_VISITED_ARMORY_KEY];
  if (!hasVisited) {
    [self displayInfo];
    
    [def setBool:YES forKey:HAS_VISITED_ARMORY_KEY];
  } else {
    [self displayBuyChests];
  }
  
  [[SoundEngine sharedSoundEngine] armoryEnter];
}

- (void) loadForLevel:(int)level rarity:(FullEquipProto_Rarity)rarity {
  _level = level;
  _shouldCostCoins = (rarity < FullEquipProto_RarityRare);
  [self refresh];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int num = self.boosterPacks.count;
  
  if (num > 0) {
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
  } else {
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
  }
  
  return num;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"ArmoryRow";
  
  ArmoryRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"ArmoryRow" owner:self options:nil];
    cell = self.armoryRow;
  }
  
  BoosterPackProto *bpp = [self.boosterPacks objectAtIndex:indexPath.row];
  [cell updateForBoosterPack:bpp];
  
  return cell;
}

- (void) refresh {
  // Order boosters
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *bp = [NSMutableArray arrayWithArray:gs.boosterPacks];
  [bp sortUsingComparator:^NSComparisonResult(BoosterPackProto *obj1, BoosterPackProto *obj2) {
    BOOL inRange1 = gs.level > obj1.minLevel;
    BOOL inRange2 = gs.level > obj2.minLevel;
    if (!inRange1 && !inRange2) {
      if (obj1.minLevel < obj2.minLevel) {
        return NSOrderedAscending;
      } else if (obj1.minLevel > obj2.minLevel) {
        return NSOrderedDescending;
      } else {
        if (obj1.costsCoins) {
          return NSOrderedDescending;
        } else if (obj2.costsCoins) {
          return NSOrderedAscending;
        }
        return NSOrderedSame;
      }
      return NSOrderedSame;
    } else if (inRange1 && inRange2) {
      if (obj1.minLevel < obj2.minLevel) {
        return NSOrderedDescending;
      } else if (obj1.minLevel > obj2.minLevel) {
        return NSOrderedAscending;
      } else {
        if (obj1.costsCoins) {
          return NSOrderedDescending;
        } else if (obj2.costsCoins) {
          return NSOrderedAscending;
        }
        return NSOrderedSame;
      }
    } else if (inRange1) {
      return NSOrderedAscending;
    } else {
      return NSOrderedDescending;
    }
  }];
  self.boosterPacks = bp;
  
  [self.armoryTableView reloadData];
  [self.armoryTableView setContentOffset:ccp(0,-self.armoryTableView.contentInset.top)];
  
  if (_level) {
    for (int i = 0; i < self.boosterPacks.count; i++) {
      BoosterPackProto *bp = [self.boosterPacks objectAtIndex:i];
      if (bp.minLevel <= _level && bp.maxLevel >= _level && (bp.costsCoins == _shouldCostCoins)) {
        [self armoryRowClicked:[self.armoryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
        _level = 0;
      }
    }
  }
}

- (IBAction)armoryRowClicked:(UIView *)sender {
  ArmoryRow *row = nil;
  while (![sender isKindOfClass:[ArmoryRow class]]) {
    sender = sender.superview;
  }
  row = (ArmoryRow *)sender;
  
  GameState *gs = [GameState sharedGameState];
  UserBoosterPackProto *userPack = [gs myBoosterPackForId:row.boosterPack.boosterPackId];
  [self.carouselView updateForBoosterPack:row.boosterPack userPack:userPack];
  
  CGRect curRect = self.armoryTableView.frame;
  CGRect r = self.carouselView.frame;
  r.origin.x = self.view.frame.size.width;
  self.carouselView.frame = r;
  self.carouselView.hidden = NO;
  self.coinBar.alpha = 0.f;
  self.coinBar.hidden = NO;
  [UIView animateWithDuration:0.3f animations:^{
    CGRect r = self.armoryTableView.frame ;
    r.origin.x = -r.size.width;
    self.armoryTableView.frame = r;
    
    self.topBar.alpha = 0.f;
    self.coinBar.alpha = 1.f;
    
    self.carouselView.frame = curRect;
    self.backView.alpha = 1.f;
  } completion:^(BOOL finished) {
    self.armoryTableView.frame = curRect;
    self.armoryTableView.hidden = YES;
    
    self.topBar.hidden = YES;
  }];
}

- (IBAction)backClicked:(id)sender {
  if (!self.armoryTableView.hidden) {
    return;
  }
  
  CGRect curRect = self.armoryTableView.frame;
  CGRect r = self.armoryTableView.frame;
  r.origin.x = -r.size.width;
  self.armoryTableView.frame = r;
  self.armoryTableView.hidden = NO;
  self.topBar.alpha = 0.f;
  self.topBar.hidden = NO;
  [UIView animateWithDuration:0.3f animations:^{
    CGRect r = self.carouselView.frame ;
    r.origin.x = self.view.frame.size.width;
    self.carouselView.frame = r;
    
    self.topBar.alpha = 1.f;
    self.coinBar.alpha = 0.f;
    
    self.backView.alpha = 0.f;
    
    self.armoryTableView.frame = curRect;
  } completion:^(BOOL finished) {
    self.carouselView.frame = curRect;
    self.carouselView.hidden = YES;
    self.coinBar.hidden = YES;
  }];
}

- (IBAction)purchaseClicked:(UIView *)sender {
  PurchaseOption option = 0;
  if (sender.tag == 1) {
    option = PurchaseOptionOne;
  } else if (sender.tag == 2) {
    option = PurchaseOptionTwo;
  }
  
  GameState *gs = [GameState sharedGameState];
  BoosterPackProto *bpp = self.carouselView.booster;
  int price = 0;
  BOOL canAfford = YES;
  if (option == PurchaseOptionOne) {
    price = bpp.salePriceOne > 0 ? bpp.salePriceOne : bpp.retailPriceOne;
  } else if (option == PurchaseOptionTwo) {
    price = bpp.salePriceTwo > 0 ? bpp.salePriceTwo : bpp.retailPriceTwo;
  }
  
  if (bpp.costsCoins) {
    if (price > gs.silver) {
      [[RefillMenuController sharedRefillMenuController] displayBuySilverView:price];
      canAfford = NO;
    }
  } else {
    if (price > gs.gold) {
      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:price];
      canAfford = NO;
    }
  }
  
  if (canAfford) {
    [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.carouselView.booster.boosterPackId purchaseOption:option];
    [self.coinBar updateLabels];
    [self.loadingView display:self.view];
  }
}

- (IBAction)resetClicked:(id)sender {
  [GenericPopupController displayConfirmationWithDescription:@"Resetting a chest removes history of equips collected and restarts it. Reset?" title:@"Reset Chest?" okayButton:@"Reset" cancelButton:@"Cancel" target:self selector:@selector(reset)];
}

- (void) reset {
  GameState *gs = [GameState sharedGameState];
  UserBoosterPackProto *bp = [gs myBoosterPackForId:self.carouselView.booster.boosterPackId];
  
  BOOL valid = NO;
  for (UserBoosterItemProto *i in bp.userBoosterItemsList) {
    if (i.numReceived > 0) {
      valid = YES;
    }
  }
  
  if (valid) {
    [[OutgoingEventController sharedOutgoingEventController] resetBoosterPack:bp.boosterPackId];
    [self.loadingView display:self.view];
  } else {
    [Globals popupMessage:@"This chest is already full! Try purchasing equips before resetting."];
  }
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  if (self.view.superview) {
    CGRect f = self.view.frame;
    [UIView animateWithDuration:FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION animations:^{
      self.view.center = CGPointMake(self.view.center.x, f.size.height*3/2);
    } completion:^(BOOL finished) {
      [ArmoryViewController removeView];
    }];
    
    [[SoundEngine sharedSoundEngine] armoryLeave];
  }
}

- (void) receivedPurchaseBoosterPackResponse:(PurchaseBoosterPackResponseProto *)proto {
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    self.cardDisplayView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:_cardDisplayView];
    
    [self.cardDisplayView beginAnimatingForEquips:proto.userEquipsList];
    
    if (self.carouselView.booster.boosterPackId == proto.userBoosterPack.boosterPackId) {
      [self.carouselView updateForBoosterPack:self.carouselView.booster userPack:proto.userBoosterPack];
    }
    [self.armoryTableView reloadData];
  }
  
  [self.coinBar updateLabels];
  
  [self.loadingView stop];
}

- (void) resetBoosterPackResponse:(ResetBoosterPackResponseProto *)proto {
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    if (self.carouselView.booster.boosterPackId == proto.userBoosterPack.boosterPackId) {
      [self.carouselView updateForBoosterPack:self.carouselView.booster userPack:proto.userBoosterPack];
    }
    [self.armoryTableView reloadData];
  }
  
  [self.coinBar updateLabels];
  
  [self.loadingView stop];
}

@end
