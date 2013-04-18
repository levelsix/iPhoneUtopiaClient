//
//  BattleMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattleMenus.h"
#import "GameState.h"
#import "Globals.h"
#import "DialogMenuController.h"

@implementation BattleSummaryEquipView

@synthesize rarityLabel, equipIcon, equipLevelIcon;
@synthesize enhanceLevelIcon, bgdIcon;

- (void) updateForUserEquip:(UserEquip *)ue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSString *fileEnd = @"mini.png";
  NSString *emptyFile = @"dottedmini.png";
  
  if ([ue isKindOfClass:[UserEquip class]]) {
    FullEquipProto *fep = [gs equipWithId:ue.equipId];
    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
    equipIcon.equipId = fep.equipId;
    equipIcon.level = ue.level;
    equipIcon.enhancePercent = ue.enhancementPercentage;
    equipLevelIcon.level = ue.level;
    enhanceLevelIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
    
    NSString *base = [[[Globals stringForRarity:fep.rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    NSString *bgdFile = [base stringByAppendingString:fileEnd];
    [Globals imageNamed:bgdFile withView:bgdIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  } else {
    rarityLabel.text = @"";
    equipIcon.equipId = 0;
    enhanceLevelIcon.level = 0;
    enhanceLevelIcon.level = 0;
    [Globals imageNamed:emptyFile withView:bgdIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  }
}

- (void) dealloc {
  self.rarityLabel = nil;
  self.equipIcon = nil;
  self.equipLevelIcon = nil;
  self.enhanceLevelIcon = nil;
  self.bgdIcon = nil;
  [super dealloc];
}

@end

@implementation BattleTutorialView

- (void) displayInitialViewWithSummaryView:(BattleSummaryView *)summaryView andAnalysisView:(BattleAnalysisView *)analysisView {
  GameState *gs = [GameState sharedGameState];
  
  CGPoint oldCenter = self.speechBubble.center;
  self.alpha = 0.f;
  self.buttonView.hidden = YES;
  self.speechBubble.center = CGPointMake(oldCenter.x-(1.f-SPEECH_BUBBLE_SCALE)/2.f*self.speechBubble.frame.size.width, oldCenter.y);
  self.speechBubble.transform = CGAffineTransformMakeScale(SPEECH_BUBBLE_SCALE, SPEECH_BUBBLE_SCALE);
  [UIView animateWithDuration:0.3f animations:^{
    self.alpha = 1.f;
    self.speechBubble.center = oldCenter;
    self.speechBubble.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    self.buttonView.hidden = NO;
    [Globals bounceView:self.buttonView];
  }];
  
  self.speechLabel.text = @"Losing your first battle is tough. Your weapons aren't good enough!";
  self.buttonLabel.text = @"OK, WHAT DO I DO?";
  
  self.girlImageView.image = [Globals imageNamed:[Globals userTypeIsGood:gs.type] ? @"rubyspeech.png" : @"adrianaspeech.png"];
  
  self.summaryView = summaryView;
  self.analysisView = analysisView;
}

- (void) displayGoToAnalysisView {
  [self addSubview:self.summaryView.analysisButtonView];
  self.buttonView.hidden = YES;
  
  self.speechLabel.text = @"Check out the battle analysis to see how you could improve!";
  
  UIImageView *arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [self addSubview:arrow];
  arrow.tag = 5;
  arrow.center = ccpAdd(self.summaryView.analysisButtonView.center, ccp(0, -25));
  [Globals animateUIArrow:arrow atAngle:-M_PI_2];
  
  [self.summaryView.analysisButton addTarget:self action:@selector(analysisClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.analysisView performTutorialPhase];
}

- (IBAction)buttonClicked:(id)sender {
  [self displayGoToAnalysisView];
}

- (void)analysisClicked:(id)sender {
  // This will send a message to both the battle layer as well as this.
  [UIView animateWithDuration:0.3f animations:^{
    self.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.summaryView.mainView addSubview:self.summaryView.analysisButtonView];
    [self.summaryView.analysisButton removeTarget:self action:@selector(analysisClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[self viewWithTag:5] removeFromSuperview];
    
    self.summaryView = nil;
    self.analysisView = nil;
    
    [self removeFromSuperview];
  }];
}

- (void) dealloc {
  self.speechBubble = nil;
  self.speechLabel = nil;
  self.girlImageView = nil;
  self.buttonLabel = nil;
  self.buttonView = nil;
  self.summaryView = nil;
  [super dealloc];
}

@end

@implementation BattleAnalysisView

- (void) getBarSizesForEnemy:(FullUserProto *)enemy withArray:(float *)arr {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  const int arrSize = 3;
  UserEquip *myEqs[arrSize] = {[gs myEquipWithUserEquipId:gs.weaponEquipped], [gs myEquipWithUserEquipId:gs.armorEquipped], [gs myEquipWithUserEquipId:gs.amuletEquipped]};
  UserEquip *myEqs2[arrSize] = {[gs myEquipWithUserEquipId:gs.weaponEquipped2], [gs myEquipWithUserEquipId:gs.armorEquipped2], [gs myEquipWithUserEquipId:gs.amuletEquipped2]};
  FullUserEquipProto *enEqs[arrSize] = {enemy.weaponEquippedUserEquip, enemy.armorEquippedUserEquip, enemy.amuletEquippedUserEquip};
  FullUserEquipProto *enEqs2[arrSize] = {enemy.weaponTwoEquippedUserEquip, enemy.armorTwoEquippedUserEquip, enemy.amuletTwoEquippedUserEquip};
  
  for (int i = 0; i < arrSize; i++) {
    UserEquip *ue = myEqs[i];
    UserEquip *ue2 = myEqs2[i];
    FullUserEquipProto *fuep = enEqs[i];
    FullUserEquipProto *fuep2 = enEqs2[i];
    
    float myStats1 = [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage] + [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage];
    float myStats2 = [gl calculateAttackForEquip:ue2.equipId level:ue2.level enhancePercent:ue2.enhancementPercentage] + [gl calculateDefenseForEquip:ue2.equipId level:ue2.level enhancePercent:ue2.enhancementPercentage];
    float enStats1 = [gl calculateAttackForEquip:fuep.equipId level:fuep.level enhancePercent:fuep.enhancementPercentage] + [gl calculateDefenseForEquip:fuep.equipId level:fuep.level enhancePercent:fuep.enhancementPercentage];
    float enStats2 = [gl calculateAttackForEquip:fuep2.equipId level:fuep2.level enhancePercent:fuep2.enhancementPercentage] + [gl calculateDefenseForEquip:fuep2.equipId level:fuep2.level enhancePercent:fuep2.enhancementPercentage];
    float myStats = myStats1 + myStats2;
    float enStats = enStats1 + enStats2;
    
    if (myStats == 0 && enStats == 0) {
      arr[2*i] = 0.f;
      arr[2*i+1] = 0.f;
    } else if (myStats > enStats) {
      arr[2*i] = 1.f;
      arr[2*i+1] = enStats / myStats;
    } else {
      arr[2*i] = myStats / enStats;
      arr[2*i+1] = 1.f;
    }
  }
}

- (void) loadSpeechBubbleLabelsForEnemy:(FullUserProto *)enemy {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.speechGirlImage.image = [Globals imageNamed:[Globals userTypeIsGood:gs.type] ? @"rubyspeech.png" : @"adrianaspeech.png"];
  
  float myTotalStats = [gl calculateAttackForAttackStat:gs.attack weapon:[gs myEquipWithUserEquipId:gs.weaponEquipped] armor:[gs myEquipWithUserEquipId:gs.armorEquipped] amulet:[gs myEquipWithUserEquipId:gs.amuletEquipped]];
  myTotalStats += [gl calculateDefenseForDefenseStat:gs.attack weapon:[gs myEquipWithUserEquipId:gs.weaponEquipped] armor:[gs myEquipWithUserEquipId:gs.armorEquipped] amulet:[gs myEquipWithUserEquipId:gs.amuletEquipped]];
  float enTotalStats = [gl calculateAttackForAttackStat:enemy.attack weapon:(UserEquip *)enemy.weaponEquippedUserEquip armor:(UserEquip *)enemy.armorEquippedUserEquip amulet:(UserEquip *)enemy.amuletEquippedUserEquip];
  enTotalStats += [gl calculateDefenseForDefenseStat:enemy.attack weapon:(UserEquip *)enemy.weaponEquippedUserEquip armor:(UserEquip *)enemy.armorEquippedUserEquip amulet:(UserEquip *)enemy.amuletEquippedUserEquip];
  if (myTotalStats > enTotalStats) {
    self.topLabel2.text = [NSString stringWithFormat:@" %d%% Stronger", (int)ceilf((1.f-enTotalStats/myTotalStats)*100.f)];
    self.topLabel2.textColor = [Globals greenColor];
    self.topLabel3.text = [NSString stringWithFormat:@" than %@.", enemy.name];
  } else if (myTotalStats < enTotalStats) {
    self.topLabel2.text = [NSString stringWithFormat:@" %d%% Weaker", (int)ceilf((1.f-myTotalStats/enTotalStats)*100.f)];
    self.topLabel2.textColor = [Globals redColor];
    self.topLabel3.text = [NSString stringWithFormat:@" than %@.", enemy.name];
  } else {
    self.topLabel2.text = @" even";
    self.topLabel2.textColor = [Globals creamColor];
    self.topLabel3.text = [NSString stringWithFormat:@" with %@.", enemy.name];
  }
  
  BoosterPackProto *bp = nil;
  for (BoosterPackProto *bpp in gs.boosterPacks) {
    if (_isForTutorial) {
      if (bpp.isStarterPack) {
        bp = bpp;
      }
    } else {
      if (!bpp.costsCoins && bpp.minLevel > bp.minLevel && bpp.minLevel <= gs.level) {
        bp = bpp;
      }
    }
  }
  self.botLabel2.text = [NSString stringWithFormat:@" %@", bp.name];
  
  CGRect r;
  CGSize s;
  UILabel *l;
  
  l = self.topLabel1;
  s = [l.text sizeWithFont:l.font];
  r = l.frame;
  r.size.width = s.width;
  l.frame = r;
  
  l = self.topLabel2;
  s = [l.text sizeWithFont:l.font];
  r = l.frame;
  r.origin.x = CGRectGetMaxX(self.topLabel1.frame);
  r.size.width = s.width;
  l.frame = r;
  
  l = self.topLabel3;
  s = [l.text sizeWithFont:l.font];
  r = l.frame;
  r.origin.x = CGRectGetMaxX(self.topLabel2.frame);
  r.size.width = s.width;
  l.frame = r;
  
  l = self.botLabel1;
  s = [l.text sizeWithFont:l.font];
  r = l.frame;
  r.size.width = s.width;
  l.frame = r;
  
  l = self.botLabel2;
  s = [l.text sizeWithFont:l.font];
  r = l.frame;
  r.origin.x = CGRectGetMaxX(self.botLabel1.frame);
  r.size.width = s.width;
  l.frame = r;
  
  l = self.botLabel3;
  s = [l.text sizeWithFont:l.font];
  r = l.frame;
  r.origin.x = CGRectGetMaxX(self.botLabel2.frame);
  r.size.width = s.width;
  l.frame = r;
  
  [Globals adjustViewForCentering:self.topLabelView withLabel:self.topLabel3];
  [Globals adjustViewForCentering:self.botLabelView withLabel:self.botLabel3];
}

- (void) loadForEnemy:(FullUserProto *)enemy {
  const int arrSize = 6;
  UIImageView *bars[arrSize] = {self.leftBar1, self.rightBar1, self.leftBar2, self.rightBar2, self.leftBar3, self.rightBar3};
  UILabel *labels[arrSize/2] = {self.weaponLabel, self.armorLabel, self.amuletLabel};
  
  float barSizes[6];
  [self getBarSizesForEnemy:enemy withArray:barSizes];
  
  for (int i = 0; i < arrSize; i++) {
    UIImageView *bar = bars[i];
    
    CGRect r = bar.frame;
    r.origin.y = CGRectGetMaxY(r);
    r.size.height = 0;
    bar.frame = r;
    
    int regHeight = bar.image.size.height;
    int newHeight = regHeight*barSizes[i];
    
    // If it is even, fill in the label as well
    UILabel *label = nil;
    if (i % 2 == 0) {
      label = labels[i/2];
      float mySize = barSizes[i];
      float enSize = barSizes[i+1];
      
      if (mySize > enSize) {
        label.text = [NSString stringWithFormat:@"%d%% Stronger", (int)ceilf((1.f-enSize/mySize)*100.f)];
        label.textColor = [Globals greenColor];
      } else if (mySize < enSize) {
        label.text = [NSString stringWithFormat:@"%d%% Weaker", (int)ceilf((1.f-mySize/enSize)*100.f)];
        label.textColor = [Globals redColor];
      } else {
        label.text = @"Even";
        label.textColor = [Globals creamColor];
      }
      
      label.alpha = 0.f;
    }
    
    [UIView animateWithDuration:0.35f delay:i*0.35f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      CGRect r = bar.frame;
      r.origin.y = CGRectGetMaxY(r)-newHeight;
      r.size.height = newHeight;
      bar.frame = r;
    } completion:nil];
    
    if (label) {
      float delay = 2.1f+(i/2)*0.3f;
      [UIView animateWithDuration:0.2f delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        label.alpha = 1.f;
      } completion:nil];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [Globals bounceView:label];
      });
    }
  }
  
  [self loadSpeechBubbleLabelsForEnemy:enemy];
  
  // Alpha will only start at 0 if it is not already there
  CGPoint oldCenter = self.speechBubble.center;
  self.speechView.alpha = 0.f;
  self.speechBubble.center = CGPointMake(oldCenter.x-(1.f-SPEECH_BUBBLE_SCALE)/2.f*self.speechBubble.frame.size.width, oldCenter.y);
  self.speechBubble.transform = CGAffineTransformMakeScale(SPEECH_BUBBLE_SCALE, SPEECH_BUBBLE_SCALE);
  self.topLabelView.alpha = 0.f;
  self.botLabelView.alpha = 0.f;
  self.buttonView.alpha = 0.f;
  [UIView animateWithDuration:SPEECH_BUBBLE_ANIMATION_DURATION delay:3.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.speechView.alpha = 1.f;
    self.speechBubble.center = oldCenter;
    self.speechBubble.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2f delay:0.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.topLabelView.alpha = 1.f;
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.2f delay:0.4f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.botLabelView.alpha = 1.f;
      } completion:^(BOOL finished) {
        self.buttonView.alpha = 1.f;
        [Globals bounceView:self.buttonView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
          if (_isForTutorial) {
            _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
            [self addSubview:_arrow];
            _arrow.center = ccpAdd(self.buttonView.center, ccp(self.buttonView.frame.size.width/2+_arrow.frame.size.width/2, 0));
            [Globals animateUIArrow:_arrow atAngle:M_PI];
          }
        });
      }];
    }];
  }];
}

- (IBAction)closeClicked:(id)sender {
  if (_arrow) {
    [_arrow removeFromSuperview];
  }
  
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

- (void) performTutorialPhase {
  self.closeButton.hidden = YES;
  self.buttonLabel.text = @"SHOW ME HOW »";
  
  _isForTutorial = YES;
}

- (void) endTutorialPhase {
  self.closeButton.hidden = NO;
  self.buttonLabel.text = @"VIEW CHEST IN ARMORY »";
  _isForTutorial = NO;
}

- (void) dealloc {
  self.leftBar1 = nil;
  self.leftBar2 = nil;
  self.leftBar3 = nil;
  self.rightBar1 = nil;
  self.rightBar2 = nil;
  self.rightBar3 = nil;
  self.topLabel1 = nil;
  self.topLabel2 = nil;
  self.topLabel3 = nil;
  self.topLabelView = nil;
  self.botLabel1 = nil;
  self.botLabel2 = nil;
  self.botLabel3 = nil;
  self.botLabelView = nil;
  self.weaponLabel = nil;
  self.armorLabel = nil;
  self.amuletLabel = nil;
  self.speechBubble = nil;
  self.speechView = nil;
  self.speechGirlImage = nil;
  self.mainView = nil;
  self.bgdView = nil;
  [_arrow release];
  [super dealloc];
}

@end

@implementation BattleSummaryView

@synthesize leftNameLabel, leftLevelLabel, leftPlayerIcon, leftAttackLabel, leftDefenseLabel, leftBgdImage, leftCircleIcon;
@synthesize rightNameLabel, rightLevelLabel, rightPlayerIcon, rightAttackLabel, rightDefenseLabel, rightBgdImage, rightCircleIcon;
@synthesize coinsGainedLabel, coinsLostLabel, expGainedLabel, titleImage;
@synthesize winLabelsView, defeatLabelsView;
@synthesize mainView, bgdView;

- (void) awakeFromNib {
  [self setUpEquipViews];
}

- (void) setUpEquipViews {
  NSArray *scrollViews = [NSArray arrayWithObjects:self.leftScrollView, self.rightScrollView, nil];
  NSArray *equipViewArrays = [NSArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], nil];
  
  for (int i = 0; i < 2; i++) {
    UIScrollView *scrollView = [scrollViews objectAtIndex:i];
    NSMutableArray *equipViews = [equipViewArrays objectAtIndex:i];
    
    float baseX = scrollView.frame.size.width/6.f;
    float baseY = scrollView.frame.size.height/2.f;
    int i;
    for (i = 0; i < 6; i++) {
      [[NSBundle mainBundle] loadNibNamed:@"BattleSummaryEquipView" owner:self options:nil];
      BattleSummaryEquipView *ev = self.equipView;
      ev.center = ccp(baseX*(2*i+1), baseY);
      [scrollView addSubview:ev];
      [equipViews addObject:ev];
    }
    scrollView.contentSize = CGSizeMake(baseX*(2*i), scrollView.frame.size.height);
  }
  
  self.leftEquipViews = [equipViewArrays objectAtIndex:0];
  self.rightEquipViews = [equipViewArrays objectAtIndex:1];
}

- (void) loadBattleSummaryForBattleResponse:(BattleResponseProto *)brp enemy:(FullUserProto *)fup {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSString *myPrefix = [Globals userTypeIsGood:gs.type] ? @"alliance" : @"legion";
  NSString *enemyPrefix = [Globals userTypeIsGood:fup.userType] ? @"alliance" : @"legion";
  
  [leftNameLabel setTitle:gs.name forState:UIControlStateNormal];
  leftLevelLabel.text = [NSString stringWithFormat:@"Lvl %d", gs.level];
  [leftPlayerIcon setImage:[Globals circleImageForUser:gs.type] forState:UIControlStateNormal];
  leftAttackLabel.text = [Globals commafyNumber:[gl calculateAttackForAttackStat:gs.attack weapon:[gs myEquipWithUserEquipId:gs.weaponEquipped] armor:[gs myEquipWithUserEquipId:gs.armorEquipped] amulet:[gs myEquipWithUserEquipId:gs.amuletEquipped]]];
  leftDefenseLabel.text = [Globals commafyNumber:[gl calculateDefenseForDefenseStat:gs.attack weapon:[gs myEquipWithUserEquipId:gs.weaponEquipped] armor:[gs myEquipWithUserEquipId:gs.armorEquipped] amulet:[gs myEquipWithUserEquipId:gs.amuletEquipped]]];
  [Globals imageNamed:[myPrefix stringByAppendingString:@"bg.png"] withView:leftBgdImage maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:[myPrefix stringByAppendingString:@"circle.png"] withView:leftCircleIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  [rightNameLabel setTitle:fup.name forState:UIControlStateNormal];
  rightLevelLabel.text = [NSString stringWithFormat:@"Lvl %d", fup.level];
  [rightPlayerIcon setImage:[Globals circleImageForUser:fup.userType] forState:UIControlStateNormal];
  rightAttackLabel.text = [Globals commafyNumber:[gl calculateAttackForAttackStat:fup.attack weapon:(UserEquip *)fup.weaponEquippedUserEquip armor:(UserEquip *)fup.armorEquippedUserEquip amulet:(UserEquip *)fup.amuletEquippedUserEquip]];
  rightDefenseLabel.text = [Globals commafyNumber:[gl calculateDefenseForDefenseStat:fup.attack weapon:(UserEquip *)fup.weaponEquippedUserEquip armor:(UserEquip *)fup.armorEquippedUserEquip amulet:(UserEquip *)fup.amuletEquippedUserEquip]];
  [Globals imageNamed:[enemyPrefix stringByAppendingString:@"bg.png"] withView:rightBgdImage maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:[enemyPrefix stringByAppendingString:@"circle.png"] withView:rightCircleIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSArray *equips = [gs getUserEquipArray];
  NSArray *equipViews = self.leftEquipViews;
  for (int i = 0; i < equips.count; i++) {
    UserEquip *ue = [equips objectAtIndex:i];
    BattleSummaryEquipView *ev = [equipViews objectAtIndex:i];
    
    [ev updateForUserEquip:ue];
  }
  
  equips = [Globals getUserEquipArrayFromFullUserProto:fup];
  equipViews = self.rightEquipViews;
  for (int i = 0; i < equips.count; i++) {
    UserEquip *ue = [equips objectAtIndex:i];
    BattleSummaryEquipView *ev = [equipViews objectAtIndex:i];
    
    [ev updateForUserEquip:ue];
  }
  
  if (brp.hasExpGained) {
    // This is a win
    winLabelsView.hidden = NO;
    defeatLabelsView.hidden = YES;
    coinsGainedLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:brp.coinsGained]];
    expGainedLabel.text = [NSString stringWithFormat:@"%@ Exp.", [Globals commafyNumber:brp.expGained]];
    [Globals imageNamed:@"youwonthebatt.png" withView:titleImage maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  } else {
    winLabelsView.hidden = YES;
    defeatLabelsView.hidden = NO;
    // Coins gained is the loss amount
    coinsLostLabel.text = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:brp.coinsGained]];
    [Globals imageNamed:@"youlostthebatt.png" withView:titleImage maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  }
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

- (void) dealloc {
  self.leftNameLabel = nil;
  self.leftLevelLabel = nil;
  self.leftPlayerIcon = nil;
  self.leftAttackLabel = nil;
  self.leftDefenseLabel = nil;
  self.rightNameLabel = nil;
  self.rightLevelLabel = nil;
  self.rightPlayerIcon = nil;
  self.rightAttackLabel = nil;
  self.rightDefenseLabel = nil;
  self.leftScrollView = nil;
  self.rightScrollView = nil;
  self.equipView = nil;
  self.leftEquipViews = nil;
  self.rightEquipViews = nil;
  self.coinsGainedLabel = nil;
  self.coinsLostLabel = nil;
  self.expGainedLabel = nil;
  self.winLabelsView = nil;
  self.defeatLabelsView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.titleImage = nil;
  [super dealloc];
}

@end

@implementation StolenEquipView

@synthesize nameLabel, equipIcon, attackLabel, defenseLabel, titleLabel, levelIcon;
@synthesize mainView, bgdView, statsView;

- (void) loadForEquip:(FullUserEquipProto *)fuep {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [gs equipWithId:fuep.equipId];
  nameLabel.text = fep.name;
  nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  equipIcon.equipId = fep.equipId;
  attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:fuep.equipId level:fuep.level enhancePercent:fuep.enhancementPercentage]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:fuep.equipId level:fuep.level enhancePercent:fuep.enhancementPercentage]];
  levelIcon.level = fuep.level;
  self.enhanceIcon.level = [gl calculateEnhancementLevel:fuep.enhancementPercentage];
  
  statsView.hidden = NO;
  levelIcon.hidden = NO;
  self.enhanceIcon.hidden = NO;
}

- (void) loadForLockBox:(int)eventId {
  GameState *gs = [GameState sharedGameState];
  LockBoxEventProto *e = [gs lockBoxEventWithId:eventId];
  titleLabel.text = @"Lock Box Found!";
  nameLabel.text = @"Lock Box";
  nameLabel.textColor = [Globals goldColor];
  equipIcon.equipId = 0;
  [Globals imageNamed:e.lockBoxImageName withView:equipIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  statsView.hidden = YES;
  levelIcon.hidden = YES;
  self.enhanceIcon.hidden = YES;
}

- (void) dealloc {
  self.nameLabel = nil;
  self.equipIcon = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.levelIcon = nil;
  self.enhanceIcon = nil;
  self.statsView = nil;
  [super dealloc];
}

@end