//
//  ThreeCardMonteViewController.h
//  Utopia
//
//  Created by Danny Huang on 9/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "LNSynthesizeSingleton.h"
#import "Protocols.pb.h"
#import "NibUtils.h"

typedef enum {
  kSilverPrize = 1,
  kGoldPrize,
  kWeaponPrize,
  kGoldAndSilverPrize,
  kGoldAndEquipPrize,
  kGoldAndEquipPrizeAndSilverPrize,
  kSilverAndEquipPrize,
}PrizeList;

@interface ThreeCardMonteViewController : UIViewController {
  CGRect posOneRect;
  CGRect posTwoRect;
  CGRect posThreeRect;
  UIImage *cardBack;
  UIImage *greaterPrize;
  UIImage *equalPrize;
  UIImage *smallerPrize;
  BOOL tapped;
  BOOL cardOneWasFlipped;
  BOOL cardTwoWasFlipped;
  BOOL cardThreeWasFlipped;
  int reward;
  CGFloat beforeTransformWidth;
  CGFloat beforeTransformHeight;
  UIView *badView;
  UIView *mediumView;
  UIView *goodView;
  int badEquipId;
  int mediumEquipId;
  int goodEquipId;
  int badCardID;
  int mediumCardID;
  int goodCardID;
  int cardID;
}

@property (nonatomic, retain) IBOutlet UIView      *cardViewOne;
@property (nonatomic, retain) IBOutlet UIView      *cardViewTwo;
@property (nonatomic, retain) IBOutlet UIView      *cardViewThree;
@property (nonatomic, retain) IBOutlet UIImageView *cardImageViewOne;
@property (nonatomic, retain) IBOutlet UIImageView *cardImageViewTwo;
@property (nonatomic, retain) IBOutlet UIImageView *cardImageViewThree;
@property (nonatomic, retain) IBOutlet UIImageView *popupGlow;
@property (nonatomic, retain) IBOutlet UIView      *cardView;
@property (nonatomic, retain) IBOutlet UIButton    *flipButton;
@property (nonatomic, retain) IBOutlet UIButton    *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton    *infoButton;
@property (nonatomic, retain) IBOutlet UIButton    *cancelInfoButton;
@property (nonatomic, assign) IBOutlet UILabel     *currentGold;
@property (nonatomic, assign) IBOutlet UILabel     *payLabel;
@property (nonatomic, assign) IBOutlet UIImageView *goldCoin;
@property (nonatomic, assign) IBOutlet UILabel     *playLabel;
@property (nonatomic, assign) IBOutlet UILabel     *okayLabel;
@property (nonatomic, retain) IBOutlet UIButton    *okayButton;
@property (nonatomic, retain) IBOutlet UIButton    *buyGold;
@property (nonatomic, assign) IBOutlet UIImageView *goldLabelBg;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) IBOutlet UILabel     *loadingLabel;

//list of prize views
@property (nonatomic, retain) IBOutlet UIView      *oneItemDecentView;
@property (nonatomic, retain) IBOutlet UIView      *oneItemBetterView;
@property (nonatomic, retain) IBOutlet UIView      *oneItemBestView;
@property (nonatomic, retain) IBOutlet UIView      *decentWeaponView;
@property (nonatomic, retain) IBOutlet UIView      *betterWeaponView;
@property (nonatomic, retain) IBOutlet UIView      *bestWeaponView;
@property (nonatomic, retain) IBOutlet UIView      *twoPrizeDecentView;
@property (nonatomic, retain) IBOutlet UIView      *twoPrizeBetterView;
@property (nonatomic, retain) IBOutlet UIView      *twoPrizeBestView;
@property (nonatomic, retain) IBOutlet UIView      *threePrizeDecentView;
@property (nonatomic, retain) IBOutlet UIView      *threePrizeBetterView;
@property (nonatomic, retain) IBOutlet UIView      *threePrizeBestView;

//one item prize
@property (nonatomic, assign) IBOutlet UILabel     *decentAmountLabel;
@property (nonatomic, assign) IBOutlet UILabel     *betterAmountabel;
@property (nonatomic, assign) IBOutlet UILabel     *bestAmountLabel;
@property (nonatomic, retain) IBOutlet UIImageView *decentPrizeImg;
@property (nonatomic, retain) IBOutlet UIImageView *betterPrizeImg;
@property (nonatomic, retain) IBOutlet UIImageView *bestPrizeImg;

//two item prize
@property (nonatomic, assign) IBOutlet UILabel     *decentTwoItemOneAmount;
@property (nonatomic, assign) IBOutlet UILabel     *decentTwoItemTwoAmount;
@property (nonatomic, assign) IBOutlet UILabel     *betterTwoItemOneAmount;
@property (nonatomic, assign) IBOutlet UILabel     *betterTwoItemTwoAmount;
@property (nonatomic, assign) IBOutlet UILabel     *bestTwoItemOneAmount;
@property (nonatomic, assign) IBOutlet UILabel     *bestTwoItemTwoAmount;
@property (nonatomic, retain) IBOutlet UIImageView *decentTwoPrizeItemOneImg;
@property (nonatomic, retain) IBOutlet UIImageView *decentTwoPrizeItemTwoImg;
@property (nonatomic, retain) IBOutlet UIImageView *betterTwoPrizeItemOneImg;
@property (nonatomic, retain) IBOutlet UIImageView *betterTwoPrizeItemTwoImg;
@property (nonatomic, retain) IBOutlet UIImageView *bestTwoPrizeItemOneImg;
@property (nonatomic, retain) IBOutlet UIImageView *bestTwoPrizeItemTwoImg;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *decentTwoPrizeEquipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *betterTwoPrizeEquipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *bestTwoPrizeEquipIcon;

//three item prize
@property (nonatomic, assign) IBOutlet UILabel     *decentThreePrizeItemOneAmount;
@property (nonatomic, assign) IBOutlet UILabel     *decentThreePrizeItemTwoAmount;
@property (nonatomic, assign) IBOutlet UILabel     *decentThreePrizeItemThreeAmount;
@property (nonatomic, assign) IBOutlet UILabel     *betterThreePrizeItemOneAmount;
@property (nonatomic, assign) IBOutlet UILabel     *betterThreePrizeItemTwoAmount;
@property (nonatomic, assign) IBOutlet UILabel     *betterThreePrizeItemThreeAmount;
@property (nonatomic, assign) IBOutlet UILabel     *bestThreePrizeItemOneAmount;
@property (nonatomic, assign) IBOutlet UILabel     *bestThreePrizeItemTwoAmount;
@property (nonatomic, assign) IBOutlet UILabel     *bestThreePrizeItemThreeAmount;
@property (nonatomic, retain) IBOutlet UIImageView *decentThreePrizeItemThreeImg;
@property (nonatomic, retain) IBOutlet UIImageView *betterThreePrizeItemThreeImg;
@property (nonatomic, retain) IBOutlet UIImageView *bestThreePrizeItemThreeImg;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *decentThreeItemEquipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *betterThreeItemEquipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *bestThreeItemEquipIcon;

//weapon
@property (nonatomic, assign) IBOutlet UILabel     *decentWeaponName;
@property (nonatomic, assign) IBOutlet UILabel     *betterWeaponName;
@property (nonatomic, assign) IBOutlet UILabel     *bestWeaponName;
@property (nonatomic, assign) IBOutlet UILabel     *decentAttackValue;
@property (nonatomic, assign) IBOutlet UILabel     *decentDefenceValue;
@property (nonatomic, assign) IBOutlet UILabel     *betterAttackValue;
@property (nonatomic, assign) IBOutlet UILabel     *betterDefenceValue;
@property (nonatomic, assign) IBOutlet UILabel     *bestAttackValue;
@property (nonatomic, assign) IBOutlet UILabel     *bestDefenceValue;
@property (nonatomic, retain) IBOutlet UIImageView *decentWeaponImg;
@property (nonatomic, retain) IBOutlet UIImageView *betterWeaponImg;
@property (nonatomic, retain) IBOutlet UIImageView *bestWeaponImg;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *decentEquipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *betterEquipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *bestEquipIcon;

- (IBAction) flipCard:(id)sender;
- (IBAction) closeView:(id)sender;
- (IBAction) info:(id)sender;
- (IBAction) okay:(id)sender;
- (IBAction) buyGold:(id)sender;

- (void) receivedRetreiveThreeCardMonteResponse:(RetrieveThreeCardMonteResponseProto *)proto;
- (void) receivedPlayThreeCardMonteResponse:(PlayThreeCardMonteResponseProto *)proto;

+ (ThreeCardMonteViewController *)sharedThreeCardMonteViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
@end
