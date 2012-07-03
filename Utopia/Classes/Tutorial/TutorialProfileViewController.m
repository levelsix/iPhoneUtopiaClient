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
  if ((self = [super initWithNibName:@"ProfileViewController" bundle:nil])) {
    _justLoaded = YES;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  self.profileBar.userInteractionEnabled = NO;
  _addingStatsPhase = YES;
  _equippingPhase = NO;
  _closingPhase = NO;
  _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  
  self.curWeaponView.userInteractionEnabled = NO;
  self.curArmorView.userInteractionEnabled = NO;
  self.curAmuletView.userInteractionEnabled = NO;
  
  self.wallTabView.userInteractionEnabled = NO;
}

- (void) viewDidAppear:(BOOL)animated {
  if (_justLoaded) {
    _justLoaded = NO;
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.beforeSkillsText];
    DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
    dmc.view.center = ccpAdd(dmc.view.center, ccp(0, -95));
    
    [self.view addSubview:_arrow];
    CGPoint base = [self.view convertPoint:self.attackStatButton.center fromView:self.skillTabView];
    _arrow.center = ccpAdd(base, ccp(self.attackStatButton.frame.size.width/2+_arrow.frame.size.width/2,self.attackStatButton.frame.size.height/2+_arrow.frame.size.height/2-4));
    
    float rotation = -M_PI_2-3*M_PI_4;
    _arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
    [_arrow.layer removeAllAnimations];
    
    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:0.75f delay:0.f options:opt animations:^{
      CGPoint base = [self.view convertPoint:self.hpStatButton.center fromView:self.skillTabView];
      _arrow.center = ccpAdd(base, ccp(self.hpStatButton.frame.size.width/2+_arrow.frame.size.width/2, -(self.hpStatButton.frame.size.height/2+_arrow.frame.size.height/2-15)));
      
      float rotation = M_PI_4;
      _arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
    } completion:nil];
  } else {
    _tutorialEnding = YES;
    [self performSelector:@selector(arrowOnClose) withObject:nil afterDelay:1.f];
  }
}

- (IBAction)skillButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  [DialogMenuController closeView];
  
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

  [self refreshSkillPointsButtons];
  [self loadSkills];
  
  if (gs.skillPoints <= 0) {
    [self addingSkillsDone];
  }
}

- (void) addingSkillsDone {
  _addingStatsPhase = NO;
  _moveToEquipScreenPhase = YES;
  self.profileBar.userInteractionEnabled = YES;
  
  // Move arrow to equip top bar button
  [_arrow removeFromSuperview];
  [self.profileBar addSubview:_arrow];
  _arrow.center = CGPointMake(CGRectGetMaxX(self.profileBar.equipSelectedSmallImage.frame), self.profileBar.equipSelectedSmallImage.center.y);
  [Globals animateUIArrow:_arrow atAngle:M_PI];
  
  [DialogMenuController displayViewForText:[TutorialConstants sharedTutorialConstants].afterSkillPointsText];
  [Analytics tutorialSkillPointsAdded];
}

- (void) setState:(ProfileState)state {
  [super setState:state];
  if (state == kEquipState && _moveToEquipScreenPhase) {
    [self.profileBar setUserInteractionEnabled:NO];
    
    _moveToEquipScreenPhase = NO;
    _equippingPhase = YES;
    
    [DialogMenuController closeView];
    
    [_arrow removeFromSuperview];
    [self.equipsScrollView addSubview:_arrow];
    
    UIView *amuletEquipView = [self.equipsScrollView viewWithTag:2];
    _arrow.center = CGPointMake(CGRectGetMinX(amuletEquipView.frame)-_arrow.frame.size.width/2, amuletEquipView.center.y);
    [Globals animateUIArrow:_arrow atAngle:0];
  }
}

- (IBAction)closeClicked:(id)sender {
  if (_closingPhase) {
    [_arrow removeFromSuperview];
    [super closeClicked:sender];
    
    if (_tutorialEnding) {
      TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
      [DialogMenuController displayViewForText:tc.duringCreateText];
      
      [[DialogMenuController sharedDialogMenuController] createUser];
    } else {
      [[TutorialMissionMap sharedTutorialMissionMap] levelUpComplete];
    }
  }
}

- (void) equipViewSelected:(EquipView *)ev {
  if (_equippingPhase && ev.tag == 2) {
    FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ev.equip.equipId];
    [self doEquippingAnimation:ev forType:fep.equipType];
    
    GameState *gs = [GameState sharedGameState];
    gs.amuletEquipped = fep.equipId;
    
    self.unequippableView.hidden = YES;
    
    [self arrowOnClose];
    
    _equippingPhase = NO;
    [Analytics tutorialAmuletEquipped];
  }
}

- (void) arrowOnClose {
  [self.view addSubview:_arrow];
  UIView *close = [self.view viewWithTag:20];
  _arrow.center = CGPointMake(CGRectGetMinX(close.frame)-_arrow.frame.size.width/2, close.center.y);
  [Globals animateUIArrow:_arrow atAngle:0];
  
  _closingPhase = YES;
}

- (void) currentEquipViewSelected:(CurrentEquipView *)cev {
  return;
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
