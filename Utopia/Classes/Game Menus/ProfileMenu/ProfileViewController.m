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

#define EQUIPS_VERTICAL_SEPARATION 3.f
#define EQUIPS_HORIZONTAL_SEPARATION 1.f

#define SHAKE_DURATION 0.05f
#define SHAKE_REPEAT_COUNT 4.f
#define SHAKE_OFFSET 3.f

@implementation ProfileBar

@synthesize state = _state;
@synthesize equipIcon, skillsIcon, wallIcon;
@synthesize equipLabel, skillsLabel, wallLabel;
@synthesize equipSelectedLargeImage, equipSelectedSmallImage, skillsSelectedSmallImage;
@synthesize wallSelectedSmallImage, wallSelectedLargeImage;
@synthesize glowIcon;
@synthesize clickedButtons;

- (void) awakeFromNib {
  wallSelectedLargeImage.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
  wallSelectedSmallImage.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
  
  clickedButtons = 0;
  
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
        
        glowIcon.center = CGPointMake(equipSelectedSmallImage.center.x, glowIcon.center.y);
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
        
        glowIcon.center = CGPointMake(equipSelectedLargeImage.center.x, glowIcon.center.y);
        break;
        
      default:
        break;
    }
  }
  [self clickButton:kEquipButton];
  [self unclickButton:kSkillsButton];
  [self unclickButton:kWallButton];
}

- (void) clickButton:(ProfileBarButton)button {
  switch (button) {
    case kEquipButton:
      equipIcon.highlighted = YES;
      equipLabel.highlighted = YES;
      _curEquipSelectedImage.hidden = NO;
      clickedButtons |= kEquipButton;
      break;
      
    case kSkillsButton:
      if (self.state == kMyProfile) {
        skillsIcon.highlighted = YES;
        skillsLabel.highlighted = YES;
        _curSkillsSelectedImage.hidden = NO;
        clickedButtons |= kSkillsButton;
      }
      break;
      
    case kWallButton:
      wallIcon.highlighted = YES;
      wallLabel.highlighted = YES;
      _curWallSelectedImage.hidden = NO;
      clickedButtons |= kWallButton;
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
      clickedButtons &= ~kEquipButton;
      break;
      
    case kSkillsButton:
      if (_state == kMyProfile) {
        skillsIcon.highlighted = NO;
        skillsLabel.highlighted = NO;
        _curSkillsSelectedImage.hidden = YES;
        clickedButtons &= ~kSkillsButton;
      }
      break;
      
    case kWallButton:
      wallIcon.highlighted = NO;
      wallLabel.highlighted = NO;
      _curWallSelectedImage.hidden = YES;
      clickedButtons &= ~kWallButton;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:_curEquipSelectedImage];
  if (!(clickedButtons & kEquipButton) && [_curEquipSelectedImage pointInside:pt withEvent:nil]) {
    _trackingEquip = YES;
    [self clickButton:kEquipButton];
  }
  
  if (_state == kMyProfile) {
    pt = [touch locationInView:_curSkillsSelectedImage];
    if (!(clickedButtons & kSkillsButton) && [_curSkillsSelectedImage pointInside:pt withEvent:nil]) {
      _trackingSkills = YES;
      [self clickButton:kSkillsButton];
    }
  }
  
  pt = [touch locationInView:_curWallSelectedImage];
  if (!(clickedButtons & kWallButton) && [_curWallSelectedImage pointInside:pt withEvent:nil]) {
    _trackingWall = YES;
    [self clickButton:kWallButton];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:_curEquipSelectedImage];
  if (_trackingEquip) {
    if ([_curEquipSelectedImage pointInside:pt withEvent:nil]) {
      [self clickButton:kEquipButton];
    } else {
      [self unclickButton:kEquipButton];
    }
  }
  
  if (_state == kMyProfile) {
    pt = [touch locationInView:_curSkillsSelectedImage];
    if (_trackingSkills) {
      if ([_curSkillsSelectedImage pointInside:pt withEvent:nil]) {
        [self clickButton:kSkillsButton];
      } else {
        [self unclickButton:kSkillsButton];
      }
    }
  }
  
  pt = [touch locationInView:_curWallSelectedImage];
  if (_trackingWall) {
    if ([_curWallSelectedImage pointInside:pt withEvent:nil]) {
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
    if ([_curEquipSelectedImage pointInside:pt withEvent:nil]) {
      [self clickButton:kEquipButton];
      [self unclickButton:kWallButton];
      [self unclickButton:kSkillsButton];
      glowIcon.center = CGPointMake(_curEquipSelectedImage.center.x, glowIcon.center.y);
    } else {
      [self unclickButton:kEquipButton];
    }
  }
  
  if (_state == kMyProfile) {
    pt = [touch locationInView:_curSkillsSelectedImage];
    if (_trackingSkills) {
      if ([_curSkillsSelectedImage pointInside:pt withEvent:nil]) {
        [self clickButton:kSkillsButton];
        [self unclickButton:kEquipButton];
        [self unclickButton:kWallButton];
        glowIcon.center = CGPointMake(_curSkillsSelectedImage.center.x, glowIcon.center.y);
      } else {
        [self unclickButton:kSkillsButton];
      }
    }
  }
  
  pt = [touch locationInView:_curWallSelectedImage];
  if (_trackingWall) {
    if ([_curWallSelectedImage pointInside:pt withEvent:nil]) {
      [self clickButton:kWallButton];
      [self unclickButton:kEquipButton];
      [self unclickButton:kSkillsButton];
      glowIcon.center = CGPointMake(_curWallSelectedImage.center.x, glowIcon.center.y);
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

@end

@implementation EquipView

@synthesize bgd;
@synthesize equipIcon, border, rarityLabel, attackLabel, defenseLabel;
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
  equipIcon.image = [Globals imageForEquip:fuep.equipId];
  rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
  rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
  
  self.equip = fuep;
  
  if ([Globals canEquip:fuep]) {
    bgd.highlighted = NO;
  } else {
    bgd.highlighted = YES;
  }
}

- (void) doShake {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  [animation setDuration:SHAKE_DURATION];
  [animation setRepeatCount:SHAKE_REPEAT_COUNT];
  [animation setAutoreverses:YES];
  [animation setFromValue:[NSValue valueWithCGPoint:
                           CGPointMake(self.center.x - SHAKE_OFFSET, self.center.y)]];
  [animation setToValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.center.x + SHAKE_OFFSET, self.center.y)]];
  [self.layer addAnimation:animation forKey:@"position"];
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
  [darkOverlay release];
  [super dealloc];
}

@end

@implementation CurrentEquipView

@synthesize equipIcon, label, chooseEquipButton, border;
@synthesize selected = _selected;

- (void) setSelected:(BOOL)selected {
  if (selected != _selected) {
    _selected = selected;
    border.hidden = _selected ? NO : YES;
  }
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
    [[ProfileViewController sharedProfileViewController] currentEquipView:self];
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  border.hidden = _selected ? NO : YES;
}

@end

@implementation ProfileViewController

@synthesize state = _state, curScope = _curScope;
@synthesize userNameLabel, factionLabel, levelLabel, classLabel, attackLabel, defenseLabel;
@synthesize winsLabel, lossesLabel, fleesLabel;
@synthesize curArmorView, curAmuletView, curWeaponView;
@synthesize profilePicture, profileBar;
@synthesize equipViews, nibEquipView, equipsScrollView;
@synthesize unequippableView, unequippableLabel;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ProfileViewController);

- (void) setState:(ProfileState)state {
  if (state != _state) {
    _state = state;
  }
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.equipViews = [NSMutableArray array];
}

- (void) setCurScope:(EquipScope)curScope {
  _curScope = curScope;
  [self updateScrollViewForCurrentScope:YES];
}

- (NSArray *) sortEquips:(NSArray *)equips {
  NSMutableArray *arr = [equips mutableCopy];
  NSMutableArray *toRet = [NSMutableArray arrayWithCapacity:equips.count];
  GameState *gs = [GameState sharedGameState];
  
  for (int i = 0; i < equips.count; i++) {
    FullUserEquipProto *bestFuep = [arr objectAtIndex:0];
    FullEquipProto *bestFep = [gs equipWithId:bestFuep.equipId];
    for (int j = 1; j < arr.count; j++) {
      FullUserEquipProto *compFuep = [arr objectAtIndex:j];
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
  
  return toRet;
}

- (CGPoint) centerForCell:(int)cellNum equipView:(EquipView *)ev {
  int x = equipsScrollView.frame.size.width/2 + ((cellNum % 3)-1)*(ev.frame.size.width+EQUIPS_HORIZONTAL_SEPARATION);
  int y = (cellNum/3*(ev.frame.size.height+EQUIPS_VERTICAL_SEPARATION))+ev.frame.size.height/2+EQUIPS_VERTICAL_SEPARATION;
  return CGPointMake(x, y);
}

- (void) equipViewSelected:(EquipView *)ev {
  GameState *gs = [GameState sharedGameState];
  FullUserEquipProto *fuep = ev.equip;
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:fuep.equipId];
  if (profileBar.state == kMyProfile && fuep.userId == gs.userId) {
    if ([Globals canEquip:fuep]) {
      NSLog(@"equipping");
      if (!unequippableView.hidden) {

      }
    } else {
      [ev doShake];
      if (fep.classType == gs.type % 3) {
        unequippableLabel.text = [NSString stringWithFormat:@"You Must Be A %@ To Equip This Item", [Globals stringForEquipType:fep.equipType]];
      }
      else if (fep.minLevel > gs.level) {
        unequippableLabel.text = [NSString stringWithFormat:@"You Must Be Level %d To Equip This Item", fep.minLevel];
      } else {
        unequippableLabel.text = @"Unable to equip for unknown reason";
      }
      unequippableView.alpha = 1.f;
      unequippableView.hidden = NO;
      [UIView animateWithDuration:5 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
        unequippableView.alpha = 0.f;
        NSLog(@"%@", [NSDate date]);
      } completion:^(BOOL finished) {
        unequippableView.hidden = YES;
        NSLog(@"%@", [NSDate date]);
      }];
    }
  } else {
    [Globals popupMessage:@"Attempting to equip an item that is not yours"];
  }
}

- (void) currentEquipView:(CurrentEquipView *)cev {
  EquipScope scope;
  if (cev == curWeaponView) {
    scope = kEquipScopeWeapons;
  } else if (cev == curArmorView) {
    scope = kEquipScopeArmor;
  } else if (cev == curAmuletView) {
    scope = kEquipScopeAmulets;
  } else {
    [Globals popupMessage:@"Error attaining scope value"];
  }
  
  // cev will be selected/deselected correctly
  if (scope == _curScope) {
    scope = kEquipScopeAll;
  } else if (_curScope == kEquipScopeWeapons) {
    curWeaponView.selected = NO;
  } else if (_curScope == kEquipScopeArmor) {
    curArmorView.selected = NO;
  } else if (_curScope == kEquipScopeAmulets) {
    curAmuletView.selected = NO;
  }
  
  self.curScope = scope;
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
    } else if (scope == kEquipScopeAmulets && fep.equipType == FullEquipProto_EquipTypeAccessory) {
      [arr addObject:ev];
    }
  }
  return arr;
}

- (void) updateScrollViewForCurrentScope:(BOOL)animated {
  NSArray *toDisplay = [self equipViewsForScope:self.curScope];
  EquipView *ev = nil;
  int j = 0;
  [UIView beginAnimations:nil context:nil];
  for (int i = 0; i < equipViews.count; i++) {
    ev = [equipViews objectAtIndex:i];
    if ([toDisplay containsObject:ev]) {
      ev.hidden = NO;
      ev.center = [self centerForCell:j equipView:ev];
      j++;
    } else {
      ev.hidden = YES;
    }
  }
  equipsScrollView.contentSize = CGSizeMake(equipsScrollView.frame.size.width,((j/3)*(ev.frame.size.height+EQUIPS_VERTICAL_SEPARATION))+EQUIPS_VERTICAL_SEPARATION);
}

- (void) loadEquips:(NSArray *)equips curWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet touchEnabled:(BOOL)touchEnabled {
  GameState *gs = [GameState sharedGameState];
  
  BOOL weaponFound = NO, armorFound = NO, amuletFound = NO;
  
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
      curWeaponView.equipIcon.image = [Globals imageForEquip:fep.equipId];
      curWeaponView.equipIcon.hidden = NO;
      curWeaponView.chooseEquipButton.hidden = YES;
      
      ev.border.hidden = NO;
      weaponFound = YES;
    } else if (fuep.equipId == armor) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      curArmorView.label.text = fep.name;
      curArmorView.label.textColor = [Globals colorForRarity:fep.rarity];
      curArmorView.equipIcon.image = [Globals imageForEquip:fep.equipId];
      curArmorView.equipIcon.hidden = NO;
      curArmorView.chooseEquipButton.hidden = YES;
      
      ev.border.hidden = NO;
      armorFound = YES;
    } else if (fuep.equipId == amulet) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      curAmuletView.label.text = fep.name;
      curAmuletView.label.textColor = [Globals colorForRarity:fep.rarity];
      curAmuletView.equipIcon.image = [Globals imageForEquip:fep.equipId];
      curAmuletView.equipIcon.hidden = NO;
      curAmuletView.chooseEquipButton.hidden = YES;
      
      ev.border.hidden = NO;
      amuletFound = YES;
    } else {
      ev.border.hidden = YES;
    }
  }
  _curScope = kEquipScopeAll;
  [self updateScrollViewForCurrentScope:NO];
  
  if (!weaponFound) {
    if (weapon > 0) {
      [Globals popupMessage:@"Unable to find equipped weapon for this player"];
    }
    curWeaponView.label.text = @"No Weapon";
    curWeaponView.equipIcon.image = nil;
    curWeaponView.label.textColor = [UIColor colorWithWhite:87/256.f alpha:1.f];
    curWeaponView.equipIcon.hidden = YES;
    curWeaponView.chooseEquipButton.hidden = NO;
  }
  if (!armorFound) {
    if (armor > 0) {
      [Globals popupMessage:@"Unable to find equipped armor for this player"];
    }
    curArmorView.label.text = @"No Armor";
    curArmorView.equipIcon.image = nil;
    curArmorView.label.textColor = [UIColor colorWithWhite:87/256.f alpha:1.f];
    curArmorView.equipIcon.hidden = YES;
    curArmorView.chooseEquipButton.hidden = NO;
  }
  if (!amuletFound) {
    if (amulet > 0) {
      [Globals popupMessage:@"Unable to find equipped amulet for this player"];
    }
    curAmuletView.label.text = @"No Amulet";
    curAmuletView.equipIcon.image = nil;
    curAmuletView.label.textColor = [UIColor colorWithWhite:87/256.f alpha:1.f];
    curAmuletView.equipIcon.hidden = YES;
    curAmuletView.chooseEquipButton.hidden = NO;
  }
  
  curWeaponView.userInteractionEnabled = touchEnabled;
  curArmorView.userInteractionEnabled = touchEnabled;
  curAmuletView.userInteractionEnabled = touchEnabled;
}

- (void) loadMyProfile {
  GameState *gs = [GameState sharedGameState];
  
  userNameLabel.text = gs.name;
  winsLabel.text = [NSString stringWithFormat:@"%d", gs.battlesWon];
  lossesLabel.text = [NSString stringWithFormat:@"%d", gs.battlesLost];
  levelLabel.text = [NSString stringWithFormat:@"%d", gs.level];
  factionLabel.text = [Globals factionForUserType:gs.type];
  classLabel.text = [Globals classForUserType:gs.type];
  attackLabel.text = [NSString stringWithFormat:@"%d", gs.attack];
  defenseLabel.text = [NSString stringWithFormat:@"%d", gs.defense];
  
  [self loadEquips:gs.myEquips curWeapon:gs.weaponEquipped curArmor:gs.armorEquipped curAmulet:gs.amuletEquipped touchEnabled:YES];
  self.profileBar.state = kMyProfile;
}

- (IBAction)closeClicked:(id)sender {
  [ProfileViewController removeView];
}

- (void) viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.equipViews = nil;
}

@end
