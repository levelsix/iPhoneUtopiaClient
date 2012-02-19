//
//  DiamondShopViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "DiamondShopViewController.h"
#import "IAPHelper.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"

@implementation DiamondPackageView

@synthesize descLabel = _descLabel;
@synthesize priceLabel = _priceLabel;
@synthesize product = _product;

- (void) updateForProduct:(SKProduct *)product {
  self.product = product;
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  
  self.descLabel.text = product.localizedTitle;
  
  [numberFormatter setLocale:product.priceLocale];
  NSString *formattedString = [numberFormatter stringFromNumber:product.price];
  self.priceLabel.text = formattedString;
  self.layer.cornerRadius = 10;
  self.layer.borderWidth = 1;
  self.layer.borderColor = [[UIColor blackColor] CGColor];
  
  [numberFormatter release];
}

- (IBAction) buyButtonTapped:(id) sender {
  [[IAPHelper sharedIAPHelper] buyProductIdentifier:self.product];
}

@end


@implementation DiamondShopViewController

@synthesize scrollView = _scrollView;
@synthesize itemView = _itemView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(DiamondShopViewController);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  NSArray *products = [[IAPHelper sharedIAPHelper] products];
  UINib *nib = [UINib nibWithNibName:@"DiamondPackageView" bundle:nil];
  for (int i = 0; i < [products count]; i++) {
    SKProduct *product = [products objectAtIndex:i];
    
    // Make a new itemView for each product
    [nib instantiateWithOwner:self options:nil];
    [self.itemView updateForProduct:product];
    
    self.itemView.frame = CGRectMake(0, (i+1)*self.itemView.frame.size.height, self.itemView.frame.size.width, self.itemView.frame.size.height);
    
    [self.scrollView addSubview:self.itemView];
  }
  
  self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, ([products count]+1)*self.itemView.frame.size.height);
  self.scrollView.layer.cornerRadius = 10;
  self.scrollView.layer.borderWidth = 3;
  self.scrollView.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (IBAction)closeButtonClicked:(id)sender {
  [self.view removeFromSuperview];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
