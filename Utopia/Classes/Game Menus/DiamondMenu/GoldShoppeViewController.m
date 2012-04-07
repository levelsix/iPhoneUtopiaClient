//
//  DiamondShopViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GoldShoppeViewController.h"
#import "IAPHelper.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"

@implementation PriceLabel

@synthesize price, bigLabel, littleLabel;

- (void) setPrice:(NSString *)pr {
  // Expects the format "$x.yy" and will make x big and ys small
  if (price != pr) {
    [price release];
    price = [pr retain];
    
    // Remember to remove $ sign in front
    NSString *left = [price substringWithRange:NSMakeRange(1, price.length-4)];
    NSString *right = [price substringFromIndex:price.length-3];
    bigLabel.text = left;
    littleLabel.text = right;
    
    CGRect r = bigLabel.frame;
    r.origin.x = 0;
    r.size.width = [left sizeWithFont:bigLabel.font].width;
    bigLabel.frame = r;
    
    r = littleLabel.frame;
    r.origin.x = CGRectGetMaxX(bigLabel.frame);
    r.size.width = [right sizeWithFont:littleLabel.font].width;
    littleLabel.frame = r;
    
    r = self.frame;
    r.size.width = bigLabel.frame.size.width + littleLabel.frame.size.width;
    self.frame = r;
    self.center = CGPointMake(CGRectGetMidX(self.superview.bounds), self.center.y);
  }
}

@end

@implementation GoldPackageView

@synthesize product = _product;
@synthesize pkgIcon, pkgGoldLabel, pkgNameLabel, priceLabel;
@synthesize selectedView;

- (void) updateForProduct:(SKProduct *)product {
  self.product = product;
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  
  self.pkgNameLabel.text = product.localizedTitle;
  self.pkgGoldLabel.text = [NSString stringWithFormat:@"%@", [[[Globals sharedGlobals] productIdentifiers] objectForKey:product.productIdentifier]];
  [numberFormatter setLocale:product.priceLocale];
  NSString *formattedString = [numberFormatter stringFromNumber:product.price];
  self.priceLabel.price = formattedString;
  
  [numberFormatter release];
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

- (void) buyItem {
  [[IAPHelper sharedIAPHelper] buyProductIdentifier:self.product];
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

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GoldShoppeViewController);

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.pkgTableView.rowHeight = 62;
  
  self.state = kPackagesState;
}

- (void) viewDidAppear:(BOOL)animated {
  [self.pkgTableView reloadData];
  
  curGoldLabel.text = [NSString stringWithFormat:@"%d", [[GameState sharedGameState] gold]];
}

- (void) setState:(GoldShoppeState)state {
  if (state != _state) {
    _state = state;
    switch (state) {
      case kEarnFreeState:
        [Globals popupMessage:@"There are no free offers at this time. Please check back in a future version."];
        [Analytics clickedFreeOffers];
        _state = kPackagesState;
        break;
        
      default:
        break;
    }
    [self.topBar unclickButton:kEarnFreeButton];
    [self.topBar clickButton:kGoldCoinsButton];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[IAPHelper sharedIAPHelper] products] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"GoldPackageView";
  
  GoldPackageView *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"GoldPackageView" owner:self options:nil];
    cell = self.itemView;
  }
  [cell updateForProduct:[[[IAPHelper sharedIAPHelper] products] objectAtIndex:indexPath.row]];
  cell.pkgIcon.image = [Globals imageNamed:@"stack.png"];
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GoldPackageView *gpv = (GoldPackageView *)[tableView cellForRowAtIndexPath:indexPath];
  [gpv buyItem];
  [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.07]];
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  [self startLoading];
}

- (IBAction)closeButtonClicked:(id)sender {
  [GoldShoppeViewController removeView];
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
}

@end
