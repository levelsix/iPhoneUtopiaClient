//
//  ArmoryFeedView.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ArmoryFeedView.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"
#import "ProfileViewController.h"

@implementation ArmoryFeedDragView

- (void) awakeFromNib {
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
  [self addGestureRecognizer:tap];
  [tap release];
}

- (void) tap {
  if (_isOpen) {
    [self.feedView closeFeedAnimated:YES];
    _isOpen = NO;
  } else {
    [self.feedView openFeedAnimated:YES];
    _isOpen = YES;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  _passedThreshold = NO;
  _initialY = self.feedView.frame.origin.y;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  // Use superview's superview as basis view because it remains static
  UITouch *touch = [touches anyObject];
  UIView *view = self.feedView;
  CGPoint pt = [touch locationInView:view.superview];
  
  CGRect r = view.frame;
  
  // If moving left or staying still, we want it to default to going back
  if ((_isOpen && pt.y > _initialY+10) || (!_isOpen && pt.y < _initialY-10)) {
    _passedThreshold = YES;
  }
  
  r.origin.y = clampf(pt.y, [self.feedView minY], [self.feedView maxY]);
  view.frame = r;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  UIView *view = self.superview;
  CGPoint pt = [touch locationInView:view.superview];
  
  if (!_passedThreshold) {
    if (_isOpen) {
      [self.feedView closeFeedAnimated:YES];
      _isOpen = NO;
    } else {
      [self.feedView openFeedAnimated:YES];
      _isOpen = YES;
    }
  } else {
    float mid = self.feedView.superview.frame.size.height-self.feedView.frame.size.height/2;
    if (pt.y < mid) {
      [self.feedView openFeedAnimated:YES];
      _isOpen = YES;
    } else {
      [self.feedView closeFeedAnimated:YES];
      _isOpen = NO;
    }
  }
}

@end

@implementation ArmoryFeedCell

- (void) updateForBoosterPurchase:(RareBoosterPurchaseProto *)bp {
  self.boosterPurchase = bp;
  
  self.nameLabel.text = [Globals fullNameWithName:bp.user.name clanTag:bp.user.clan.tag];
  self.nameLabel.textColor = [Globals userTypeIsGood:bp.user.userType] ? [Globals blueColor] : [Globals redColor];
  [self.typeIcon setImage:[Globals circleImageForUser:bp.user.userType] forState:UIControlStateNormal];
  self.chestLabel.text = [NSString stringWithFormat:@"%@.", bp.booster.name];
  self.equipLabel.text = bp.equip.name;
  self.equipLabel.textColor = [Globals colorForRarity:bp.equip.rarity];
  self.equipIcon.equipId = bp.equip.equipId;
  self.timeLabel.text = [Globals stringForTimeSinceNow:[NSDate dateWithTimeIntervalSince1970:bp.timeOfPurchase/1000.] shortened:YES];
  
  NSString *base = [[[Globals stringForRarity:bp.equip.rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  NSString *bgdFile = [base stringByAppendingString:@"mini.png"];
  [Globals imageNamed:bgdFile withView:self.equipBgdButton maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  CGSize s;
  CGRect r;
  
  s = [self.nameLabel.text sizeWithFont:self.nameLabel.font];
  r = self.nameLabel.frame;
  r.size.width = s.width;
  self.nameLabel.frame = r;
  
  s = [self.leftMiddleLabel.text sizeWithFont:self.leftMiddleLabel.font];
  r = self.leftMiddleLabel.frame;
  r.origin.x = CGRectGetMaxX(self.nameLabel.frame)+2;
  r.size.width = s.width;
  self.leftMiddleLabel.frame = r;
  
  s = [self.equipLabel.text sizeWithFont:self.equipLabel.font];
  r = self.equipLabel.frame;
  r.origin.x = CGRectGetMaxX(self.leftMiddleLabel.frame)+2;
  r.size.width = s.width;
  self.equipLabel.frame = r;
  
  s = [self.rightMiddleLabel.text sizeWithFont:self.rightMiddleLabel.font];
  r = self.rightMiddleLabel.frame;
  r.origin.x = CGRectGetMaxX(self.equipLabel.frame)+2;
  r.size.width = s.width;
  self.rightMiddleLabel.frame = r;
  
  s = [self.chestLabel.text sizeWithFont:self.chestLabel.font];
  r = self.chestLabel.frame;
  r.origin.x = CGRectGetMaxX(self.rightMiddleLabel.frame)+2;
  r.size.width = s.width;
  self.chestLabel.frame = r;
}

- (IBAction)profileClicked:(id)sender {
  [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:self.boosterPurchase.user withState:kProfileState];
  [ProfileViewController displayView];
}

- (void) dealloc {
  self.boosterPurchase = nil;
  self.typeIcon = nil;
  self.nameLabel = nil;
  self.leftMiddleLabel = nil;
  self.chestLabel = nil;
  self.rightMiddleLabel = nil;
  self.equipLabel = nil;
  self.timeLabel = nil;
  self.equipBgdButton = nil;
  self.equipIcon = nil;
  [super dealloc];
}

@end

@implementation ArmoryFeedLineView

- (void) updateForBoosterPurchase:(RareBoosterPurchaseProto *)bp {
  self.nameLabel.text = [Globals fullNameWithName:bp.user.name clanTag:bp.user.clan.tag];
  self.nameLabel.textColor = [Globals userTypeIsGood:bp.user.userType] ? [Globals blueColor] : [Globals redColor];
  self.chestLabel.text = [NSString stringWithFormat:@"%@.", bp.booster.name];
  self.equipLabel.text = bp.equip.name;
  self.equipLabel.textColor = [Globals colorForRarity:bp.equip.rarity];
  self.timeLabel.text = [Globals stringForTimeSinceNow:[NSDate dateWithTimeIntervalSince1970:bp.timeOfPurchase/1000.] shortened:YES];
  
  CGSize s;
  CGRect r;
  
  s = [self.nameLabel.text sizeWithFont:self.nameLabel.font];
  r = self.nameLabel.frame;
  r.size.width = s.width;
  self.nameLabel.frame = r;
  
  s = [self.leftMiddleLabel.text sizeWithFont:self.leftMiddleLabel.font];
  r = self.leftMiddleLabel.frame;
  r.origin.x = CGRectGetMaxX(self.nameLabel.frame)+2;
  r.size.width = s.width;
  self.leftMiddleLabel.frame = r;
  
  s = [self.equipLabel.text sizeWithFont:self.equipLabel.font];
  r = self.equipLabel.frame;
  r.origin.x = CGRectGetMaxX(self.leftMiddleLabel.frame)+2;
  r.size.width = s.width;
  self.equipLabel.frame = r;
  
  s = [self.rightMiddleLabel.text sizeWithFont:self.rightMiddleLabel.font];
  r = self.rightMiddleLabel.frame;
  r.origin.x = CGRectGetMaxX(self.equipLabel.frame)+2;
  r.size.width = s.width;
  self.rightMiddleLabel.frame = r;
  
  s = [self.chestLabel.text sizeWithFont:self.chestLabel.font];
  r = self.chestLabel.frame;
  r.origin.x = CGRectGetMaxX(self.rightMiddleLabel.frame)+2;
  r.size.width = s.width;
  self.chestLabel.frame = r;
}


- (void) dealloc {
  self.nameLabel = nil;
  self.leftMiddleLabel = nil;
  self.chestLabel = nil;
  self.rightMiddleLabel = nil;
  self.equipLabel = nil;
  self.timeLabel = nil;
  [super dealloc];
}

@end

@implementation ArmoryFeedView

- (void) awakeFromNib {
  CGRect r = self.curLineView.frame;
  r.size.width = self.closedClearView.frame.size.width;
  r.origin.y = CGRectGetMaxY(self.closedClearView.frame)-r.size.height;
  self.curLineView.frame = r;
  
  self.bgdLineView.frame = self.curLineView.frame;
  [self insertSubview:self.curLineView belowSubview:self.closedClearView];
  [self insertSubview:self.bgdLineView belowSubview:self.closedClearView];
  self.bgdLineView.alpha = 0.f;
  self.curLineView.alpha = 0.f;
  self.feedTable.alpha = 0.f;
}

- (float) minY {
  return self.superview.frame.size.height-self.frame.size.height;
}

- (float) maxY {
  return self.superview.frame.size.height-self.closedClearView.frame.size.height;
}

- (float) changeFrameToY:(float)y animated:(BOOL)animated {
  __block CGRect r = self.frame;
  void (^anim)(void) = ^{
    r.origin.y = y;
    self.frame = r;
  };
  
  float time = 0.f;
  if (animated) {
    time = abs(self.frame.origin.y-y)/500.f;
    [UIView animateWithDuration:time delay:0.f options:UIViewAnimationCurveEaseInOut animations:anim completion:nil];
  } else {
    anim();
  }
  return time;
}

- (void) openFeedAnimated:(BOOL)animated {
  float time = [self changeFrameToY:[self minY] animated:animated];
  
  [UIView animateWithDuration:MAX(time, 0.2f) delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
    self.curLineView.alpha = 0.f;
    self.feedTable.alpha = 1.f;
  } completion:nil];
}

- (void) closeFeedAnimated:(BOOL)animated {
  float time = [self changeFrameToY:[self maxY] animated:animated];
  
  GameState *gs = [GameState sharedGameState];
  if (gs.boosterPurchases.count > 0) {
    [self.curLineView updateForBoosterPurchase:[gs.boosterPurchases objectAtIndex:0]];
    [UIView animateWithDuration:MAX(time, 0.2f) delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
      self.curLineView.alpha = 1.f;
      self.feedTable.alpha = 0.f;
    } completion:nil];
  }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  return gs.boosterPurchases.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  ArmoryFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArmoryFeedCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ArmoryFeedCell" owner:self options:nil];
    cell = self.feedCell;
  }
  
  [cell updateForBoosterPurchase:[gs.boosterPurchases objectAtIndex:indexPath.row]];
  
  return cell;
}

- (void) addedBoosterPurchase {
  NSArray *ips = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
  [self.feedTable insertRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationTop];
  
  GameState *gs = [GameState sharedGameState];
  [self.bgdLineView updateForBoosterPurchase:[gs.boosterPurchases objectAtIndex:0]];
  ArmoryFeedLineView *l = self.bgdLineView;
  self.bgdLineView = self.curLineView;
  self.curLineView = l;
  
  if (self.feedTable.alpha == 0.f) {
    [UIView animateWithDuration:0.3f animations:^{
      self.bgdLineView.alpha = 0.f;
      self.curLineView.alpha = 1.f;
    }];
  }
}

- (void) dealloc {
  self.closedClearView = nil;
  self.feedTable = nil;
  self.feedCell = nil;
  self.curLineView = nil;
  self.bgdLineView = nil;
  [super dealloc];
}

@end
