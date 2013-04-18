//
//  ProfileMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ProfileMenus.h"
#import "ProfileViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"

#define EQUIPS_VERTICAL_SEPARATION 3.f
#define EQUIPS_HORIZONTAL_SEPARATION 1.f

#define SHAKE_DURATION 0.2f
#define SHAKE_OFFSET 3.f

#define WALL_POST_LABEL_MIN_Y 28.75
#define WALL_POST_CELL_OFFSET 5
#define WALL_POST_FONT [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:15]
#define WALL_POST_LABEL_WIDTH 242

#define PRICE_DIGITS 7

@implementation ProfileBar

@synthesize state = _state;
@synthesize wallIcon, skillsIcon, profileIcon, specialIcon;
@synthesize wallLabel, skillsLabel, profileLabel, specialLabel;
@synthesize wallButton, skillsButton, profileButton, specialButton;
@synthesize profileBadgeView, profileBadgeLabel;

- (void) awakeFromNib {
  _clickedButtons = 0;
  
  [self setState:kMyProfile];
}

- (void) setState:(ProfileBarState)state {
  if (state != _state) {
    _state = state;
    
    switch (state) {
      case kMyProfile:
        profileBadgeView.hidden = _profileBadgeNum <= 0;
        break;
        
      case kOtherPlayerProfile:
        profileBadgeView.hidden = YES;
        break;
        
      default:
        break;
    }
  }
  [self clickButton:kProfileButton1];
  [self unclickButton:kProfileButton2];
  [self unclickButton:kProfileButton3];
  [self unclickButton:kProfileButton4];
}

- (void) incrementProfileBadge {
  if ([ProfileViewController sharedProfileViewController].state != kWallState || _state != kMyProfile) {
    _profileBadgeNum++;
    profileBadgeLabel.text = _profileBadgeNum < 10 ? [NSString stringWithFormat:@"%d", _profileBadgeNum] : @"!";
    
    if (_state == kMyProfile) {
      profileBadgeView.hidden = NO;
    }
  }
}

- (void) clearProfileBadge {
  _profileBadgeNum = 0;
  profileBadgeView.hidden = YES;
}

- (void) setProfileState:(ProfileState)s {
  if (s == kProfileState) {
    [self clickButton:kProfileButton1];
    [self unclickButton:kProfileButton2];
    [self unclickButton:kProfileButton3];
    [self unclickButton:kProfileButton4];
  } else if (s == kWallState) {
    [self clickButton:kProfileButton2];
    [self unclickButton:kProfileButton1];
    [self unclickButton:kProfileButton3];
    [self unclickButton:kProfileButton4];
    
    if (_state == kMyProfile) {
      [self clearProfileBadge];
    }
  } else if (s == kSkillsState) {
    [self clickButton:kProfileButton3];
    [self unclickButton:kProfileButton1];
    [self unclickButton:kProfileButton2];
    [self unclickButton:kProfileButton4];
  } else if (s == kSpecialState) {
    [self clickButton:kProfileButton4];
    [self unclickButton:kProfileButton1];
    [self unclickButton:kProfileButton3];
    [self unclickButton:kProfileButton2];
  }
}

- (void) clickButton:(ProfileBarButton)button {
  switch (button) {
    case kProfileButton1:
      profileIcon.highlighted = YES;
      profileLabel.highlighted = YES;
      profileButton.highlighted = YES;
      _clickedButtons |= kProfileButton1;
      break;
      
    case kProfileButton3:
      if (self.state == kMyProfile) {
        skillsIcon.highlighted = YES;
        skillsLabel.highlighted = YES;
        skillsButton.highlighted = YES;
        _clickedButtons |= kProfileButton3;
      }
      break;
      
    case kProfileButton2:
      wallIcon.highlighted = YES;
      wallLabel.highlighted = YES;
      wallButton.highlighted = YES;
      _clickedButtons |= kProfileButton2;
      break;
      
    case kProfileButton4:
      if (self.state == kMyProfile) {
        specialIcon.highlighted = YES;
        specialLabel.highlighted = YES;
        specialButton.highlighted = YES;
        _clickedButtons |= kProfileButton4;
      }
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(ProfileBarButton)button {
  switch (button) {
    case kProfileButton1:
      profileIcon.highlighted = NO;
      profileLabel.highlighted = NO;
      profileButton.highlighted = NO;
      _clickedButtons &= ~kProfileButton1;
      break;
      
    case kProfileButton3:
      skillsIcon.highlighted = NO;
      skillsLabel.highlighted = NO;
      skillsButton.highlighted = NO;
      _clickedButtons &= ~kProfileButton3;
      break;
      
    case kProfileButton2:
      wallIcon.highlighted = NO;
      wallLabel.highlighted = NO;
      wallButton.highlighted = NO;
      _clickedButtons &= ~kProfileButton2;
      break;
      
    case kProfileButton4:
      specialIcon.highlighted = NO;
      specialLabel.highlighted = NO;
      specialButton.highlighted = NO;
      _clickedButtons &= ~kProfileButton4;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:profileButton];
  if (!(_clickedButtons & kProfileButton1) && [profileButton pointInside:pt withEvent:nil]) {
    _trackingProfile = YES;
    [self clickButton:kProfileButton1];
  }
  
  pt = [touch locationInView:wallButton];
  if (!(_clickedButtons & kProfileButton2) && [wallButton pointInside:pt withEvent:nil]) {
    _trackingWall = YES;
    [self clickButton:kProfileButton2];
  }
  
  if (self.state == kMyProfile) {
    pt = [touch locationInView:skillsButton];
    if (!(_clickedButtons & kProfileButton3) && [skillsButton pointInside:pt withEvent:nil]) {
      _trackingSkills = YES;
      [self clickButton:kProfileButton3];
    }
    
    pt = [touch locationInView:specialButton];
    if (!(_clickedButtons & kProfileButton4) && [specialButton pointInside:pt withEvent:nil]) {
      _trackingSpecial = YES;
      [self clickButton:kProfileButton4];
    }
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:profileButton];
  if (_trackingProfile) {
    if (CGRectContainsPoint(CGRectInset(profileButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton1];
    } else {
      [self unclickButton:kProfileButton1];
    }
  }
  
  pt = [touch locationInView:skillsButton];
  if (_trackingSkills) {
    if (CGRectContainsPoint(CGRectInset(skillsButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton3];
    } else {
      [self unclickButton:kProfileButton3];
    }
  }
  
  pt = [touch locationInView:wallButton];
  if (_trackingWall) {
    if (CGRectContainsPoint(CGRectInset(wallButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton2];
    } else {
      [self unclickButton:kProfileButton2];
    }
  }
  
  pt = [touch locationInView:specialButton];
  if (_trackingSpecial) {
    if (CGRectContainsPoint(CGRectInset(specialButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton4];
    } else {
      [self unclickButton:kProfileButton4];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:profileButton];
  if (_trackingProfile) {
    if (CGRectContainsPoint(CGRectInset(profileButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton1];
      [self unclickButton:kProfileButton2];
      [self unclickButton:kProfileButton3];
      [self unclickButton:kProfileButton4];
      [[ProfileViewController sharedProfileViewController] setState:kProfileState];
    } else {
      [self unclickButton:kProfileButton1];
    }
  }
  
  pt = [touch locationInView:skillsButton];
  if (_trackingSkills) {
    if (CGRectContainsPoint(CGRectInset(skillsButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton3];
      [self unclickButton:kProfileButton2];
      [self unclickButton:kProfileButton1];
      [self unclickButton:kProfileButton4];
      [[ProfileViewController sharedProfileViewController] setState:kSkillsState];
    } else {
      [self unclickButton:kProfileButton3];
    }
  }
  
  pt = [touch locationInView:wallButton];
  if (_trackingWall) {
    if (CGRectContainsPoint(CGRectInset(wallButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton2];
      [self unclickButton:kProfileButton1];
      [self unclickButton:kProfileButton3];
      [self unclickButton:kProfileButton4];
      [[ProfileViewController sharedProfileViewController] setState:kWallState];
    } else {
      [self unclickButton:kProfileButton2];
    }
  }
  
  pt = [touch locationInView:specialButton];
  if (_trackingSpecial) {
    if (CGRectContainsPoint(CGRectInset(specialButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton4];
      [self unclickButton:kProfileButton2];
      [self unclickButton:kProfileButton3];
      [self unclickButton:kProfileButton1];
      [[ProfileViewController sharedProfileViewController] setState:kSpecialState];
    } else {
      [self unclickButton:kProfileButton4];
    }
  }
  
  _trackingProfile = NO;
  _trackingWall = NO;
  _trackingSkills = NO;
  _trackingSpecial = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kProfileButton1];
  [self unclickButton:kProfileButton2];
  [self unclickButton:kProfileButton3];
  [self unclickButton:kProfileButton1];
  _trackingProfile = NO;
  _trackingWall = NO;
  _trackingSkills = NO;
  _trackingSpecial = NO;
}

- (void) dealloc {
  self.wallIcon = nil;
  self.skillsIcon = nil;
  self.profileIcon = nil;
  self.specialIcon = nil;
  self.wallLabel = nil;
  self.skillsLabel = nil;
  self.profileLabel = nil;
  self.specialLabel = nil;
  self.wallButton = nil;
  self.skillsButton = nil;
  self.profileButton = nil;
  self.specialButton = nil;
  self.profileBadgeView = nil;
  self.profileBadgeLabel = nil;
  [super dealloc];
}

@end

@implementation ProfileEquipBrowseBar

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

- (void) updateForScope:(EquipScope)scope {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  [self unclickButton:kButton3];
  
  switch (scope) {
    case kEquipScopeWeapons:
      [self clickButton:kButton1];
      break;
    case kEquipScopeArmor:
      [self clickButton:kButton2];
      break;
    case kEquipScopeAmulets:
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
      
      [self.browseView updateForScope:kEquipScopeWeapons isSlot2:NO];
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
      
      [self.browseView updateForScope:kEquipScopeArmor isSlot2:NO];
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
      
      [self.browseView updateForScope:kEquipScopeAmulets isSlot2:NO];
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

@implementation EquipView

@synthesize bgd, border;
@synthesize equipIcon;
@synthesize nameLabel;
@synthesize attackLabel, defenseLabel;
@synthesize equip;
@synthesize darkOverlay;
@synthesize levelIcon;

static float origLabelCenterY = 0;

- (void) awakeFromNib {
  self.noEquipView.frame = self.mainView.frame;
  [self addSubview:self.noEquipView];
  darkOverlay = [[UIImageView alloc] initWithFrame:self.bgd.frame];
  darkOverlay.contentMode = bgd.contentMode;
  darkOverlay.hidden = YES;
  [self addSubview:darkOverlay];
  
  origLabelCenterY = self.noEquipLabel.center.y;
}

- (void) updateForEquip:(UserEquip *)ue {
  // This is for the browse cell
  if (!ue) {
    self.hidden = YES;
    return;
  } else {
    self.hidden = NO;
  }
  
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
  attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  //  wallIcon.image = [Globals imageForEquip:fuep.equipId];
  [Globals loadImageForEquip:fep.equipId toView:equipIcon maskedView:nil];
  nameLabel.text = fep.name;
  nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  levelIcon.level = ue.level;
  _enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
  
  NSString *base = [[[Globals stringForRarity:fep.rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  NSString *bgdFile = [base stringByAppendingString:@"profileequip.png"];
  [Globals imageNamed:bgdFile withView:self.bgd maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:bgdFile withView:self.darkOverlay maskedColor:[UIColor colorWithWhite:0.f alpha:0.3f] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.equip = ue;
  
  self.mainView.hidden = NO;
  self.noEquipView.hidden = YES;
}

- (void) updateForNoEquipIsMine:(BOOL)mine type:(FullEquipProto_EquipType)type {
  
  NSString *bgdFile = @"nothingequipped.png";
  [Globals imageNamed:bgdFile withView:self.bgd maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:bgdFile withView:self.darkOverlay maskedColor:[UIColor colorWithWhite:0.f alpha:0.3f] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.equip = nil;
  
  self.mainView.hidden = YES;
  self.noEquipView.hidden = NO;
  
  self.noEquipLabel.text = [NSString stringWithFormat:@"No %@ Equipped", [Globals stringForEquipType:type]];
  if (mine) {
    self.buttonView.hidden = NO;
    self.noEquipLabel.center = ccp(self.noEquipLabel.center.x, origLabelCenterY);
  } else {
    self.buttonView.hidden = YES;
    self.noEquipLabel.center = ccp(self.noEquipLabel.center.x, self.noEquipView.frame.size.height/2);
  }
}

- (void) updateForNotEnoughPrestiges:(int)prestigeLevelRequired {
  NSString *bgdFile = @"nothingequipped.png";
  [Globals imageNamed:bgdFile withView:self.bgd maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:bgdFile withView:self.darkOverlay maskedColor:[UIColor colorWithWhite:0.f alpha:0.3f] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.equip = nil;
  
  self.mainView.hidden = YES;
  self.noEquipView.hidden = NO;
  self.buttonView.hidden = YES;
  
  self.noEquipLabel.text = [NSString stringWithFormat:@"Prestige %@ to Unlock", prestigeLevelRequired == 1 ? @"Once" : (prestigeLevelRequired == 2 ? @"Twice" : [NSString stringWithFormat:@"%d Times", prestigeLevelRequired])];
  
  self.noEquipLabel.center = ccp(self.noEquipLabel.center.x, self.noEquipView.frame.size.height/2);
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
    [_delegate equipViewSelected:self];
  }
  darkOverlay.hidden = YES;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  darkOverlay.hidden = YES;
}

- (void) dealloc {
  self.bgd = nil;
  self.equipIcon = nil;
  self.border = nil;
  self.nameLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.equip = nil;
  self.darkOverlay = nil;
  self.levelIcon = nil;
  self.enhanceIcon = nil;
  self.noEquipView = nil;
  self.mainView = nil;
  self.noEquipLabel = nil;
  self.buttonView = nil;
  [super dealloc];
}

@end

@implementation MarketplacePostView

@synthesize bgdView, mainView;
@synthesize postedPriceIcon, postedPriceTextField;
@synthesize armoryPriceIcon, armoryPriceLabel;

- (void) updateForEquip:(UserEquip *)ue andAddToSuperView:(UIView *)view {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL sellsForGold = [Globals sellsForGoldInMarketplace:fep];
  int retail = [gl calculateRetailValueForEquip:ue.equipId level:ue.level];
  NSString *price = retail > 0 ? [Globals commafyNumber:retail] : @"N/A";
  
  if (sellsForGold) {
    postedPriceIcon.highlighted = YES;
    armoryPriceIcon.highlighted = YES;
    armoryPriceLabel.text = price;
  } else {
    postedPriceIcon.highlighted = NO;
    armoryPriceIcon.highlighted = NO;
    armoryPriceLabel.text = price;
  }
  postedPriceTextField.text = @"";
  
  self.frame = view.bounds;
  [view addSubview:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [postedPriceTextField becomeFirstResponder];
}

- (IBAction)closeClicked:(id)sender {
  if (self.superview) {
    [postedPriceTextField resignFirstResponder];
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self removeFromSuperview];
    }];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > PRICE_DIGITS) {
    return NO;
  }
  return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.mainView.center = ccpAdd(self.mainView.center, ccp(0, -75));
  }];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.mainView.center = ccpAdd(self.mainView.center, ccp(0, 75));
  }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self endEditing:YES];
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
@synthesize descriptionLabel, levelIcon;
@synthesize mainView, bgdView;
@synthesize equipButton, equipLabel;
@synthesize sellButton, sellLabel;
@synthesize userEquip;
@synthesize mktPostView;
@synthesize soldSilverLabel, soldItemLabel, soldView;

- (void) updateForUserEquip:(UserEquip *)ue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  
  titleLabel.text = fep.name;
  titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  classLabel.text = [Globals stringForEquipClassType:fep.classType];
  typeLabel.text = [Globals stringForEquipType:fep.equipType];
  attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  levelLabel.text = [NSString stringWithFormat:@"%d", fep.minLevel];
  descriptionLabel.text = fep.description;
  levelIcon.level = ue.level;
  self.enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
  
  equipIcon.equipId = fep.equipId;
  equipIcon.level = ue.level;
  equipIcon.enhancePercent = ue.enhancementPercentage;
  
  if ([Globals canEquip:fep]) {
    equipButton.enabled = YES;
    equipLabel.alpha = 1.f;
  } else {
    equipButton.enabled = NO;
    equipLabel.alpha = 0.75f;
  }
  
  if (!fep.isBuyableInArmory || fep.diamondPrice > 0) {
    sellButton.enabled = NO;
  } else {
    sellButton.enabled = YES;
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
  if (self.superview) {
    [[ProfileViewController sharedProfileViewController] loadMyProfile];
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
      [self removeFromSuperview];
    }];
    
    [self.mktPostView closeClicked:nil];
  }
}

- (IBAction)wrongClassClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable by %@s.", titleLabel.text, classLabel.text]];
}

- (IBAction)tooLowLevelClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable at Level %@.", titleLabel.text, levelLabel.text]];
}

- (IBAction)equipItemClicked:(id)sender {
  [[ProfileViewController sharedProfileViewController] doEquip:userEquip];
  [self closeClicked:nil];
}

//- (IBAction)sellClicked:(id)sender {
//  GameState *gs = [GameState sharedGameState];
//  FullEquipProto *fep = [gs equipWithId:userEquip.equipId];
//  int sellAmt = fep.coinPrice ? [[Globals sharedGlobals] calculateEquipSilverSellCost:userEquip] : [[Globals sharedGlobals] calculateEquipGoldSellCost:userEquip];
//  NSString *str = [NSString stringWithFormat:@"Sell for %d %@?", sellAmt, fep.coinPrice ? @"silver" : @"gold"];
//  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Sell" cancelButton:nil target:self selector:@selector(sellItem)];
//}

//- (void) sellItem {
//  [[OutgoingEventController sharedOutgoingEventController] sellEquip:userEquip.equipId];
//  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:userEquip.equipId];
//  Globals *gl = [Globals sharedGlobals];
//
//  int price = fep.coinPrice > 0 ? [gl calculateEquipSilverSellCost:userEquip] : [gl calculateEquipGoldSellCost:userEquip];
//  CGPoint startLoc = wallIcon.center;
//  startLoc = [self.superview convertPoint:startLoc fromView:self];
//
//  UIView *testView = [EquipDeltaView
//                      createForUpperString:[NSString stringWithFormat:@"+ %d",
//                                            price]
//                      andLowerString:[NSString stringWithFormat:@"-1 %@", fep.name]
//                      andCenter:startLoc
//                      topColor:[Globals greenColor]
//                      botColor:[Globals colorForRarity:fep.rarity]];
//
//  [Globals popupView:testView
//         onSuperView:self.superview
//             atPoint:startLoc
// withCompletionBlock:nil];
//
//  if (userEquip.quantity <= 0) {
//    [self closeClicked:nil];
//  }
//}

- (IBAction)postClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.level < gl.minLevelConstants.marketplaceMinLevel) {
    [Globals popupMessage:[NSString stringWithFormat:@"You cannot post to the marketplace until level %d.", gl.minLevelConstants.marketplaceMinLevel]];
  } else {
    [self.mktPostView updateForEquip:userEquip andAddToSuperView:self.superview];
  }
}

- (IBAction)postOkayClicked:(id)sender
{
  [[OutgoingEventController sharedOutgoingEventController] equipPostToMarketplace:userEquip.userEquipId price:[self.mktPostView.postedPriceTextField.text intValue]];
  [self.mktPostView closeClicked:nil];
  
  [self closeClicked:nil];
}

- (void) dealloc {
  self.titleLabel = nil;
  self.classLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.typeLabel = nil;
  self.levelLabel = nil;
  self.equipIcon = nil;
  self.levelIcon = nil;
  self.enhanceIcon = nil;
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
  [nameLabel setTitle:[Globals fullNameWithName:wallPost.poster.name clanTag:wallPost.poster.clan.tag] forState:UIControlStateNormal];
  timeLabel.text = [Globals stringForTimeSinceNow:[NSDate dateWithTimeIntervalSince1970:wallPost.timeOfPost/1000.0] shortened:NO];
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
  if (!wallPosts) {
    [Globals popupMessage:@"Please wait! Retrieving current wall posts."];
    [self endEditing];
    return;
  }
  
  NSString *content = wallTextField.text;
  if (content.length > 0) {
    ProfileViewController *pvc = [ProfileViewController sharedProfileViewController];
    int userId = pvc.userId;
    PlayerWallPostProto *wallPost = [[OutgoingEventController sharedOutgoingEventController] postToPlayerWall:userId withContent:content];
    
    GameState *gs = [GameState sharedGameState];
    if ([Globals userType:gs.type isAlliesWith:pvc.fup.userType]) {
      [Analytics postedToAllyProfile];
    } else {
      [Analytics postedToEnemyProfile];
    }
    
    if (wallPost) {
      [self.wallPosts insertObject:wallPost atIndex:0];
      [self displayNewWallPost];
    }
    
    wallTextField.text = @"";
  }
  [self endEditing];
}

- (void) displayNewWallPost {
  int old = [self.wallTableView numberOfRowsInSection:0];
  int new = self.wallPosts.count;
  
  if (old+1 == new) {
    self.wallTableView.contentOffset = ccp(0,0);
    [self.wallTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  Globals *gl = [Globals sharedGlobals];
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > gl.maxCharLengthForWallPost) {
    return NO;
  }
  return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [self postToWall:nil];
  return YES;
}

- (IBAction)visitProfile:(id)sender {
  UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
  NSIndexPath *path = [wallTableView indexPathForCell:cell];
  PlayerWallPostProto *proto = [wallPosts objectAtIndex:path.row];
  
  [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:proto.poster withState:kProfileState];
}

- (void) dealloc {
  self.wallPosts = nil;
  self.wallTableView = nil;
  self.wallTextField = nil;
  self.postCell = nil;
  [super dealloc];
}

@end

@implementation EquipTabView

- (void) setUpCurEquipViewsWithDelegate:(id<EquipViewDelegate>)delegate {
  NSMutableArray *arr = [NSMutableArray array];
  
  float baseX = self.scrollView.frame.size.width/6.f;
  float baseY = self.scrollView.frame.size.height/2.f;
  int i;
  for (i = 0; i < 6; i++) {
    [[NSBundle mainBundle] loadNibNamed:@"EquipView" owner:self options:nil];
    EquipView *ev = self.nibEquipView;
    ev.center = ccp(baseX*(2*i+1), baseY);
    ev.delegate = delegate;
    ev.tag = i;
    [self.scrollView addSubview:ev];
    [arr addObject:ev];
    
    if (i > 0) {
      UIImageView *divider = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"equipdivider.png"]];
      divider.center = ccp(baseX*(2*i), baseY);
      [self.scrollView addSubview:divider];
      [divider release];
    }
  }
  self.scrollView.contentSize = CGSizeMake(baseX*(2*i), self.scrollView.frame.size.height);
  self.curEquipViews = arr;
}

- (void) updateForEquips:(NSArray *)equips isMine:(BOOL)mine prestigeLevel:(int)prestigeLevel {
  for (int i = 0; i < self.curEquipViews.count; i++) {
    EquipView *ev = [self.curEquipViews objectAtIndex:i];
    id eq = [equips objectAtIndex:i];
    if ([eq isKindOfClass:[UserEquip class]]) {
      [ev updateForEquip:eq];
    } else {
      if (i > 2+prestigeLevel) {
        [ev updateForNotEnoughPrestiges:i-2];
      } else {
        [ev updateForNoEquipIsMine:mine type:i%3];
      }
    }
  }
  
  Globals *gl = [Globals sharedGlobals];
  UserEquip *weapon = [(EquipView *)[self.curEquipViews objectAtIndex:0] equip];
  UserEquip *armor = [(EquipView *)[self.curEquipViews objectAtIndex:1] equip];
  UserEquip *amulet = [(EquipView *)[self.curEquipViews objectAtIndex:2] equip];
  self.attackLabel.text = [Globals commafyNumber:[gl calculateAttackForAttackStat:0 weapon:weapon armor:armor amulet:amulet]];
  self.defenseLabel.text = [Globals commafyNumber:[gl calculateDefenseForDefenseStat:0 weapon:weapon armor:armor amulet:amulet]];
  
  self.scrollView.contentOffset = ccp(0,0);
}

- (void) dealloc {
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.scrollView = nil;
  self.nibEquipView = nil;
  self.curEquipViews = nil;
  [super dealloc];
}

@end

@implementation EquipTableViewDelegate

- (void) loadEquips:(NSArray *)equips withDelegate:(id<EquipViewDelegate>)delegate {
  [_equips release];
  _equips = [equips retain];
  _delegate = delegate;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (void) loadEquipsForScope:(EquipScope)scope {
  [_equipsForScope release];
  _equipsForScope = [[NSMutableArray alloc] init];
  
  GameState *gs = [GameState sharedGameState];
  for (UserEquip *ue in _equips) {
    FullEquipProto *fep = [gs equipWithId:ue.equipId];
    if (scope == kEquipScopeWeapons && fep.equipType == FullEquipProto_EquipTypeWeapon) {
      [_equipsForScope addObject:ue];
    } else if (scope == kEquipScopeArmor && fep.equipType == FullEquipProto_EquipTypeArmor) {
      [_equipsForScope addObject:ue];
    } else if (scope == kEquipScopeAmulets && fep.equipType == FullEquipProto_EquipTypeAmulet) {
      [_equipsForScope addObject:ue];
    }
  }
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _equipsForScope.count > 0 ? (_equipsForScope.count-1)/3+1 : 0;
}
int x = 0;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EquipBrowseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EquipBrowseCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"EquipBrowseCell" owner:self options:nil];
    cell = self.browseCell;
  }
  
  int row = indexPath.row;
  UserEquip *ue1 = [_equipsForScope objectAtIndex:row*3];
  UserEquip *ue2 = _equipsForScope.count > row*3+1 ? [_equipsForScope objectAtIndex:row*3+1] : nil;
  UserEquip *ue3 = _equipsForScope.count > row*3+2 ? [_equipsForScope objectAtIndex:row*3+2] : nil;
  [cell.containerView1.nibEquipView updateForEquip:ue1];
  [cell.containerView2.nibEquipView updateForEquip:ue2];
  [cell.containerView3.nibEquipView updateForEquip:ue3];
  cell.containerView1.nibEquipView.delegate = _delegate;
  cell.containerView2.nibEquipView.delegate = _delegate;
  cell.containerView3.nibEquipView.delegate = _delegate;
  cell.containerView1.nibEquipView.tag = EQUIP_BROWSE_VIEW_TAG;
  cell.containerView2.nibEquipView.tag = EQUIP_BROWSE_VIEW_TAG;
  cell.containerView3.nibEquipView.tag = EQUIP_BROWSE_VIEW_TAG;
  
  //  GameState *gs = [GameState sharedGameState];
  //  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  //  if (fep.equipType == FullEquipProto_EquipTypeWeapon && ue.userEquipId == _weaponId) {
  //    cell.border.hidden = NO;
  //  } else if (fep.equipType == FullEquipProto_EquipTypeArmor && ue.userEquipId == _armorId) {
  //    cell.border.hidden = NO;
  //  } else if (fep.equipType == FullEquipProto_EquipTypeAmulet && ue.userEquipId == _amuletId) {
  //    cell.border.hidden = NO;
  //  } else {
  //    cell.border.hidden = YES;
  //  }
  
  return cell;
}

- (void) dealloc {
  [_equips release];
  self.browseCell = nil;
  [super dealloc];
}

@end

@implementation EquipBrowseCell

- (void) dealloc {
  self.containerView1 = nil;
  self.containerView2 = nil;
  self.containerView3 = nil;
  [super dealloc];
}

@end

@implementation ProfileEquipContainerView

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"EquipView" owner:self options:nil];
  [self addSubview:self.nibEquipView];
  self.nibEquipView.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
  self.backgroundColor = [UIColor clearColor];
}

- (void) dealloc {
  self.nibEquipView = nil;
  [super dealloc];
}

@end

@implementation ProfileEquipBrowseView

- (void) awakeFromNib {
  EquipTableViewDelegate *del = [[EquipTableViewDelegate alloc] init];
  self.equipTable.delegate = del;
  self.equipTable.dataSource = del;
  self.equipsTableDelegate = del;
  [del release];
  
  [[NSBundle mainBundle] loadNibNamed:@"EquipView" owner:self options:nil];
  [self.mainView addSubview:self.nibEquipView];
  self.nibEquipView.hidden = YES;
}

- (void) loadForEquips:(NSArray *)equips curEquips:(NSArray *)curEquips prestigeLevel:(int)prestigeLevel isMe:(BOOL)isMe {
  [self.equipsTableDelegate loadEquips:equips withDelegate:[ProfileViewController sharedProfileViewController]];
  self.curEquips = curEquips;
  [self updateForScope:self.curScope isSlot2:_isFlipped];
  _prestigeLevel = prestigeLevel;
  _isMe = isMe;
}

- (void) updateForScope:(EquipScope)scope isSlot2:(BOOL)isSlot2 {
  [self.equipsTableDelegate loadEquipsForScope:scope];
  [self.equipTable reloadData];
  [self updateSlotForScope:scope isSlot2:isSlot2];
  
  if (scope != _curScope) {
    self.equipTable.contentOffset = ccp(0,0);
  }
  
  [self.browseBar updateForScope:scope];
  
  if (isSlot2) {
    [self flipSlots];
  } else {
    [self unflipSlots];
  }
  _curScope = scope;
}

- (void) updateSlotForScope:(EquipScope)scope isSlot2:(BOOL)isSlot2 {
  int index = (scope - 1) + (isSlot2 ? 3 : 0);
  if (index < 0 || index >= self.curEquips.count) {
    return;
  }
  
  id ue = [self.curEquips objectAtIndex:index];
  
  if ([ue isKindOfClass:[NSNull class]]) {
    if (isSlot2 && scope > _prestigeLevel) {
      [self.equipContainerView.nibEquipView updateForNotEnoughPrestiges:scope];
    } else {
      [self.equipContainerView.nibEquipView updateForNoEquipIsMine:NO type:scope-1];
    }
  } else {
    [self.equipContainerView.nibEquipView updateForEquip:ue];
  }
}

- (IBAction)backSlotClicked:(id)sender {
  if (_isFlipped) {
    [self updateForScope:self.curScope isSlot2:NO];
  } else {
    [self updateForScope:self.curScope isSlot2:YES];
  }
}

- (IBAction)closeClicked:(id)sender {
  if (self.superview) {
    [[ProfileViewController sharedProfileViewController] loadMyProfile];
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
      [self removeFromSuperview];
    }];
    _curScope = 0;
  }
}

- (void) flipSlots {
  self.mainSlotView.transform = CGAffineTransformMakeScale(-1, 1);
  self.backSlotView.transform = CGAffineTransformMakeScale(-1, 1);
  
  CGRect r = self.backSlotView.frame;
  r.origin.x = self.mainSlotView.frame.origin.x;
  self.backSlotView.frame = r;
  
  _isFlipped = YES;
}

- (void) unflipSlots {
  self.mainSlotView.transform = CGAffineTransformIdentity;
  self.backSlotView.transform = CGAffineTransformIdentity;
  
  CGRect r = self.backSlotView.frame;
  r.origin.x = CGRectGetMaxX(self.mainSlotView.frame)-r.size.width;
  self.backSlotView.frame = r;
  
  _isFlipped = NO;
}

- (void) doEquippingAnimation:(UserEquip *)ue withNewCurEquipArray:(NSArray *)curEquips {
  EquipView *ev = nil;
  for (EquipBrowseCell *e in self.equipTable.visibleCells) {
    if (e.containerView1.nibEquipView.equip.userEquipId == ue.userEquipId) {
      ev = e.containerView1.nibEquipView;
    } else if (e.containerView2.nibEquipView.equip.userEquipId == ue.userEquipId) {
      ev = e.containerView2.nibEquipView;
    } else if (e.containerView3.nibEquipView.equip.userEquipId == ue.userEquipId) {
      ev = e.containerView3.nibEquipView;
    }
  }
  
  if (ev) {
    EquipView *equippingView = self.nibEquipView;
    
    equippingView.frame = [self.mainView convertRect:ev.frame fromView:ev.superview];
    [equippingView updateForEquip:ev.equip];
    equippingView.hidden = NO;
    [equippingView.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.3f animations:^{
      equippingView.frame = [self.mainView convertRect:self.equipContainerView.nibEquipView.frame fromView:self.equipContainerView];
      self.equipContainerView.alpha = 0.f;
    } completion:^(BOOL finished) {
      equippingView.hidden = YES;
      [self.equipContainerView.nibEquipView updateForEquip:ev.equip];
      self.equipContainerView.alpha = 1.f;
      
      self.curEquips = curEquips;
    }];
  }
}

- (void) dealloc {
  self.mainSlotView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.backSlotView = nil;
  self.nibEquipView = nil;
  self.equipTable = nil;
  [super dealloc];
}

@end