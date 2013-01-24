//
//  DiamondShopViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GoldShoppeViewController.h"
#import "IAPHelper.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"

@implementation PriceLabel

@synthesize price, bigLabel, littleLabel;

- (void) setLeftText:(NSString *)leftText andRightText:(NSString *)rightText
{
  bigLabel.text    = leftText;
  littleLabel.text = rightText;
  
  CGRect rect     = bigLabel.frame;
  rect.origin.x   = 0;
  rect.size.width = [leftText sizeWithFont:bigLabel.font].width;
  bigLabel.frame  = rect;
  
  rect                 = littleLabel.frame;
  rect.origin.x        = CGRectGetMaxX(bigLabel.frame);
  rect.size.width      = [rightText sizeWithFont:littleLabel.font].width;
  littleLabel.frame = rect;
  
  rect            = self.frame;
  rect.size.width = bigLabel.frame.size.width
  + littleLabel.frame.size.width;
  self.frame   = rect;
  self.center  = CGPointMake(CGRectGetMidX(self.superview.bounds),
                             self.center.y);
}

- (void) setPrice:(NSString *)newPrice {
  // Expects the format "$x.yy" and will make x big and ys small
  if (price != newPrice) {
    [price release];
    price = [newPrice retain];
    
    if ([newPrice length] > 0) {
      if ([newPrice isEqualToString:[InAppPurchaseData unknownPrice]]) {
        [self setLeftText:newPrice andRightText:@""];
      }
      else {
        // Remember to remove $ sign in front
        BOOL signInFront = ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[price characterAtIndex:0]];
        NSString *left  = [price substringWithRange:NSMakeRange(signInFront, price.length-4)];
        NSString *right  = [price substringWithRange:NSMakeRange(price.length-3-!signInFront,3)];
        [self setLeftText:left andRightText:right];
      }
    }
    else {
      newPrice = [InAppPurchaseData freePrice];
      [self setLeftText:newPrice andRightText:@""];
    }
  }
}

- (void) dealloc {
  self.price = nil;
  self.bigLabel = nil;
  self.littleLabel = nil;
  [super dealloc];
}

@end

@implementation GoldPackageView
@synthesize productData;
@synthesize pkgIcon, pkgGoldLabel, pkgNameLabel, priceLabel, coinIcon;
@synthesize selectedView;
@synthesize saleDiscountView, salePriceLabel, salePriceTagView;
@synthesize discountLabel, notSalePriceTagView, slashedPriceLabel;

- (void) awakeFromNib {
  [selectedView.superview bringSubviewToFront:selectedView];
  
  notSalePriceTagView.frame = salePriceTagView.frame;
  [salePriceTagView.superview addSubview:notSalePriceTagView];
}

- (void) updateForPurchaseData:(id<InAppPurchaseData>)product
{
  if (!product.primaryTitle) {
    self.hidden = YES;
  } else {
    self.hidden = NO;
  }
  
  // Set Free offer title
  self.pkgNameLabel.text = product.primaryTitle;
  
  // Set gold quantity text
  self.pkgGoldLabel.text = product.secondaryTitle;
  
  NSString *salePrice = product.salePrice;
  NSString *price = product.price;
  if (salePrice) {
    salePriceLabel.price = salePrice;
    slashedPriceLabel.price = price;
    
    discountLabel.text = [NSString stringWithFormat:@"%d%%", product.discount];
    
    saleDiscountView.hidden = NO;
    salePriceTagView.hidden = NO;
    notSalePriceTagView.hidden = YES;
  } else {
    priceLabel.price = price;
    
    saleDiscountView.hidden = YES;
    salePriceTagView.hidden = YES;
    notSalePriceTagView.hidden = NO;
  }
  
  // Set the icon
  self.coinIcon.highlighted = !product.isGold;
  
  [Globals imageNamed:product.rewardPicName withImageView:self.pkgIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  if (selected) {
    selectedView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
  } else if (!self.highlighted) {
    selectedView.backgroundColor = [UIColor clearColor];
  }
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  if (highlighted) {
    selectedView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
  } else if (!self.selected) {
    selectedView.backgroundColor = [UIColor clearColor];
  }
}

- (void) dealloc {
  self.pkgIcon = nil;
  self.pkgGoldLabel = nil;
  self.pkgNameLabel = nil;
  self.priceLabel = nil;
  self.selectedView = nil;
  self.saleDiscountView = nil;
  self.salePriceLabel = nil;
  self.salePriceTagView = nil;
  self.slashedPriceLabel = nil;
  self.discountLabel = nil;
  self.notSalePriceTagView = nil;
  [super dealloc];
}

@end

@implementation GoldShoppeBar

@synthesize goldCoinsLabel, goldCoinsClicked, earnFreeLabel, earnFreeClicked;

- (void) awakeFromNib {
  _clickedButtons = 0;
}

- (void) clickButton:(GoldShoppeButton)button {
  switch (button) {
    case kGoldCoinsButton:
      goldCoinsClicked.hidden = NO;
      _clickedButtons |= kGoldCoinsButton;
      goldCoinsLabel.highlighted = NO;
      break;
      
    case kEarnFreeButton:
      earnFreeClicked.hidden = NO;
      _clickedButtons |= kEarnFreeButton;
      earnFreeLabel.highlighted = NO;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(GoldShoppeButton)button {
  switch (button) {
    case kGoldCoinsButton:
      goldCoinsClicked.hidden = YES;
      _clickedButtons &= ~kGoldCoinsButton;
      goldCoinsLabel.highlighted = YES;
      break;
      
    case kEarnFreeButton:
      earnFreeClicked.hidden = YES;
      _clickedButtons &= ~kEarnFreeButton;
      earnFreeLabel.highlighted = YES;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:goldCoinsClicked];
  if (!(_clickedButtons & kGoldCoinsButton) && [goldCoinsClicked pointInside:pt withEvent:nil]) {
    _trackingGoldCoins = YES;
    [self clickButton:kGoldCoinsButton];
  }
  
  pt = [touch locationInView:earnFreeClicked];
  if (!(_clickedButtons & kEarnFreeButton) && [earnFreeClicked pointInside:pt withEvent:nil]) {
    _trackingEarnFree = YES;
    [self clickButton:kEarnFreeButton];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:goldCoinsClicked];
  if (_trackingGoldCoins) {
    if (CGRectContainsPoint(CGRectInset(goldCoinsClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kGoldCoinsButton];
    } else {
      [self unclickButton:kGoldCoinsButton];
    }
  }
  
  pt = [touch locationInView:earnFreeClicked];
  if (_trackingEarnFree) {
    if (CGRectContainsPoint(CGRectInset(earnFreeClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kEarnFreeButton];
    } else {
      [self unclickButton:kEarnFreeButton];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:goldCoinsClicked];
  if (_trackingGoldCoins) {
    if (CGRectContainsPoint(CGRectInset(goldCoinsClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [[GoldShoppeViewController sharedGoldShoppeViewController] setState:kPackagesState];
      [self clickButton:kGoldCoinsButton];
      [self unclickButton:kEarnFreeButton];
    } else {
      [self unclickButton:kGoldCoinsButton];
    }
  }
  
  pt = [touch locationInView:earnFreeClicked];
  if (_trackingEarnFree) {
    if (CGRectContainsPoint(CGRectInset(earnFreeClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kEarnFreeButton];
      [self unclickButton:kGoldCoinsButton];
      [[GoldShoppeViewController sharedGoldShoppeViewController] setState:kEarnFreeState];
    } else {
      [self unclickButton:kEarnFreeButton];
    }
  }
  _trackingGoldCoins = NO;
  _trackingEarnFree = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kGoldCoinsButton];
  [self unclickButton:kEarnFreeButton];
  _trackingGoldCoins = NO;
  _trackingEarnFree = NO;
}

- (void) dealloc {
  self.goldCoinsLabel = nil;
  self.goldCoinsClicked = nil;
  self.earnFreeLabel = nil;
  self.earnFreeClicked = nil;
  [super dealloc];
}

@end

@implementation GoldShoppeViewController

@synthesize loadingView;
@synthesize itemView = _itemView;
@synthesize pkgTableView, curGoldLabel;
@synthesize state = _state;
@synthesize topBar;
@synthesize mainView, bgdView;
@synthesize timer;
@synthesize saleView, dayLabel, hrsLabel, minsLabel, secsLabel;
@synthesize saleBackgroundView, curGoldView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GoldShoppeViewController);

#pragma mark - View lifecycle

- (id) init {
  Globals *gl = [Globals sharedGlobals];
  return [self initWithNibName:@"GoldShoppeViewController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.goldShoppeNibName]];
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

-(void) resetSponsoredOffers
{
  // Initialize the Ad Sponsored deals
  [_sponsoredOffers release];
  _sponsoredOffers = [InAppPurchaseData allSponsoredOffers];
  [_sponsoredOffers retain];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.pkgTableView.rowHeight = 62;
  
  self.state = kPackagesState;
  
  // Initialize the Ad Sponsored deals
  [self resetSponsoredOffers];
  
  NSString *name = [InAppPurchaseData
                    adTakeoverResignedNotification];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(refreshTableView)
                                               name:name
                                             object:self];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self update];
}

- (void) viewDidDisappear:(BOOL)animated {
  self.timer = nil;
}

- (void) update {
  [self.pkgTableView reloadData];
  
  GameState *gs = [GameState sharedGameState];
  curGoldLabel.text = [Globals commafyNumber:gs.gold];
  
  GoldSaleProto *sale = [gs getCurrentGoldSale];
  if (sale) {
    [self updateTimeLabels];
    self.timer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(updateTimeLabels) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [Globals imageNamed:sale.goldShoppeImageName withImageView:saleBackgroundView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
    
    self.saleView.hidden = NO;
    
    self.curGoldView.center = ccp(72, 262);
  } else {
    self.timer = nil;
    
    self.saleView.hidden = YES;
    
    self.curGoldView.center = ccp(72, 230);
  }
}

- (void) updateTimeLabels {
  GameState *gs = [GameState sharedGameState];
  GoldSaleProto *sale = [gs getCurrentGoldSale];
  
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:sale.endDate/1000.];
  NSTimeInterval timeInterval = [endDate timeIntervalSinceNow];
  if (sale) {
    int days = (int)(timeInterval/86400);
    int hrs = (int)((timeInterval-86400*days)/3600);
    int mins = (int)((timeInterval-86400*days-3600*hrs)/60);
    float secs = timeInterval-86400*days-3600*hrs-60*mins;
    dayLabel.text = [NSString stringWithFormat:@"%d Day%@", days, days == 1 ? @"" : @"s"];
    hrsLabel.text = [NSString stringWithFormat:@"%d Hr%@", hrs, hrs == 1 ? @"" : @"s"];
    minsLabel.text = [NSString stringWithFormat:@"%d Min%@", mins, mins == 1 ? @"" : @"s"];
    secsLabel.text = [NSString stringWithFormat:@"%.02f", secs];
  } else {
    [self update];
  }
}

- (void) setState:(GoldShoppeState)state {
  if (state != _state) {
    _state = state;
    switch (state) {
      case kPackagesState:
        [self.topBar unclickButton:kEarnFreeButton];
        [self.topBar clickButton:kGoldCoinsButton];
        break;
      case kEarnFreeState:
        //        [self.topBar unclickButton:kGoldCoinsButton];
        //        [self.topBar clickButton:kEarnFreeButton];
        
        [Globals popupMessage:@"Sorry, there are no free offers at this time."];
        self.state = kPackagesState;
        
        [Analytics clickedFreeOffers];
        break;
        
      default:
        break;
    }
    
    [[self pkgTableView] reloadData];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  Globals *gl = [Globals sharedGlobals];
  switch (_state) {
    case kPackagesState:
      return gl.iapPackages.count;
    case kEarnFreeState:
      return [_sponsoredOffers count];
    default:
      break;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"GoldPackageView";
  
  GoldPackageView *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    Globals *gl = [Globals sharedGlobals];
    [[Globals bundleNamed:gl.downloadableNibConstants.goldShoppeNibName] loadNibNamed:@"GoldPackageView" owner:self options:nil];
    cell = self.itemView;
  }
  
  id<InAppPurchaseData> cellData = nil;
  if (_state == kPackagesState) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    GoldSaleProto *sale = [gs getCurrentGoldSale];
    NSDictionary *dict = [[IAPHelper sharedIAPHelper] products];
    id arr[10] = {sale.package1SaleIdentifier, sale.packageS1SaleIdentifier, sale.package2SaleIdentifier, sale.packageS2SaleIdentifier, sale.package3SaleIdentifier, sale.packageS3SaleIdentifier, sale.package4SaleIdentifier, sale.packageS4SaleIdentifier, sale.package5SaleIdentifier, sale.packageS5SaleIdentifier};
    NSString *productId = [[gl.iapPackages objectAtIndex:indexPath.row] packageId];
    NSString *saleProductId = arr[indexPath.row];
    SKProduct *product = [dict objectForKey:productId];
    SKProduct *saleProduct = [dict objectForKey:saleProductId];
    cellData = [InAppPurchaseData createWithProduct:product saleProduct:saleProduct];
  } else if (_state == kEarnFreeState) {
    cellData = [_sponsoredOffers objectAtIndex:indexPath.row];
  }
  
  cell.productData = cellData;
  
  [cell updateForPurchaseData:cellData];
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GoldPackageView *gpv = (GoldPackageView *)[tableView
                                             cellForRowAtIndexPath:indexPath];
  
  [gpv.productData makePurchaseWithViewController:self];
  
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  if (_state == kPackagesState) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate
                                              dateWithTimeIntervalSinceNow:0.07]];
    [self.loadingView display:self.view];
  }
}

- (IBAction)closeButtonClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [GoldShoppeViewController removeView];
  }];
}

-(void) refreshTableView
{
  [self resetSponsoredOffers];
  [self.pkgTableView reloadData];
}

- (void) stopLoading {
  [self.loadingView stop];
  [self update];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (!self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loadingView = nil;
    self.itemView = nil;
    self.pkgTableView = nil;
    self.curGoldLabel = nil;
    self.topBar = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.timer = nil;
    self.saleView = nil;
    self.minsLabel = nil;
    self.hrsLabel = nil;
    self.secsLabel = nil;
    self.dayLabel = nil;
    self.saleBackgroundView = nil;
    self.curGoldView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_sponsoredOffers release];
    _sponsoredOffers = nil;
  }
}

@end
