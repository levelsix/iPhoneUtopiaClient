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
@synthesize leftTopBarLabel, rightTopBarLabel;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(GoldShoppeViewController);

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.pkgTableView.rowHeight = 62;
  
  curGoldLabel.text = [NSString stringWithFormat:@"%d", [[GameState sharedGameState] gold]];
}

- (void) viewDidAppear:(BOOL)animated {
  [self.pkgTableView reloadData];
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
}

- (void) fadeOut {
  if (self.view.superview) {
    [self stopLoading];
    
    [UIView animateWithDuration:1.f animations:^{
      self.view.alpha = 0.f;
    } completion:^(BOOL finished) {
      [GoldShoppeViewController removeView];
    }];
  }
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
  self.leftTopBarLabel = nil;
  self.rightTopBarLabel = nil;
}

@end
