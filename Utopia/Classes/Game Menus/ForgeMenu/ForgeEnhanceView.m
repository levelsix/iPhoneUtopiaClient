//
//  ForgeEnhanceView.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ForgeEnhanceView.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "ForgeMenuController.h"
#import "GenericPopupController.h"
#import "RefillMenuController.h"

@implementation ForgeEnhanceItemView

- (void) updateForUserEquip:(UserEquip *)ue {
  if (!ue) {
    [self updateForNoEquip];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  Globals *gl = [Globals sharedGlobals];
  
  [Globals loadImageForEquip:ue.equipId toView:self.equipIcon maskedView:nil];
  self.borderIcon.highlighted = YES;
  self.nameLabel.text = fep.name;
  self.nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  
  int oldAttack = [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage];
  int oldDefense = [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage];
  int newAttack = [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage+gl.enhancePercentPerLevel];
  int newDefense = [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage+gl.enhancePercentPerLevel];
  self.attackLabel.text = [NSString stringWithFormat:@"%@+%@", [Globals commafyNumber:oldAttack], [Globals commafyNumber:newAttack-oldAttack]];
  self.defenseLabel.text = [NSString stringWithFormat:@"%@+%@", [Globals commafyNumber:oldDefense], [Globals commafyNumber:newDefense-oldDefense]];
  
  self.itemChosenView.hidden = NO;
  self.itemNotChosenView.hidden = YES;
  
  self.enhanceLevelIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
  self.topProgressBar.percentage = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageToNextLevel:ue.enhancementPercentage]];
  self.bottomProgressBar.percentage = self.topProgressBar.percentage;
  
  self.userEquip = ue;
}

- (void) updateForNoEquip {
  self.topProgressBar.percentage = 0.f;
  self.bottomProgressBar.percentage = 0.f;
  
  self.borderIcon.highlighted = NO;
  
  self.itemChosenView.hidden = YES;
  self.itemNotChosenView.hidden = NO;
  
  self.userEquip = nil;
}

- (void) dealloc {
  self.equipIcon = nil;
  self.borderIcon = nil;
  self.nameLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.topProgressBar = nil;
  self.bottomProgressBar = nil;
  self.enhanceLevelIcon = nil;
  self.itemChosenView = nil;
  self.itemNotChosenView = nil;
  self.cancelButton = nil;
  [super dealloc];
}

@end

@implementation ForgeEnhanceView

- (void) reload {
  [self clearAllViewsAnimated:NO];
  
  [self reloadUserEquips];
  
  [self updateBottomView];
}

- (void) setTimer:(NSTimer *)t {
  if (_timer != t) {
    [_timer invalidate];
    [_timer release];
    _timer = [t retain];
  }
}

- (void) reloadUserEquips {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSMutableArray *mut = gs.myEquips.mutableCopy;
  
  [mut sortUsingComparator:^NSComparisonResult(UserEquip *obj1, UserEquip *obj2) {
    int stats1 = [gl calculateAttackForEquip:obj1.equipId level:obj1.level enhancePercent:obj1.enhancementPercentage] + [gl calculateDefenseForEquip:obj1.equipId level:obj1.level enhancePercent:obj1.enhancementPercentage];
    int stats2 = [gl calculateAttackForEquip:obj2.equipId level:obj2.level enhancePercent:obj2.enhancementPercentage] + [gl calculateDefenseForEquip:obj2.equipId level:obj2.level enhancePercent:obj2.enhancementPercentage];
    
    if (stats1 > stats2) {
      return NSOrderedAscending;
    } else if (stats1 < stats2) {
      return NSOrderedDescending;
    } else {
      if (obj1.enhancementPercentage > obj2.enhancementPercentage) {
        return NSOrderedAscending;
      } else if (obj1.enhancementPercentage < obj2.enhancementPercentage) {
        return NSOrderedDescending;
      }
      return NSOrderedSame;
    }
  }];
  
  if (gs.equipEnhancement) {
    UserEquip *ue = [UserEquip userEquipWithEquipEnhancementItemProto:gs.equipEnhancement.enhancingEquip];
    [mut insertObject:ue atIndex:0];
  }
  
  self.userEquips = mut;
  [self.enhanceTableView reloadData];
  
  if (gs.equipEnhancement) {
    self.enhanceTableView.allowsMultipleSelection = YES;
    [self.enhanceTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.enhanceTableView.allowsSelection = NO;
  } else {
    self.enhanceTableView.allowsMultipleSelection = YES;
  }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.userEquips.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"ForgeItemView";
  
  ForgeItemView *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    Globals *gl = [Globals sharedGlobals];
#warning change back
    NSBundle *bundle = [NSBundle mainBundle];// [Globals bundleNamed:gl.downloadableNibConstants.blacksmithNibName];
    [bundle loadNibNamed:@"ForgeItemView" owner:self options:nil];
    cell = self.itemView;
  }
  
  [cell loadForUserEquip:[self.userEquips objectAtIndex:indexPath.row]];
  
  if (self.enhancingView.userEquip) {
    [self updateCellForClickedEquip:cell];
  }
  
  return cell;
}

- (void) reloadCurrentCells {
  NSArray *cells = self.enhanceTableView.visibleCells;
  for (ForgeItemView *fiv in cells) {
    [self updateCellForClickedEquip:fiv];
  }
}

- (void) updateCellForClickedEquip:(ForgeItemView *)cell {
  GameState *gs = [GameState sharedGameState];
  UserEquip *ue = self.enhancingView.userEquip;
  if (ue && !gs.equipEnhancement && ue.userEquipId != cell.userEquip.userEquipId) {
    Globals *gl = [Globals sharedGlobals];
    cell.bottomProgressBar.percentage = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageIncrease:self.enhancingView.userEquip feeder:cell.userEquip]];
    
    cell.topProgressBar.hidden = YES;
    cell.bottomProgressBar.hidden = NO;
  } else {
    cell.topProgressBar.hidden = NO;
    cell.bottomProgressBar.hidden = YES;
  }
}

- (void) deselectAllRows {
  // Deselect all rows
  NSArray *s = [[self.enhanceTableView indexPathsForSelectedRows] copy];
  for (NSIndexPath *p in s) {
    [self.enhanceTableView deselectRowAtIndexPath:p animated:NO];
  }
}

- (void) clearAllViewsAnimated:(BOOL)animated {
  [self deselectAllRows];
  
  if (animated) {
    self.enhancingView.topProgressBar.percentage = 0.f;
    [UIView transitionWithView:self.enhancingView duration:0.3f options:UIViewAnimationOptionTransitionNone animations:^{
      [self.enhancingView updateForNoEquip];
    } completion:nil];
    
    [UIView animateWithDuration:0.3f animations:^{
      self.feederContainerView.alpha = 0.f;
    } completion:^(BOOL finished) {
      for (ForgeEnhanceItemView *v in self.feederViews) {
        [v updateForNoEquip];
      }
    }];
  } else {
    [self.enhancingView updateForNoEquip];
    self.feederContainerView.alpha = 0.f;
    for (ForgeEnhanceItemView *v in self.feederViews) {
      [v updateForNoEquip];
    }
  }
  
  [self reloadCurrentCells];
}

- (void) updateEnhancingViewYellowBar {
  NSArray *feeders = [self feederEquips];
  Globals *gl = [Globals sharedGlobals];
  UserEquip *ue = self.enhancingView.userEquip;
  float base = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageToNextLevel:ue.enhancementPercentage]];
  float increase = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageIncrease:ue feeders:feeders]];
  [UIView animateWithDuration:0.2f animations:^{
    self.enhancingView.bottomProgressBar.percentage = base+increase;
  }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.equipEnhancement) {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    return;
  }
  
  ForgeItemView *iv = (ForgeItemView *)[self.enhanceTableView cellForRowAtIndexPath:indexPath];
  UserEquip *ue = iv.userEquip;
  ForgeEnhanceItemView *finalView = nil;
  if (!self.enhancingView.userEquip) {
    if ([gl calculateEnhancementLevel:ue.enhancementPercentage] >= gl.maxEnhancementLevel) {
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
      [Globals popupMessage:@"This item can not be enhanced anymore."];
      return;
    }
    
    [UIView transitionWithView:self.enhancingView duration:0.3f options:UIViewAnimationOptionTransitionNone animations:^{
      [self.enhancingView updateForUserEquip:ue];
    } completion:nil];
    
    [UIView animateWithDuration:0.3f animations:^{
      self.feederContainerView.alpha = 1.f;
    }];
    
    finalView = self.enhancingView;
    
    [self reloadCurrentCells];
  } else {
    // Check if it is feasible to add this
    Globals *gl = [Globals sharedGlobals];
    NSMutableArray *feeders = [[[self feederEquips] mutableCopy] autorelease];
    float increaseA = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageIncrease:self.enhancingView.userEquip feeders:feeders]];
    [feeders addObject:ue];
    float increaseB = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageIncrease:self.enhancingView.userEquip feeders:feeders]];
    
    if (increaseB > increaseA) {
      BOOL foundFeederView = NO;
      for (ForgeEnhanceItemView *fv in self.feederViews) {
        if (!fv.userEquip) {
          [fv updateForUserEquip:ue];
          foundFeederView = YES;
          finalView = fv;
          break;
        }
      }
      
      [self updateEnhancingViewYellowBar];
      
      if (!foundFeederView) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
      }
    } else {
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
      [Globals popupMessage:@"You already have enough points to reach the next enhancement level."];
    }
  }
  
  // Animate the flying icon
  if (finalView) {
    UIImageView *startView = iv.equipIcon;
    UIImageView *endView = finalView.equipIcon;
    
    UIImageView *animatedIconView = [[[UIImageView alloc] init] autorelease];
    animatedIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:animatedIconView];
    
    animatedIconView.frame = [self convertRect:startView.frame fromView:startView.superview];
    animatedIconView.image = startView.image;
    finalView.equipIcon.hidden = YES;
    finalView.itemChosenView.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
      animatedIconView.frame = [self convertRect:endView.frame fromView:endView.superview];
      finalView.itemChosenView.alpha = 1.f;
    } completion:^(BOOL finished) {
      [animatedIconView removeFromSuperview];
      finalView.equipIcon.hidden = NO;
    }];
  }
  
  [self updateBottomView];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  if (gs.equipEnhancement) {
    return;
  }
  
  UserEquip *ue = [self.userEquips objectAtIndex:indexPath.row];
  
  if (ue.userEquipId == self.enhancingView.userEquip.userEquipId) {
    [self clearAllViewsAnimated:YES];
  } else {
    for (int i = 0; i < self.feederViews.count; i++) {
      ForgeEnhanceItemView *fv = [self.feederViews objectAtIndex:i];
      if (fv.userEquip.userEquipId == ue.userEquipId) {
        
        // Found it
        [self.animatedItemView updateForUserEquip:fv.userEquip];
        [fv.superview insertSubview:self.animatedItemView atIndex:0];
        self.animatedItemView.frame = fv.frame;
        self.animatedItemView.alpha = 1.f;
        
        //Calculate diff between the frames
        ForgeEnhanceItemView *a = [self.feederViews objectAtIndex:0];
        ForgeEnhanceItemView *b = [self.feederViews objectAtIndex:1];
        float diff = b.frame.origin.x-a.frame.origin.x;
        
        for (int j = i+1; j < self.feederViews.count+1; j++) {
          ForgeEnhanceItemView *fv2 = j < self.feederViews.count ? [self.feederViews objectAtIndex:j] : nil;
          if (fv2.userEquip) {
            [fv updateForUserEquip:fv2.userEquip];
          } else {
            [fv updateForNoEquip];
          }
          
          CGRect r = fv.frame;
          r.origin.x += diff;
          fv.frame = r;
          
          fv = fv2;
        }
        
        [UIView animateWithDuration:0.3f animations:^{
          self.animatedItemView.alpha = 0.f;
          
          for (int j = i; j < self.feederViews.count; j++) {
            ForgeEnhanceItemView *x = [self.feederViews objectAtIndex:j];
            
            CGRect r = x.frame;
            r.origin.x -= diff;
            x.frame = r;
          }
        } completion:^(BOOL finished) {
          [self.animatedItemView removeFromSuperview];
        }];
      }
    }
    
    [self updateEnhancingViewYellowBar];
  }
  
  [self updateBottomView];
}

- (NSString *) convertSecsToString:(int)seconds {
  int hrs = seconds / 3600;
  seconds %= 3600;
  int mins = seconds / 60;
  seconds %= 60;
  NSString *h = hrs > 0 ? [NSString stringWithFormat:@"%dh ", hrs] : @"";
  NSString *m = hrs > 0 || mins > 0 ? [NSString stringWithFormat:@"%dm ", mins] : @"";
  NSString *s = [NSString stringWithFormat:@"%ds", seconds];
  return [NSString stringWithFormat:@"%@%@%@", h, m, s];
}

- (void) updateBottomView {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.timer = nil;
  
  if (!gs.equipEnhancement) {
    NSArray *arr = [self feederEquips];
    int secs = [gl calculateMinutesToEnhance:self.enhancingView.userEquip feeders:arr]*60;
    
    [self.feederViews enumerateObjectsUsingBlock:^(ForgeEnhanceItemView *obj, NSUInteger idx, BOOL *stop) {
      obj.cancelButton.hidden = NO;
      obj.checkmarkBox.hidden = YES;
      obj.checkmark.hidden = YES;
    }];
    self.enhancingView.cancelButton.hidden = NO;
    
    if (secs > 0) {
      NSString *s = [self convertSecsToString:secs];
      // Remove the seconds from the string (last 3 characters)
      self.timeLabel.text = [s substringToIndex:s.length-3];
    } else {
      self.timeLabel.text = @"N/A";
    }
    
    self.buttonLabel.text = @"ENHANCE";
  } else {
    EquipEnhancementProto *ee = gs.equipEnhancement;
    UserEquip *ue = [UserEquip userEquipWithEquipEnhancementItemProto:ee.enhancingEquip];
    [self.enhancingView updateForUserEquip:ue];
    self.enhancingView.cancelButton.hidden = YES;
    
    for (int i = 0; i < ee.feederEquipsList.count && i < self.feederViews.count; i++) {
      EquipEnhancementItemProto *eei = [ee.feederEquipsList objectAtIndex:i];
      ue = [UserEquip userEquipWithEquipEnhancementItemProto:eei];
      ForgeEnhanceItemView *fv = [self.feederViews objectAtIndex:i];
      [fv updateForUserEquip:ue];
      fv.cancelButton.hidden = YES;
      fv.checkmarkBox.hidden = NO;
    }
    
    self.feederContainerView.alpha = 1.f;
    
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self updateLabels];
    
    [self updateEnhancingViewYellowBar];
  }
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  if (!self.enhancingView.userEquip || !gs.equipEnhancement) {
    self.timer = nil;
    return;
  }
  
  Globals *gl = [Globals sharedGlobals];
  NSArray *arr = [self feederEquips];
  UserEquip *ue = self.enhancingView.userEquip;
  int secs = [gl calculateMinutesToEnhance:self.enhancingView.userEquip feeders:arr]*60;
  
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:gs.equipEnhancement.startTime/1000.+secs];
  NSTimeInterval interval = date.timeIntervalSinceNow;
  if (interval > 0) {
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [self convertSecsToString:interval]];
    self.buttonLabel.text = @"SPEED UP";
  } else {
    self.timeLabel.text = @"Finished!";
    self.timer = nil;
    self.buttonLabel.text = @"COLLECT";
  }
  
  int timePassed = interval > 0 ? secs-interval : secs;
  float percentageOfTotal = ((float)timePassed)/secs;
  
  float base = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageToNextLevel:ue.enhancementPercentage]];
  float increase = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageIncrease:ue feeders:arr]];
  self.enhancingView.topProgressBar.percentage = base+percentageOfTotal*increase;
  
  float totalPercentIncrease = [gl calculateEnhancementPercentageIncrease:self.enhancingView.userEquip feeders:arr];
  while (1) {
    float percentOfSubSection = [gl calculateEnhancementPercentageIncrease:self.enhancingView.userEquip feeders:arr]/totalPercentIncrease;
    if (percentOfSubSection > percentageOfTotal) {
      arr = [arr subarrayWithRange:NSMakeRange(0, arr.count-1)];
    } else {
      break;
    }
  }
  int i = 0;
  for (; i < arr.count; i++) {
    ForgeEnhanceItemView *fiv = [self.feederViews objectAtIndex:i];
    if (fiv.checkmark.hidden) {
      fiv.checkmark.hidden = NO;
      [Globals bounceView:fiv.checkmark];
    }
  }
  for (; i < [self feederEquips].count; i++) {
    ForgeEnhanceItemView *fiv = [self.feederViews objectAtIndex:i];
    
    fiv.checkmark.hidden = YES;
  }
}

- (IBAction)cancelClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (gs.equipEnhancement) {
    return;
  }
  
  UIView *v = sender;
  while (![v isKindOfClass:[ForgeEnhanceItemView class]]) {
    v = v.superview;
  }
  // Pretend it was a deselect from the table
  ForgeEnhanceItemView *fv = (ForgeEnhanceItemView *)v;
  UserEquip *ue = fv.userEquip;
  if (ue) {
    int index = [self.userEquips indexOfObject:ue];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
    [self.enhanceTableView deselectRowAtIndexPath:ip animated:NO];
    [self tableView:self.enhanceTableView didDeselectRowAtIndexPath:ip];
  }
}

- (NSArray *) feederEquips {
  NSMutableArray *arr = [NSMutableArray array];
  for (ForgeEnhanceItemView *iv in self.feederViews) {
    if (iv.userEquip) {
      [arr addObject:iv.userEquip];
    }
  }
  return arr;
}

- (IBAction)redButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.equipEnhancement) {
    int enhancingId = self.enhancingView.userEquip.userEquipId;
    NSMutableArray *feederIds = [NSMutableArray array];
    for (ForgeEnhanceItemView *iv in self.feederViews) {
      if (iv.userEquip) {
        [feederIds addObject:[NSNumber numberWithInt:iv.userEquip.userEquipId]];
      }
    }
    
    if (!enhancingId) {
      [Globals popupMessage:@"You must click an item from the left to begin enhancing."];
    } else if (feederIds.count <= 0) {
      [Globals popupMessage:@"You must enhance this item with at least one other item."];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] submitEquipEnhancement:enhancingId feeders:feederIds];
      
      ForgeMenuController *fmc = [ForgeMenuController sharedForgeMenuController];
      [fmc.loadingView display:fmc.view];
    }
  } else {
    NSArray *arr = [self feederEquips];
    int secs = [gl calculateMinutesToEnhance:self.enhancingView.userEquip feeders:arr]*60;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:gs.equipEnhancement.startTime/1000.+secs];
    NSTimeInterval interval = date.timeIntervalSinceNow;
    if (interval >= 0.f) {
      int cost = [gl calculateGoldCostToSpeedUpEnhance:self.enhancingView.userEquip feeders:arr];
      
      NSString *desc = [NSString stringWithFormat:@"Would you like to speed up your enhancement for %d gold?", cost];
      [GenericPopupController displayConfirmationWithDescription:desc title:@"Speed Up Enhancement?" okayButton:@"Speed Up" cancelButton:@"Cancel" target:self selector:@selector(speedUp)];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] collectEquipEnhancement:gs.equipEnhancement.enhancementId speedup:NO gold:0];
      
      ForgeMenuController *fmc = [ForgeMenuController sharedForgeMenuController];
      [fmc.loadingView display:fmc.view];
    }
  }
}

- (void) speedUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSArray *arr = [self feederEquips];
  int cost = [gl calculateGoldCostToSpeedUpEnhance:self.enhancingView.userEquip feeders:arr];
  if (gs.gold < cost) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] collectEquipEnhancement:gs.equipEnhancement.enhancementId speedup:YES gold:cost];
    
    ForgeMenuController *fmc = [ForgeMenuController sharedForgeMenuController];
    [fmc.loadingView display:fmc.view];
  }
}

- (void) receivedSubmitEquipEnhancementResponse:(SubmitEquipEnhancementResponseProto *)proto {
  [self updateBottomView];
  [self reloadUserEquips];
  
  ForgeMenuController *fmc = [ForgeMenuController sharedForgeMenuController];
  [fmc.loadingView stop];
}

- (void) receivedCollectEquipEnhancementResponse:(CollectEquipEnhancementResponseProto *)proto {
  Globals *gl = [Globals sharedGlobals];
  [self reloadUserEquips];
  
  [UIView animateWithDuration:0.3f animations:^{
    for (ForgeEnhanceItemView *fiv in self.feederViews) {
      fiv.equipIcon.alpha = 0.f;
    }
  } completion:^(BOOL finished) {
    for (ForgeEnhanceItemView *fiv in self.feederViews) {
      [fiv updateForNoEquip];
      fiv.equipIcon.alpha = 1.f;
    }
    
    [self updateBottomView];
  }];
  
  int index = 0;
  for (int i = 0; i < self.userEquips.count; i++) {
    UserEquip *ue = [self.userEquips objectAtIndex:i];
    if (ue.userEquipId == proto.resultingEquip.userEquipId) {
      index = i;
    }
  }
  
  if (index != NSNotFound) {
    UserEquip *ue = [self.userEquips objectAtIndex:index];
    if([gl calculateEnhancementLevel:ue.enhancementPercentage] >= gl.maxEnhancementLevel) {
      [self clearAllViewsAnimated:YES];
    } else {
      [self.enhanceTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
      [self.enhancingView updateForUserEquip:ue];
      [self reloadCurrentCells];
    }
  }
  
  ForgeMenuController *fmc = [ForgeMenuController sharedForgeMenuController];
  [fmc.loadingView stop];
  [fmc.coinBar updateLabels];
}

- (IBAction)infoClicked:(id)sender {
  [GenericPopupController displayNotificationViewWithText:@"Enhancement percent is determined by an equip's attack and defense stats." title:@"Enhancement Information"];
}

- (void) dealloc {
  self.enhanceTableView = nil;
  self.itemView = nil;
  self.enhancingView = nil;
  self.feederViews = nil;
  self.movingView = nil;
  self.feederContainerView = nil;
  self.animatedItemView = nil;
  self.buttonLabel = nil;
  self.timeLabel = nil;
  self.userEquips = nil;
  self.timer = nil;
  [super dealloc];
}

@end
