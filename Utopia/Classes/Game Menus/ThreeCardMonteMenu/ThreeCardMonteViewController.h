//
//  ThreeCardMonteViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"

@interface MonteCardView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *cardBackImageView;
@property (nonatomic, retain) IBOutlet UIImageView *cardFrontImageView;

@property (nonatomic, retain) IBOutlet UIView *frontView;

@property (nonatomic, retain) IBOutlet UIView *threeItemView;
@property (nonatomic, retain) IBOutlet UIView *twoItemView;
@property (nonatomic, retain) IBOutlet UIView *oneItemCoinView;
@property (nonatomic, retain) IBOutlet UIView *oneItemEquipView;

@property (nonatomic, retain) IBOutlet UILabel *threeItemSilverLabel;
@property (nonatomic, retain) IBOutlet UILabel *threeItemGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *threeItemEquipLabel;
@property (nonatomic, retain) IBOutlet EquipButton *threeItemEquipButton;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *threeItemLevelIcon;
@property (nonatomic, retain) IBOutlet UILabel *threeItemBottomLabel;

@property (nonatomic, retain) IBOutlet UILabel *twoItemFirstLabel;
@property (nonatomic, retain) IBOutlet UILabel *twoItemSecondLabel;
@property (nonatomic, retain) IBOutlet UIImageView *twoItemFirstImageView;
@property (nonatomic, retain) IBOutlet EquipButton *twoItemEquipButton;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *twoItemLevelIcon;
@property (nonatomic, retain) IBOutlet UILabel *twoItemBottomLabel;

@property (nonatomic, retain) IBOutlet UILabel *equipItemAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipItemDefenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipItemNameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *equipItemAttackIcon;
@property (nonatomic, retain) IBOutlet UIImageView *equipItemDefenseIcon;
@property (nonatomic, retain) IBOutlet EquipButton *equipItemEquipButton;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *equipItemLevelIcon;
@property (nonatomic, retain) IBOutlet UILabel *equipItemBottomLabel;

@property (nonatomic, retain) IBOutlet UILabel *coinItemLabel;
@property (nonatomic, retain) IBOutlet UIImageView *coinItemImageView;
@property (nonatomic, retain) IBOutlet UILabel *coinItemBottomLabel;

@end

@interface ThreeCardMonteViewController : UIViewController {
  BOOL _continueShuffling;
  BOOL _allowPicking;
  BOOL _shouldRestart;
  
  int _numPlays;
  
  MonteCardView *_winningCardView;
}

@property (nonatomic, retain) IBOutlet MonteCardView *monteCardView;

@property (nonatomic, retain) IBOutlet UILabel *goldLabel;

@property (nonatomic, retain) IBOutlet UIView *cardContainerView;

@property (nonatomic, retain) IBOutlet UIButton *bottomButton;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIView *playView;
@property (nonatomic, retain) IBOutlet UILabel *okayLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomGoldLabel;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) MonteCardView *badCardView;
@property (nonatomic, retain) MonteCardView *mediumCardView;
@property (nonatomic, retain) MonteCardView *goodCardView;

@property (nonatomic, retain) MonteCardProto *badCard;
@property (nonatomic, retain) MonteCardProto *mediumCard;
@property (nonatomic, retain) MonteCardProto *goodCard;

@property (nonatomic, retain) UIImageView *winningGlow;

@property (nonatomic, retain) NSString *pattern;

- (void) monteCardPicked:(MonteCardView *)mcv;

- (void) receivedRetreiveThreeCardMonteResponse:(RetrieveThreeCardMonteResponseProto *)proto;
- (void) receivedPlayThreeCardMonteResponse:(PlayThreeCardMonteResponseProto *)proto;

+ (ThreeCardMonteViewController *)sharedThreeCardMonteViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
