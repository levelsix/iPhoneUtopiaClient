//
//  ThreeCardMonteViewController.m
//  Utopia
//
//  Created by Danny Huang on 9/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ThreeCardMonteViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GameState.h"
#import "GoldShoppeViewController.h"
#import "OutgoingEventController.h"
#import "Downloader.h"
#import "EquipMenuController.h"
#import "Globals.h"

#define Greater 1
#define Smaller 2
#define Equal 3

#define Gold_Cost 60
#define Transform_Ratio 1.15f
#define Swap_Delay  1.0f
#define Flip_duration 0.5f
#define Deform_time 0.3f
#define Hidden_Delay 0.355555f
#define Swap_Duration 0.7f

@implementation ThreeCardMonteViewController
@synthesize cardView, cardImageViewOne, cardImageViewTwo,cardImageViewThree, flipButton, cancelButton, infoButton,loadingLabel;
@synthesize cancelInfoButton;
@synthesize cardViewOne, cardViewTwo ,cardViewThree;
@synthesize currentGold, popupGlow;
@synthesize okayLabel, playLabel, goldCoin, payLabel, okayButton,buyGold, goldLabelBg;
@synthesize spinner;
@synthesize oneItemDecentView, oneItemBestView, oneItemBetterView, decentWeaponView,betterWeaponView,bestWeaponView,twoPrizeDecentView,twoPrizeBetterView,twoPrizeBestView,threePrizeBestView,threePrizeBetterView,threePrizeDecentView;
@synthesize decentAmountLabel, betterAmountabel, bestAmountLabel, decentPrizeImg, betterPrizeImg, bestPrizeImg;
@synthesize decentTwoItemOneAmount, decentTwoItemTwoAmount, betterTwoItemOneAmount, betterTwoItemTwoAmount, bestTwoItemOneAmount, bestTwoItemTwoAmount, decentTwoPrizeItemOneImg, decentTwoPrizeItemTwoImg, betterTwoPrizeItemOneImg, betterTwoPrizeItemTwoImg, bestTwoPrizeItemOneImg, bestTwoPrizeItemTwoImg;
@synthesize decentThreePrizeItemOneAmount, decentThreePrizeItemTwoAmount, decentThreePrizeItemThreeAmount, betterThreePrizeItemOneAmount, betterThreePrizeItemTwoAmount,betterThreePrizeItemThreeAmount, bestThreePrizeItemThreeImg, bestThreePrizeItemOneAmount, bestThreePrizeItemTwoAmount, bestThreePrizeItemThreeAmount, betterThreePrizeItemThreeImg, decentThreePrizeItemThreeImg;
@synthesize decentWeaponName, betterWeaponName, bestWeaponName, decentAttackValue, decentDefenceValue, betterAttackValue, betterDefenceValue, betterWeaponImg, bestWeaponImg,bestAttackValue,bestDefenceValue,decentWeaponImg;
@synthesize decentTwoPrizeEquipIcon, betterTwoPrizeEquipIcon, bestTwoPrizeEquipIcon, decentThreeItemEquipIcon, betterThreeItemEquipIcon, bestThreeItemEquipIcon, decentEquipIcon, betterEquipIcon, bestEquipIcon;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ThreeCardMonteViewController)

- (void)viewDidLoad
{
  [super viewDidLoad];
  cardOneWasFlipped = YES;
  cardTwoWasFlipped = YES;
  cardThreeWasFlipped   = YES;
  
}

-(void)hidePrizeView {
  badView.alpha = 0.0f;
  mediumView.alpha = 0.0f;
  goodView.alpha = 0.0f;
}

- (void)performHiddenWithView:(UIView *)view {
  badView.alpha = 1.0f;
  goodView.alpha = 1.0f;
  mediumView.alpha = 1.0f;
}

- (IBAction)okay:(id)sender {
  if(self.popupGlow.hidden == NO) {
    self.popupGlow.hidden = YES;
  }
  [self updateGold];
  self.okayButton.enabled = NO;
  typedef void (^completionBlock)(BOOL);
  completionBlock enable = ^(BOOL finished) {
    self.okayButton.hidden = YES;
    self.okayLabel.hidden = YES;
    self.goldCoin.hidden  = NO;
    self.payLabel.hidden = NO;
    self.playLabel.hidden = NO;
    self.flipButton.hidden = NO;
    self.flipButton.enabled = YES;
    self.cancelButton.enabled = YES;
  };
  if(reward == Smaller) {
    mediumView.frame = posOneRect;
    goodView.frame = posThreeRect;
  }
  else if(reward == Equal) {
    badView.frame = posOneRect;
    goodView.frame = posThreeRect;
  }
  else if(reward == Greater) {
    badView.frame = posOneRect;
    mediumView.frame = posThreeRect;
  }
  if (cardOneWasFlipped){
    completionBlock flip = ^(BOOL finished) {
      [UIView transitionWithView:self.cardImageViewTwo duration:Flip_duration
                         options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           if(reward == Smaller) {
                             [self.view insertSubview:mediumView aboveSubview:self.cardViewTwo];
                             self.cardImageViewTwo.image = equalPrize;
                           }
                           else if(reward == Equal) {
                             [self.view insertSubview:badView aboveSubview:self.cardViewTwo];
                             self.cardImageViewTwo.image = smallerPrize;
                             
                           }
                           else if(reward == Greater) {
                             [self.view insertSubview:badView aboveSubview:self.cardViewTwo];
                             self.cardImageViewTwo.image = smallerPrize;
                           }
                           [self performSelector:@selector(performHiddenWithView:) withObject:nil afterDelay:Hidden_Delay];
                         } completion:enable];
      
      [UIView transitionWithView:self.cardImageViewThree duration:Flip_duration
                         options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           if(reward == Smaller) {
                             [self.view insertSubview:goodView aboveSubview:self.cardViewThree];
                             self.cardImageViewThree.image = greaterPrize;
                           }
                           else if(reward == Equal) {
                             [self.view insertSubview:goodView aboveSubview:self.cardViewThree];
                             self.cardImageViewThree.image = greaterPrize;
                           }
                           else if(reward == Greater) {
                             [self.view insertSubview:mediumView aboveSubview:self.cardViewThree];
                             self.cardImageViewThree.image = equalPrize;
                           }
                           [self performSelector:@selector(performHiddenWithView:) withObject:nil afterDelay:Hidden_Delay];
                         } completion:enable];
    };
    [UIView animateWithDuration:Deform_time animations:^ {
      [self deformView:self.cardViewOne];
      [self deformView:badView];
      [self deformView:goodView];
      [self deformView:mediumView];
    }completion:flip];
  }
  if (cardTwoWasFlipped) {
    completionBlock flip = ^(BOOL finished) {
      [UIView transitionWithView:self.cardImageViewOne duration:Flip_duration
                         options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           if(reward == Smaller) {
                             [self.view insertSubview:mediumView aboveSubview:self.cardViewOne];
                             self.cardImageViewOne.image = equalPrize;
                           }
                           else if(reward == Equal) {
                             [self.view insertSubview:badView aboveSubview:self.cardViewOne];
                             self.cardImageViewOne.image = smallerPrize;
                           }
                           else if(reward == Greater) {
                             [self.view insertSubview:badView aboveSubview:self.cardViewOne];
                             self.cardImageViewOne.image = smallerPrize;
                           }
                           [self performSelector:@selector(performHiddenWithView:) withObject:nil afterDelay:Hidden_Delay];
                         } completion:enable];
      
      [UIView transitionWithView:self.cardImageViewThree duration:Flip_duration
                         options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           if(reward == Smaller) {
                             [self.view insertSubview:goodView aboveSubview:self.cardViewThree];
                             self.cardImageViewThree.image = greaterPrize;
                           }
                           else if(reward == Equal) {
                             [self.view insertSubview:goodView aboveSubview:self.cardViewThree];
                             self.cardImageViewThree.image = greaterPrize;
                           }
                           else if(reward == Greater) {
                             [self.view insertSubview:mediumView aboveSubview:self.cardViewThree];
                             self.cardImageViewThree.image = equalPrize;
                           }
                           [self performSelector:@selector(performHiddenWithView:) withObject:nil afterDelay:Hidden_Delay];
                         } completion:enable];
    };
    
    [UIView animateWithDuration:Deform_time animations:^{
      [self deformView:self.cardViewTwo];
      [self deformView:badView];
      [self deformView:goodView];
      [self deformView:mediumView];
    }completion:flip];
  }
  if (cardThreeWasFlipped) {
    completionBlock flip = ^(BOOL finished) {
      [UIView transitionWithView:self.cardImageViewOne duration:Flip_duration
                         options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           if(reward == Smaller) {
                             [self.view insertSubview:mediumView aboveSubview:self.cardViewOne];
                             self.cardImageViewOne.image = equalPrize;
                           }
                           else if(reward == Equal) {
                             [self.view insertSubview:badView aboveSubview:self.cardViewOne];
                             self.cardImageViewOne.image = smallerPrize;
                           }
                           else if(reward == Greater) {
                             [self.view insertSubview:badView aboveSubview:self.cardViewOne];
                             self.cardImageViewOne.image = smallerPrize;
                           }
                           [self performSelector:@selector(performHiddenWithView:) withObject:nil afterDelay:Hidden_Delay];
                         } completion:enable];
      
      [UIView transitionWithView:self.cardImageViewTwo duration:Flip_duration
                         options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           if(reward == Smaller) {
                             [self.view insertSubview:goodView aboveSubview:self.cardViewTwo];
                             self.cardImageViewTwo.image = greaterPrize;
                           }
                           else if(reward == Equal) {
                             [self.view insertSubview:goodView aboveSubview:self.cardViewTwo];
                             self.cardImageViewTwo.image = greaterPrize;
                           }
                           else if(reward == Greater) {
                             [self.view insertSubview:mediumView aboveSubview:self.cardViewTwo];
                             self.cardImageViewTwo.image = equalPrize;
                           }
                           [self performSelector:@selector(performHiddenWithView:) withObject:nil afterDelay:Hidden_Delay];
                         } completion:enable];
    };
    
    [UIView animateWithDuration:Deform_time animations:^{
      [self deformView:self.cardViewThree];
      [self deformView:badView];
      [self deformView:goodView];
      [self deformView:mediumView];
    }completion:flip];
  }
  cardOneWasFlipped = YES;
  cardTwoWasFlipped = YES;
  cardThreeWasFlipped = YES;
}

- (IBAction)flipCard:(id)sender {
  self.flipButton.enabled = NO;
  typedef void (^completionBlock)(BOOL);
  [self prizeCalculation];
  [[OutgoingEventController sharedOutgoingEventController] playThreeCardMonte:cardID];
}

- (void)updateGold {
  GameState *gs = [GameState sharedGameState];
  self.currentGold.text = [NSString stringWithFormat:@"%d",gs.gold];
}

- (void)swappingPositions {
  typedef void (^completionBlock)(BOOL);
  completionBlock moveToExtremeRight = ^(BOOL finished) {
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionRepeat animations:^{
      CGRect posOne = CGRectMake(self.cardViewOne.frame.origin.x, self.cardViewOne.frame.origin.y, self.cardViewOne.frame.size.width, self.cardViewOne.frame.size.height);
      CGRect posTwo = CGRectMake(self.cardViewTwo.frame.origin.x, self.cardViewTwo.frame.origin.y, self.cardViewTwo.frame.size.width, self.cardViewTwo.frame.size.height);
      CGRect posThree = CGRectMake(self.cardViewThree.frame.origin.x, self.cardViewThree.frame.origin.y,self.cardViewThree.frame.size.width ,self.cardViewThree.frame.size.height);
      self.cardViewOne.frame = posTwo;
      self.cardViewTwo.frame = posThree;
      self.cardViewThree.frame = posOne;
    }completion:nil];
  };
  
  [UIView animateWithDuration:0.1f animations:^{
    CGRect posOne = CGRectMake(self.cardViewOne.frame.origin.x, self.cardViewOne.frame.origin.y, self.cardViewOne.frame.size.width, self.cardViewOne.frame.size.height);
    CGRect posTwo = CGRectMake(self.cardViewTwo.frame.origin.x, self.cardViewTwo.frame.origin.y, self.cardViewTwo.frame.size.width, self.cardViewTwo.frame.size.height);
    CGRect posThree = CGRectMake(self.cardViewThree.frame.origin.x, self.cardViewThree.frame.origin.y,self.cardViewThree.frame.size.width ,self.cardViewThree.frame.size.height);
    self.cardViewOne.frame = posTwo;
    self.cardViewTwo.frame = posThree;
    self.cardViewThree.frame = posOne;
  }completion:moveToExtremeRight];
  [self performSelector:@selector(stopBlock) withObject:nil afterDelay:4];
}

- (void)stopBlock {
  typedef void (^completionBlock)(BOOL);
  completionBlock allowChoosing = ^(BOOL finished) {
    self.cardViewOne.userInteractionEnabled = YES;
    self.cardViewTwo.userInteractionEnabled = YES;
    self.cardViewThree.userInteractionEnabled = YES;
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardOneTouched:)];
    UITapGestureRecognizer *touchTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTwoTouched:)];
    UITapGestureRecognizer *touchThree = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardThreeTouched:)];
    
    [self.cardViewOne addGestureRecognizer:touchOne];
    [self.cardViewTwo addGestureRecognizer:touchTwo];
    [self.cardViewThree addGestureRecognizer:touchThree];
  };
  [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
    self.cardViewOne.frame = posOneRect;
    self.cardViewTwo.frame = posTwoRect;
    self.cardViewThree.frame = posThreeRect;
    self.flipButton.hidden = YES;
    self.goldCoin.hidden = YES;
    self.payLabel.hidden = YES;
    self.playLabel.hidden = YES;
    self.okayButton.hidden = NO;
    self.okayLabel.hidden = NO;
    self.okayButton.enabled = NO;
    self.okayLabel.text = @"Choose one";
  }completion:allowChoosing];
  if(reward == Smaller) {
    badView.frame = posTwoRect;
  }
  else if(reward == Equal) {
    mediumView.frame = posTwoRect;
  }
  else if(reward == Greater) {
    goodView.frame = posTwoRect;
  }
}

- (void)prizeCalculation {
  Globals *gl = [Globals sharedGlobals];
  float prize = (float)(arc4random() % 100);
  if(prize <= gl.goodMonteCardPercentageChance*100) {
    reward = Greater;
    cardID = goodCardID;
    return;
  }
  prize -= gl.goodMonteCardPercentageChance*100;
  if (prize <= gl.mediumMonteCardPercentageChance*100){
    reward = Equal;
    cardID = mediumCardID;
    return;
  }
  reward = Smaller;
  cardID = badCardID;
}

- (void)performHidden {
  NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
  [standard setObject:[NSNumber numberWithBool:YES] forKey:@"tapped"];
  [standard synchronize];
  if(reward == Smaller){
    badView.alpha = 1.0f;
    mediumView.alpha = 0.0f;;
    goodView.alpha = 0.0f;
    if(cardOneWasFlipped) {
      [self.view insertSubview:badView aboveSubview:self.cardViewOne];
    }
    else if (cardTwoWasFlipped) {
      [self.view insertSubview:badView aboveSubview:self.cardViewTwo];
    }
    else if (cardThreeWasFlipped) {
      [self.view insertSubview:badView aboveSubview:self.cardViewThree];
    }
  }
  else if(reward == Equal) {
    mediumView.alpha = 1.0f;;
    badView.alpha = 0.0f;
    goodView.alpha = 0.0f;
    if(cardOneWasFlipped) {
      [self.view insertSubview:mediumView aboveSubview:self.cardViewOne];
    }
    else if (cardTwoWasFlipped) {
      [self.view insertSubview:mediumView aboveSubview:self.cardViewTwo];
    }
    else if (cardThreeWasFlipped) {
      [self.view insertSubview:mediumView aboveSubview:self.cardViewThree];
    }
  }
  else if(reward == Greater) {
    goodView.alpha = 1.0f;
    badView.alpha = 0.0f;
    mediumView.alpha = 0.0f;
    if(cardOneWasFlipped) {
      [self.view insertSubview:goodView aboveSubview:self.cardViewOne];
    }
    else if (cardTwoWasFlipped) {
      [self.view insertSubview:goodView aboveSubview:self.cardViewTwo];
    }
    else if (cardThreeWasFlipped) {
      [self.view insertSubview:goodView aboveSubview:self.cardViewThree];
    }
  }
}

- (void)transformView:(UIView *)aView {
  CGAffineTransform tr = CGAffineTransformScale(aView.transform, Transform_Ratio, Transform_Ratio);
  aView.transform = tr;
  if(reward == Smaller){
    CGAffineTransform a = CGAffineTransformScale(badView.transform, Transform_Ratio, Transform_Ratio);
    badView.transform = a;
  }
  else if (reward == Equal) {
    CGAffineTransform a = CGAffineTransformScale(mediumView.transform, Transform_Ratio, Transform_Ratio);
    mediumView.transform = a;
  }
  else if (reward == Greater) {
    CGAffineTransform a = CGAffineTransformScale(goodView.transform, Transform_Ratio, Transform_Ratio);
    goodView.transform = a;
  }
}

- (void)deformView:(UIView *)aView {
  CGAffineTransform tr = CGAffineTransformScale(aView.transform, beforeTransformWidth/aView.frame.size.width, beforeTransformHeight/aView.frame.size.height);
  aView.transform = tr;
  if(reward == Smaller){
    CGAffineTransform a = CGAffineTransformScale(badView.transform, 1.0f, 1.0f);
    badView.transform = a;
  }
  else if (reward == Equal) {
    CGAffineTransform a = CGAffineTransformScale(mediumView.transform, 1.0f, 1.0f);
    mediumView.transform = a;
  }
  else if (reward == Greater) {
    CGAffineTransform a = CGAffineTransformScale(goodView.transform, 1.0f, 1.0f);
    goodView.transform = a;
  }
}

- (void)cardOneTouched:(UITapGestureRecognizer *)gesture {
  self.cardViewOne.userInteractionEnabled = NO;
  self.cardViewTwo.userInteractionEnabled = NO;
  self.cardViewThree.userInteractionEnabled = NO;
  cardOneWasFlipped = YES;
  cardTwoWasFlipped = NO;
  cardThreeWasFlipped = NO;
  typedef void (^completionBlock)(BOOL);
  completionBlock allowUserinteraction = ^(BOOL finished) {
    [UIView animateWithDuration:0.5f animations:^{
      [self transformView:self.cardViewOne];
      self.okayButton.enabled = YES;
    }];
  };
  [UIView transitionWithView:self.cardImageViewOne duration:Swap_Duration
                     options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                       UIImage *cardOne;
                       if(reward == Smaller) {
                         cardOne = smallerPrize;
                       }
                       else if(reward == Equal) {
                         cardOne = equalPrize;
                       }
                       else if(reward == Greater) {
                         cardOne = greaterPrize;
                       }
                       self.cardImageViewOne.image = cardOne;
                       self.popupGlow.hidden = NO;
                       self.okayLabel.text = @"Okay";
                       [self.view insertSubview:self.popupGlow aboveSubview:self.cardViewTwo];
                       [self.view insertSubview:self.popupGlow aboveSubview:self.cardViewThree];
                       [self.view insertSubview:self.cardViewOne aboveSubview:self.popupGlow];
                       [self setOnTop];
                       self.cardViewOne.frame = posTwoRect;
                       self.cardViewTwo.frame = posOneRect;
                       [self performSelector:@selector(performHidden) withObject:nil afterDelay:0.6f];
                     } completion:allowUserinteraction];
  
}

- (void)cardTwoTouched:(UITapGestureRecognizer *)gesture {
  self.cardViewOne.userInteractionEnabled = NO;
  self.cardViewTwo.userInteractionEnabled = NO;
  self.cardViewThree.userInteractionEnabled = NO;
  cardTwoWasFlipped = YES;
  cardThreeWasFlipped = NO;
  cardOneWasFlipped = NO;
  typedef void (^completionBlock)(BOOL);
  completionBlock allowUserinteraction = ^(BOOL finished) {
    [UIView animateWithDuration:0.5f animations:^{
      [self transformView:self.cardViewTwo];
      self.okayButton.enabled = YES;
    }];
  };
  [UIView transitionWithView:self.cardImageViewTwo duration:Swap_Duration
                     options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                       UIImage *cardOne;
                       if(reward == Smaller) {
                         cardOne = smallerPrize;
                       }
                       else if(reward == Equal) {
                         cardOne = equalPrize;
                       }
                       else if(reward == Greater) {
                         cardOne = greaterPrize;
                       }
                       
                       self.cardImageViewTwo.image = cardOne;
                       self.popupGlow.hidden = NO;
                       self.okayLabel.text = @"Okay";
                       [self.view insertSubview:self.popupGlow aboveSubview:self.cardViewOne];
                       [self.view insertSubview:self.popupGlow aboveSubview:self.cardViewThree];
                       [self.view insertSubview:self.cardViewTwo aboveSubview:self.popupGlow];
                       [self setOnTop];
                       [self performSelector:@selector(performHidden) withObject:nil afterDelay:0.6f];
                     } completion:allowUserinteraction];
  
}

- (void)cardThreeTouched:(UITapGestureRecognizer *)gesture {
  self.cardViewOne.userInteractionEnabled = NO;
  self.cardViewTwo.userInteractionEnabled = NO;
  self.cardViewThree.userInteractionEnabled = NO;
  cardThreeWasFlipped = YES;
  cardTwoWasFlipped = NO;
  cardOneWasFlipped = NO;
  typedef void (^completionBlock)(BOOL);
  completionBlock allowUserinteraction = ^(BOOL finished) {
    [UIView animateWithDuration:0.5f animations:^{
      [self transformView:self.cardViewThree];
      self.okayButton.enabled = YES;
    }];
  };
  [UIView transitionWithView:self.cardImageViewThree duration:Swap_Duration
                     options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                       UIImage *cardOne;
                       if(reward == Smaller) {
                         cardOne = smallerPrize;
                       }
                       else if(reward == Equal) {
                         cardOne = equalPrize;
                       }
                       else if(reward == Greater) {
                         cardOne = greaterPrize;
                       }
                       
                       self.cardImageViewThree.image = cardOne;
                       self.popupGlow.hidden = NO;
                       self.okayLabel.text = @"Okay";
                       self.cardViewTwo.frame = posThreeRect;
                       self.cardViewThree.frame = posTwoRect;
                       [self.view insertSubview:self.popupGlow aboveSubview:self.cardViewOne];
                       [self.view insertSubview:self.popupGlow aboveSubview:self.cardViewTwo];
                       [self.view insertSubview:self.cardViewThree aboveSubview:self.popupGlow];
                       [self setOnTop];
                       [self performSelector:@selector(performHidden) withObject:nil afterDelay:0.6f];
                     } completion:allowUserinteraction];
}

- (void)setOnTop {
  [self.view insertSubview:self.okayButton aboveSubview:self.popupGlow];
  [self.view insertSubview:self.okayLabel aboveSubview:self.okayButton];
  [self.view insertSubview:self.flipButton aboveSubview:self.popupGlow];
  [self.view insertSubview:self.goldCoin aboveSubview:self.flipButton];
  [self.view insertSubview:self.playLabel aboveSubview:self.flipButton];
  [self.view insertSubview:self.payLabel aboveSubview:self.flipButton];
}

- (IBAction)closeView:(id)sender {
  typedef void (^completionBlock)(BOOL);
  completionBlock closeView = ^(BOOL finished) {
    [ThreeCardMonteViewController removeView];
  };
  [UIView animateWithDuration:0.3f animations:^{
    self.view.center = CGPointMake(240, 480);
    self.popupGlow.alpha = 0.f;
  }completion:closeView];
}

- (IBAction)info:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  NSString *desc = [NSString stringWithFormat:@"%d%% Good, %d%% Better, %d%% Best", (int)(gl.badMonteCardPercentageChance*100), (int)(gl.mediumMonteCardPercentageChance*100), (int)(gl.goodMonteCardPercentageChance*100)];
  [Globals popupMessage:desc];
}

- (IBAction)buyGold:(id)sender {
  [GoldShoppeViewController displayView];
}

-(void)viewDidDisappear:(BOOL)animated {
  [self deformView:badView];
  [self deformView:mediumView];
  [self deformView:goodView];
  [badView removeFromSuperview];
  [mediumView removeFromSuperview];
  [goodView removeFromSuperview];
  self.cardViewOne.frame = posOneRect;
  self.cardViewTwo.frame = posTwoRect;
  self.cardViewThree.frame = posThreeRect;
}

-(void) restartView {
  NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
  NSNumber *tappped = [[NSUserDefaults standardUserDefaults]objectForKey:@"tapped"];
  if([tappped intValue] != 0) {
    self.okayLabel.hidden = YES;
    self.okayButton.hidden = YES;
    self.flipButton.hidden = NO;
    self.flipButton.enabled = YES;
    self.cardViewOne.frame = posOneRect;
    self.cardViewTwo.frame = posTwoRect;
    self.cardViewThree.frame = posThreeRect;
    self.cardImageViewOne.image  = smallerPrize;
    self.cardImageViewTwo.image = equalPrize;
    self.cardImageViewThree.image = greaterPrize;
    self.cancelButton.enabled = YES;
    self.playLabel.hidden = NO;
    self.goldCoin.hidden = NO;
    self.payLabel.hidden = NO;
    self.popupGlow.hidden = YES;
    badView.frame = self.cardViewOne.frame;
    mediumView.frame = self.cardViewTwo.frame;
    goodView.frame = self.cardViewThree.frame;
    [standard setObject:[NSNumber numberWithBool:NO] forKey:@"tapped"];
    [standard synchronize];
    cardOneWasFlipped = YES;
    cardTwoWasFlipped = YES;
    cardThreeWasFlipped = YES;
    goodView.alpha = 1.0f;
    mediumView.alpha = 1.0f;
    badView.alpha = 1.0f;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  typedef void (^completionBlock)(BOOL);
  completionBlock loadView = ^(BOOL finished) {
    [self.view insertSubview:self.spinner aboveSubview:self.cardViewTwo];
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    self.loadingLabel.hidden = NO;
    [self updateGold];
    cardBack = [UIImage imageNamed:@"cardback.png"];
    greaterPrize = [UIImage imageNamed:@"cardfrontblack.png"];
    smallerPrize = [UIImage imageNamed:@"cardfrontsilver.png"];
    equalPrize = [UIImage imageNamed:@"cardfront.png"];
    posOneRect = self.cardViewOne.frame;
    posTwoRect = self.cardViewTwo.frame;
    posThreeRect = self.cardViewThree.frame;
    self.flipButton.enabled = NO;
    [[OutgoingEventController sharedOutgoingEventController] retrieveThreeCardMonte];
  };
  self.view.center = CGPointMake(240, 480);
  self.popupGlow.alpha = 0.f;
  [UIView transitionWithView:self.view duration:0.3f options:UIViewAnimationCurveEaseIn animations:^{
    self.view.center = CGPointMake(240, 160);
    self.popupGlow.alpha = 1.f;
  }completion:loadView];
}
#pragma mark socket stuff

-(void)calculateBadCardValues:(RetrieveThreeCardMonteResponseProto *)proto {
  int gold = proto.badMonteCard.diamondsGained;
  FullEquipProto *equip = proto.badMonteCard.equip;
  int  equipLevel = proto.badMonteCard.equipLevel;
  int silver = proto.badMonteCard.coinsGained;
  badEquipId = equip.equipId;
  badCardID = proto.badMonteCard.cardId;
  
  //determine bad view type
  if(proto.badMonteCard.hasCoinsGained && proto.badMonteCard.hasEquip && proto.badMonteCard.hasDiamondsGained) {
    self.decentThreePrizeItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.decentThreePrizeItemTwoAmount.text = [NSString stringWithFormat:@"%d",gold];
    self.decentThreePrizeItemThreeAmount.text = [NSString stringWithFormat:@"%@",equip.name];
    self.decentThreeItemEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.decentThreePrizeItemThreeImg  maskedView: nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(badWeaponClicked)];
    [self.decentThreePrizeItemThreeImg addGestureRecognizer:touchOne];
    badView = self.threePrizeDecentView;
  }
  else if(proto.badMonteCard.hasCoinsGained && proto.badMonteCard.hasEquip && !proto.badMonteCard.hasDiamondsGained) {
    self.decentTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.decentTwoItemTwoAmount.text = equip.name;
    self.decentTwoPrizeEquipIcon.hidden = NO;
    self.decentTwoPrizeEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.decentTwoPrizeItemTwoImg maskedView:nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(badWeaponClicked)];
    [self.decentTwoPrizeItemTwoImg addGestureRecognizer:touchOne];
    badView = self.twoPrizeDecentView;
  }
  else if(!proto.badMonteCard.hasCoinsGained && proto.badMonteCard.hasEquip && proto.badMonteCard.hasDiamondsGained) {
    self.decentTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",gold];
    self.decentTwoItemTwoAmount.text = equip.name;
    self.decentTwoPrizeEquipIcon.hidden = NO;
    self.decentTwoPrizeEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.decentTwoPrizeItemTwoImg maskedView:nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(badWeaponClicked)];
    [self.decentTwoPrizeItemTwoImg addGestureRecognizer:touchOne];
    badView = self.twoPrizeDecentView;
  }
  else if (proto.badMonteCard.hasCoinsGained && !proto.badMonteCard.hasEquip && proto.badMonteCard.hasDiamondsGained) {
    self.decentTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.decentTwoItemTwoAmount.text = [NSString stringWithFormat:@"%d",gold];
    badView = self.twoPrizeDecentView;
  }
  else if(!proto.badMonteCard.hasCoinsGained && !proto.badMonteCard.hasEquip && proto.badMonteCard.hasDiamondsGained) {
    self.decentAmountLabel.text = [NSString stringWithFormat:@"%d",gold];
    self.decentPrizeImg.image = [UIImage imageNamed:@"refillgoldstack.png"];
    badView = self.oneItemDecentView;
  }
  else if (proto.badMonteCard.hasCoinsGained && !proto.badMonteCard.hasEquip && !proto.badMonteCard.hasDiamondsGained) {
    self.decentAmountLabel.text = [NSString stringWithFormat:@"%d",silver];
    self.decentPrizeImg.image = [UIImage imageNamed:@"refillsilverstack.png"];
    badView = self.oneItemDecentView;
  }
  else if(!proto.badMonteCard.hasCoinsGained && proto.badMonteCard.hasEquip && !proto.badMonteCard.hasDiamondsGained) {
    [Globals loadImageForEquip:equip.equipId toView:self.decentWeaponImg maskedView:nil];
    Globals *g = [Globals sharedGlobals];
    int attackValue = [g calculateAttackForEquip:equip.equipId level:equipLevel];
    int defenseValue = [g calculateDefenseForEquip:equip.equipId level:equipLevel];
    self.decentAttackValue.text = [NSString stringWithFormat:@"%d",attackValue];
    self.decentDefenceValue.text = [NSString stringWithFormat:@"%d",defenseValue];
    self.decentWeaponName.text = equip.name;
    self.decentEquipIcon.level = equipLevel;
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(badWeaponClicked)];
    [self.decentWeaponImg addGestureRecognizer:touchOne];
    badView = self.decentWeaponView;
  }
}

-(void)calculateMediumCardValues:(RetrieveThreeCardMonteResponseProto *)proto {
  int gold = proto.mediumMonteCard.diamondsGained;
  FullEquipProto *equip = proto.mediumMonteCard.equip;
  int equipLevel = proto.mediumMonteCard.equipLevel;
  int silver = proto.mediumMonteCard.coinsGained;
  mediumEquipId = equip.equipId;
  mediumCardID = proto.mediumMonteCard.cardId;
  
  if(proto.mediumMonteCard.hasCoinsGained && proto.mediumMonteCard.hasEquip && proto.mediumMonteCard.hasDiamondsGained) {
    self.betterThreePrizeItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.betterThreePrizeItemTwoAmount.text = [NSString stringWithFormat:@"%d",gold];
    self.betterThreePrizeItemThreeAmount.text = [NSString stringWithFormat:@"%@",equip.name];
    self.betterThreeItemEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.betterThreePrizeItemThreeImg  maskedView: nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediumWeaponClicked)];
    [self.betterThreePrizeItemThreeImg addGestureRecognizer:touchOne];
    mediumView = self.threePrizeBetterView;
  }
  else if(proto.mediumMonteCard.hasCoinsGained && proto.mediumMonteCard.hasEquip && !proto.mediumMonteCard.hasDiamondsGained) {
    self.betterTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.betterTwoItemTwoAmount.text = equip.name;
    self.betterTwoPrizeEquipIcon.hidden = NO;
    self.betterTwoPrizeEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.betterTwoPrizeItemTwoImg maskedView:nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediumWeaponClicked)];
    [self.betterTwoPrizeItemTwoImg addGestureRecognizer:touchOne];
    mediumView = self.twoPrizeBetterView;
  }
  else if(!proto.mediumMonteCard.hasCoinsGained && proto.mediumMonteCard.hasEquip && proto.mediumMonteCard.hasDiamondsGained) {
    self.betterTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",gold];
    self.betterTwoItemTwoAmount.text = equip.name;
    self.betterTwoPrizeEquipIcon.hidden = NO;
    self.betterTwoPrizeEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.betterTwoPrizeItemTwoImg maskedView:nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediumWeaponClicked)];
    [self.betterTwoPrizeItemTwoImg addGestureRecognizer:touchOne];
    mediumView = self.twoPrizeBetterView;
  }
  else if (proto.mediumMonteCard.hasCoinsGained && !proto.mediumMonteCard.hasEquip && proto.mediumMonteCard.hasDiamondsGained) {
    self.betterTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.betterTwoItemTwoAmount.text = [NSString stringWithFormat:@"%d",gold];
    mediumView = self.twoPrizeBetterView;
  }
  else if(!proto.mediumMonteCard.hasCoinsGained && !proto.mediumMonteCard.hasEquip && proto.mediumMonteCard.hasDiamondsGained) {
    self.betterAmountabel.text = [NSString stringWithFormat:@"%d",gold];
    self.betterPrizeImg.image = [UIImage imageNamed:@"refillgoldstack.png"];
    mediumView = self.oneItemBetterView;
  }
  else if (proto.mediumMonteCard.hasCoinsGained && !proto.mediumMonteCard.hasEquip && !proto.mediumMonteCard.hasDiamondsGained) {
    self.betterAmountabel.text = [NSString stringWithFormat:@"%d",silver];
    self.betterPrizeImg.image = [UIImage imageNamed:@"refillsilverstack.png"];
    mediumView = self.oneItemBetterView;
  }
  else if(!proto.mediumMonteCard.hasCoinsGained && proto.mediumMonteCard.hasEquip && !proto.mediumMonteCard.hasDiamondsGained) {
    Globals *g = [Globals sharedGlobals];
    int attackValue = [g calculateAttackForEquip:equip.equipId level:equipLevel];
    int defenseValue = [g calculateDefenseForEquip:equip.equipId level:equipLevel];
    self.betterAttackValue.text = [NSString stringWithFormat:@"%d",attackValue];
    self.betterDefenceValue.text = [NSString stringWithFormat:@"%d",defenseValue];
    self.betterWeaponName.text = [NSString stringWithFormat:@"%@",equip.name];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediumWeaponClicked)];
    [self.betterWeaponImg addGestureRecognizer:touchOne];
    self.betterEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.betterWeaponImg maskedView:nil];
    mediumView = self.betterWeaponView;
  }
}

-(void)calculateGoodCardValue:(RetrieveThreeCardMonteResponseProto *)proto {
  int gold = proto.goodMonteCard.diamondsGained;
  FullEquipProto *equip = proto.goodMonteCard.equip;
  int equipLevel = proto.goodMonteCard.equipLevel;
  int silver = proto.goodMonteCard.coinsGained;
  goodEquipId = equip.equipId;
  goodCardID = proto.goodMonteCard.cardId;
  
  if(proto.goodMonteCard.hasCoinsGained && proto.goodMonteCard.hasEquip && proto.goodMonteCard.hasDiamondsGained) {
    self.bestThreePrizeItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.bestThreePrizeItemTwoAmount.text = [NSString stringWithFormat:@"%d",gold];
    self.bestThreePrizeItemThreeAmount.text = [NSString stringWithFormat:@"%@",equip.name];
    self.bestThreeItemEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.bestThreePrizeItemThreeImg  maskedView: nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodWeaponClicked)];
    [self.bestThreePrizeItemThreeImg addGestureRecognizer:touchOne];
    goodView = self.threePrizeBestView;
  }
  else if(proto.goodMonteCard.hasCoinsGained && proto.goodMonteCard.hasEquip && !proto.goodMonteCard.hasDiamondsGained) {
    
    self.bestTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.bestTwoItemTwoAmount.text = equip.name;
    self.bestTwoPrizeEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.bestTwoPrizeItemTwoImg maskedView:nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodWeaponClicked)];
    [self.bestTwoPrizeItemTwoImg addGestureRecognizer:touchOne];
    goodView = self.twoPrizeBestView;
  }
  else if(!proto.goodMonteCard.hasCoinsGained && proto.goodMonteCard.hasEquip && proto.goodMonteCard.hasDiamondsGained) {
    self.bestTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",gold];
    self.bestTwoItemTwoAmount.text = equip.name;
    self.bestTwoPrizeEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.bestTwoPrizeItemTwoImg maskedView:nil];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodWeaponClicked)];
    [self.bestTwoPrizeItemTwoImg addGestureRecognizer:touchOne];
    goodView = self.twoPrizeBestView;
  }
  else if (proto.goodMonteCard.hasCoinsGained && !proto.goodMonteCard.hasEquip && proto.goodMonteCard.hasDiamondsGained) {
    self.bestTwoItemOneAmount.text = [NSString stringWithFormat:@"%d",silver];
    self.bestTwoItemTwoAmount.text = [NSString stringWithFormat:@"%d",gold];
    goodView = self.twoPrizeBestView;
  }
  else if(!proto.goodMonteCard.hasCoinsGained && !proto.goodMonteCard.hasEquip && proto.goodMonteCard.hasDiamondsGained) {
    self.bestAmountLabel.text = [NSString stringWithFormat:@"%d",gold];
    self.bestPrizeImg.image = [UIImage imageNamed:@"refillgoldstack.png"];
    goodView = self.oneItemBestView;
  }
  else if (proto.goodMonteCard.hasCoinsGained && !proto.goodMonteCard.hasEquip && !proto.goodMonteCard.hasDiamondsGained) {
    self.bestAmountLabel.text = [NSString stringWithFormat:@"%d",silver];
    self.bestPrizeImg.image = [UIImage imageNamed:@"refillsilverstack.png"];
    goodView = self.oneItemBestView;
  }
  else if(!proto.goodMonteCard.hasCoinsGained && proto.goodMonteCard.hasEquip && !proto.goodMonteCard.hasDiamondsGained) {
    Globals *g = [Globals sharedGlobals];
    int attackValue = [g calculateAttackForEquip:equip.equipId level:equipLevel];
    int defenseValue = [g calculateDefenseForEquip:equip.equipId level:equipLevel];
    self.bestAttackValue.text = [NSString stringWithFormat:@"%d",attackValue];
    self.bestDefenceValue.text = [NSString stringWithFormat:@"%d",defenseValue];
    self.bestWeaponName.text = [NSString stringWithFormat:@"%@",equip.name];
    UITapGestureRecognizer *touchOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodWeaponClicked)];
    [self.bestWeaponView addGestureRecognizer:touchOne];
    self.bestEquipIcon.level = equipLevel;
    [Globals loadImageForEquip:equip.equipId toView:self.bestWeaponImg maskedView:nil];
    goodView = self.bestWeaponView;
  }
}

- (void)receivedRetreiveThreeCardMonteResponse:(RetrieveThreeCardMonteResponseProto *)proto {
  [self calculateBadCardValues: proto];
  [self calculateMediumCardValues:proto];
  [self calculateGoodCardValue:proto];
  [self updateCardsWithBadView];
}

- (void)updateCardsWithBadView{
  badView.center = cardImageViewOne.center;
  mediumView.center = cardImageViewTwo.center;
  goodView.center = cardImageViewThree.center;
  [self.cardViewOne addSubview:badView];
  [self.cardViewTwo addSubview:mediumView];
  [self.cardViewThree addSubview:goodView];
  [self.cardViewOne setExclusiveTouch:YES];
  [self.cardViewTwo setExclusiveTouch:YES];
  [self.cardViewThree setExclusiveTouch:YES];
  [self.cardImageViewOne setExclusiveTouch:YES];
  [self.cardImageViewTwo setExclusiveTouch:YES];
  [self.cardImageViewThree setExclusiveTouch:YES];
  self.buyGold.frame = self.goldLabelBg.frame;
  beforeTransformWidth = self.cardViewTwo.frame.size.width;
  beforeTransformHeight = self.cardViewTwo.frame.size.height;
  self.flipButton.enabled = YES;
  self.loadingLabel.hidden = YES;
  [self.spinner stopAnimating];
  self.spinner.hidden = YES;
}


- (void) receivedPlayThreeCardMonteResponse:(PlayThreeCardMonteResponseProto *)proto{
  self.flipButton.enabled = NO;
  self.cancelButton.enabled = NO;
  typedef void (^completionBlock)(BOOL);
  completionBlock swap = ^(BOOL finished) {
    self.cardViewOne.frame = posOneRect;
    self.cardViewTwo.frame = posTwoRect;
    self.cardViewThree.frame = posThreeRect;
  };
  [self hidePrizeView];
  if(cardOneWasFlipped) {
    [UIView transitionWithView:self.cardViewOne duration:Flip_duration
                       options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                         self.cardImageViewOne.image = cardBack;
                       } completion:swap];
    
    
  }
  if(cardTwoWasFlipped) {
    [UIView transitionWithView:self.cardImageViewTwo duration:Flip_duration
                       options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                         self.cardImageViewTwo.image = cardBack;
                       } completion:swap];
  }
  if(cardThreeWasFlipped) {
    [UIView transitionWithView:self.cardImageViewThree duration:Flip_duration
                       options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                         self.cardImageViewThree.image = cardBack;
                       } completion:swap];
  }
  [self updateGold];
  [self performSelector:@selector(swappingPositions) withObject: nil afterDelay:Swap_Delay];
}

- (void)badWeaponClicked {
  [EquipMenuController displayViewForEquip:badEquipId];
}

- (void)mediumWeaponClicked {
  [EquipMenuController displayViewForEquip:mediumEquipId];
}

- (void)goodWeaponClicked {
  [EquipMenuController displayViewForEquip:goodEquipId];
}

#pragma release stuff

- (void)dealloc
{
  [self.cardImageViewOne release];
  [self.cardImageViewTwo release];
  [self.cardImageViewThree release];
  [self.flipButton release];
  [self.cancelButton release];
  [self.infoButton release];
  [self.cancelInfoButton release];
  [self.cardViewOne release];
  [self.cardViewTwo release];
  [self.cardViewThree release];
  [self.popupGlow release];
  [self.goldCoin release];
  [self.okayButton release];
  [self.buyGold release];
  [self.spinner release];
  [self.oneItemBestView release];
  [self.oneItemBetterView release];
  [self.oneItemDecentView release];
  [self.decentWeaponView release];
  [self.betterWeaponView release];
  [self.bestWeaponView release];
  [self.twoPrizeDecentView release];
  [self.twoPrizeBestView release];
  [self.twoPrizeBetterView release];
  [self.threePrizeDecentView release];
  [self.threePrizeBetterView release];
  [self.threePrizeBestView release];
  [self.decentPrizeImg release];
  [self.betterPrizeImg release];
  [self.bestPrizeImg release];
  [self.decentTwoPrizeItemOneImg release];
  [self.decentTwoPrizeItemTwoImg release];
  [self.betterTwoPrizeItemOneImg release];
  [self.betterTwoPrizeItemTwoImg release];
  [self.bestTwoPrizeItemOneImg release];
  [self.bestTwoPrizeItemTwoImg release];
  [self.decentThreePrizeItemThreeImg release];
  [self.betterThreePrizeItemThreeImg release];
  [self.bestThreePrizeItemThreeImg release];
  [self.decentWeaponImg release];
  [self.betterWeaponImg release];
  [self.bestWeaponImg release];
  [self.decentTwoPrizeEquipIcon release];
  [self.betterTwoPrizeEquipIcon release];
  [self.bestTwoPrizeEquipIcon release];
  [self.decentThreeItemEquipIcon release];
  [self.betterThreeItemEquipIcon release];
  [self.bestThreeItemEquipIcon release];
  [self.decentEquipIcon release];
  [self.betterEquipIcon release];
  [self.bestEquipIcon release];
  [super dealloc];
}


@end
