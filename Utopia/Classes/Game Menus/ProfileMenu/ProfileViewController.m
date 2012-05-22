//
//  ProfileViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfileViewController.h"
#import "SynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "BattleLayer.h"
#import "GenericPopupController.h"

#define EQUIPS_VERTICAL_SEPARATION 3.f
#define EQUIPS_HORIZONTAL_SEPARATION 1.f

#define SHAKE_DURATION 0.2f
#define SHAKE_OFFSET 3.f

#define EQUIPPING_DURATION 0.5f

#define WALL_POST_LABEL_MIN_Y 28.75
#define WALL_POST_CELL_OFFSET 5
#define WALL_POST_FONT [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:15]
#define WALL_POST_LABEL_WIDTH 217

#define PRICE_DIGITS 7

@implementation ProfileBar

@synthesize state = _state;
@synthesize equipIcon, skillsIcon, wallIcon;
@synthesize equipLabel, skillsLabel, wallLabel;
@synthesize equipSelectedLargeImage, equipSelectedSmallImage, skillsSelectedSmallImage;
@synthesize wallSelectedSmallImage, wallSelectedLargeImage;
@synthesize glowIcon;

- (void) awakeFromNib {
  wallSelectedLargeImage.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
  wallSelectedSmallImage.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
  
  _clickedButtons = 0;
  
  [self setState:kMyProfile];
}

- (void) setState:(ProfileBarState)state {
  if (state != _state) {
    _state = state;
    
    switch (state) {
      case kMyProfile:
        wallSelectedLargeImage.hidden = YES;
        equipSelectedLargeImage.hidden = YES;
        wallSelectedSmallImage.hidden = NO;
        skillsSelectedSmallImage.hidden = NO;
        equipSelectedSmallImage.hidden = NO;
        
        skillsIcon.hidden = NO;
        skillsLabel.hidden = NO;
        
        _curEquipSelectedImage = equipSelectedSmallImage;
        _curSkillsSelectedImage = skillsSelectedSmallImage;
        _curWallSelectedImage = wallSelectedSmallImage;
        
        equipIcon.center = CGPointMake(equipSelectedSmallImage.center.x, equipIcon.center.y);
        equipLabel.center = CGPointMake(equipSelectedSmallImage.center.x, equipLabel.center.y);
        
        wallIcon.center = CGPointMake(wallSelectedSmallImage.center.x, wallIcon.center.y);
        wallLabel.center = CGPointMake(wallSelectedSmallImage.center.x, wallLabel.center.y);
        break;
        
      case kOtherPlayerProfile:
        wallSelectedLargeImage.hidden = NO;
        equipSelectedLargeImage.hidden = NO;
        wallSelectedSmallImage.hidden = YES;
        skillsSelectedSmallImage.hidden = YES;
        equipSelectedSmallImage.hidden = YES;
        
        skillsIcon.hidden = YES;
        skillsLabel.hidden = YES;
        
        _curEquipSelectedImage = equipSelectedLargeImage;
        _curSkillsSelectedImage = nil;
        _curWallSelectedImage = wallSelectedLargeImage;
        
        equipIcon.center = CGPointMake(equipSelectedLargeImage.center.x, equipIcon.center.y);
        equipLabel.center = CGPointMake(equipSelectedLargeImage.center.x, equipLabel.center.y);
        
        wallIcon.center = CGPointMake(wallSelectedLargeImage.center.x, wallIcon.center.y);
        wallLabel.center = CGPointMake(wallSelectedLargeImage.center.x, wallLabel.center.y);
        break;
        
      default:
        break;
    }
  }
  [self clickButton:kEquipButton];
  [self unclickButton:kSkillsButton];
  [self unclickButton:kWallButton];
  
  glowIcon.center = CGPointMake(_curEquipSelectedImage.center.x, glowIcon.center.y);
}

- (void) setProfileState:(ProfileState)s {
  if (s == kEquipState) {
    [self clickButton:kEquipButton];
    [self unclickButton:kSkillsState];
    [self unclickButton:kWallButton];
    glowIcon.center = CGPointMake(_curEquipSelectedImage.center.x, glowIcon.center.y);
  } else if (s == kSkillsState) {
    [self clickButton:kSkillsButton];
    [self unclickButton:kEquipButton];
    [self unclickButton:kWallButton];
    glowIcon.center = CGPointMake(_curSkillsSelectedImage.center.x, glowIcon.center.y);
  } else if (s == kWallState) {
    [self clickButton:kWallButton];
    [self unclickButton:kEquipButton];
    [self unclickButton:kSkillsButton];
    glowIcon.center = CGPointMake(_curWallSelectedImage.center.x, glowIcon.center.y);
  }
}

- (void) clickButton:(ProfileBarButton)button {
  switch (button) {
    case kEquipButton:
      equipIcon.highlighted = YES;
      equipLabel.highlighted = YES;
      _curEquipSelectedImage.hidden = NO;
      _clickedButtons |= kEquipButton;
      break;
      
    case kSkillsButton:
      if (self.state == kMyProfile) {
        skillsIcon.highlighted = YES;
        skillsLabel.highlighted = YES;
        _curSkillsSelectedImage.hidden = NO;
        _clickedButtons |= kSkillsButton;
      }
      break;
      
    case kWallButton:
      wallIcon.highlighted = YES;
      wallLabel.highlighted = YES;
      _curWallSelectedImage.hidden = NO;
      _clickedButtons |= kWallButton;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(ProfileBarButton)button {
  switch (button) {
    case kEquipButton:
      equipIcon.highlighted = NO;
      equipLabel.highlighted = NO;
      _curEquipSelectedImage.hidden = YES;
      _clickedButtons &= ~kEquipButton;
      break;
      
    case kSkillsButton:
      if (_state == kMyProfile) {
        skillsIcon.highlighted = NO;
        skillsLabel.highlighted = NO;
        _curSkillsSelectedImage.hidden = YES;
        _clickedButtons &= ~kSkillsButton;
      }
      break;
      
    case kWallButton:
      wallIcon.highlighted = NO;
      wallLabel.highlighted = NO;
      _curWallSelectedImage.hidden = YES;
      _clickedButtons &= ~kWallButton;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:_curEquipSelectedImage];
  if (!(_clickedButtons & kEquipButton) && [_curEquipSelectedImage pointInside:pt withEvent:nil]) {
    _trackingEquip = YES;
    [self clickButton:kEquipButton];
  }
  
  if (_state == kMyProfile) {
    pt = [touch locationInView:_curSkillsSelectedImage];
    if (!(_clickedButtons & kSkillsButton) && [_curSkillsSelectedImage pointInside:pt withEvent:nil]) {
      _trackingSkills = YES;
      [self clickButton:kSkillsButton];
    }
  }
  
  pt = [touch locationInView:_curWallSelectedImage];
  if (!(_clickedButtons & kWallButton) && [_curWallSelectedImage pointInside:pt withEvent:nil]) {
    _trackingWall = YES;
    [self clickButton:kWallButton];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:_curEquipSelectedImage];
  if (_trackingEquip) {
    if (CGRectContainsPoint(CGRectInset(_curEquipSelectedImage.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kEquipButton];
    } else {
      [self unclickButton:kEquipButton];
    }
  }
  
  if (_state == kMyProfile) {
    pt = [touch locationInView:_curSkillsSelectedImage];
    if (_trackingSkills) {
      if (CGRectContainsPoint(CGRectInset(_curSkillsSelectedImage.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
        [self clickButton:kSkillsButton];
      } else {
        [self unclickButton:kSkillsButton];
      }
    }
  }
  
  pt = [touch locationInView:_curWallSelectedImage];
  if (_trackingWall) {
    if (CGRectContainsPoint(CGRectInset(_curWallSelectedImage.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kWallButton];
    } else {
      [self unclickButton:kWallButton];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:_curEquipSelectedImage];
  if (_trackingEquip) {
    if (CGRectContainsPoint(CGRectInset(_curEquipSelectedImage.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kEquipButton];
      [self unclickButton:kWallButton];
      [self unclickButton:kSkillsButton];
      glowIcon.center = CGPointMake(_curEquipSelectedImage.center.x, glowIcon.center.y);
      [[ProfileViewController sharedProfileViewController] setState:kEquipState];
    } else {
      [self unclickButton:kEquipButton];
    }
  }
  
  if (_state == kMyProfile) {
    pt = [touch locationInView:_curSkillsSelectedImage];
    if (_trackingSkills) {
      if (CGRectContainsPoint(CGRectInset(_curSkillsSelectedImage.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
        [self clickButton:kSkillsButton];
        [self unclickButton:kEquipButton];
        [self unclickButton:kWallButton];
        glowIcon.center = CGPointMake(_curSkillsSelectedImage.center.x, glowIcon.center.y);
        [[ProfileViewController sharedProfileViewController] setState:kSkillsState];
      } else {
        [self unclickButton:kSkillsButton];
      }
    }
  }
  
  pt = [touch locationInView:_curWallSelectedImage];
  if (_trackingWall) {
    if (CGRectContainsPoint(CGRectInset(_curWallSelectedImage.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kWallButton];
      [self unclickButton:kEquipButton];
      [self unclickButton:kSkillsButton];
      glowIcon.center = CGPointMake(_curWallSelectedImage.center.x, glowIcon.center.y);
      [[ProfileViewController sharedProfileViewController] setState:kWallState];
    } else {
      [self unclickButton:kWallButton];
    }
  }
  _trackingEquip = NO;
  _trackingSkills = NO;
  _trackingWall = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kEquipButton];
  [self unclickButton:kSkillsButton];
  [self unclickButton:kWallButton];
  _trackingEquip = NO;
  _trackingSkills = NO;
  _trackingWall = NO;
}

- (void) dealloc {
  self.equipIcon = nil;
  self.skillsIcon = nil;
  self.wallIcon = nil;
  self.equipLabel = nil;
  self.skillsLabel = nil;
  self.wallLabel = nil;
  self.equipSelectedLargeImage = nil;
  self.equipSelectedSmallImage = nil;
  self.skillsSelectedSmallImage = nil;
  self.wallSelectedLargeImage = nil;
  self.wallSelectedSmallImage = nil;
  self.glowIcon = nil;
  [super dealloc];
}

@end

@implementation EquipView

@synthesize bgd;
@synthesize equipIcon, maskedEquipIcon, border;
@synthesize rarityLabel, quantityLabel, attackLabel, defenseLabel;
@synthesize equip;
@synthesize darkOverlay;

- (void) awakeFromNib {
  int offset = 2.5;
  CGRect rect = CGRectMake(offset, offset, self.bounds.size.width-2*offset, self.bounds.size.height-2*offset);
  darkOverlay = [[UIView alloc] initWithFrame:rect];
  darkOverlay.layer.cornerRadius = 2.5f;
  darkOverlay.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
  darkOverlay.hidden = YES;
  [self addSubview:darkOverlay];
}

- (void) updateForEquip:(FullUserEquipProto *)fuep {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:fuep.equipId];
  attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
  //  equipIcon.image = [Globals imageForEquip:fuep.equipId];
  [Globals loadImageForEquip:fep.equipId toView:equipIcon maskedView:nil];
  rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
  rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
  quantityLabel.text = [NSString stringWithFormat:@"x%d", fuep.quantity];
  
  self.equip = fuep;
  
  if ([Globals canEquip:fep]) {
    bgd.highlighted = NO;
    maskedEquipIcon.hidden = YES;
  } else {
    bgd.highlighted = YES;
    maskedEquipIcon.image =[Globals maskImage:equipIcon.image withColor:[Globals colorForUnequippable]];
    maskedEquipIcon.hidden = NO;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  darkOverlay.hidden = NO;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self pointInside:[[touches anyObject] locationInView:self] withEvent:event]) {
    darkOverlay.hidden = NO;
  } else {
    darkOverlay.hidden = YES;
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self pointInside:[[touches anyObject] locationInView:self] withEvent:event]) {
    [[ProfileViewController sharedProfileViewController] equipViewSelected:self];
    darkOverlay.hidden = NO;
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  darkOverlay.hidden = YES;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  darkOverlay.hidden = YES;
}

- (void) dealloc {
  self.bgd = nil;
  self.equipIcon = nil;
  self.maskedEquipIcon = nil;
  self.border = nil;
  self.rarityLabel = nil;
  self.quantityLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.equip = nil;
  self.darkOverlay = nil;
  [super dealloc];
}

@end

@implementation CurrentEquipView

@synthesize equipIcon, label, chooseEquipButton, border, unknownLabel;
@synthesize selected = _selected;

- (void) awakeFromNib {
  [super awakeFromNib];
  
  unknownLabel = [[UILabel alloc] initWithFrame:equipIcon.frame];
  CGRect r = unknownLabel.frame;
  r.origin.y += 5;
  unknownLabel.frame = r;
  
  unknownLabel.clipsToBounds = NO;
  unknownLabel.font = [UIFont fontWithName:@"Trajan Pro" size:30];
  unknownLabel.text = @"?";
  unknownLabel.textColor = [Globals colorForUnknownEquip];
  unknownLabel.backgroundColor = [UIColor clearColor];
  unknownLabel.textAlignment = UITextAlignmentCenter;
  
  [self.superview addSubview:unknownLabel];
}

- (void) setSelected:(BOOL)selected {
  if (selected != _selected) {
    _selected = selected;
    border.hidden = _selected ? NO : YES;
  }
}

- (void) unknownEquip {
  label.text = @"Unknown";
  label.textColor = [Globals colorForUnknownEquip];
  
  unknownLabel.hidden = NO;
  chooseEquipButton.hidden = YES;
  equipIcon.hidden = YES;
}

- (void) knownEquip {
  unknownLabel.hidden = YES;
  chooseEquipButton.hidden = NO;
  equipIcon.hidden = NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  border.hidden = _selected ? YES : NO;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self pointInside:[[touches anyObject] locationInView:self] withEvent:event]) {
    border.hidden = _selected ? YES : NO;
  } else {
    border.hidden = _selected ? NO : YES;
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self pointInside:[[touches anyObject] locationInView:self] withEvent:event]) {
    _selected = !_selected;
    [[ProfileViewController sharedProfileViewController] currentEquipViewSelected:self];
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  border.hidden = _selected ? NO : YES;
}

- (void) dealloc {
  self.equipIcon = nil;
  self.label = nil;
  self.chooseEquipButton = nil;
  self.border = nil;
  self.unknownLabel = nil;
  
  [super dealloc];
}

@end

@implementation MarketplacePostView

@synthesize bgdView, mainView;
@synthesize postedPriceIcon, postedPriceTextField;
@synthesize armoryPriceIcon, armoryPriceLabel;

- (void) updateForEquip:(int)equipId andAddToSuperView:(UIView *)view {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  BOOL sellsForGold = [Globals sellsForGoldInMarketplace:fep];
  
  if (sellsForGold) {
    postedPriceIcon.highlighted = YES;
    armoryPriceIcon.highlighted = YES;
    armoryPriceLabel.text = [Globals commafyNumber:fep.diamondPrice];
  } else {
    postedPriceIcon.highlighted = NO;
    armoryPriceIcon.highlighted = NO;
    armoryPriceLabel.text = [Globals commafyNumber:fep.coinPrice];
  }
  postedPriceTextField.text = @"";
  
  [view addSubview:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [postedPriceTextField becomeFirstResponder];
}

- (IBAction)closeClicked:(id)sender {
  [postedPriceTextField resignFirstResponder];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > PRICE_DIGITS) {
    return NO;
  }
  return YES;
}

- (void) dealloc {
  self.bgdView = nil;
  self.mainView = nil;
  self.postedPriceIcon = nil;
  self.postedPriceTextField = nil;
  self.armoryPriceLabel = nil;
  self.armoryPriceIcon = nil;
  [super dealloc];
}

@end

@implementation ProfileEquipPopup

@synthesize titleLabel, classLabel, attackLabel, defenseLabel;
@synthesize typeLabel, levelLabel;
@synthesize equipIcon, wrongClassView, tooLowLevelView;
@synthesize descriptionLabel;
@synthesize mainView, bgdView;
@synthesize equipButton, equipLabel;
@synthesize sellButton, sellLabel;
@synthesize userEquip;
@synthesize mktPostView;
@synthesize soldSilverLabel, soldItemLabel, soldView;

- (void) updateForUserEquip:(UserEquip *)ue {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  
  titleLabel.text = fep.name;
  titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  classLabel.text = [Globals stringForEquipClassType:fep.classType];
  typeLabel.text = [Globals stringForEquipType:fep.equipType];
  attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
  levelLabel.text = [NSString stringWithFormat:@"%d", fep.minLevel];
  descriptionLabel.text = fep.description;
  
  equipIcon.equipId = fep.equipId;
  
  if ([Globals canEquip:fep]) {
    equipButton.enabled = YES;
    equipLabel.alpha = 1.f;
  } else {
    equipButton.enabled = NO;
    equipLabel.alpha = 0.75f;
  }
  
  if ([Globals class:gs.type canEquip:fep.classType]) {
    wrongClassView.hidden = YES;
  } else {
    wrongClassView.hidden = NO;
  }
  
  if (gs.level >= fep.minLevel) {
    tooLowLevelView.hidden = YES;
  } else {
    tooLowLevelView.hidden = NO;
  }
  
  self.userEquip = ue;
}

- (IBAction)closeClicked:(id)sender {
  [[ProfileViewController sharedProfileViewController] loadMyProfile];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
    [self removeFromSuperview];
  }];
}

- (IBAction)wrongClassClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable by %@s.", titleLabel.text, classLabel.text]];
}

- (IBAction)tooLowLevelClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable at Level %@.", titleLabel.text, levelLabel.text]];
}

- (IBAction)equipItemClicked:(id)sender {
  [self closeClicked:nil];
  [[ProfileViewController sharedProfileViewController] doEquip:userEquip];
}

- (IBAction)sellClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:userEquip.equipId];
  int sellAmt = fep.coinPrice ? [[Globals sharedGlobals] calculateEquipSilverSellCost:userEquip] : [[Globals sharedGlobals] calculateEquipGoldSellCost:userEquip];
  NSString *str = [NSString stringWithFormat:@"Sell for %d %@?", sellAmt, fep.coinPrice ? @"silver" : @"gold"]; 
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Sell" cancelButton:nil target:self selector:@selector(sellItem)];
}

- (void) sellItem {
  [[OutgoingEventController sharedOutgoingEventController] sellEquip:userEquip.equipId];
  if (userEquip.quantity <= 0) {
    [self closeClicked:nil];
  }
}

- (IBAction)postClicked:(id)sender {
  [self.mktPostView updateForEquip:userEquip.equipId andAddToSuperView:self];
}

- (IBAction)postOkayClicked:(id)sender
{
  [[OutgoingEventController sharedOutgoingEventController] equipPostToMarketplace:userEquip.equipId price:[self.mktPostView.postedPriceTextField.text intValue]];
  [self.mktPostView closeClicked:nil];
  
  if (userEquip.quantity <= 0) {
    [self closeClicked:nil];
  }
}

- (void) dealloc {
  self.titleLabel = nil;
  self.classLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.typeLabel = nil;
  self.levelLabel = nil;
  self.equipIcon = nil;
  self.descriptionLabel = nil;
  self.wrongClassView = nil;
  self.tooLowLevelView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.equipButton = nil;
  self.equipLabel = nil;
  self.sellButton = nil;
  self.sellLabel = nil;
  self.mktPostView = nil;
  [super dealloc];
}

@end

@implementation WallPostCell

@synthesize postLabel, playerIcon, nameLabel, timeLabel;
@synthesize gradientLayer;

- (void) awakeFromNib {
  self.gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = self.bounds;
  UIColor *topColor = [UIColor colorWithRed:35/255.f green:35/255.f blue:35/255.f alpha:0.3f];
  UIColor *botColor = [UIColor colorWithRed:12/255.f green:12/255.f blue:12/255.f alpha:0.3f];
  gradientLayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[botColor CGColor], nil];
  [self.contentView.layer insertSublayer:gradientLayer atIndex:0];
}

- (void) updateForWallPost:(PlayerWallPostProto *)wallPost {
  [playerIcon setImage:[Globals squareImageForUser:wallPost.poster.userType] forState:UIControlStateNormal];
  [nameLabel setTitle:wallPost.poster.name forState:UIControlStateNormal];
  timeLabel.text = [Globals stringForTimeSinceNow:[NSDate dateWithTimeIntervalSince1970:wallPost.timeOfPost/1000]];
  postLabel.text = wallPost.content;
  
  CGSize size = postLabel.frame.size;
  size.height = 9999;
  size = [postLabel.text sizeWithFont:postLabel.font constrainedToSize:size];
  
  CGRect rect = postLabel.frame;
  rect.size.height = size.height;
  postLabel.frame = rect;
  
  gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, CGRectGetMaxY(postLabel.frame)+WALL_POST_CELL_OFFSET);
}

- (void) dealloc {
  self.postLabel = nil;
  self.playerIcon = nil;
  self.nameLabel = nil;
  self.timeLabel = nil;
  self.gradientLayer = nil;
  [super dealloc];
}

@end

@implementation WallTabView

@synthesize spinner;
@synthesize wallTableView, wallTextField, postCell;
@synthesize wallPosts;

- (void) awakeFromNib {
  wallTextField.label.textColor = [UIColor whiteColor];

  // This will prevent empty cells from being made when the page is not full..
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
  wallTableView.tableFooterView = view;
  [view release];
}

- (void) setWallPosts:(NSMutableArray *)w {
  if (wallPosts != w) {
    [wallPosts release];
    wallPosts = [w retain];
  }
  
  if (wallPosts == nil) {
    spinner.hidden = NO;
    [spinner startAnimating];
  } else {
    [spinner stopAnimating];
    spinner.hidden = YES;
  }
  
  [self.wallTableView reloadData];
  [self.wallTableView setContentOffset:CGPointZero];
}

- (void) endEditing {
  if ([wallTextField isFirstResponder]) {
    [wallTextField resignFirstResponder];
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self endEditing];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.wallPosts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  WallPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WallPostCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"WallPostCell" owner:self options:nil];
    cell = self.postCell;
  }
  
  [cell updateForWallPost:[self.wallPosts objectAtIndex:indexPath.row]];
  
  return cell;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  [self endEditing];
} 

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  PlayerWallPostProto *wallPost = [self.wallPosts objectAtIndex:indexPath.row];
  
  CGSize size = CGSizeMake(WALL_POST_LABEL_WIDTH, 9999);
  size = [wallPost.content sizeWithFont:WALL_POST_FONT constrainedToSize:size];
  
  return WALL_POST_LABEL_MIN_Y+size.height+WALL_POST_CELL_OFFSET;
}

- (IBAction)postToWall:(id)sender {
  NSString *content = wallTextField.text;
  if (content.length > 0) {
    int userId = [[ProfileViewController sharedProfileViewController] userId];
    PlayerWallPostProto *wallPost = [[OutgoingEventController sharedOutgoingEventController] postToPlayerWall:userId withContent:content];
    
    if (wallPost) {
      [self.wallPosts insertObject:wallPost atIndex:0];
      [self.wallTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    wallTextField.text = @"";
  }
  [self endEditing];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [self postToWall:nil];
  return YES;
}

- (IBAction)visitProfile:(id)sender {
  UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
  NSIndexPath *path = [wallTableView indexPathForCell:cell];
  PlayerWallPostProto *proto = [wallPosts objectAtIndex:path.row];
  
  [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:proto.poster withState:kWallState];
}

- (void) dealloc {
  self.wallPosts = nil;
  self.wallTableView = nil;
  self.wallTextField = nil;
  self.postCell = nil;
  [super dealloc];
}

@end

@implementation ProfileViewController

@synthesize state = _state, curScope = _curScope;
@synthesize userNameLabel, typeLabel, levelLabel, attackLabel, defenseLabel, codeLabel;
@synthesize winsLabel, lossesLabel, fleesLabel;
@synthesize curArmorView, curAmuletView, curWeaponView;
@synthesize profilePicture, profileBar;
@synthesize equipViews, nibEquipView, equipsScrollView;
@synthesize unequippableView, unequippableLabel;
@synthesize equippingView, equipTabView, skillTabView, wallTabView;
@synthesize attackStatLabel, defenseStatLabel, staminaStatLabel, energyStatLabel, hpStatLabel;
@synthesize attackStatButton, defenseStatButton, staminaStatButton, energyStatButton, hpStatButton;
@synthesize enemyAttackLabel, enemyMiddleView;
@synthesize staminaCostLabel, hpCostLabel, skillPointsLabel;
@synthesize selfLeftView, enemyLeftView, friendLeftView;
@synthesize visitButton, smallAttackButton, bigAttackButton;
@synthesize spinner;
@synthesize mainView, bgdView;
@synthesize fup = _fup;
@synthesize userId;
@synthesize equipPopup;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ProfileViewController);

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.equipViews = [NSMutableArray array];
  
  equippingView = [[UIImageView alloc] init];
  equippingView.contentMode = UIViewContentModeScaleAspectFit;
  [equipTabView addSubview:equippingView];
  equippingView.hidden = YES;
  
  skillTabView.frame = equipTabView.frame;
  [self.mainView addSubview:skillTabView];
  
  wallTabView.frame = equipTabView.frame;
  [self.mainView addSubview:wallTabView];
  
  enemyMiddleView.frame = equipsScrollView.frame;
  [equipTabView addSubview:enemyMiddleView];
  
  selfLeftView.frame = enemyLeftView.frame;
  [self.mainView addSubview:selfLeftView];
  
  friendLeftView.frame = enemyLeftView.frame;
  [self.mainView addSubview:friendLeftView];
}

- (void) viewWillAppear:(BOOL)animated {
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewDidDisappear:(BOOL)animated {
  self.fup = nil;
}

- (void) setState:(ProfileState)state {
  if (state != _state) {
    
    switch (state) {
      case kEquipState:
        equipTabView.hidden = NO;
        skillTabView.hidden = YES;
        wallTabView.hidden = YES;
        [self.profileBar setProfileState:state];
        break;
        
      case kSkillsState:
        equipTabView.hidden = YES;
        skillTabView.hidden = NO;
        wallTabView.hidden = YES;
        [self.profileBar setProfileState:state];
        break;
        
      case kWallState:
        equipTabView.hidden = YES;
        skillTabView.hidden = YES;
        wallTabView.hidden = NO;
        [self.profileBar setProfileState:state];
        break;
        
      default:
        break;
    }
    _state = state;
    [wallTabView endEditing];
  }
}

- (void) setCurScope:(EquipScope)curScope {
  _curScope = curScope;
  [self updateScrollViewForCurrentScope:YES];
}

- (CGPoint) centerForCell:(int)cellNum equipView:(EquipView *)ev {
  int x = equipsScrollView.frame.size.width/2 + ((cellNum % 3)-1)*(ev.frame.size.width+EQUIPS_HORIZONTAL_SEPARATION);
  int y = (cellNum/3*(ev.frame.size.height+EQUIPS_VERTICAL_SEPARATION))+ev.frame.size.height/2+EQUIPS_VERTICAL_SEPARATION;
  return CGPointMake(x, y);
}

- (void) doEquip:(UserEquip *)equip {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:equip.equipId];
  for (EquipView *ev in equipViews) {
    if (ev.equip == (FullUserEquipProto *)equip) {
      [[OutgoingEventController sharedOutgoingEventController] wearEquip:equip.equipId];
      [self doEquippingAnimation:ev forType:fep.equipType];
    }
  }
}

- (void) doEquippingAnimation:(EquipView *)ev forType:(FullEquipProto_EquipType)type {
  equippingView.frame = [equipTabView convertRect:ev.equipIcon.frame fromView:ev];
  equippingView.image = ev.equipIcon.image;
  equippingView.hidden = NO;
  [equippingView.layer removeAllAnimations];
  
  CurrentEquipView *cev;
  EquipView *curBorderView;
  
  switch (type) {
    case FullEquipProto_EquipTypeWeapon:
      cev = curWeaponView;
      curBorderView = _weaponEquipView;
      _weaponEquipView = ev;
      break;
    case FullEquipProto_EquipTypeArmor:
      cev = curArmorView;
      curBorderView = _armorEquipView;
      _armorEquipView = ev;
      break;
    case FullEquipProto_EquipTypeAmulet:
      cev = curAmuletView;
      curBorderView = _amuletEquipView;
      _amuletEquipView = ev;
      break;
      
    default:
      break;
  }
  
  cev.equipIcon.image = ev.equipIcon.image;
  cev.equipIcon.alpha = 0.25f;
  cev.chooseEquipButton.hidden = YES;
  cev.equipIcon.hidden = NO;
  ev.border.alpha = 0.f;
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:EQUIPPING_DURATION];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(finishedEquippingAnimation)];
  
  equippingView.frame = cev.equipIcon.frame;
  curBorderView.border.alpha = 0.f;
  ev.border.alpha = 1.f;
  
  [UIView commitAnimations];
  
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ev.equip.equipId];
  
  CATransition *labelAnimation = [CATransition animation];
  labelAnimation.duration = EQUIPPING_DURATION;
  labelAnimation.type = kCATransitionFade;
  [cev.label.layer removeAnimationForKey:@"changeTextTransition"];
  [cev.label.layer addAnimation:labelAnimation forKey:@"changeTextTransition"];
  
  cev.label.text = fep.name;
  cev.label.textColor = [Globals colorForRarity:fep.rarity];
}

- (void) finishedEquippingAnimation {
  equippingView.hidden = YES;
  curWeaponView.equipIcon.alpha = 1.f;
  curArmorView.equipIcon.alpha = 1.f;
  curAmuletView.equipIcon.alpha = 1.f;
  
  [curWeaponView.label.layer removeAnimationForKey:@"changeTextTransition"];
  [curArmorView.label.layer removeAnimationForKey:@"changeTextTransition"];
  [curAmuletView.label.layer removeAnimationForKey:@"changeTextTransition"];
}

- (void) equipViewSelected:(EquipView *)ev {
  GameState *gs = [GameState sharedGameState];
  FullUserEquipProto *fuep = ev.equip;
  if (profileBar.state == kMyProfile && fuep.userId == gs.userId) {
    // The fuep is actually a UserEquip.. see @selector(loadMyProfile)
    [equipPopup updateForUserEquip:(UserEquip *)fuep];
    [self.view addSubview:equipPopup];
    [Globals bounceView:equipPopup.mainView fadeInBgdView:equipPopup.bgdView];
  } else {
    [Globals popupMessage:@"Attempting to equip an item that is not yours"];
  }
}

- (void) currentEquipViewSelected:(CurrentEquipView *)cev {
  // Synchronize this method, cuz otherwise there are random race conditions
  // for letting go of another button while this is being evaluated
  EquipScope scope = 0;
  
  if (cev == curWeaponView) {
    scope = kEquipScopeWeapons;
    
    if (scope == _curScope) {
      scope = kEquipScopeAll;
      curWeaponView.selected = NO;
      curArmorView.selected = NO;
      curAmuletView.selected = NO;
    } else {
      curWeaponView.selected = YES;
      curArmorView.selected = NO;
      curAmuletView.selected = NO;
    }
  } else if (cev == curArmorView) {
    scope = kEquipScopeArmor;
    
    if (scope == _curScope) {
      scope = kEquipScopeAll;
      curWeaponView.selected = NO;
      curArmorView.selected = NO;
      curAmuletView.selected = NO;
    } else {
      curWeaponView.selected = NO;
      curArmorView.selected = YES;
      curAmuletView.selected = NO;
    }
  } else if (cev == curAmuletView) {
    scope = kEquipScopeAmulets;
    
    if (scope == _curScope) {
      scope = kEquipScopeAll;
      curWeaponView.selected = NO;
      curArmorView.selected = NO;
      curAmuletView.selected = NO;
    } else {
      curWeaponView.selected = NO;
      curArmorView.selected = NO;
      curAmuletView.selected = YES;
    }
  } else {
    [Globals popupMessage:@"Error attaining scope value"];
  }
  
  self.curScope = scope;
  
  [self.equipsScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (NSArray *) sortEquips:(NSArray *)equips {
  NSMutableArray *arr = [equips mutableCopy];
  NSMutableArray *toRet = [NSMutableArray arrayWithCapacity:equips.count];
  GameState *gs = [GameState sharedGameState];
  
  for (int i = 0; i < equips.count; i++) {
    UserEquip *bestFuep = [arr objectAtIndex:0];
    FullEquipProto *bestFep = [gs equipWithId:bestFuep.equipId];
    for (int j = 1; j < arr.count; j++) {
      UserEquip *compFuep = [arr objectAtIndex:j];
      FullEquipProto *compFep = [gs equipWithId:compFuep.equipId];
      
      if (compFep.rarity > bestFep.rarity) {
        bestFuep = compFuep;
        bestFep = compFep;
      } else if (compFep.rarity == bestFep.rarity &&
                 compFep.attackBoost + compFep.defenseBoost >
                 bestFep.attackBoost + bestFep.defenseBoost) {
        bestFuep = compFuep;
        bestFep = compFep;
      }
    }
    [toRet addObject:bestFuep];
    [arr removeObject:bestFuep];
  }
  [arr release];
  
  return toRet;
}

- (NSArray *) equipViewsForScope:(EquipScope) scope {
  if (scope == kEquipScopeAll) {
    return equipViews;
  }
  
  NSMutableArray *arr = [NSMutableArray array];
  for (EquipView *ev in equipViews) {
    FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ev.equip.equipId];
    if (scope == kEquipScopeWeapons && fep.equipType == FullEquipProto_EquipTypeWeapon) {
      [arr addObject:ev];
    } else if (scope == kEquipScopeArmor && fep.equipType == FullEquipProto_EquipTypeArmor) {
      [arr addObject:ev];
    } else if (scope == kEquipScopeAmulets && fep.equipType == FullEquipProto_EquipTypeAmulet) {
      [arr addObject:ev];
    }
  }
  return arr;
}

- (void) updateScrollViewForCurrentScope:(BOOL)animated {
  NSArray *toDisplay = [self equipViewsForScope:self.curScope];
  EquipView *ev = nil;
  int j = 0;
  if (animated) {
    [UIView beginAnimations:nil context:nil];
  }
  for (int i = 0; i < equipViews.count; i++) {
    ev = [equipViews objectAtIndex:i];
    if ([toDisplay containsObject:ev]) {
      ev.alpha = 1.0;
      ev.center = [self centerForCell:j equipView:ev];
      ev.tag = j;
      j++;
    } else {
      ev.tag = -1;
      ev.alpha = 0.0;
    }
  }
  if (animated) {
    [UIView commitAnimations];
  }
  equipsScrollView.contentSize = CGSizeMake(equipsScrollView.frame.size.width,(((j+2)/3)*(ev.frame.size.height+EQUIPS_VERTICAL_SEPARATION))+EQUIPS_VERTICAL_SEPARATION);
}

- (void) loadEquips:(NSArray *)equips curWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet touchEnabled:(BOOL)touchEnabled {
  GameState *gs = [GameState sharedGameState];
  
  BOOL weaponFound = NO, armorFound = NO, amuletFound = NO;
  
  [curWeaponView knownEquip];
  [curArmorView knownEquip];
  [curAmuletView knownEquip];
  
  curWeaponView.userInteractionEnabled = touchEnabled;
  curArmorView.userInteractionEnabled = touchEnabled;
  curAmuletView.userInteractionEnabled = touchEnabled;
  
  equips = [self sortEquips:equips];
  EquipView *ev;
  int i;
  
  for (i = 0; i < equips.count; i++) {
    FullUserEquipProto *fuep = [equips objectAtIndex:i];
    if (i < equipViews.count) {
      ev = [equipViews objectAtIndex:i];
    } else {
      [[NSBundle mainBundle] loadNibNamed:@"EquipView" owner:self options:nil];
      ev = self.nibEquipView;
      [equipViews addObject:ev];
      [equipsScrollView addSubview:ev];
      self.nibEquipView = nil;
    }
    
    [ev updateForEquip:fuep];
    ev.userInteractionEnabled = touchEnabled;
    
    // check if this item is equipped
    if (fuep.equipId == weapon) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      curWeaponView.label.text = fep.name;
      curWeaponView.label.textColor = [Globals colorForRarity:fep.rarity];
      //      curWeaponView.equipIcon.image = [Globals imageForEquip:fep.equipId];
      [Globals loadImageForEquip:fep.equipId toView:curWeaponView.equipIcon maskedView:nil];
      curWeaponView.equipIcon.hidden = NO;
      curWeaponView.chooseEquipButton.hidden = YES;
      
      ev.border.alpha = 1.f;
      _weaponEquipView = ev;
      weaponFound = YES;
    } else if (fuep.equipId == armor) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      curArmorView.label.text = fep.name;
      curArmorView.label.textColor = [Globals colorForRarity:fep.rarity];
      //      curArmorView.equipIcon.image = [Globals imageForEquip:fep.equipId];
      [Globals loadImageForEquip:fep.equipId toView:curArmorView.equipIcon maskedView:nil];
      curArmorView.equipIcon.hidden = NO;
      curArmorView.chooseEquipButton.hidden = YES;
      
      ev.border.alpha = 1.f;
      _armorEquipView = ev;
      armorFound = YES;
    } else if (fuep.equipId == amulet) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      curAmuletView.label.text = fep.name;
      curAmuletView.label.textColor = [Globals colorForRarity:fep.rarity];
      //      curAmuletView.equipIcon.image = [Globals imageForEquip:fep.equipId];
      [Globals loadImageForEquip:fep.equipId toView:curAmuletView.equipIcon maskedView:nil];
      curAmuletView.equipIcon.hidden = NO;
      curAmuletView.chooseEquipButton.hidden = YES;
      
      ev.border.alpha = 1.f;
      _amuletEquipView = ev;
      amuletFound = YES;
    } else {
      ev.border.alpha = 0.f;
    }
  }
  
  // Now remove the rest of the equipViews..
  while (i < equipViews.count) {
    [[equipViews objectAtIndex:i] removeFromSuperview];
    i++;
  }
  [equipViews removeObjectsInRange:NSMakeRange(equips.count, equipViews.count-equips.count)];
  
  _curScope = kEquipScopeAll;
  curWeaponView.selected = NO;
  curArmorView.selected = NO;
  curAmuletView.selected = NO;
  [self updateScrollViewForCurrentScope:NO];
  
  if (!weaponFound) {
    if (weapon > 0) {
      [Globals popupMessage:@"Unable to find equipped weapon for this player"];
    }
    curWeaponView.label.text = @"No Weapon";
    curWeaponView.label.textColor = [Globals colorForUnknownEquip];
    curWeaponView.equipIcon.hidden = YES;
    curWeaponView.chooseEquipButton.hidden = NO;
    _weaponEquipView = nil;
  }
  if (!armorFound) {
    if (armor > 0) {
      [Globals popupMessage:@"Unable to find equipped armor for this player"];
    }
    curArmorView.label.text = @"No Armor";
    curArmorView.label.textColor = [Globals colorForUnknownEquip];
    curArmorView.equipIcon.hidden = YES;
    curArmorView.chooseEquipButton.hidden = NO;
    _armorEquipView = nil;
  }
  if (!amuletFound) {
    if (amulet > 0) {
      [Globals popupMessage:@"Unable to find equipped amulet for this player"];
    }
    curAmuletView.label.text = @"No Amulet";
    curAmuletView.label.textColor = [Globals colorForUnknownEquip];
    curAmuletView.equipIcon.hidden = YES;
    curAmuletView.chooseEquipButton.hidden = NO;
    _amuletEquipView = nil;
  }
}

- (void) loadProfileForPlayer:(FullUserProto *)fup buttonsEnabled:(BOOL)enabled {
  if (fup.userId == [[GameState sharedGameState] userId]) {
    [self loadMyProfile];
    return;
  }
  
  userNameLabel.text = fup.name;
  profilePicture.image = [Globals profileImageForUser:fup.userType];
  winsLabel.text = [NSString stringWithFormat:@"%d", fup.battlesWon];
  lossesLabel.text = [NSString stringWithFormat:@"%d", fup.battlesLost];
  fleesLabel.text = [NSString stringWithFormat:@"%d", fup.flees];
  levelLabel.text = [NSString stringWithFormat:@"%d", fup.level];
  typeLabel.text = [NSString stringWithFormat:@"%@ %@", [Globals factionForUserType:fup.userType], [Globals classForUserType:fup.userType]];
  attackLabel.text = @"?";
  defenseLabel.text = @"?";
  
  equipsScrollView.hidden = YES;
  enemyMiddleView.hidden = NO;
  
  enemyLeftView.hidden = NO;
  friendLeftView.hidden = YES;
  selfLeftView.hidden = YES;
  
  [curWeaponView unknownEquip];
  [curArmorView unknownEquip];
  [curAmuletView unknownEquip];
  
  enemyAttackLabel.text = [NSString stringWithFormat:@"Attack %@ to see Equipment", fup.name];
  
  self.profileBar.state = kOtherPlayerProfile;
  self.state = kEquipState;
  
  visitButton.enabled = enabled;
  smallAttackButton.enabled = enabled;
  bigAttackButton.enabled = enabled;
  
  [spinner stopAnimating];
  self.spinner.hidden = YES;
  
  self.fup = fup;
  self.userId = fup.userId;
  
  if (userId != fup.userId) {
    wallTabView.wallPosts = nil;
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:userId];
  }
}

- (void) loadProfileForPlayer:(FullUserProto *)fup equips:(NSArray *)equips attack:(int)attack defense:(int)defense {
  // This method is only used from battle
  [self loadProfileForPlayer:fup buttonsEnabled:YES];
  
  equipsScrollView.hidden = NO;
  enemyMiddleView.hidden = YES;
  
  attackLabel.text = [NSString stringWithFormat:@"%d", attack];
  defenseLabel.text = [NSString stringWithFormat:@"%d", defense];
  
  if (fup.isFake) {
    // Fake the equips for fake players
    equips = [NSMutableArray arrayWithCapacity:3];
    
    FullUserEquipProto_Builder *bldr = [FullUserEquipProto builder];
    bldr.userId = fup.userId;
    bldr.quantity = 1;
    if (fup.weaponEquipped > 0) {
      bldr.equipId = fup.weaponEquipped;
      [(NSMutableArray *)equips addObject:[[bldr clone] build]];
    }
    
    if (fup.armorEquipped > 0) {
      bldr.equipId = fup.armorEquipped;
      [(NSMutableArray *)equips addObject:[[bldr clone] build]];
    }
    
    if (fup.amuletEquipped > 0) {
      bldr.equipId = fup.amuletEquipped;
      [(NSMutableArray *)equips addObject:[[bldr clone] build]];
    }
  }
  
  if (equips) {
    [self loadEquips:equips curWeapon:fup.weaponEquipped curArmor:fup.armorEquipped curAmulet:fup.amuletEquipped touchEnabled:NO];
  } else {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    _waitingForEquips = YES;
  }
}

- (void) receivedWallPosts:(RetrievePlayerWallPostsResponseProto *)proto {
  if (proto.relevantUserId == userId) {
    // Wall Tab View will take control of the wall posts
    // Make sure to send empty list if there are no wall posts so that spinner stops..
    wallTabView.wallPosts = proto.playerWallPostsList ? proto.playerWallPostsList.mutableCopy : [NSMutableArray array];
  }
}

- (void) loadProfileForMinimumUser:(MinimumUserProto *)user withState:(ProfileState)pState {
  if (userId == user.userId) {
    [ProfileViewController displayView];
    return;
  } else if (user.userId == [[GameState sharedGameState] userId]) {
    [ProfileViewController displayView];
    [self loadMyProfile];
    self.state = pState;
    return;
  }
  
  self.state = pState;
  self.profileBar.state = kOtherPlayerProfile;
  [self.profileBar setProfileState:pState];
  self.userId = user.userId;
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveUsersForUserIds:[NSArray arrayWithObject:[NSNumber numberWithInt:userId]]];
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:user.userId];
  
  userNameLabel.text = user.name;
  profilePicture.image = [Globals profileImageForUser:user.userType];
  winsLabel.text = @"";
  lossesLabel.text = @"";
  fleesLabel.text = @"";
  levelLabel.text = @"";
  typeLabel.text = @"";
  attackLabel.text = @"";
  defenseLabel.text = @"";
  
  selfLeftView.hidden = YES;
  enemyLeftView.hidden = YES;
  friendLeftView.hidden = YES;
  
  wallTabView.wallPosts = nil;
  [self loadEquips:nil curWeapon:0 curArmor:0 curAmulet:0 touchEnabled:NO];
  
  // Make equip spinner spin
  self.spinner.hidden = NO;
  [self.spinner startAnimating];
  
  [ProfileViewController displayView];
}

- (void) receivedFullUserProtos:(NSArray *)protos {
  for (FullUserProto *fup in protos) {
    if (fup.userId == userId) {
      ProfileState st = self.state;
      [self loadProfileForPlayer:fup buttonsEnabled:YES];
      self.state = st;
    }
  }
}

- (void) updateEquips:(NSArray *)equips {
  if (_waitingForEquips) {
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    [self loadEquips:equips curWeapon:_fup.weaponEquipped curArmor:_fup.armorEquipped curAmulet:_fup.amuletEquipped touchEnabled:NO];
  }
}

- (void) displayMyCurrentStats {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  attackLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateAttackForStat:gs.attack weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:gs.amuletEquipped]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateDefenseForStat:gs.defense weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:gs.amuletEquipped]];
}

- (void) loadMyProfile {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  userNameLabel.text = gs.name;
  profilePicture.image = [Globals profileImageForUser:gs.type];
  winsLabel.text = [NSString stringWithFormat:@"%d", gs.battlesWon];
  lossesLabel.text = [NSString stringWithFormat:@"%d", gs.battlesLost];
  fleesLabel.text = [NSString stringWithFormat:@"%d", gs.flees];
  levelLabel.text = [NSString stringWithFormat:@"%d", gs.level];
  typeLabel.text = [NSString stringWithFormat:@"%@ %@", [Globals factionForUserType:gs.type], [Globals classForUserType:gs.type]];
  codeLabel.text = gs.referralCode;
  
  [self displayMyCurrentStats];
  
  // Hacky: Fake my equips as FullUserEquipProtos because they have the same methods..
  [self loadEquips:gs.myEquips curWeapon:gs.weaponEquipped curArmor:gs.armorEquipped curAmulet:gs.amuletEquipped touchEnabled:YES];
  self.profileBar.state = kMyProfile;
  [self loadSkills];
  self.state = kEquipState;
  
  equipsScrollView.hidden = NO;
  enemyMiddleView.hidden = YES;
  
  enemyLeftView.hidden = YES;
  friendLeftView.hidden = YES;
  selfLeftView.hidden = NO;
  
  self.fup = nil;
  self.userId = gs.userId;
  
  wallTabView.wallPosts = [[GameState sharedGameState] wallPosts];
  
  // Update calculate labels
  staminaCostLabel.text = [NSString stringWithFormat:@"(%d skill %@ = %d)", gl.staminaBaseCost, gl.staminaBaseCost != 1 ? @"points" : @"point", gl.staminaBaseGain];
  hpCostLabel.text = [NSString stringWithFormat:@"(%d skill %@ = %d)", gl.healthBaseCost, gl.healthBaseCost != 1 ? @"points" : @"point", gl.healthBaseGain];
}

- (void) loadSkills {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  attackStatLabel.text = [NSString stringWithFormat:@"%d", gs.attack];
  defenseStatLabel.text = [NSString stringWithFormat:@"%d", gs.defense];
  energyStatLabel.text = [NSString stringWithFormat:@"%d", gs.maxEnergy];
  staminaStatLabel.text = [NSString stringWithFormat:@"%d", gs.maxStamina];
  hpStatLabel.text = [NSString stringWithFormat:@"%d", gs.maxHealth];
  
  skillPointsLabel.text = [NSString stringWithFormat:@"%d", gs.skillPoints];
  
  attackStatButton.enabled = gl.attackBaseCost <= gs.skillPoints;
  defenseStatButton.enabled = gl.defenseBaseCost <= gs.skillPoints;
  energyStatButton.enabled = gl.energyBaseCost <= gs.skillPoints;
  staminaStatButton.enabled = gl.staminaBaseCost <= gs.skillPoints;
  hpStatButton.enabled = gl.healthBaseCost <= gs.skillPoints;
}

- (void) openSkillsMenu {
  self.state = kSkillsState;
}

- (IBAction)skillButtonClicked:(id)sender {
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  
  if (sender == attackStatButton) {
    [oec addAttackSkillPoint];
    [Analytics addedSkillPoint:@"Attack"];
  } else if (sender == defenseStatButton) {
    [oec addDefenseSkillPoint];
    [Analytics addedSkillPoint:@"Defense"];
  } else if (sender == energyStatButton) {
    [oec addEnergySkillPoint];
    [Analytics addedSkillPoint:@"Energy"];
  } else if (sender == staminaStatButton) {
    [oec addStaminaSkillPoint];
    [Analytics addedSkillPoint:@"Stamina"];
  } else if (sender == hpStatButton) {
    [oec addHealthSkillPoint];
    [Analytics addedSkillPoint:@"Hp"];
  }
  
  [self loadSkills];
  [self displayMyCurrentStats];
}

- (IBAction)closeClicked:(id)sender {
  [self.wallTabView endEditing];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [ProfileViewController removeView];
  }];
  self.userId = 0;
}

- (IBAction)visitClicked:(id)sender {
  [Globals popupMessage:@"Sorry, visiting an enemy's city is coming soon!"];
  [Analytics clickedVisitCity];
}

- (IBAction)attackClicked:(id)sender {
  [[BattleLayer sharedBattleLayer] beginBattleAgainst:_fup];
  [ProfileViewController removeView];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self setCurScope:kEquipScopeAll];
  curWeaponView.selected = NO;
  curArmorView.selected = NO;
  curAmuletView.selected = NO;
  [wallTabView endEditing];
}

- (void) viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [_fup release];
  self.userNameLabel = nil;
  self.typeLabel = nil;
  self.levelLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.codeLabel = nil;
  self.winsLabel = nil;
  self.lossesLabel = nil;
  self.fleesLabel = nil;
  self.curArmorView = nil;
  self.curAmuletView = nil;
  self.curWeaponView = nil;
  self.profilePicture = nil;
  self.profileBar = nil;
  self.equipViews = nil;
  self.nibEquipView = nil;
  self.equipsScrollView = nil;
  self.unequippableView = nil;
  self.unequippableLabel = nil;
  self.equippingView = nil;
  self.equipTabView = nil;
  self.skillTabView = nil;
  self.wallTabView = nil;
  self.attackStatLabel = nil;
  self.defenseStatLabel = nil;
  self.staminaStatLabel = nil;
  self.energyStatLabel = nil;
  self.hpStatLabel = nil;
  self.attackStatButton = nil;
  self.defenseStatButton = nil;
  self.staminaStatButton = nil;
  self.energyStatButton = nil;
  self.hpStatButton = nil;
  self.enemyAttackLabel = nil;
  self.enemyMiddleView = nil;
  self.staminaCostLabel = nil;
  self.hpCostLabel = nil;
  self.skillPointsLabel = nil;
  self.selfLeftView = nil;
  self.enemyLeftView = nil;
  self.friendLeftView = nil;
  self.visitButton = nil;
  self.smallAttackButton = nil;
  self.bigAttackButton = nil;
  self.spinner = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.equipPopup = nil;
}

@end
