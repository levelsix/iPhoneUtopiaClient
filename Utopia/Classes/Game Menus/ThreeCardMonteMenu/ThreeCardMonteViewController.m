//
//  ThreeCardMonteViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ThreeCardMonteViewController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "GoldShoppeViewController.h"
#import "RefillMenuController.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "Downloader.h"

#define FLIP_DURATION 0.5f
#define SHUFFLE_DURATION 2.f
#define SHUFFLE_SPEED 0.15f
#define CARD_SCALE 1.15f

typedef enum {
  BAD = 1,
  MEDIUM = 2,
  GOOD = 3
} MonteCardType;

@implementation MonteCardView

@synthesize frontView, cardBackImageView, cardFrontImageView;
@synthesize threeItemBottomLabel, threeItemEquipButton, threeItemEquipLabel;
@synthesize threeItemGoldLabel, threeItemLevelIcon, threeItemSilverLabel, threeItemView;
@synthesize twoItemView, twoItemBottomLabel, twoItemEquipButton, twoItemFirstImageView;
@synthesize twoItemFirstLabel, twoItemLevelIcon, twoItemSecondLabel;
@synthesize oneItemCoinView, coinItemBottomLabel, coinItemImageView, coinItemLabel;
@synthesize equipItemAttackIcon, equipItemAttackLabel, equipItemBottomLabel, equipItemNameLabel;
@synthesize equipItemDefenseIcon, equipItemDefenseLabel, equipItemEquipButton, equipItemLevelIcon;
@synthesize oneItemEquipView;

- (void) flipFaceUp:(BOOL)animated {
  if (animated) {
    [UIView transitionFromView:cardBackImageView toView:frontView duration:FLIP_DURATION options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
  } else {
    [cardBackImageView removeFromSuperview];
    [self addSubview:frontView];
  }
}

- (void) flipFaceDown:(BOOL)animated {
  if (animated) {
    [UIView transitionFromView:frontView toView:cardBackImageView duration:FLIP_DURATION options:UIViewAnimationOptionTransitionFlipFromRight completion: nil];
  } else {
    [frontView removeFromSuperview];
    [self addSubview:cardBackImageView];
  }
}

- (void) updateForCard:(MonteCardProto *)card type:(MonteCardType)type {
  Globals *gl = [Globals sharedGlobals];
  NSString *bottomLabelText = nil;
  UIColor *textColor = nil;
  NSString *base = gl.downloadableNibConstants.threeCardMonteNibName;
  if (type == BAD) {
    bottomLabelText = @"Good";
    cardFrontImageView.image = [Globals imageNamed:[base stringByAppendingString:@"/cardfrontsilver.png"]];
    textColor = [UIColor colorWithWhite:0.15f alpha:1.f];
  } else if (type == MEDIUM) {
    bottomLabelText = @"Better";
    cardFrontImageView.image = [Globals imageNamed:[base stringByAppendingString:@"/cardfrontblack.png"]];
    textColor = [Globals goldColor];
  } else if (type == GOOD) {
    bottomLabelText = @"Best";
    cardFrontImageView.image = [Globals imageNamed:[base stringByAppendingString:@"/cardfront.png"]];
    textColor = [UIColor colorWithRed:146/255.f green:49/255.f blue:13/255.f alpha:1.f];
  }
  
  UIView *contentView = nil;
  BOOL isSilver = card.hasCoinsGained;
  BOOL isGold = card.hasDiamondsGained;
  BOOL isEquip = card.hasEquip;
  int numValidValues = isSilver + isGold + isEquip;
  int silver = card.coinsGained;
  int gold = card.diamondsGained;
  FullEquipProto *fep = card.equip;
  int level = card.equipLevel;
  
  if (numValidValues == 3) {
    contentView = threeItemView;
    threeItemBottomLabel.text = bottomLabelText;
    
    threeItemSilverLabel.text = [Globals commafyNumber:silver];
    threeItemGoldLabel.text = [Globals commafyNumber:gold];
    threeItemEquipButton.equipId = fep.equipId;
    threeItemEquipLabel.text = fep.name;
    threeItemLevelIcon.level = level;
    
    threeItemSilverLabel.textColor = textColor;
    threeItemGoldLabel.textColor = textColor;
    threeItemEquipLabel.textColor = textColor;
  } else if (numValidValues == 2) {
    contentView = twoItemView;
    twoItemBottomLabel.text = bottomLabelText;
    
    twoItemFirstLabel.text = [Globals commafyNumber:isSilver ? silver : gold];
    twoItemSecondLabel.text = isEquip ? fep.name : [Globals commafyNumber:gold];
    twoItemFirstImageView.highlighted = isSilver;
    if (isEquip) twoItemEquipButton.equipId = fep.equipId;
    twoItemLevelIcon.level = isEquip ? level : 0;
    
    twoItemFirstLabel.textColor = textColor;
    twoItemSecondLabel.textColor = textColor;
  } else {
    if (isEquip) {
      contentView = oneItemEquipView;
      equipItemBottomLabel.text = bottomLabelText;
      
      equipItemNameLabel.text = fep.name;
      equipItemEquipButton.equipId = fep.equipId;
      equipItemLevelIcon.level = level;
      equipItemAttackIcon.highlighted = (type != MEDIUM);
      equipItemDefenseIcon.highlighted = (type != MEDIUM);
      equipItemAttackLabel.text = [Globals commafyNumber:[gl calculateAttackForEquip:fep.equipId level:level enhancePercent:0]];
      equipItemDefenseLabel.text = [Globals commafyNumber:[gl calculateDefenseForEquip:fep.equipId level:level enhancePercent:0]];
      
      equipItemNameLabel.textColor = textColor;
      equipItemAttackLabel.textColor = textColor;
      equipItemDefenseLabel.textColor = textColor;
    } else {
      contentView = oneItemCoinView;
      coinItemBottomLabel.text = bottomLabelText;
      
      coinItemImageView.highlighted = isSilver;
      coinItemLabel.text = [Globals commafyNumber:isSilver ? silver : gold];
      
      coinItemLabel.textColor = textColor;
    }
  }
  
  [self.frontView addSubview:contentView];
}

- (void) dealloc {
  self.frontView = nil;
  self.cardBackImageView = nil;
  self.cardFrontImageView = nil;
  self.threeItemView = nil;
  self.twoItemView = nil;
  self.oneItemCoinView = nil;
  self.oneItemEquipView = nil;
  self.threeItemSilverLabel = nil;
  self.threeItemGoldLabel = nil;
  self.threeItemEquipLabel = nil;
  self.threeItemEquipButton = nil;
  self.threeItemLevelIcon = nil;
  self.threeItemBottomLabel = nil;
  self.twoItemFirstLabel = nil;
  self.twoItemSecondLabel = nil;
  self.twoItemFirstImageView = nil;
  self.twoItemEquipButton = nil;
  self.twoItemLevelIcon = nil;
  self.twoItemBottomLabel = nil;
  self.equipItemAttackLabel = nil;
  self.equipItemDefenseLabel = nil;
  self.equipItemNameLabel = nil;
  self.equipItemAttackIcon = nil;
  self.equipItemDefenseIcon = nil;
  self.equipItemEquipButton = nil;
  self.equipItemLevelIcon = nil;
  self.equipItemBottomLabel = nil;
  self.coinItemLabel = nil;
  self.coinItemImageView = nil;
  self.coinItemBottomLabel = nil;
  [super dealloc];
}

@end

@implementation ThreeCardMonteViewController

@synthesize monteCardView, mainView, bgdView;
@synthesize goldLabel, cardContainerView;
@synthesize badCardView, mediumCardView, goodCardView;
@synthesize bottomButton, loadingView;
@synthesize badCard, mediumCard, goodCard;
@synthesize bottomGoldLabel, okayLabel, playView;
@synthesize winningGlow, closeButton;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ThreeCardMonteViewController)

- (id) init {
  Globals *gl = [Globals sharedGlobals];
  return [self initWithNibName:@"ThreeCardMonteViewController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.threeCardMonteNibName]];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  cardContainerView.backgroundColor = [UIColor clearColor];
  
  self.loadingView.center = bottomButton.center;
  [self.mainView addSubview:loadingView];
  
  self.playView.center = bottomButton.center;
  [self.mainView addSubview:playView];
  
  winningGlow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"popupglow.png"]];
  [self.cardContainerView addSubview:winningGlow];
  winningGlow.frame = CGRectMake(-cardContainerView.frame.origin.x, -cardContainerView.frame.origin.y, winningGlow.frame.size.width, winningGlow.frame.size.height);
  winningGlow.userInteractionEnabled = NO;
}

- (void) viewWillAppear:(BOOL)animated {
  self.mainView.center = CGPointMake(self.view.frame.size.width/2, 3.f/2.f*self.view.frame.size.height);
  self.bgdView.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    self.mainView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2.f);
    self.bgdView.alpha = 1.f;
  }];
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveThreeCardMonte];
  
  bottomGoldLabel.text = [Globals commafyNumber:[[Globals sharedGlobals] diamondCostToPlayThreeCardMonte]];
  
  self.loadingView.hidden = NO;
  self.bottomButton.enabled = NO;
  self.okayLabel.hidden = YES;
  self.playView.hidden = YES;
  
  [self positionMonteCards];
  
  _numPlays = 0;
  self.pattern = nil;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGoldLabel) name:IAP_SUCCESS_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) positionMonteCards {
  Globals *gl = [Globals sharedGlobals];
  NSString *bundleName = gl.downloadableNibConstants.threeCardMonteNibName;
  NSBundle *bundle = [Globals bundleNamed:bundleName];
  if (!badCardView) {
    [bundle loadNibNamed:@"MonteCardView" owner:self options:nil];
    self.badCardView = self.monteCardView;
    [self.cardContainerView addSubview:self.badCardView];
  }
  
  if (!mediumCardView) {
    [bundle loadNibNamed:@"MonteCardView" owner:self options:nil];
    self.mediumCardView = self.monteCardView;
    [self.cardContainerView addSubview:self.mediumCardView];
  }
  
  if (!goodCardView) {
    [bundle loadNibNamed:@"MonteCardView" owner:self options:nil];
    self.goodCardView = self.monteCardView;
    [self.cardContainerView addSubview:self.goodCardView];
  }
  
  [self disallowPicking];
  [self updateGoldLabel];
  
  winningGlow.alpha = 0.f;
  
  badCardView.transform = CGAffineTransformIdentity;
  mediumCardView.transform = CGAffineTransformIdentity;
  goodCardView.transform = CGAffineTransformIdentity;
  
  CGPoint p = badCardView.center;
  p.x = badCardView.frame.size.width/2;
  badCardView.center = p;
  
  p = mediumCardView.center;
  p.x = cardContainerView.frame.size.width/2;
  mediumCardView.center = p;
  
  p = goodCardView.center;
  p.x = cardContainerView.frame.size.width-goodCardView.frame.size.width/2;
  goodCardView.center = p;
  
  self.closeButton.enabled = YES;
}

- (void) beginShuffling {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold < gl.diamondCostToPlayThreeCardMonte) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondCostToPlayThreeCardMonte];
  } else {
    int cardId = [self calculateWinningCard];
    [[OutgoingEventController sharedOutgoingEventController] playThreeCardMonte:cardId];
    
    [self flipCardsDown:YES];
    [self performSelector:@selector(shuffleCards) withObject:nil afterDelay:FLIP_DURATION];
    [self performSelector:@selector(stopShuffling) withObject:nil afterDelay:SHUFFLE_DURATION+FLIP_DURATION];
    
    [self updateGoldLabel];
    
    self.bottomButton.enabled = NO;
    self.closeButton.enabled = NO;
    
    _numPlays++;
    self.pattern = _pattern ? [_pattern stringByAppendingFormat:@", %d", cardId] : [NSString stringWithFormat:@"%d", cardId];
  }
}

- (void) shuffleCards {
  _continueShuffling = YES;
  [UIView animateWithDuration:SHUFFLE_SPEED animations:^{
    CGRect frame = badCardView.frame;
    badCardView.frame = mediumCardView.frame;
    mediumCardView.frame = goodCardView.frame;
    goodCardView.frame = frame;
  } completion:^(BOOL finished) {
    if (_continueShuffling) {
      [self shuffleCards];
    } else {
      [self allowPicking];
    }
  }];
}

- (void) stopShuffling {
  _continueShuffling = NO;
}

- (void) allowPicking {
  _allowPicking = YES;
  
  self.okayLabel.hidden = NO;
  self.okayLabel.text = @"Choose One";
  self.playView.hidden = YES;
}

- (void) disallowPicking {
  _allowPicking = NO;
}

- (void) monteCardPicked:(MonteCardView *)mcv {
  if (!_allowPicking) {
    return;
  }
  [self disallowPicking];
  
  CGRect r = mcv.frame;
  mcv.frame = _winningCardView.frame;
  _winningCardView.frame = r;
  
  [cardContainerView bringSubviewToFront:winningGlow];
  [cardContainerView bringSubviewToFront:_winningCardView];
  
  [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
  
  // Find middle view
  MonteCardView *middleView = nil;
  float mid = cardContainerView.frame.size.width/2;
  if (badCardView.center.x < mid+5 && badCardView.center.x > mid-5) {
    middleView = badCardView;
  } else if (mediumCardView.center.x < mid+5 && mediumCardView.center.x > mid-5) {
    middleView = mediumCardView;
  } else if (goodCardView.center.x < mid+5 && goodCardView.center.x > mid-5) {
    middleView = goodCardView;
  }
  
  [_winningCardView flipFaceUp:YES];
  [UIView animateWithDuration:FLIP_DURATION animations:^{
    if (middleView != _winningCardView) {
      CGRect r = middleView.frame;
      middleView.frame = _winningCardView.frame;
      _winningCardView.frame = r;
    }
    
    _winningCardView.transform = CGAffineTransformMakeScale(CARD_SCALE, CARD_SCALE);
    
    winningGlow.alpha = 1.f;
  } completion:^(BOOL finished) {
    self.bottomButton.enabled = YES;
    self.okayLabel.hidden = NO;
    self.okayLabel.text = @"Okay";
  }];
}

- (void) flipCardsUp:(BOOL)animated {
  [self.badCardView flipFaceUp:animated];
  [self.mediumCardView flipFaceUp:animated];
  [self.goodCardView flipFaceUp:animated];
}

- (void) flipCardsDown:(BOOL)animated {
  [self.badCardView flipFaceDown:animated];
  [self.mediumCardView flipFaceDown:animated];
  [self.goodCardView flipFaceDown:animated];
}

- (int) calculateWinningCard {
  Globals *gl = [Globals sharedGlobals];
  float prize = (float)(arc4random() % 100);
  if(prize <= gl.goodMonteCardPercentageChance*100) {
    _winningCardView = goodCardView;
    return goodCard.cardId;
  }
  prize -= gl.goodMonteCardPercentageChance*100;
  if (prize <= gl.mediumMonteCardPercentageChance*100){
    _winningCardView = mediumCardView;
    return mediumCard.cardId;
  }
  _winningCardView = badCardView;
  return badCard.cardId;
}

- (void) updateGoldLabel {
  GameState *gs = [GameState sharedGameState];
  self.goldLabel.text = [Globals commafyNumber:gs.gold];
}

- (void) receivedPlayThreeCardMonteResponse:(PlayThreeCardMonteResponseProto *)proto {
  
}

- (void) receivedRetreiveThreeCardMonteResponse:(RetrieveThreeCardMonteResponseProto *)proto {
  [self.badCardView updateForCard:proto.badMonteCard type:BAD];
  [self.mediumCardView updateForCard:proto.mediumMonteCard type:MEDIUM];
  [self.goodCardView updateForCard:proto.goodMonteCard type:GOOD];
  [self flipCardsUp:YES];
  
  self.badCard = proto.badMonteCard;
  self.mediumCard =  proto.mediumMonteCard;
  self.goodCard = proto.goodMonteCard;
  
  self.loadingView.hidden = YES;
  self.bottomButton.enabled = YES;
  self.playView.hidden = NO;
  
  [Analytics threeCardMonteImpression:badCard.cardId];
}

- (IBAction)bottomButtonClicked:(id)sender {
  if (!_shouldRestart) {
    [self beginShuffling];
    _shouldRestart = YES;
  } else {
    [self flipCardsUp:YES];
    [UIView animateWithDuration:FLIP_DURATION animations:^{
      [self positionMonteCards];
    }];
    _shouldRestart = NO;
    
    self.playView.hidden = NO;
    self.okayLabel.hidden = YES;
  }
}

- (IBAction)goldClicked:(id)sender {
  [GoldShoppeViewController displayView];
}

- (IBAction)infoClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  NSString *desc = [NSString stringWithFormat:@"%d%% Good, %d%% Better, %d%% Best", (int)(gl.badMonteCardPercentageChance*100), (int)(gl.mediumMonteCardPercentageChance*100), (int)(gl.goodMonteCardPercentageChance*100)];
  [Globals popupMessage:desc];
}

- (IBAction)closeClicked:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.mainView.center = CGPointMake(self.view.frame.size.width/2, 3.f/2.f*self.view.frame.size.height);
    self.bgdView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
  }];
  
  if (_numPlays > 0) {
    [Analytics threeCardMonteConversion:badCard.cardId numPlays:_numPlays pattern:self.pattern];
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_allowPicking) {
    UITouch *touch = touches.anyObject;
    
    MonteCardView *mcv = badCardView;
    CGPoint loc = [touch locationInView:mcv];
    if ([mcv pointInside:loc withEvent:event]) {
      [self monteCardPicked:mcv];
    }
    
    mcv = mediumCardView;
    loc = [touch locationInView:mcv];
    if ([mcv pointInside:loc withEvent:event]) {
      [self monteCardPicked:mcv];
    }
    
    mcv = goodCardView;
    loc = [touch locationInView:mcv];
    if ([mcv pointInside:loc withEvent:event]) {
      [self monteCardPicked:mcv];
    }
  }
}

- (void) viewDidUnload {
  [super viewDidUnload];
  self.monteCardView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.cardContainerView = nil;
  self.badCardView = nil;
  self.mediumCardView = nil;
  self.goodCardView = nil;
  self.bottomButton = nil;
  self.loadingView = nil;
  self.badCard = nil;
  self.mediumCard = nil;
  self.goodCard = nil;
  self.okayLabel = nil;
  self.bottomGoldLabel = nil;
  self.playView = nil;
  self.winningGlow = nil;
  self.closeButton = nil;
}

@end
