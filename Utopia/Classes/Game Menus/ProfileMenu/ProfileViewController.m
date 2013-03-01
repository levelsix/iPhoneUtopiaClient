//
//  ProfileViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfileViewController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "BattleLayer.h"
#import "GenericPopupController.h"
#import "EquipMenuController.h"
#import "EquipDeltaView.h"
//#import "KiipDelegate.h"
#import "RefillMenuController.h"
#import "CharSelectionViewController.h"
#import "ArmoryViewController.h"
#import "ClanMenuController.h"

#define EQUIPS_VERTICAL_SEPARATION 3.f
#define EQUIPS_HORIZONTAL_SEPARATION 1.f

#define SHAKE_DURATION 0.2f
#define SHAKE_OFFSET 3.f

#define EQUIPPING_DURATION 0.5f

#define WALL_POST_LABEL_MIN_Y 28.75
#define WALL_POST_CELL_OFFSET 5
#define WALL_POST_FONT [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:15]
#define WALL_POST_LABEL_WIDTH 242

#define PRICE_DIGITS 7

@implementation ProfileBar

@synthesize state = _state;
@synthesize equipIcon, skillsIcon, profileIcon, specialIcon;
@synthesize equipLabel, skillsLabel, profileLabel, specialLabel;
@synthesize equipButton, skillsButton, profileButton, specialButton;
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
  [self clickButton:kProfileButton];
  [self unclickButton:kEquipButton];
  [self unclickButton:kSkillsButton];
  [self unclickButton:kSpecialButton];
}

- (void) incrementProfileBadge {
  if ([ProfileViewController sharedProfileViewController].state != kProfileState || _state != kMyProfile) {
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
    [self clickButton:kProfileButton];
    [self unclickButton:kEquipButton];
    [self unclickButton:kSkillsButton];
    [self unclickButton:kSpecialButton];
    
    if (_state == kMyProfile) {
      [self clearProfileBadge];
    }
  } else if (s == kEquipState) {
    [self clickButton:kEquipButton];
    [self unclickButton:kProfileButton];
    [self unclickButton:kSkillsButton];
    [self unclickButton:kSpecialButton];
  } else if (s == kSkillsState) {
    [self clickButton:kSkillsButton];
    [self unclickButton:kProfileButton];
    [self unclickButton:kEquipButton];
    [self unclickButton:kSpecialButton];
  } else if (s == kSpecialState) {
    [self clickButton:kSpecialButton];
    [self unclickButton:kProfileButton];
    [self unclickButton:kSkillsButton];
    [self unclickButton:kEquipButton];
  }
}

- (void) clickButton:(ProfileBarButton)button {
  switch (button) {
    case kProfileButton:
      profileIcon.highlighted = YES;
      profileLabel.highlighted = YES;
      profileButton.highlighted = YES;
      _clickedButtons |= kProfileButton;
      break;
      
    case kSkillsButton:
      if (self.state == kMyProfile) {
        skillsIcon.highlighted = YES;
        skillsLabel.highlighted = YES;
        skillsButton.highlighted = YES;
        _clickedButtons |= kSkillsButton;
      }
      break;
      
    case kEquipButton:
      equipIcon.highlighted = YES;
      equipLabel.highlighted = YES;
      equipButton.highlighted = YES;
      _clickedButtons |= kEquipButton;
      break;
      
    case kSpecialButton:
      if (self.state == kMyProfile) {
        specialIcon.highlighted = YES;
        specialLabel.highlighted = YES;
        specialButton.highlighted = YES;
        _clickedButtons |= kSpecialButton;
      }
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(ProfileBarButton)button {
  switch (button) {
    case kProfileButton:
      profileIcon.highlighted = NO;
      profileLabel.highlighted = NO;
      profileButton.highlighted = NO;
      _clickedButtons &= ~kProfileButton;
      break;
      
    case kSkillsButton:
      skillsIcon.highlighted = NO;
      skillsLabel.highlighted = NO;
      skillsButton.highlighted = NO;
      _clickedButtons &= ~kSkillsButton;
      break;
      
    case kEquipButton:
      equipIcon.highlighted = NO;
      equipLabel.highlighted = NO;
      equipButton.highlighted = NO;
      _clickedButtons &= ~kEquipButton;
      break;
      
    case kSpecialButton:
      specialIcon.highlighted = NO;
      specialLabel.highlighted = NO;
      specialButton.highlighted = NO;
      _clickedButtons &= ~kSpecialButton;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:profileButton];
  if (!(_clickedButtons & kProfileButton) && [profileButton pointInside:pt withEvent:nil]) {
    _trackingProfile = YES;
    [self clickButton:kProfileButton];
  }
  
  pt = [touch locationInView:equipButton];
  if (!(_clickedButtons & kEquipButton) && [equipButton pointInside:pt withEvent:nil]) {
    _trackingEquip = YES;
    [self clickButton:kEquipButton];
  }
  
  if (self.state == kMyProfile) {
    pt = [touch locationInView:skillsButton];
    if (!(_clickedButtons & kSkillsButton) && [skillsButton pointInside:pt withEvent:nil]) {
      _trackingSkills = YES;
      [self clickButton:kSkillsButton];
    }
    
    pt = [touch locationInView:specialButton];
    if (!(_clickedButtons & kSpecialButton) && [specialButton pointInside:pt withEvent:nil]) {
      _trackingSpecial = YES;
      [self clickButton:kSpecialButton];
    }
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:profileButton];
  if (_trackingProfile) {
    if (CGRectContainsPoint(CGRectInset(profileButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton];
    } else {
      [self unclickButton:kProfileButton];
    }
  }
  
  pt = [touch locationInView:skillsButton];
  if (_trackingSkills) {
    if (CGRectContainsPoint(CGRectInset(skillsButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kSkillsButton];
    } else {
      [self unclickButton:kSkillsButton];
    }
  }
  
  pt = [touch locationInView:equipButton];
  if (_trackingEquip) {
    if (CGRectContainsPoint(CGRectInset(equipButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kEquipButton];
    } else {
      [self unclickButton:kEquipButton];
    }
  }
  
  pt = [touch locationInView:specialButton];
  if (_trackingSpecial) {
    if (CGRectContainsPoint(CGRectInset(specialButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kSpecialButton];
    } else {
      [self unclickButton:kSpecialButton];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:profileButton];
  if (_trackingProfile) {
    if (CGRectContainsPoint(CGRectInset(profileButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kProfileButton];
      [self unclickButton:kEquipButton];
      [self unclickButton:kSkillsButton];
      [self unclickButton:kSpecialButton];
      [[ProfileViewController sharedProfileViewController] setState:kProfileState];
    } else {
      [self unclickButton:kProfileButton];
    }
  }
  
  pt = [touch locationInView:skillsButton];
  if (_trackingSkills) {
    if (CGRectContainsPoint(CGRectInset(skillsButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kSkillsButton];
      [self unclickButton:kEquipButton];
      [self unclickButton:kProfileButton];
      [self unclickButton:kSpecialButton];
      [[ProfileViewController sharedProfileViewController] setState:kSkillsState];
    } else {
      [self unclickButton:kSkillsButton];
    }
  }
  
  pt = [touch locationInView:equipButton];
  if (_trackingEquip) {
    if (CGRectContainsPoint(CGRectInset(equipButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kEquipButton];
      [self unclickButton:kProfileButton];
      [self unclickButton:kSkillsButton];
      [self unclickButton:kSpecialButton];
      [[ProfileViewController sharedProfileViewController] setState:kEquipState];
    } else {
      [self unclickButton:kEquipButton];
    }
  }
  
  pt = [touch locationInView:specialButton];
  if (_trackingSpecial) {
    if (CGRectContainsPoint(CGRectInset(specialButton.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kSpecialButton];
      [self unclickButton:kEquipButton];
      [self unclickButton:kSkillsButton];
      [self unclickButton:kProfileButton];
      [[ProfileViewController sharedProfileViewController] setState:kSpecialState];
    } else {
      [self unclickButton:kSpecialButton];
    }
  }
  
  _trackingProfile = NO;
  _trackingEquip = NO;
  _trackingSkills = NO;
  _trackingSpecial = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kProfileButton];
  [self unclickButton:kEquipButton];
  [self unclickButton:kSkillsButton];
  [self unclickButton:kProfileButton];
  _trackingProfile = NO;
  _trackingEquip = NO;
  _trackingSkills = NO;
  _trackingSpecial = NO;
}

- (void) dealloc {
  self.equipIcon = nil;
  self.skillsIcon = nil;
  self.profileIcon = nil;
  self.specialIcon = nil;
  self.equipLabel = nil;
  self.skillsLabel = nil;
  self.profileLabel = nil;
  self.specialLabel = nil;
  self.equipButton = nil;
  self.skillsButton = nil;
  self.profileButton = nil;
  self.specialButton = nil;
  self.profileBadgeView = nil;
  self.profileBadgeLabel = nil;
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

- (void) awakeFromNib {
  int offset = 2.5;
  CGRect rect = CGRectMake(offset, offset, self.bounds.size.width-2*offset, self.bounds.size.height-2*offset);
  darkOverlay = [[UIView alloc] initWithFrame:rect];
  darkOverlay.layer.cornerRadius = 2.5f;
  darkOverlay.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
  darkOverlay.hidden = YES;
  [self insertSubview:darkOverlay belowSubview:levelIcon];
}

- (void) updateForEquip:(UserEquip *)ue {
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
  attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  //  equipIcon.image = [Globals imageForEquip:fuep.equipId];
  [Globals loadImageForEquip:fep.equipId toView:equipIcon maskedView:nil];
  nameLabel.text = fep.name;
  nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  levelIcon.level = ue.level;
  _enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
  
  self.equip = ue;
  
  if ([Globals canEquip:fep]) {
    bgd.highlighted = NO;
  } else {
    bgd.highlighted = YES;
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
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
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
  [super dealloc];
}

@end

@implementation CurrentEquipView

@synthesize equipIcon, levelIcon, selectedView, typeLabel;
@synthesize knownView, unknownView;
@synthesize selected = _selected;

- (void) awakeFromNib {
  self.selectedView.hidden = YES;
}

- (void) setSelected:(BOOL)selected {
  if (selected != _selected) {
    _selected = selected;
    self.selectedView.hidden = !_selected;
  }
}

- (void) unknownEquip {
  equipIcon.hidden = YES;
  equipIcon.image = nil;
  levelIcon.level = 0;
  _enhanceIcon.level = 0;
  self.knownView.hidden = YES;
  self.unknownView.hidden = NO;
}

- (void) knownEquip {
  equipIcon.hidden = NO;
  equipIcon.image = nil;
  self.knownView.hidden = NO;
  self.unknownView.hidden = YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!_selected) {
    selectedView.hidden = NO;
    typeLabel.highlighted = NO;
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!_selected) {
    if ([self pointInside:[[touches anyObject] locationInView:self] withEvent:event]) {
      selectedView.hidden = NO;
      typeLabel.highlighted = NO;
    } else {
      selectedView.hidden = YES;
      typeLabel.highlighted = YES;
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!_selected) {
    if ([self pointInside:[[touches anyObject] locationInView:self] withEvent:event]) {
      self.selected = YES;
      [[ProfileViewController sharedProfileViewController] currentEquipViewSelected:self];
    }
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!_selected) {
    selectedView.hidden = YES;
    typeLabel.highlighted = YES;
  }
}

- (void) dealloc {
  self.equipIcon = nil;
  self.levelIcon = nil;
  self.enhanceIcon = nil;
  self.selectedView = nil;
  self.typeLabel = nil;
  self.knownView = nil;
  self.unknownView = nil;
  
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
//  CGPoint startLoc = equipIcon.center;
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

@implementation EquipTableViewDelegate

@synthesize nibEquipView;

- (void) loadEquips:(NSArray *)equips curWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet {
  [_equips release];
  _equips = [equips retain];
  [self setCurWeapon:weapon curArmor:armor curAmulet:amulet];
}

- (void) setCurWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet {
  _weaponId = weapon;
  _armorId = armor;
  _amuletId = amulet;
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
  return _equipsForScope.count;
}
int x = 0;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EquipView *cell = [tableView dequeueReusableCellWithIdentifier:@"EquipView"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"EquipView" owner:self options:nil];
    cell = self.nibEquipView;
  }
  
  UserEquip *ue = [_equipsForScope objectAtIndex:indexPath.row];
  [cell updateForEquip:ue];
  cell.tag = ue.userEquipId;
  
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  if (fep.equipType == FullEquipProto_EquipTypeWeapon && ue.userEquipId == _weaponId) {
    cell.border.hidden = NO;
  } else if (fep.equipType == FullEquipProto_EquipTypeArmor && ue.userEquipId == _armorId) {
    cell.border.hidden = NO;
  } else if (fep.equipType == FullEquipProto_EquipTypeAmulet && ue.userEquipId == _amuletId) {
    cell.border.hidden = NO;
  } else {
    cell.border.hidden = YES;
  }
  
  return cell;
}

- (void) dealloc {
  [_equips release];
  self.nibEquipView = nil;
  [super dealloc];
}

@end

@implementation ProfileViewController

@synthesize state = _state, curScope = _curScope;
@synthesize clanButton;
@synthesize userNameLabel, typeLabel, levelLabel, attackLabel, defenseLabel, codeLabel;
@synthesize winsLabel, lossesLabel, fleesLabel;
@synthesize curArmorView, curAmuletView, curWeaponView;
@synthesize profilePicture, profileBar;
@synthesize equipsTableView;
@synthesize equippingView, equipTabView, skillTabView, wallTabView;
@synthesize attackStatLabel, defenseStatLabel, staminaStatLabel, energyStatLabel;
@synthesize attackStatButton, defenseStatButton, staminaStatButton, energyStatButton;
@synthesize enemyAttackLabel, enemyMiddleView;
@synthesize staminaCostLabel, skillPointsLabel;
@synthesize selfLeftView, enemyLeftView, friendLeftView;
@synthesize visitButton, smallAttackButton, bigAttackButton;
@synthesize spinner;
@synthesize mainView, bgdView, loadingView;
@synthesize fup = _fup;
@synthesize userId;
@synthesize equipPopup;
@synthesize specialTabView, profileTabView;
@synthesize nameChangeView, nameChangeTextField, equipHeaderLabel;
@synthesize equipsTableDelegate;
@synthesize noEquipLabel, noEquipMiddleView, noEquipButtonView;
@synthesize clanView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ProfileViewController);

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  equippingView = [[UIImageView alloc] init];
  equippingView.contentMode = UIViewContentModeScaleAspectFit;
  [equipTabView addSubview:equippingView];
  equippingView.hidden = YES;
  
  skillTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:skillTabView aboveSubview:profileTabView];
  
  specialTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:specialTabView aboveSubview:profileTabView];
  
  equipTabView.frame = profileTabView.frame;
  [self.mainView insertSubview:equipTabView aboveSubview:profileTabView];
  
  enemyMiddleView.frame = equipsTableView.frame;
  [equipTabView addSubview:enemyMiddleView];
  
  noEquipMiddleView.frame = equipsTableView.frame;
  [equipTabView addSubview:noEquipMiddleView];
  
  enemyLeftView.frame = selfLeftView.frame;
  [selfLeftView.superview addSubview:enemyLeftView];
  
  friendLeftView.frame = enemyLeftView.frame;
  [selfLeftView.superview addSubview:friendLeftView];
  
  // Start state at 0 so that when it gets unloaded it won't be ignored
  _state = 0;
  self.state = kProfileState;
  _curScope = kEquipScopeWeapons;
  self.curWeaponView.selected = YES;
  
  EquipTableViewDelegate *del = [[EquipTableViewDelegate alloc] init];
  self.equipsTableView.delegate = del;
  self.equipsTableView.dataSource = del;
  self.equipsTableDelegate = del;
  [del release];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self refreshSkillPointsButtons];
}

- (void) viewDidDisappear:(BOOL)animated {
  [Globals endPulseForView:attackStatButton];
  [Globals endPulseForView:defenseStatButton];
  [Globals endPulseForView:energyStatButton];
  [Globals endPulseForView:staminaStatButton];
  
  self.fup = nil;
}

- (void) setState:(ProfileState)state {
  switch (state) {
    case kProfileState:
      profileTabView.hidden = NO;
      equipTabView.hidden = YES;
      skillTabView.hidden = YES;
      specialTabView.hidden = YES;
      [self.profileBar setProfileState:state];
      break;
      
    case kEquipState:
      profileTabView.hidden = YES;
      equipTabView.hidden = NO;
      skillTabView.hidden = YES;
      specialTabView.hidden = YES;
      [self.profileBar setProfileState:state];
      break;
      
    case kSkillsState:
      profileTabView.hidden = YES;
      equipTabView.hidden = YES;
      skillTabView.hidden = NO;
      specialTabView.hidden = YES;
      [self.profileBar setProfileState:state];
      break;
      
    case kSpecialState:
      profileTabView.hidden = YES;
      equipTabView.hidden = YES;
      skillTabView.hidden = YES;
      specialTabView.hidden = NO;
      [self.profileBar setProfileState:state];
      break;
      
    default:
      break;
  }
  _state = state;
  [wallTabView endEditing];
}

- (void) setCurScope:(EquipScope)curScope {
  _curScope = curScope;
  [self updateScrollViewForCurrentScope];
  
  if (_curScope == kEquipScopeWeapons) {
    self.equipHeaderLabel.text = @"ALL WEAPONS";
  } else if (_curScope == kEquipScopeArmor) {
    self.equipHeaderLabel.text = @"ALL ARMOR";
  } else if (_curScope == kEquipScopeAmulets) {
    self.equipHeaderLabel.text = @"ALL AMULETS";
  }
}

- (void) doEquip:(UserEquip *)equip {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:equip.equipId];
  EquipView *e = nil;
  for (EquipView *ev in equipsTableView.visibleCells) {
    if (ev.equip == equip) {
      e = ev;
    }
  }
  
  [[OutgoingEventController sharedOutgoingEventController] wearEquip:equip.userEquipId];
  if (e) {
    [self doEquippingAnimation:e forType:fep.equipType];
    
    GameState *gs = [GameState sharedGameState];
    [self.equipsTableDelegate setCurWeapon:gs.weaponEquipped curArmor:gs.armorEquipped curAmulet:gs.amuletEquipped];
    
    [self.equipsTableView reloadData];
    
    [self displayMyCurrentStats];
  }
}

- (void) doEquippingAnimation:(EquipView *)ev forType:(FullEquipProto_EquipType)type {
  Globals *gl = [Globals sharedGlobals];
  
  equippingView.frame = [equipTabView convertRect:ev.equipIcon.frame fromView:ev.equipIcon.superview];
  equippingView.image = ev.equipIcon.image;
  equippingView.hidden = NO;
  [equippingView.layer removeAllAnimations];
  
  CurrentEquipView *cev;
  
  switch (type) {
    case FullEquipProto_EquipTypeWeapon:
      cev = curWeaponView;
      break;
    case FullEquipProto_EquipTypeArmor:
      cev = curArmorView;
      break;
    case FullEquipProto_EquipTypeAmulet:
      cev = curAmuletView;
      break;
      
    default:
      break;
  }
  
  cev.equipIcon.image = ev.equipIcon.image;
  cev.equipIcon.alpha = 0.25f;
  cev.equipIcon.hidden = NO;
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:EQUIPPING_DURATION];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(finishedEquippingAnimation)];
  
  equippingView.frame = [equipTabView convertRect:cev.equipIcon.frame fromView:cev.equipIcon.superview];
  
  [UIView commitAnimations];
  cev.levelIcon.level = ev.equip.level;
  cev.enhanceIcon.level = [gl calculateEnhancementLevel:ev.equip.enhancementPercentage];
}

- (void) finishedEquippingAnimation {
  equippingView.hidden = YES;
  curWeaponView.equipIcon.alpha = 1.f;
  curArmorView.equipIcon.alpha = 1.f;
  curAmuletView.equipIcon.alpha = 1.f;
}

- (void) equipViewSelected:(EquipView *)ev {
  GameState *gs = [GameState sharedGameState];
  UserEquip *fuep = ev.equip;
  if (profileBar.state == kMyProfile && fuep.userId == gs.userId) {
    // The fuep is actually a UserEquip.. see @selector(loadMyProfile)
    [equipPopup updateForUserEquip:(UserEquip *)fuep];
    [self.view addSubview:equipPopup];
    [Globals bounceView:equipPopup.mainView fadeInBgdView:equipPopup.bgdView];
    equipPopup.frame = self.view.bounds;
  } else {
    [EquipMenuController displayViewForEquip:fuep.equipId level:fuep.level enhancePercent:fuep.enhancementPercentage];
  }
}

- (void) currentEquipViewSelected:(CurrentEquipView *)cev {
  EquipScope scope = 0;
  
  if (cev == curWeaponView) {
    scope = kEquipScopeWeapons;
    curWeaponView.selected = YES;
    curArmorView.selected = NO;
    curAmuletView.selected = NO;
  } else if (cev == curArmorView) {
    scope = kEquipScopeArmor;
    curWeaponView.selected = NO;
    curArmorView.selected = YES;
    curAmuletView.selected = NO;
  } else if (cev == curAmuletView) {
    scope = kEquipScopeAmulets;
    curWeaponView.selected = NO;
    curArmorView.selected = NO;
    curAmuletView.selected = YES;
  } else {
    [Globals popupMessage:@"Error attaining scope value"];
  }
  
  self.curScope = scope;
  
  [self.equipsTableView setContentOffset:CGPointMake(0, -self.equipsTableView.contentInset.top) animated:YES];
}

- (NSArray *) sortEquips:(NSArray *)equips {
  NSMutableArray *arr = [equips mutableCopy];
  Globals *gl = [Globals sharedGlobals];
  
  [arr sortUsingComparator:^NSComparisonResult(UserEquip *obj1, UserEquip *obj2) {
    int compAttack = [gl calculateAttackForEquip:obj1.equipId level:obj1.level enhancePercent:obj1.enhancementPercentage];
    int compDefense = [gl calculateDefenseForEquip:obj1.equipId level:obj1.level enhancePercent:obj1.enhancementPercentage];
    int bestAttack = [gl calculateAttackForEquip:obj2.equipId level:obj2.level enhancePercent:obj2.enhancementPercentage];
    int bestDefense = [gl calculateDefenseForEquip:obj2.equipId level:obj2.level enhancePercent:obj2.enhancementPercentage];
    
    if (compAttack+compDefense > bestDefense+bestAttack) {
      return NSOrderedAscending;
    } else if (compAttack+compDefense < bestDefense+bestAttack) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }];
  
  return arr;
}

- (void) updateScrollViewForCurrentScope {
  [self.equipsTableDelegate loadEquipsForScope:self.curScope];
  [self.equipsTableView reloadData];
  
  int numRows = [self.equipsTableView numberOfRowsInSection:0];
  if (numRows == 0) {
    GameState *gs = [GameState sharedGameState];
    
    NSString *equipType = nil;
    if (self.curScope == kEquipScopeWeapons) {
      equipType = @"Weapons";
    } else if (self.curScope == kEquipScopeArmor) {
      equipType = @"Armor";
    } else if (self.curScope == kEquipScopeAmulets) {
      equipType = @"Amulets";
    }
    
    if (self.userId == gs.userId) {
      self.noEquipMiddleView.hidden = NO;
      self.noEquipButtonView.hidden = NO;
      
      self.noEquipLabel.text = [NSString stringWithFormat:@"You do not have any %@ to equip.", equipType];
    } else if (_fup && !_waitingForEquips) {
      BOOL isEnemy = ![Globals userType:gs.type isAlliesWith:_fup.userType];
      if (!isEnemy) {
        self.noEquipMiddleView.hidden = NO;
        self.noEquipButtonView.hidden = YES;
        self.noEquipLabel.text = [NSString stringWithFormat:@"%@ does not have any %@.", _fup.name, equipType];
      } else {
        self.noEquipMiddleView.hidden = YES;
      }
    } else {
      self.noEquipMiddleView.hidden = YES;
    }
  } else {
    self.noEquipMiddleView.hidden = YES;
  }
}

- (IBAction)goToArmoryClicked:(id)sender {
  [ArmoryViewController displayView];
}

- (void) loadEquips:(NSArray *)equips curWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL weaponFound = NO, armorFound = NO, amuletFound = NO;
  
  [curWeaponView knownEquip];
  [curArmorView knownEquip];
  [curAmuletView knownEquip];
  
  // Sort equips by equippable and then non-equippable.
  NSMutableArray *equippables = [NSMutableArray array];
  NSMutableArray *unequippables = [NSMutableArray array];
  
  for (UserEquip *ue in equips) {
    FullEquipProto *fep = [gs equipWithId:ue.equipId];
    // this will prevent a crash..
    if (!fep) return;
    if ([Globals canEquip:fep]) {
      [equippables addObject:ue];
    } else {
      [unequippables addObject:ue];
    }
  }
  
  NSMutableArray *sortedEquips = [[self sortEquips:equippables].mutableCopy autorelease];
  [sortedEquips addObjectsFromArray:[self sortEquips:unequippables]];
  
  int i;
  
  for (i = 0; i < sortedEquips.count; i++) {
    UserEquip *ue = [sortedEquips objectAtIndex:i];
    FullEquipProto *fep = [gs equipWithId:ue.equipId];
    
    // check if this item is equipped
    if (ue.userEquipId == weapon && fep.equipType == FullEquipProto_EquipTypeWeapon) {
      curWeaponView.levelIcon.level = ue.level;
      curWeaponView.enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
      [Globals loadImageForEquip:fep.equipId toView:curWeaponView.equipIcon maskedView:nil];
      curWeaponView.equipIcon.hidden = NO;
      weaponFound = YES;
      [sortedEquips removeObjectAtIndex:i];
      [sortedEquips insertObject:ue atIndex:0];
    } else if (ue.userEquipId == armor && fep.equipType == FullEquipProto_EquipTypeArmor) {
      curArmorView.levelIcon.level = ue.level;
      curArmorView.enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
      [Globals loadImageForEquip:fep.equipId toView:curArmorView.equipIcon maskedView:nil];
      curArmorView.equipIcon.hidden = NO;
      armorFound = YES;
      [sortedEquips removeObjectAtIndex:i];
      [sortedEquips insertObject:ue atIndex:0];
    } else if (ue.userEquipId == amulet && fep.equipType == FullEquipProto_EquipTypeAmulet) {
      curAmuletView.levelIcon.level = ue.level;
      curAmuletView.enhanceIcon.level = [gl calculateEnhancementLevel:ue.enhancementPercentage];
      [Globals loadImageForEquip:fep.equipId toView:curAmuletView.equipIcon maskedView:nil];
      curAmuletView.equipIcon.hidden = NO;
      amuletFound = YES;
      [sortedEquips removeObjectAtIndex:i];
      [sortedEquips insertObject:ue atIndex:0];
    }
  }
  
  [self.equipsTableDelegate loadEquips:sortedEquips curWeapon:weapon curArmor:armor curAmulet:amulet];
  
  // Reload the cur scope
  self.curScope = self.curScope;
  
  if (!weaponFound) {
    if (weapon > 0) {
      [Globals popupMessage:@"Unable to find equipped weapon for this player"];
    }
    [curWeaponView unknownEquip];
  }
  if (!armorFound) {
    if (armor > 0) {
      [Globals popupMessage:@"Unable to find equipped armor for this player"];
    }
    [curArmorView unknownEquip];
  }
  if (!amuletFound) {
    if (amulet > 0) {
      [Globals popupMessage:@"Unable to find equipped amulet for this player"];
    }
    [curAmuletView unknownEquip];
  }
}

- (void) loadProfileForPlayer:(FullUserProto *)fup buttonsEnabled:(BOOL)enabled {
  if (fup.userId == [[GameState sharedGameState] userId]) {
    [self loadMyProfile];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  BOOL isEnemy = ![Globals userType:gs.type isAlliesWith:fup.userType];
  
  if (userId != fup.userId) {
    wallTabView.wallPosts = nil;
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:fup.userId];
  }
  
  self.fup = fup;
  self.userId = fup.userId;
  
  userNameLabel.text = fup.name;
  profilePicture.image = [Globals profileImageForUser:fup.userType];
  winsLabel.text = [Globals commafyNumber:fup.battlesWon];
  lossesLabel.text = [Globals commafyNumber:fup.battlesLost];
  fleesLabel.text = [Globals commafyNumber:fup.flees];
  levelLabel.text = [NSString stringWithFormat:@"%d", fup.level];
  typeLabel.text = [NSString stringWithFormat:@"%@ %@", [Globals factionForUserType:fup.userType], [Globals classForUserType:fup.userType]];
  attackLabel.text = @"?";
  defenseLabel.text = @"?";
  
  if (fup.hasClan) {
    [self setClanName:fup.clan.name];
    clanButton.enabled = YES;
  } else {
    [self setClanName:@"No Clan"];
    clanButton.enabled = NO;
  }
  
  _curScope = kEquipScopeWeapons;
  
  equipsTableView.hidden = isEnemy;
  enemyMiddleView.hidden = !isEnemy;
  
  enemyLeftView.hidden = !isEnemy;
  friendLeftView.hidden = isEnemy;
  selfLeftView.hidden = YES;
  
  [self loadEquips:nil curWeapon:0 curArmor:0 curAmulet:0];
  
  enemyAttackLabel.text = [NSString stringWithFormat:@"Attack %@ to see Equipment", fup.name];
  
  self.profileBar.state = kOtherPlayerProfile;
  [self.profileBar setProfileState:self.state];
  
  visitButton.enabled = enabled;
  smallAttackButton.enabled = enabled;
  bigAttackButton.enabled = enabled;
  
  curWeaponView.selected = YES;
  curArmorView.selected = NO;
  curAmuletView.selected = NO;
  self.curScope = kEquipScopeWeapons;
  
  if (self.state == kSkillsState || self.state == kSpecialState) {
    self.state = kProfileState;
  }
  
  if (!isEnemy && !_waitingForEquips) {
    _waitingForEquips = YES;
    [[OutgoingEventController sharedOutgoingEventController] retrieveEquipsForUser:fup.userId];
    [spinner startAnimating];
    self.spinner.hidden = NO;
  } else {
    [spinner stopAnimating];
    self.spinner.hidden = YES;
  }
}

- (NSArray *) createFakeEquipsForFakePlayer:(FullUserProto *)fup {
  
  // Fake the equips for fake players
  NSMutableArray *equips = [NSMutableArray arrayWithCapacity:3];
  
  UserEquip *ue = nil;
  if (fup.weaponEquippedUserEquip.equipId > 0) {
    ue = [UserEquip userEquipWithProto:fup.weaponEquippedUserEquip];
    [equips addObject:ue];
  }
  
  if (fup.armorEquippedUserEquip.equipId > 0) {
    ue = [UserEquip userEquipWithProto:fup.armorEquippedUserEquip];
    [equips addObject:ue];
  }
  
  if (fup.amuletEquippedUserEquip.equipId > 0) {
    ue = [UserEquip userEquipWithProto:fup.amuletEquippedUserEquip];
    [equips addObject:ue];
  }
  return equips;
}

- (void) loadProfileForPlayer:(FullUserProto *)fup equips:(NSArray *)equips attack:(int)attack defense:(int)defense {
  // This method is only used from battle
  
  if (userId != fup.userId) {
    wallTabView.wallPosts = nil;
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:fup.userId];
  }
  
  self.fup = fup;
  self.userId = fup.userId;
  
  [self loadProfileForPlayer:fup buttonsEnabled:YES];
  
  equipsTableView.hidden = NO;
  enemyMiddleView.hidden = YES;
  Globals *globals = [Globals sharedGlobals];
  attack  = [globals calculateAttackForAttackStat:_fup.attack
                                           weapon:_fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil
                                            armor:_fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil
                                           amulet:_fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil];
  
  defense = [globals calculateDefenseForDefenseStat:_fup.defense
                                             weapon:_fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil
                                              armor:_fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil
                                             amulet:_fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil];
  attackLabel.text = [NSString stringWithFormat:@"%d", attack];
  defenseLabel.text = [NSString stringWithFormat:@"%d", defense];
  
  if (fup.isFake) {
    equips = [self createFakeEquipsForFakePlayer:fup];
  } else if (equips) {
    equips = [self userEquipArrayFromFullUserEquipProtos:equips];
  }
  
  if (equips) {
    [self loadEquips:equips curWeapon:fup.weaponEquippedUserEquip.userEquipId curArmor:fup.armorEquippedUserEquip.userEquipId curAmulet:fup.amuletEquippedUserEquip.userEquipId];
  } else {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    _waitingForEquips = YES;
  }
}

- (NSArray *) userEquipArrayFromFullUserEquipProtos:(NSArray *)equips {
  // Create user equips and squash into quantities
  NSMutableArray *newEquips = [NSMutableArray array];
  for (FullUserEquipProto *fuep in equips) {
    UserEquip *ue = [UserEquip userEquipWithProto:fuep];
    [newEquips addObject:ue];
  }
  return newEquips;
}

- (void) receivedFullUserProtos:(NSArray *)protos {
  GameState *gs = [GameState sharedGameState];
  for (FullUserProto *fup in protos) {
    if (fup.userId == userId) {
      ProfileState st = self.state;
      [self loadProfileForPlayer:fup buttonsEnabled:YES];
      self.state = st;
      
      if (_queuedEquips || _fup.isFake) {
        if ([Globals userType:_fup.userType isAlliesWith:gs.type]) {
          // Just set this so that updateEquips runs
          _waitingForEquips = YES;
          
          NSArray *equips = _fup.isFake ? [self createFakeEquipsForFakePlayer:_fup] : _queuedEquips;
          [self updateEquips:equips];
          [_queuedEquips release];
          _queuedEquips = nil;
        }
      } else {
        _waitingForEquips = YES;
        
        if ([Globals userType:fup.userType isAlliesWith:gs.type]) {
          self.spinner.hidden = NO;
          [self.spinner startAnimating];
          
          [self loadEquips:nil curWeapon:0 curArmor:0 curAmulet:0];
        }
      }
    }
  }
}

- (void) receivedWallPosts:(RetrievePlayerWallPostsResponseProto *)proto {
  if (proto.relevantUserId == userId) {
    // Wall Tab View will take control of updating the wall posts
    // Make sure to send empty list if there are no wall posts so that spinner stops..
    wallTabView.wallPosts = proto.playerWallPostsList ? [proto.playerWallPostsList.mutableCopy autorelease] : [NSMutableArray array];
  }
}

- (void) receivedEquips:(RetrieveUserEquipForUserResponseProto *)proto {
  if (proto.relevantUserId == userId) {
    if (_fup) {
      NSArray *equips = _fup.isFake ? [self createFakeEquipsForFakePlayer:_fup] : proto.userEquipsList;
      [self updateEquips:equips];
    } else {
      _queuedEquips = [proto.userEquipsList retain];
    }
  }
}

- (void) updateEquips:(NSArray *)equips {
  if (_waitingForEquips) {
    // Make sure to create UserEquip array
    _waitingForEquips = NO;
    [self loadEquips:[self userEquipArrayFromFullUserEquipProtos:equips] curWeapon:_fup.weaponEquippedUserEquip.userEquipId curArmor:_fup.armorEquippedUserEquip.userEquipId curAmulet:_fup.amuletEquippedUserEquip.userEquipId];
    
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    
    Globals *gl = [Globals sharedGlobals];
    UserEquip *weapon = _fup.hasWeaponEquippedUserEquip ? (UserEquip *)_fup.weaponEquippedUserEquip : nil;
    UserEquip *armor = _fup.hasArmorEquippedUserEquip ? (UserEquip *)_fup.armorEquippedUserEquip : nil;
    UserEquip *amulet = _fup.hasAmuletEquippedUserEquip ? (UserEquip *)_fup.amuletEquippedUserEquip : nil;
    attackLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateAttackForAttackStat:_fup.attack weapon:weapon armor:armor amulet:amulet]];
    defenseLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateDefenseForDefenseStat:_fup.defense weapon:weapon armor:armor amulet:amulet]];
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
  self.fup = nil;
  [_queuedEquips release];
  _queuedEquips = nil;
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveUsersForUserIds:[NSArray arrayWithObject:[NSNumber numberWithInt:userId]]];
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentWallPostsForPlayer:user.userId];
  
  GameState *gs = [GameState sharedGameState];
  if ([Globals userType:gs.type isAlliesWith:user.userType]) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveEquipsForUser:user.userId];
    _waitingForEquips = YES;
  }
  
  userNameLabel.text = user.name;
  profilePicture.image = [Globals profileImageForUser:user.userType];
  winsLabel.text = @"";
  lossesLabel.text = @"";
  fleesLabel.text = @"";
  levelLabel.text = @"?";
  typeLabel.text = @"";
  attackLabel.text = @"";
  defenseLabel.text = @"";
  
  [self setClanName:@"Loading..."];
  self.clanButton.enabled = NO;
  
  selfLeftView.hidden = YES;
  enemyLeftView.hidden = YES;
  friendLeftView.hidden = YES;
  
  wallTabView.wallPosts = nil;
  
  [self loadEquips:nil curWeapon:0 curArmor:0 curAmulet:0];
  
  // Make equip spinner spin
  self.enemyMiddleView.hidden = YES;
  self.spinner.hidden = NO;
  [self.spinner startAnimating];
  
  [ProfileViewController displayView];
}

- (void) displayMyCurrentStats {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEquip *weaponEquipped = [gs myEquipWithUserEquipId:gs.weaponEquipped];
  UserEquip *armorEquipped = [gs myEquipWithUserEquipId:gs.armorEquipped];
  UserEquip *amuletEquipped = [gs myEquipWithUserEquipId:gs.amuletEquipped];
  attackLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateAttackForAttackStat:gs.attack weapon:weaponEquipped armor:armorEquipped amulet:amuletEquipped]];
  defenseLabel.text = [NSString stringWithFormat:@"%d", (int)[gl calculateDefenseForDefenseStat:gs.defense weapon:weaponEquipped armor:armorEquipped amulet:amuletEquipped]];
}

- (void) loadMyProfileWithLevelUp {
  [self loadMyProfile];
  _displayKiipOnClose = YES;
}

- (void) loadMyProfile {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  self.fup = nil;
  self.userId = gs.userId;
  
  userNameLabel.text = gs.name;
  profilePicture.image = [Globals profileImageForUser:gs.type];
  winsLabel.text = [Globals commafyNumber:gs.battlesWon];
  lossesLabel.text = [Globals commafyNumber:gs.battlesLost];
  fleesLabel.text = [Globals commafyNumber:gs.flees];
  levelLabel.text = [NSString stringWithFormat:@"%d", gs.level];
  typeLabel.text = [NSString stringWithFormat:@"%@ %@", [Globals factionForUserType:gs.type], [Globals classForUserType:gs.type]];
  codeLabel.text = gs.referralCode;
  
  if (gs.clan) {
    [self setClanName:gs.clan.name];
    clanButton.enabled = YES;
  } else {
    [self setClanName:@"No Clan"];
    clanButton.enabled = NO;
  }
  
  [self displayMyCurrentStats];
  
  [self loadEquips:gs.myEquips curWeapon:gs.weaponEquipped curArmor:gs.armorEquipped curAmulet:gs.amuletEquipped];
  
  if (self.profileBar.state != kMyProfile) {
    self.profileBar.state = kMyProfile;
    self.state = kProfileState;
    
    curWeaponView.selected = YES;
    curArmorView.selected = NO;
    curAmuletView.selected = NO;
    self.curScope = kEquipScopeWeapons;
  }
  [self loadSkills];
  
  equipsTableView.hidden = NO;
  enemyMiddleView.hidden = YES;
  
  self.spinner.hidden = YES;
  [self.spinner stopAnimating];
  
  enemyLeftView.hidden = YES;
  friendLeftView.hidden = YES;
  selfLeftView.hidden = NO;
  
  wallTabView.wallPosts = [[GameState sharedGameState] wallPosts];
  
  // Update calculate labels
  staminaCostLabel.text = [NSString stringWithFormat:@"(%d skill %@ = %d)", gl.staminaBaseCost, gl.staminaBaseCost != 1 ? @"points" : @"point", gl.staminaBaseGain];
}

-(void)setupSkillPointButton:(UIButton *)curButton forCost:(int)stateCost
{
  GameState *gs = [GameState sharedGameState];
  
  if (stateCost <= gs.skillPoints) {
    if (!curButton.enabled) {
      curButton.enabled = YES;
    }
    UIColor *pulseColor = [UIColor colorWithRed:156/255.f
                                          green:202/255.f
                                           blue:16/255.f
                                          alpha:0.8f];
    
    [Globals beginPulseForView:curButton andColor:pulseColor];
  }
  else {
    curButton.enabled = NO;
    [Globals endPulseForView:curButton];
  }
}

- (void) setClanName:(NSString *)name {
  [self.clanButton setTitle:name forState:UIControlStateNormal];
  
  CGSize size = [name sizeWithFont:clanButton.titleLabel.font constrainedToSize:clanButton.frame.size lineBreakMode:clanButton.titleLabel.lineBreakMode];
  CGRect r = clanView.frame;
  r.size.width = clanButton.frame.origin.x+size.width;
  clanView.frame = r;
  
  CGPoint pt = clanView.center;
  pt.x = userNameLabel.center.x;
  clanView.center = pt;
}

- (void) loadSkills {
  GameState *gs = [GameState sharedGameState];
  
  attackStatLabel.text = [NSString stringWithFormat:@"%d", gs.attack];
  defenseStatLabel.text = [NSString stringWithFormat:@"%d", gs.defense];
  energyStatLabel.text = [NSString stringWithFormat:@"%d", gs.maxEnergy];
  staminaStatLabel.text = [NSString stringWithFormat:@"%d", gs.maxStamina];
  
  skillPointsLabel.text = [NSString stringWithFormat:@"%d", gs.skillPoints];
  
  [self refreshSkillPointsButtons];
}

- (void) openSkillsMenu {
  self.state = kSkillsState;
}

-(void)refreshSkillPointsButtons
{
  Globals *gl = [Globals sharedGlobals];
  
  [self setupSkillPointButton:attackStatButton  forCost:gl.attackBaseCost];
  [self setupSkillPointButton:defenseStatButton forCost:gl.defenseBaseCost];
  [self setupSkillPointButton:energyStatButton  forCost:gl.energyBaseCost];
  [self setupSkillPointButton:staminaStatButton forCost:gl.staminaBaseCost];
}

- (IBAction)clanClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.level < gl.minLevelConstants.clanHouseMinLevel) {
    [Globals popupMessage:[NSString stringWithFormat:@"You cannot access the clan house until level %d.", gl.minLevelConstants.clanHouseMinLevel]];
  } else if (_fup.clan) {
    [ClanMenuController displayView];
    [[ClanMenuController sharedClanMenuController] loadForClan:_fup.clan];
  } else if (profileBar.state == kMyProfile && gs.clan) {
    [ClanMenuController displayView];
    [[ClanMenuController sharedClanMenuController] loadForClan:gs.clan];
  }
}

- (IBAction)skillButtonClicked:(id)sender {
  if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
    sender = [(UIGestureRecognizer *)sender view];
  }
  
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  
  if (sender == attackStatButton) {
    [oec addAttackSkillPoint];
    [Analytics addedSkillPoint:@"Attack"];
  }
  else if (sender == defenseStatButton) {
    [oec addDefenseSkillPoint];
    [Analytics addedSkillPoint:@"Defense"];
  }
  else if (sender == energyStatButton) {
    [oec addEnergySkillPoint];
    [Analytics addedSkillPoint:@"Energy"];
  }
  else if (sender == staminaStatButton) {
    [oec addStaminaSkillPoint];
    [Analytics addedSkillPoint:@"Stamina"];
  }
  
  [self refreshSkillPointsButtons];
  [self loadSkills];
  [self displayMyCurrentStats];
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  return YES;
}

// Special screen IBActions
- (IBAction)resetSkillsClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetSkillPoints;
  NSString *str = [NSString stringWithFormat:@"Would you like to reset your skill points%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(resetSkills)];
  
  [Analytics attemptedStatReset];
}

- (void) resetSkills {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetSkillPoints;
  if (gs.gold >= cost) {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] resetStats];
    [self loadSkills];
    
    [Analytics statReset];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (IBAction)changeTypeClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToChangeCharacterType;
  NSString *str = [NSString stringWithFormat:@"Would you like to change your character%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(changeType)];
  
  [Analytics attemptedTypeChange];
}

- (void) changeType {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToChangeCharacterType;
  if (gs.gold >= cost) {
    // This will be released by the controller
    CharSelectionViewController *csvc = [[CharSelectionViewController alloc] initWithNibName:nil bundle:nil];
    [Globals displayUIView:csvc.view];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (IBAction)resetGame:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetCharacter;
  NSString *str = [NSString stringWithFormat:@"Would you like to reset your game%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
  [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(resetGame)];
  
  [Analytics attemptedResetGame];
}

- (void) resetGame {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToResetCharacter;
  if (gs.clan) {
    [Globals popupMessage:@"You must leave your clan before resetting the game."];
  } else if (gs.gold >= cost) {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] resetGame];
    
    [Analytics resetGame];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (IBAction)changeName:(id)sender {
  [GenericPopupController displayNotificationViewWithMiddleView:self.nameChangeView title:@"Change Name?" okayButton:nil target:self selector:@selector(changeName)];
  [self.nameChangeTextField becomeFirstResponder];
}

- (void) changeName {
  [self.nameChangeTextField resignFirstResponder];
  
  NSString *realStr = nameChangeTextField.text;
  realStr = [realStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  Globals *gl = [Globals sharedGlobals];
  if ([gl validateUserName:realStr]) {
    int cost = gl.diamondCostToChangeName;
    NSString *str = [NSString stringWithFormat:@"Would you like to change your name%@?", cost > 0 ? [NSString stringWithFormat:@" for %d gold", cost] : @""];
    [GenericPopupController displayConfirmationWithDescription:str title:nil okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(putName)];
    
    [Analytics attemptedNameChange];
  }
}

- (void) putName {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int cost = gl.diamondCostToChangeName;
  if (gs.gold >= cost) {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] resetName:self.nameChangeTextField.text];
    
    [Analytics nameChange];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > [[Globals sharedGlobals] maxNameLength]) {
    return NO;
  }
  return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.nameChangeView.superview.center = ccpAdd(self.nameChangeView.superview.center, ccp(0, -75));
  }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.nameChangeView.superview.center = ccpAdd(self.nameChangeView.superview.center, ccp(0, 75));
  }];
}

- (IBAction)closeClicked:(id)sender {
  [self.wallTabView endEditing];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [ProfileViewController removeView];
  }];
  self.userId = 0;
  
  [self.equipPopup closeClicked:nil];
  
  if (_displayKiipOnClose) {
    _displayKiipOnClose = NO;
    GameState *gs = [GameState sharedGameState];
    NSArray *levelUpRewards = [[[Globals sharedGlobals] kiipRewardConditions] levelUpConditionsList];
    NSSet *levelupDict = [NSSet setWithArray:levelUpRewards];
    
    if ([levelupDict containsObject:[NSNumber numberWithInt:gs.level]]) {
//      NSString *curAchievement = [NSString stringWithFormat:@"level_up_%d",
//                                  gs.level];
//      [KiipDelegate postAchievementNotificationAchievement:curAchievement];
    }
    
    // Show the level up popup here
    Globals *gl = [Globals sharedGlobals];
    if (gs.level >= gl.levelToShowRateUsPopup && gl.levelToShowRateUsPopup > 0) {
      [Globals checkRateUsPopup];
    }
  }
}

- (IBAction)visitClicked:(id)sender {
  [Globals popupMessage:@"Sorry, visiting another player's city is coming soon!"];
  [Analytics clickedVisitCity];
}

- (IBAction)attackClicked:(id)sender {
  BOOL success = [[BattleLayer sharedBattleLayer] beginBattleAgainst:_fup];
  if (success) [self closeClicked:nil];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [wallTabView endEditing];
}

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.fup = nil;
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
    self.equipsTableView = nil;
    self.equippingView = nil;
    self.equipTabView = nil;
    self.skillTabView = nil;
    self.wallTabView = nil;
    self.attackStatLabel = nil;
    self.defenseStatLabel = nil;
    self.staminaStatLabel = nil;
    self.energyStatLabel = nil;
    self.attackStatButton = nil;
    self.defenseStatButton = nil;
    self.staminaStatButton = nil;
    self.energyStatButton = nil;
    self.enemyAttackLabel = nil;
    self.enemyMiddleView = nil;
    self.staminaCostLabel = nil;
    self.skillPointsLabel = nil;
    self.selfLeftView = nil;
    self.enemyLeftView = nil;
    self.friendLeftView = nil;
    self.visitButton = nil;
    self.smallAttackButton = nil;
    self.bigAttackButton = nil;
    self.equipsTableDelegate = nil;
    self.spinner = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.equipPopup = nil;
    self.specialTabView = nil;
    self.profileTabView = nil;
    self.nameChangeView = nil;
    self.nameChangeTextField = nil;
    self.equipHeaderLabel = nil;
    self.noEquipButtonView = nil;
    self.noEquipLabel = nil;
    self.noEquipMiddleView = nil;
    self.clanButton = nil;
    self.clanView = nil;
    [_queuedEquips release];
    _queuedEquips = nil;
  }
}

@end
