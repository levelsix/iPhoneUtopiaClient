//
//  DiamondShopViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>

@interface DiamondPackageView : UIView {
  UILabel *_descLabel;
  UILabel *_priceLabel;
  SKProduct *_product;
}

@property (nonatomic, retain) IBOutlet UILabel *descLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) SKProduct *product;

- (void) updateForProduct: (SKProduct *) product;

@end


@interface DiamondShopViewController : UIViewController {
  UIScrollView *_scrollView;
  DiamondPackageView *_itemView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet DiamondPackageView *itemView;

+ (DiamondShopViewController *)sharedDiamondShopViewController;
+ (void) displayView;
+ (void) removeView;

@end
