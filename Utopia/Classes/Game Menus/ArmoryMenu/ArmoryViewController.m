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
#import "GoldShoppeViewController.h"

#define HAS_VISITED_ARMORY_KEY @"Has visited armory key 2"

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
  
  [Globals imageNamed:bpp.backgroundImage withView:self.bgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:bpp.chestImage withView:self.chestIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:bpp.middleImage withView:self.middleImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
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
  
  if (bpp.isStarterPack) {
    self.timeLeftLabel.hidden = NO;
    self.labelsView.hidden = YES;
    
    [self updateLabels];
    self.timer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  } else {
    self.timeLeftLabel.hidden = YES;
    self.labelsView.hidden = NO;
  }
  
  self.boosterPack = bpp;
}

- (void) setTimer:(NSTimer *)t {
  if (_timer != t) {
    [_timer invalidate];
    [_timer release];
    _timer = [t retain];
  }
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int numDays = gl.numDaysToBuyStarterPack;
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:gs.createTime.timeIntervalSince1970+numDays*24*60*60];
  NSTimeInterval timeInterval = [endDate timeIntervalSinceNow];
  NSString *time = @"Time up!";
  
  if (timeInterval >= 0) {
    int days = (int)(timeInterval/86400);
    int hrs = (int)((timeInterval-86400*days)/3600);
    int mins = (int)((timeInterval-86400*days-3600*hrs)/60);
    float secs = timeInterval-86400*days-3600*hrs-60*mins;
    NSString *daysString = days ? [NSString stringWithFormat:@"%dd ", days] : @"";
    NSString *hrsString = days || hrs ? [NSString stringWithFormat:@"%dh ", hrs] : @"";
    NSString *minsString = days || hrs || mins ? [NSString stringWithFormat:@"%dm ", mins] : @"";
    NSString *secsString = [NSString stringWithFormat:@"%.02fs", secs];
    time = [NSString stringWithFormat:@"%@%@%@%@", daysString, hrsString, minsString, secsString];
  }
  self.timeLeftLabel.text = time;
}

- (void) dealloc {
  self.bgdView = nil;
  self.chestIcon = nil;
  self.middleImageView = nil;
  self.levelsLabel = nil;
  self.equipsLeftLabel = nil;
  self.boosterPack = nil;
  self.timeLeftLabel = nil;
  self.labelsView = nil;
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
  
  Globals *gl = [Globals sharedGlobals];
  [Globals imageNamed:gl.infoImageName withView:self.infoImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (self.infoImageView.image) {
    CGRect r = self.infoImageView.frame;
    r.size.height = self.infoImageView.image.size.height;
    self.infoImageView.frame = r;
  }
  self.infoScrollView.contentSize = CGSizeMake(self.infoScrollView.frame.size.width, CGRectGetMaxY(self.infoImageView.frame)+self.infoImageView.frame.origin.y);
}

- (ArmoryTutorialView *) tutorialView {
  if (!_tutorialView) {
    [[NSBundle mainBundle] loadNibNamed:@"ArmoryTutorialView" owner:self options:nil];
  }
  return _tutorialView;
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
    self.infoLabel = nil;
    self.topBar = nil;
    self.tutorialView = nil;
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
  if (_isForBattleLossTutorial) {
    [self.topBar unclickButton:kButton2];
    [self.topBar clickButton:kButton1];
    return;
  }
  
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
  if (!hasVisited && !_level) {
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
  [self displayBuyChests];
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
  Globals *gl = [Globals sharedGlobals];
  NSMutableArray *bp = [NSMutableArray arrayWithArray:gs.boosterPacks];
  
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  int quant = [def integerForKey:STARTER_PACK_QUANTITY_KEY];
  int numDays = gl.numDaysToBuyStarterPack;
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:gs.createTime.timeIntervalSince1970+numDays*24*60*60];
  NSTimeInterval timeInterval = [endDate timeIntervalSinceNow];
  if (!_isForBattleLossTutorial && (quant >= gl.numTimesToBuyStarterPack || timeInterval < 0)) {
    // Get rid of starter packs
    for (int i = 0; i < bp.count; i++) {
      BoosterPackProto *bpp = [bp objectAtIndex:i];
      if (bpp.isStarterPack) {
        [bp removeObjectAtIndex:i];
        break;
      }
    }
  }
  
  [bp sortUsingComparator:^NSComparisonResult(BoosterPackProto *obj1, BoosterPackProto *obj2) {
    if (obj1.isStarterPack && !obj2.isStarterPack) {
      return NSOrderedAscending;
    } else if (!obj1.isStarterPack && obj2.isStarterPack) {
      return NSOrderedDescending;
    }
    
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
  
  if (self.boosterPacks.count > 0) {
    for (BoosterPackProto *bpp in self.boosterPacks) {
      if (bpp.hasDailyLimit) {
        self.infoLabel.text = [NSString stringWithFormat:@"Note: Each Silver chest can only be purchased %d times a day.", bpp.dailyLimit];
        break;
      }
    }
  }
  
  [self.armoryTableView reloadData];
  [self.armoryTableView setContentOffset:ccp(0,-self.armoryTableView.contentInset.top)];
  
  if (_level) {
    for (int i = 0; i < self.boosterPacks.count; i++) {
      BoosterPackProto *bp = [self.boosterPacks objectAtIndex:i];
      if (bp.minLevel <= _level && bp.maxLevel >= _level && (bp.costsCoins == _shouldCostCoins)) {
        [self armoryRowClicked:bp];
        _level = 0;
      }
    }
  }
  
  if (_isForBattleLossTutorial) {
    [_arrow removeFromSuperview];
    _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
    [self.view addSubview:_arrow];
    _arrow.center = ccp(self.view.frame.size.width/2, self.armoryTableView.frame.origin.y);
    [Globals animateUIArrow:_arrow atAngle:-M_PI_2];
    
    self.armoryTableView.scrollEnabled = NO;
  } else {
    [_arrow removeFromSuperview];
    self.armoryTableView.scrollEnabled = YES;
  }
}

- (IBAction)armoryRowClicked:(id)sender {
  if (!sender) {
    return;
  }
  
  BoosterPackProto *bp = nil;
  ArmoryRow *row = nil;
  if ([sender isKindOfClass:[BoosterPackProto class]]) {
    bp = (BoosterPackProto *)sender;
  } else {
    while (![sender isKindOfClass:[ArmoryRow class]]) {
      sender = ((UIView *)sender).superview;
    }
    row = (ArmoryRow *)sender;
    bp = row.boosterPack;
  }
  
  if (_isForBattleLossTutorial) {
    NSIndexPath *ip = [self.armoryTableView indexPathForCell:row];
    if (ip.row != 0) {
      return;
    }
    
    [_arrow removeFromSuperview];
    [_arrow release];
    _arrow = nil;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserBoosterPackProto *userPack = [gs myBoosterPackForId:bp.boosterPackId];
  [self.carouselView updateForBoosterPack:bp userPack:userPack];
  
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
    
    if (_isForBattleLossTutorial) {
      [Globals displayUIView:self.tutorialView];
      [self.tutorialView displayDescriptionForFirstLossTutorial];
    }
  }];
}

- (IBAction)backClicked:(id)sender {
  if (_isForBattleLossTutorial) {
    [self buttonClickedDuringTutorialWithBuyClicked:NO];
    return;
  }
  
  if (!self.armoryTableView.hidden || _isForBattleLossTutorial) {
    return;
  }
  
  [self refresh];
  
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
  if (_isForBattleLossTutorial) {
    [self buttonClickedDuringTutorialWithBuyClicked:YES];
    return;
  }
  
  PurchaseOption option = -1;
  if (sender.tag == 1) {
    option = PurchaseOptionOne;
  } else if (sender.tag == 2) {
    option = PurchaseOptionTwo;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  BoosterPackProto *bpp = self.carouselView.booster;
  int price = 0;
  BOOL canAfford = YES;
  if (option == PurchaseOptionOne) {
    price = bpp.salePriceOne > 0 ? bpp.salePriceOne : bpp.retailPriceOne;
  } else if (option == PurchaseOptionTwo) {
    price = bpp.salePriceTwo > 0 ? bpp.salePriceTwo : bpp.retailPriceTwo;
  }
  
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  int quant = 0;
  if (bpp.isStarterPack) {
    quant = [def integerForKey:STARTER_PACK_QUANTITY_KEY];
    int numDays = gl.numDaysToBuyStarterPack;
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:gs.createTime.timeIntervalSince1970+numDays*24*60*60];
    NSTimeInterval timeInterval = [endDate timeIntervalSinceNow];
    if (quant >= gl.numTimesToBuyStarterPack || timeInterval < 0) {
      [Globals popupMessage:@"Sorry, you cannot buy this chest anymore."];
      return;
    }
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
    
    // Check if it is the starter pack
    if (bpp.isStarterPack) {
      [def setInteger:quant+1 forKey:STARTER_PACK_QUANTITY_KEY];
    }
  }
}

- (IBAction)infoClicked:(id)sender {
  [Globals displayUIView:self.tutorialView];
  [self.tutorialView displayInfoForStarterPack];
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
  if (_isForBattleLossTutorial) {
    if (self.armoryTableView.hidden) {
      [self buttonClickedDuringTutorialWithBuyClicked:NO];
    }
    return;
  }
  
  if (!_isForBattleLossTutorial) {
    [self close];
  }
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

- (IBAction)showMeSaleClicked:(id)sender {
  [GoldShoppeViewController displayView];
  [self.tutorialView closeClicked:nil];
  _isForBattleLossTutorial = NO;
}

- (void) buttonClickedDuringTutorialWithBuyClicked:(BOOL)buyClicked {
  if (!_isForBattleLossTutorial) {
    return;
  }
  
  [Globals displayUIView:self.tutorialView];
  if (buyClicked) {
    [self.tutorialView displayNotEnoughGold];
  } else {
    [self.tutorialView displayCloseClicked];
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

- (void) performBattleLossTutorial {
  _isForBattleLossTutorial = YES;
  
  [self refresh];
}

@end
