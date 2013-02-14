//
//  ArmoryCarouselView.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/7/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "Globals.h"

@interface ArmoryListing : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *dotIcon;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *amtCollectedLabel;

@property (nonatomic, retain) IBOutlet UIView *amtCollectedView;

@property (nonatomic, retain) UIImageView *overlay;

- (void) updateForEquip:(FullEquipProto *)fep numCollected:(int)collected total:(int)total;

@end

@interface ArmoryCardDisplayView : UIView {
  int _currentIndex;
  
  BOOL _tapToFlip;
  BOOL _tapToContinue;
}

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *cardView;
@property (nonatomic, retain) IBOutlet UIImageView *cardBackImageView;
@property (nonatomic, retain) IBOutlet ArmoryListing *armoryListing;


@property (nonatomic, retain) IBOutlet UIImageView *spinnerView;
@property (nonatomic, retain) IBOutlet UIImageView *tapToFlipView;
@property (nonatomic, retain) IBOutlet UIImageView *tapToContinueView;

@property (nonatomic, retain) IBOutlet UIView *buttonView;

@property (nonatomic, retain) NSArray *equips;

- (void) beginAnimatingForEquips:(NSArray *)equips;

@end

@interface ArmoryCarouselView : UIView <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) IBOutlet ArmoryListing *armoryListing;

@property (nonatomic, retain) IBOutlet UIImageView *tagView1;
@property (nonatomic, retain) IBOutlet UIImageView *tagView2;
@property (nonatomic, retain) IBOutlet UIImageView *tagView3;
@property (nonatomic, retain) IBOutlet UILabel *amtLabel1;
@property (nonatomic, retain) IBOutlet UILabel *amtLabel2;
@property (nonatomic, retain) IBOutlet UILabel *amtLabel3;

@property (nonatomic, retain) IBOutlet UIImageView *saleCoinIcon1;
@property (nonatomic, retain) IBOutlet UILabel *saleLabel1;
@property (nonatomic, retain) IBOutlet UIImageView *retailCoinIcon1;
@property (nonatomic, retain) IBOutlet UILabel *retailLabel1;
@property (nonatomic, retain) IBOutlet UIImageView *normalCoinIcon1;
@property (nonatomic, retain) IBOutlet UILabel *normalLabel1;
@property (nonatomic, retain) IBOutlet UIView *saleView1;
@property (nonatomic, retain) IBOutlet UIView *noSaleView1;

@property (nonatomic, retain) IBOutlet UIImageView *saleCoinIcon2;
@property (nonatomic, retain) IBOutlet UILabel *saleLabel2;
@property (nonatomic, retain) IBOutlet UIImageView *retailCoinIcon2;
@property (nonatomic, retain) IBOutlet UILabel *retailLabel2;
@property (nonatomic, retain) IBOutlet UIImageView *normalCoinIcon2;
@property (nonatomic, retain) IBOutlet UILabel *normalLabel2;
@property (nonatomic, retain) IBOutlet UIView *saleView2;
@property (nonatomic, retain) IBOutlet UIView *noSaleView2;

@property (nonatomic, retain) NSArray *specialItems;
@property (nonatomic, retain) BoosterPackProto *booster;
@property (nonatomic, retain) UserBoosterPackProto *userBooster;

- (void) updateForBoosterPack:(BoosterPackProto *)bpp userPack:(UserBoosterPackProto *)ubpp;

@end
