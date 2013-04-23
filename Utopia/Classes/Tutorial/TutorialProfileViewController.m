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
  
  self.wallTabView.userInteractionEnabled = NO;
}

- (void) viewWillAppear:(BOOL)animated {
  if (_justLoaded) {
    [Analytics tutLevelUp];
    
    _justLoaded = NO;
    
    [self.view addSubview:_arrow];
    CGPoint base = [self.view convertPoint:self.attackStatButton.center fromView:self.skillTabView];
    _arrow.center = ccpAdd(base, ccp(self.attackStatButton.frame.size.width/2+_arrow.frame.size.width/2,self.attackStatButton.frame.size.height/2+_arrow.frame.size.height/2-4));
    
    float rotation = -M_PI_2-3*M_PI_4;
    _arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
    [_arrow.layer removeAllAnimations];
    
    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:0.75f delay:0.f options:opt animations:^{
      CGPoint base = [self.view convertPoint:self.staminaStatButton.center fromView:self.skillTabView];
      _arrow.center = ccpAdd(base, ccp(self.staminaStatButton.frame.size.width/2+_arrow.frame.size.width/2, -(self.staminaStatButton.frame.size.height/2+_arrow.frame.size.height/2-15)));
      
      float rotation = M_PI_4;
      _arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
    } completion:nil];
  } else {
    _tutorialEnding = YES;
    [self performSelector:@selector(arrowOnClose) withObject:nil afterDelay:1.f];
  }
  [super viewWillAppear:animated];
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
  }
  
  [self refreshSkillPointsButtons];
  [self loadSkills];
  [self displayMyCurrentStats];
  
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
  _arrow.center = CGPointMake(CGRectGetMaxX(self.profileBar.profileButton.frame), self.profileBar.profileButton.center.y);
  [Globals animateUIArrow:_arrow atAngle:M_PI];
  
  [DialogMenuController displayViewForText:[TutorialConstants sharedTutorialConstants].beforeEquipText];
  
  [Analytics tutSkillPoints];
}

- (void) setState:(ProfileState)state {
  if (_tutorialEnding) {
    [super setState:kWallState];
  } else if (!_moveToEquipScreenPhase) {
    [super setState:kSkillsState];
  } else if (state == kProfileState && _moveToEquipScreenPhase) {
    [super setState:state];
    [self.profileBar setUserInteractionEnabled:NO];
    
    _moveToEquipScreenPhase = NO;
    _equippingPhase = YES;
    
    [DialogMenuController closeView];
    
    [_arrow removeFromSuperview];
    [self.mainView addSubview:_arrow];
    
    UIView *amuletEquipView = [self.equipTabView.curEquipViews objectAtIndex:2];
    CGRect rect = [self.mainView convertRect:amuletEquipView.frame fromView:amuletEquipView.superview];
    _arrow.center = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    [Globals animateUIArrow:_arrow atAngle:0];
    
    self.equipTabView.scrollView.scrollEnabled = NO;
    
    [Analytics tutProfileClicked];
  }
  [super setState:_state];
}

- (IBAction)closeClicked:(id)sender {
  if (_closingPhase) {
    [_arrow removeFromSuperview];
    [super closeClicked:sender];
    
    if (_tutorialEnding) {
      TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
      [DialogMenuController displayViewForText:tc.duringCreateText];
      
      [Analytics tutCloseProfile2];
      
      [[DialogMenuController sharedDialogMenuController] createUser];
    } else {
      [[TutorialMissionMap sharedTutorialMissionMap] levelUpComplete];
      
      [Analytics tutCloseProfile1];
    }
  }
}

- (IBAction)resetSkillsClicked:(id)sender {
  return;
}

- (void) equipViewSelected:(EquipView *)ev {
  if (_equippingPhase) {
    int tag = ev.tag;
    
    if (tag == EQUIP_BROWSE_VIEW_TAG) {
      UserEquip *ue = ev.equip;
      [self doEquip:ue];
      self.equipBrowseView.equipTable.userInteractionEnabled = NO;
      
      self.equipBrowseView.closeButton.userInteractionEnabled = YES;
      
      UIView *close = self.equipBrowseView.closeButton;
      _arrow.center = CGPointMake(CGRectGetMinX(close.frame)-_arrow.frame.size.width/2, CGRectGetMidY(close.frame));
      [Globals animateUIArrow:_arrow atAngle:0];
      
      [self.equipBrowseView.closeButton addTarget:self action:@selector(arrowOnClose) forControlEvents:UIControlEventTouchUpInside];
      
      _equippingPhase = NO;
      
      [Analytics tutAmuletEquipped];
    } else {
      if (!ev.equip) {
        [super equipViewSelected:ev];
        self.equipBrowseView.browseBar.userInteractionEnabled = NO;
        self.equipBrowseView.backSlotView.userInteractionEnabled = NO;
        self.equipBrowseView.closeButton.userInteractionEnabled = NO;
        
        [self.equipBrowseView.mainView addSubview:_arrow];
        
        EquipBrowseCell *cell = (EquipBrowseCell *)[self.equipBrowseView.equipTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIView *amuletEquipView = cell.containerView1;
        CGRect rect = [self.equipBrowseView convertRect:amuletEquipView.frame fromView:amuletEquipView.superview];
        _arrow.center = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
        [Globals animateUIArrow:_arrow atAngle:M_PI];
        
        [Analytics tutNoAmuletClicked];
      }
    }
  }
}

- (void) arrowOnClose {
  [self.mainView addSubview:_arrow];
  UIView *close = [self.view viewWithTag:20];
  _arrow.center = CGPointMake(CGRectGetMinX(close.frame)-_arrow.frame.size.width/2, close.center.y);
  [Globals animateUIArrow:_arrow atAngle:0];
  
  _closingPhase = YES;
  
  if (!_tutorialEnding) {
    [Analytics tutCloseBrowseView];
  }
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
