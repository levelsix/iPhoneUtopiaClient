//
//  ForgeMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ForgeMenus.h"
#import "ForgeMenuController.h"

@implementation ForgeSlotTopBar

@synthesize button1, button2, button3;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
}

- (void) clickButton:(LeaderboardBarButton)button {
  switch (button) {
    case kButton1:
      button1.hidden = NO;
      _clickedButtons |= kButton1;
      break;
      
    case kButton2:
      button2.hidden = NO;
      _clickedButtons |= kButton2;
      break;
      
    case kButton3:
      button3.hidden = NO;
      _clickedButtons |= kButton3;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(LeaderboardBarButton)button {
  switch (button) {
    case kButton1:
      button1.hidden = YES;
      _clickedButtons &= ~kButton1;
      break;
      
    case kButton2:
      button2.hidden = YES;
      _clickedButtons &= ~kButton2;
      break;
      
    case kButton3:
      button3.hidden = YES;
      _clickedButtons &= ~kButton3;
      break;
      
    default:
      break;
  }
}

- (void) updateForSlotNum:(int)slotNum {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  
  switch (slotNum) {
    case 1:
      [self clickButton:kButton1];
      break;
    case 2:
      [self clickButton:kButton2];
      break;
    case 3:
      [self clickButton:kButton3];
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (!(_clickedButtons & kButton1) && [button1 pointInside:pt withEvent:nil]) {
    _trackingButton1 = YES;
    [self clickButton:kButton1];
  }
  
  pt = [touch locationInView:button3];
  if (!(_clickedButtons & kButton3) && [button3 pointInside:pt withEvent:nil]) {
    _trackingButton3 = YES;
    [self clickButton:kButton3];
  }
  
  pt = [touch locationInView:button2];
  if (!(_clickedButtons & kButton2) && [button2 pointInside:pt withEvent:nil]) {
    _trackingButton2 = YES;
    [self clickButton:kButton2];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
    } else {
      [self unclickButton:kButton2];
    }
  }
  
  pt = [touch locationInView:button3];
  if (_trackingButton3) {
    if (CGRectContainsPoint(CGRectInset(button3.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton3];
    } else {
      [self unclickButton:kButton3];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
      [self unclickButton:kButton3];
      [self unclickButton:kButton2];
      
      [[ForgeMenuController sharedForgeMenuController] setSlotNumber:1];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton3];
      [self unclickButton:kButton1];
      
      [[ForgeMenuController sharedForgeMenuController] setSlotNumber:2];
    } else {
      [self unclickButton:kButton2];
    }
  }
  
  pt = [touch locationInView:button3];
  if (_trackingButton3) {
    if (CGRectContainsPoint(CGRectInset(button3.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton3];
      [self unclickButton:kButton1];
      [self unclickButton:kButton2];
      
      [[ForgeMenuController sharedForgeMenuController] setSlotNumber:3];
    } else {
      [self unclickButton:kButton3];
    }
  }
  
  _trackingButton1 = NO;
  _trackingButton3 = NO;
  _trackingButton2 = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kButton1];
  [self unclickButton:kButton3];
  [self unclickButton:kButton2];
  _trackingButton1 = NO;
  _trackingButton3 = NO;
  _trackingButton2 = NO;
}

- (void) dealloc {
  self.button3 = nil;
  self.button2 = nil;
  self.button1 = nil;
  [super dealloc];
}

@end

@implementation ForgeItem

@synthesize equipId, level, quantity;

- (NSString *)description {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:equipId];
  return [NSString stringWithFormat:@"{%p: equip=%@, level=%d, quantity=%d, isForging=%d}", self, fep.name, level, quantity, self.isForging];
}

@end

@implementation ForgeItemView

@synthesize nameLabel, attackLabel, defenseLabel;
@synthesize quantityLabel, equipIcon, forgeItem;
@synthesize bgdImage, forgingTag, levelIcon;

- (void) awakeFromNib {
  self.enhanceView.frame = self.forgeView.frame;
  [self.forgeView.superview addSubview:self.enhanceView];
}

- (void) loadForUserEquip:(UserEquip *)ue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  
  self.nameLabel.text = fep.name;
  self.nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  [Globals loadImageForEquip:ue.equipId toView:equipIcon maskedView:nil];
  self.attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  self.defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  
  self.levelIcon.level = ue.level;
  
  if ([gl calculateEnhancementLevel:ue.enhancementPercentage] >= gl.maxEnhancementLevel) {
    self.enhanceLevelIcon.level = gl.maxEnhancementLevel;
    self.topProgressBar.percentage = 1.f;
  } else {
    self.enhanceLevelIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
    self.topProgressBar.percentage = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageToNextLevel:ue.enhancementPercentage]];
  }
  
  self.topProgressBar.hidden = NO;
  self.bottomProgressBar.hidden = YES;
  
  self.forgingTag.hidden = YES;
  self.bgdImage.highlighted = YES;
  
  self.enhanceView.hidden = NO;
  self.forgeView.hidden = YES;
  
  self.userEquip = ue;
}

- (void) loadForForgeItem:(ForgeItem *)fi {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [gs equipWithId:fi.equipId];
  
  self.forgeItem = fi;
  self.nameLabel.text = fep.name;
  self.nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  self.quantityLabel.text = [NSString stringWithFormat:@"%d", fi.quantity];
  [Globals loadImageForEquip:fi.equipId toView:equipIcon maskedView:nil];
  self.attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:fi.equipId level:fi.level enhancePercent:0]];
  self.defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:fi.equipId level:fi.level enhancePercent:0]];
  
  self.levelIcon.level = fi.level;
  
  if (fi.isForging) {
    self.forgingTag.hidden = NO;
  } else {
    self.forgingTag.hidden = YES;
  }
  
  self.enhanceView.hidden = YES;
  self.forgeView.hidden = NO;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  if (selected) {
    bgdImage.highlighted = YES;
  } else if (!self.highlighted) {
    bgdImage.highlighted = NO;
  }
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  if (highlighted) {
    bgdImage.highlighted = YES;
  } else if (!self.selected) {
    bgdImage.highlighted = NO;
  }
}

- (void) dealloc {
  self.nameLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.quantityLabel = nil;
  self.equipIcon = nil;
  self.forgeItem = nil;
  self.bgdImage = nil;
  self.forgingTag = nil;
  self.levelIcon = nil;
  self.forgeView = nil;
  self.userEquip = nil;
  self.enhanceLevelIcon = nil;
  self.enhanceView = nil;
  self.topProgressBar = nil;
  self.bottomProgressBar = nil;
  [super dealloc];
}

@end

@implementation ForgeProgressView

@synthesize timeLeftLabel, progressBar, timer;

- (void) beginAnimatingForSlot:(int)slot {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  ForgeAttempt *fa = [gs forgeAttemptForSlot:slot];
  
  int minutes = [gl calculateMinutesForForge:fa.equipId level:fa.level];
  NSDate *endDate = [fa.startTime dateByAddingTimeInterval:minutes*60.f];
  
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabel:) userInfo:endDate repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  [self updateLabel:self.timer];
  
  float timePassed = -[fa.startTime timeIntervalSinceNow];
  self.progressBar.percentage = timePassed/minutes/60.f;
  [UIView animateWithDuration:minutes*60-timePassed animations:^{
    self.progressBar.percentage = 1.f;
  }];
}

- (void) stopAnimating {
  self.timer = nil;
  [self.progressBar.layer removeAllAnimations];
}

- (void) updateLabel:(NSTimer *)t {
  NSDate *date = t.userInfo;
  NSTimeInterval interval = [date timeIntervalSinceNow];
  if (interval >= 0.f) {
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Finishes in %@", [Globals convertTimeToString:interval withDays:YES]];
  } else {
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Finishes in %@", [Globals convertTimeToString:0.f withDays:YES]];
    self.timer = nil;
  }
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

- (void) dealloc {
  self.timer = nil;
  self.timeLeftLabel = nil;
  self.progressBar = nil;
  [super dealloc];
}

@end

@implementation ForgeStatusView

@synthesize statusLabel, checkIcon, xIcon, spinner;

- (void) displayAttemptComplete {
  self.statusLabel.text = @"Attempt Complete";
  self.statusLabel.textColor = [Globals creamColor];
  self.checkIcon.hidden = NO;
  self.xIcon.hidden = YES;
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
}

- (void) displayForgeSuccess {
  self.statusLabel.text = @"Forge Succeeded";
  self.statusLabel.textColor = [Globals greenColor];
  self.checkIcon.hidden = NO;
  self.xIcon.hidden = YES;
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
}

- (void) displayForgeFailed {
  self.statusLabel.text = @"Forge Failed";
  self.statusLabel.textColor = [Globals redColor];
  self.checkIcon.hidden = YES;
  self.xIcon.hidden = NO;
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
}

- (void) displayCheckingForge {
  self.statusLabel.text = @"Checking...";
  self.statusLabel.textColor = [Globals creamColor];
  self.checkIcon.hidden = YES;
  self.xIcon.hidden = YES;
  self.spinner.hidden = NO;
  [self.spinner startAnimating];
}

- (void) dealloc {
  self.statusLabel = nil;
  self.checkIcon = nil;
  self.xIcon = nil;
  self.spinner = nil;
  [super dealloc];
}

@end