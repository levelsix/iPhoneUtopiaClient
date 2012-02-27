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
  [self clickButton:kEquipButton];
  [self unclickButton:kSkillsButton];
  [self unclickButton:kWallButton];
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
      if (self.state = kMyProfile) {
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

@synthesize equipIcon, border, rarityLabel, attackLabel, defenseLabel;

- (void) updateForEquip:(FullUserEquipProto *)fuep {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:fuep.equipId];
  attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
  equipIcon.image = [Globals imageForEquip:fuep.equipId];
  rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
  rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
}

@end

@implementation ProfileViewController

@synthesize state = _state;
@synthesize userNameLabel, factionLabel, levelLabel, classLabel, attackLabel, defenseLabel;
@synthesize winsLabel, lossesLabel, fleesLabel;
@synthesize equippedAmuletLabel, equippedArmorLabel, equippedWeaponLabel;
@synthesize equippedWeaponIcon, equippedArmorIcon, equippedAmuletIcon;
@synthesize chooseArmorButton, chooseAmuletButton, chooseWeaponButton;
@synthesize profilePicture;
@synthesize equipViews, nibEquipView, equipsScrollView;

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

- (void) loadEquips:(NSArray *)equips {
  GameState *gs = [GameState sharedGameState];
  
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
    i = i*3;
    int x = equipsScrollView.frame.size.width/2 + ((i % 3) - 1) * (ev.frame.size.width + EQUIPS_HORIZONTAL_SEPARATION);
    int y = (i/3*(ev.frame.size.height+EQUIPS_VERTICAL_SEPARATION))+ev.frame.size.height/2+EQUIPS_VERTICAL_SEPARATION;
    ev.center = CGPointMake(x,y);
    
    // check if this item is equipped
    if (fuep.equipId == gs.weaponEquipped) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      equippedWeaponLabel.text = fep.name;
      equippedWeaponLabel.textColor = [Globals colorForRarity:fep.rarity];
      equippedWeaponIcon.image = [Globals imageForEquip:fep.equipId];
      
      ev.border.hidden = NO;
    } else if (fuep.equipId == gs.armorEquipped) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      equippedArmorLabel.text = fep.name;
      equippedArmorLabel.textColor = [Globals colorForRarity:fep.rarity];
      equippedArmorIcon.image = [Globals imageForEquip:fep.equipId];
      
      ev.border.hidden = NO;
    } else if (fuep.equipId == gs.amuletEquipped) {
      FullEquipProto *fep = [gs equipWithId:fuep.equipId];
      equippedAmuletLabel.text = fep.name;
      equippedAmuletLabel.textColor = [Globals colorForRarity:fep.rarity];
      equippedAmuletIcon.image = [Globals imageForEquip:fep.equipId];
      
      ev.border.hidden = NO;
    } else {
      ev.border.hidden = YES;
    }
    i = i/3;
  }
  i=i*3;
  equipsScrollView.contentSize = CGSizeMake(equipsScrollView.frame.size.width,((i/3)*(ev.frame.size.height+EQUIPS_VERTICAL_SEPARATION))+EQUIPS_VERTICAL_SEPARATION);
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
  
  [self loadEquips:gs.myEquips];
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
