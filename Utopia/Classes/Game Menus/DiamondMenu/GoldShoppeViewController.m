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
        NSString *left  = [price substringWithRange:NSMakeRange(1,
                                                                price.length-4)];
        NSString *right  = [price substringFromIndex:price.length-3];
        
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
@synthesize pkgIcon, pkgGoldLabel, pkgNameLabel, priceLabel;
@synthesize selectedView;

- (void) updateForPurchaseData:(id<InAppPurchaseData>)product 
{
  // Set Free offer title
  self.pkgNameLabel.text = product.primaryTitle;
  
  // Set gold quantity text
  self.pkgGoldLabel.text = product.secondaryTitle;
  
  // Set the price
  self.priceLabel.price  = product.price;
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

@implementation GoldShoppeLoadingView

@synthesize darkView, actIndView;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) dealloc {
  self.darkView = nil;
  self.actIndView = nil;
  
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

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GoldShoppeViewController);

#pragma mark - View lifecycle

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
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(refreshTableView) 
                                               name:[InAppPurchaseData
                                                     adTakeoverResignedNotification]
                                             object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewDidAppear:(BOOL)animated {
  [self.pkgTableView reloadData];
  
  curGoldLabel.text = [NSString stringWithFormat:@"%d", [[GameState sharedGameState] gold]];
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
        [self.topBar unclickButton:kGoldCoinsButton];
        [self.topBar clickButton:kEarnFreeButton];

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
  switch (_state) {
    case kPackagesState:
      return [[[IAPHelper sharedIAPHelper] products] count];
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
    [[NSBundle mainBundle] loadNibNamed:@"GoldPackageView" owner:self options:nil];
    cell = self.itemView;
  }
  
  id<InAppPurchaseData> cellData;
  switch (_state) {
    case kPackagesState:
      cellData = [InAppPurchaseData createWithSKProduct:[[[IAPHelper sharedIAPHelper] products] 
                                           objectAtIndex:indexPath.row]];
      break;
    case kEarnFreeState:
      cellData = [_sponsoredOffers objectAtIndex:indexPath.row];
      break;
    default:
      break;
  }
  
  cell.productData = cellData; 

  [cell updateForPurchaseData:cellData];
  cell.pkgIcon.image = cellData.rewardPic;
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
    [self startLoading];
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

- (void) startLoading {
  [loadingView.actIndView startAnimating];
  
  [self.view addSubview:loadingView];
  _isDisplayingLoadingView = YES;
}

- (void) stopLoading {
  if (_isDisplayingLoadingView) {
    [loadingView.actIndView stopAnimating];
    [loadingView removeFromSuperview];
    _isDisplayingLoadingView = NO;
  }
  
  curGoldLabel.text = [NSString stringWithFormat:@"%d", [[GameState sharedGameState] gold]];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.loadingView = nil;
  self.itemView = nil;
  self.pkgTableView = nil;
  self.curGoldLabel = nil;
  self.topBar = nil;
  self.mainView = nil;
  self.bgdView = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [_sponsoredOffers release];
}

@end
