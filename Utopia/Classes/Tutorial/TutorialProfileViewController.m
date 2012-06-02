//
//  TutorialProfileViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialProfileViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "TutorialMissionMap.h"
#import "DialogMenuController.h"
#import "TutorialConstants.h"

@implementation TutorialProfileViewController

- (id) init {
  return [super initWithNibName:@"ProfileViewController" bundle:nil];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  self.profileBar.userInteractionEnabled = NO;
  _addingStatsPhase = YES;
  _equippingPhase = NO;
  _closingPhase = NO;
  _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
    _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
  } completion:nil];
  
  self.curWeaponView.userInteractionEnabled = NO;
  self.curArmorView.userInteractionEnabled = NO;
  self.curAmuletView.userInteractionEnabled = NO;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController incrementProgress];
  [DialogMenuController displayViewForText:tc.beforeSkillsText callbackTarget:nil action:nil];
}

- (IBAction)skillButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (sender == self.attackStatButton) {
    gs.attack += gl.attackBaseGain;
    gs.skillPoints -= gl.attackBaseCost;
  } else if (sender == self.defenseStatButton) {
    gs.defense += gl.defenseBaseGain;
    gs.skillPoints -= gl.defenseBaseCost;
  } else if (sender == self.energyStatButton) {
    gs.maxEnergy += gl.energyBaseGain;
    gs.currentEnergy += gl.energyBaseGain;
    gs.skillPoints -= gl.energyBaseCost;
  } else if (sender == self.staminaStatButton) {
    gs.maxStamina += gl.staminaBaseGain;
    gs.currentStamina += gl.staminaBaseGain;
    gs.skillPoints -= gl.staminaBaseCost;
  } else if (sender == self.hpStatButton) {
    gs.maxHealth += gl.healthBaseGain;
    gs.skillPoints -= gl.healthBaseCost;
  }
  
  [self loadSkills];
  
  if (gs.skillPoints == 0) {
    [self addingSkillsDone];
  }
}

- (void) addingSkillsDone {
  _addingStatsPhase = NO;
  _moveToEquipScreenPhase = YES;
  self.profileBar.userInteractionEnabled = YES;
  
  // Move arrow to equip top bar button
  [self.view addSubview:_arrow];
  _arrow.layer.transform = CATransform3DMakeRotation(M_PI/2, 0.0f, 0.0f, 1.0f);
  
  _arrow.center = CGPointMake(CGRectGetMaxX(self.profileBar.equipSelectedSmallImage.frame), self.profileBar.equipSelectedSmallImage.center.y);
  
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
    _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
  } completion:nil];
  
  [DialogMenuController displayViewForText:[TutorialConstants sharedTutorialConstants].afterSkillPointsText callbackTarget:nil action:nil];
  [Analytics tutorialSkillPointsAdded];
}

- (void) setState:(ProfileState)state {
  [super setState:state];
  if (state == kEquipState) {
    [self.profileBar setUserInteractionEnabled:NO];
    
    _moveToEquipScreenPhase = NO;
    _equippingPhase = YES;
    
    [_arrow removeFromSuperview];
    [self.equipsScrollView addSubview:_arrow];
    _arrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
    
    UIView *amuletEquipView = [self.equipsScrollView viewWithTag:2];
    _arrow.center = CGPointMake(CGRectGetMinX(amuletEquipView.frame)-_arrow.frame.size.width/2, amuletEquipView.center.y);
    
    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
    } completion:nil];
  }
}

- (IBAction)closeClicked:(id)sender {
  if (_closingPhase) {
    [_arrow removeFromSuperview];
    [super closeClicked:sender];
    [[TutorialMissionMap sharedTutorialMissionMap] levelUpComplete];
  }
}

- (void) equipViewSelected:(EquipView *)ev {
  if (_equippingPhase && ev.tag == 2) {
    FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ev.equip.equipId];
    [self doEquippingAnimation:ev forType:fep.equipType];
    
    self.unequippableView.hidden = YES;
    
    [self.view addSubview:_arrow];
    UIView *close = [self.view viewWithTag:20];
    _arrow.center = CGPointMake(CGRectGetMinX(close.frame)-_arrow.frame.size.width/2, close.center.y);
    
    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _arrow.center = CGPointMake(_arrow.center.x+10, _arrow.center.y);
    } completion:nil];
    
    _equippingPhase = NO;
    _closingPhase = YES;
    [Analytics tutorialAmuletEquipped];
  }
}

- (void) currentEquipViewSelected:(CurrentEquipView *)cev {
  return;
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
