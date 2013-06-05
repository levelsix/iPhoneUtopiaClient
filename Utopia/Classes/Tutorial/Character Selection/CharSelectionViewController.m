//
//  CharSelectionViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CharSelectionViewController.h"
#import "LNSynthesizeSingleton.h"
#import "Globals.h"
#import "TutorialConstants.h"
#import "TutorialBattleLayer.h"
#import "GameLayer.h"
#import "TutorialHomeMap.h"
#import "GameState.h"
#import "DialogMenuController.h"
#import "TutorialTopBar.h"
#import "Downloader.h"
#import "OutgoingEventController.h"
#import "GameViewController.h"
#import "TutorialMissionMap.h"

@implementation ActionlessTextField

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(copy:) || action == @selector(cut:)) {
    [UIMenuController sharedMenuController].menuVisible = NO;
    return NO;
  }
  return [super canPerformAction:action withSender:sender];
}

@end

@implementation CharSelectionViewController

//SYNTHESIZE_SINGLETON_FOR_CONTROLLER(CharSelectionViewController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  [self.nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
  self.nameTextField.label.textColor = [UIColor whiteColor];
  
  self.chooseNameView.frame = self.selectSideView.frame;
  [self.view addSubview:self.chooseNameView];
  self.chooseNameView.hidden = YES;
  
  self.selectCharView.frame = self.selectSideView.frame;
  [self.view addSubview:self.selectCharView];
  self.selectCharView.hidden = YES;
  
  // Set up the game state
  GameState *gs = [GameState sharedGameState];
  if (gs.isTutorial) {
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    
    gs.level = 1;
    gs.experience = 0;
    gs.currentEnergy = tc.initEnergy;
    gs.maxEnergy = tc.initEnergy;
    gs.currentStamina = tc.initStamina;
    gs.maxStamina = tc.initStamina;
    gs.gold = tc.initGold;
    gs.silver = tc.initSilver;
    
    [[TopBar sharedTopBar] update];
    
    self.nameTextField.text = tc.defaultName;
  }
  
  self.view.tag = CHAR_SELECTION_VIEW_TAG;
}

- (void) viewWillAppear:(BOOL)animated {
  self.view.alpha = 0.f;
  _animating = YES;
  [UIView animateWithDuration:2.f animations:^{
    self.view.alpha = 1.f;
  } completion:^(BOOL finished) {
    _animating = NO;
  }];
  
  GameState *gs = [GameState sharedGameState];
  self.cancelView.hidden = gs.isTutorial;
  
  self.backButton.hidden = YES;
  
  self.titleLabel.text = @"Select a Side";
}

- (void) viewDidDisappear:(BOOL)animated {
  [self didReceiveMemoryWarning];
  [self release];
}

- (IBAction)sideClicked:(UIView *)sender {
  if (_animating || self.selectSideView.hidden) {
    return;
  }
  
  _isGoodSide = sender.tag == 1;
  
  GameState *gs = [GameState sharedGameState];
  if (gs.isTutorial) {
    [Analytics tutSideChosen];
  }
  
  if (_isGoodSide) {
    [self.archerButton setImage:[Globals imageNamed:[Globals imageNameForDialogueSpeaker:DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodArcher]] forState:UIControlStateNormal];
    [self.warriorButton setImage:[Globals imageNamed:[Globals imageNameForDialogueSpeaker:DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodWarrior]] forState:UIControlStateNormal];
    [self.mageButton setImage:[Globals imageNamed:[Globals imageNameForDialogueSpeaker:DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodMage]] forState:UIControlStateNormal];
  } else {
    [self.archerButton setImage:[Globals imageNamed:[Globals imageNameForDialogueSpeaker:DialogueProto_SpeechSegmentProto_DialogueSpeakerBadArcher]] forState:UIControlStateNormal];
    [self.warriorButton setImage:[Globals imageNamed:[Globals imageNameForDialogueSpeaker:DialogueProto_SpeechSegmentProto_DialogueSpeakerBadWarrior]] forState:UIControlStateNormal];
    [self.mageButton setImage:[Globals imageNamed:[Globals imageNameForDialogueSpeaker:DialogueProto_SpeechSegmentProto_DialogueSpeakerBadMage]] forState:UIControlStateNormal];
  }
  
  self.titleLabel.text = @"Select a Character";
  
  self.selectCharView.hidden = NO;
  self.selectCharView.alpha = 0.f;
  self.backButton.hidden = NO;
  self.backButton.alpha = 0.f;
  
  _animating = YES;
  [UIView animateWithDuration:0.3f animations:^{
    self.selectSideView.alpha = 0.f;
    self.selectCharView.alpha = 1.f;
    self.backButton.alpha = 1.f;
  } completion:^(BOOL finished) {
    if (finished) {
      _animating = NO;
      self.selectSideView.hidden = YES;
    }
  }];
}

- (IBAction)selectedClicked:(UIView *)sender {
  if (_animating || self.selectCharView.hidden) {
    return;
  }
  
  _chosenType = sender.tag-1 + (_isGoodSide ? 0 : 3);
  
  GameState *gs = [GameState sharedGameState];
  // If it is tutorial, show name screen
  // Otherwise send the change user type message
  if (gs.isTutorial) {
    self.titleLabel.text = @"Choose a Name";
    
    self.chooseNameView.hidden = NO;
    self.chooseNameView.alpha = 0.f;
    
    _animating = YES;
    [UIView animateWithDuration:0.3f animations:^{
      self.selectCharView.alpha = 0.f;
      self.chooseNameView.alpha = 1.f;
    } completion:^(BOOL finished) {
      if (finished) {
        _animating = NO;
        self.selectCharView.hidden = YES;
      }
    }];
    
    [self.nameTextField becomeFirstResponder];
    
    [Analytics tutCharChosen];
  } else {
    if (gs.clan && ![Globals userType:gs.type isAlliesWith:_chosenType]) {
      [Globals popupMessage:@"You cannot switch sides without leaving your clan!"];
    } else if (_chosenType == gs.type) {
      [Globals popupMessage:[NSString stringWithFormat:@"You are already a%@ %@ %@!", [Globals userTypeIsGood:gs.type] ? @"n" : @"", [Globals factionForUserType:gs.type], [Globals classForUserType:gs.type]]];
    } else {
      [self.loadingView display:self.view];
      [[OutgoingEventController sharedOutgoingEventController] changeUserType:_chosenType];
      
      [Analytics typeChange];
      
      [self downloadNecessaryFiles];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(fadeOut)
                                                   name:CHAR_SELECTION_CLOSE_NOTIFICATION
                                                 object:nil];
      
      [[GameViewController sharedGameViewController] allowRestartOfGame];
    }
  }
}

- (void) fadeOut {
  [self.loadingView stop];
  [self cancelClicked:nil];
}

- (IBAction)backClicked:(id)sender {
  if (_animating) {
    return;
  }
  
  if (!self.chooseNameView.hidden) {
    self.titleLabel.text = @"Select a Character";
    
    self.selectCharView.hidden = NO;
    self.selectCharView.alpha = 0.f;
    _animating = YES;
    [UIView animateWithDuration:0.3f animations:^{
      self.chooseNameView.alpha = 0.f;
      self.selectCharView.alpha = 1.f;
    } completion:^(BOOL finished) {
      if (finished) {
        _animating = NO;
        self.chooseNameView.hidden = YES;
      }
    }];
    
    [self.nameTextField resignFirstResponder];
  } else if (!self.selectCharView.hidden) {
    self.titleLabel.text = @"Select a Side";
    
    self.selectSideView.hidden = NO;
    self.selectSideView.alpha = 0.f;
    _animating = YES;
    [UIView animateWithDuration:0.3f animations:^{
      self.selectCharView.alpha = 0.f;
      self.selectSideView.alpha = 1.f;
      self.backButton.alpha = 0.f;
    } completion:^(BOOL finished) {
      if (finished) {
        _animating = NO;
        self.selectCharView.hidden = YES;
        self.backButton.hidden = YES;
      }
    }];
  }
  
  GameState *gs = [GameState sharedGameState];
  self.cancelView.hidden = gs.isTutorial;
}

- (IBAction)cancelClicked:(id)sender {
  if (_animating) {
    return;
  }
  
  _animating = YES;
  [UIView animateWithDuration:4.f animations:^{
    self.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
  }];
}

- (IBAction)submitClicked:(UIView *)sender {
  if (_submitted || sender.hidden || _animating) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [self.nameTextField resignFirstResponder];
  
  NSString *realStr = self.nameTextField.text;
  realStr = [realStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (![gl validateUserName:realStr]) {
    return;
  }
  
  _submitted = YES;
  
  [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
  
  [UIView animateWithDuration:1.f animations:^{
    self.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    
    TutorialMissionMap *map = [TutorialMissionMap sharedTutorialMissionMap];
    [map beginInitialTask];
  }];
  
  FullEquipProto *weapon = nil;
  FullEquipProto *armor = nil;
  
  switch (_chosenType) {
    case UserTypeGoodWarrior:
    case UserTypeBadWarrior:
      weapon = tc.warriorInitWeapon;
      armor = tc.warriorInitArmor;
      gs.attack = tc.warriorInitAttack;
      gs.defense = tc.warriorInitDefense;
      break;
      
    case UserTypeGoodArcher:
    case UserTypeBadArcher:
      weapon = tc.archerInitWeapon;
      armor = tc.archerInitArmor;
      gs.attack = tc.archerInitAttack;
      gs.defense = tc.archerInitDefense;
      break;
      
    case UserTypeGoodMage:
    case UserTypeBadMage:
      weapon = tc.mageInitWeapon;
      armor = tc.mageInitArmor;
      gs.attack = tc.mageInitAttack;
      gs.defense = tc.mageInitDefense;
      break;
      
    default:
      break;
  }
  
  gs.name = realStr;
  gs.type = _chosenType;
  tc.enemyType = [Globals userTypeIsGood:gs.type] ? 3 : 0;
  
  [(TutorialTopBar *)[TutorialTopBar sharedTopBar] updateIcon];
  
  // Add the weapon
  UserEquip *ue = [[UserEquip alloc] init];
  ue.equipId = weapon.equipId;
  ue.userId = gs.userId;
  ue.level = 1;
  ue.userEquipId = 1;
  [gs.myEquips addObject:ue];
  [ue release];
  
  // Add the armor
  ue = [[UserEquip alloc] init];
  ue.equipId = armor.equipId;
  ue.userId = gs.userId;
  ue.level = 1;
  ue.userEquipId = 2;
  [gs.myEquips addObject:ue];
  [ue release];
  
  // Fake the userEquipIds
  gs.weaponEquipped = 1;
  gs.armorEquipped = 2;
  gs.amuletEquipped = 0;
  
  GameLayer *gLay = [GameLayer sharedGameLayer];
  [gLay loadTutorialMissionMap];
  
  [[OutgoingEventController sharedOutgoingEventController] createUser];
  
  [self downloadNecessaryFiles];
  
  [Analytics tutNameEntered];
}

- (void) downloadNecessaryFiles {
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [Globals animatedSpritePrefix:gs.type];
  NSArray *files = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%@GenericLR.plist", prefix],
                    [NSString stringWithFormat:@"%@GenericLR.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@AttackNF.plist", prefix],
                    [NSString stringWithFormat:@"%@AttackNF.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@WalkUD.plist", prefix],
                    [NSString stringWithFormat:@"%@WalkUD.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@WalkNF.plist", prefix],
                    [NSString stringWithFormat:@"%@WalkNF.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@GenericNF.plist", prefix],
                    [NSString stringWithFormat:@"%@GenericNF.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@AttackLR.plist", prefix],
                    [NSString stringWithFormat:@"%@AttackLR.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@AttackUD.plist", prefix],
                    [NSString stringWithFormat:@"%@AttackUD.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@GenericUD.plist", prefix],
                    [NSString stringWithFormat:@"%@GenericUD.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@WalkLR.plist", prefix],
                    [NSString stringWithFormat:@"%@WalkLR.pvr.ccz", prefix],
                    @"AllianceArcherWalkNF.plist", @"AllianceArcherWalkNF.pvr.ccz",
                    @"AllianceMageWalkNF.plist", @"AllianceMageWalkNF.pvr.ccz",
                    @"LegionArcherWalkNF.plist", @"LegionArcherWalkNF.pvr.ccz",
                    @"LegionMageWalkNF.plist", @"LegionMageWalkNF.pvr.ccz",
                    nil];
  
  for (NSString *file in files) {
    [Globals imageNamed:file withView:nil maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
  }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (![string isEqualToString:@"\n"]) {
    NSString *oldStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *str = [oldStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length < [[Globals sharedGlobals] minNameLength]) {
      self.submitButton.hidden = YES;
    } else {
      self.submitButton.hidden = NO;
    }
    
    if (str.length <= [[Globals sharedGlobals] maxNameLength]) {
      [[(NiceFontTextField *)textField label] setText:oldStr];
      return YES;
    }
    return NO;
  }
  return NO;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  [textField selectAll:self];
  [UIMenuController sharedMenuController].menuVisible = NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.titleLabel = nil;
    self.chooseNameView = nil;
    self.nameTextField = nil;
    self.submitButton = nil;
    self.loadingView = nil;
    self.cancelView = nil;
    self.selectCharView = nil;
    self.selectSideView = nil;
  }
}

@end
