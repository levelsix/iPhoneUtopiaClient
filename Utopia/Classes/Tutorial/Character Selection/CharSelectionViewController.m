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
#import "TutorialStartLayer.h"
#import "Downloader.h"
#import "OutgoingEventController.h"

@implementation CharSelectionViewController

@synthesize goodMageView, goodArcherView, goodWarriorView;
@synthesize badMageView, badArcherView, badWarriorView;
@synthesize leftArrowButton, rightArrowButton;
@synthesize charScrollView;
@synthesize smallAttBar, medAttBar, bigAttBar;
@synthesize smallDefBar, medDefBar, bigDefBar;
@synthesize titleLabel;
@synthesize greenGlow, redGlow;
@synthesize bottomBar, chooseNameView;
@synthesize nameTextField;
@synthesize submitButton;
@synthesize loadingView;

//SYNTHESIZE_SINGLETON_FOR_CONTROLLER(CharSelectionViewController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  [nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
  
  _pageWidth = charScrollView.frame.size.width;
  _barWidth = bigAttBar.frame.size.width;
  // Insert right above the background
  [self.view insertSubview:charScrollView atIndex:1];
  
  CGRect temp;
  UIView *cur = nil;
  UIView *prev = nil;
  
  [charScrollView addSubview:goodWarriorView];
  
  cur = goodArcherView;
  prev = goodWarriorView;
  [charScrollView addSubview:cur];
  temp = cur.frame;
  temp.origin.x = CGRectGetMaxX(prev.frame);
  cur.frame = temp;
  
  cur = goodMageView;
  prev = goodArcherView;
  [charScrollView addSubview:cur];
  temp = cur.frame;
  temp.origin.x = CGRectGetMaxX(prev.frame);
  cur.frame = temp;
  
  cur = badWarriorView;
  prev = goodMageView;
  [charScrollView addSubview:cur];
  temp = cur.frame;
  temp.origin.x = CGRectGetMaxX(prev.frame);
  cur.frame = temp;
  
  cur = badArcherView;
  prev = badWarriorView;
  [charScrollView addSubview:cur];
  temp = cur.frame;
  temp.origin.x = CGRectGetMaxX(prev.frame);
  cur.frame = temp;
  
  cur = badMageView;
  prev = badArcherView;
  [charScrollView addSubview:cur];
  temp = cur.frame;
  temp.origin.x = CGRectGetMaxX(prev.frame);
  cur.frame = temp;
  
  charScrollView.contentSize = CGSizeMake(CGRectGetMaxX(cur.frame), CGRectGetMaxY(cur.frame));
  charScrollView.scrollEnabled = YES;
  charScrollView.pagingEnabled = YES;
  charScrollView.showsHorizontalScrollIndicator = NO;
  charScrollView.delegate = self;
  // Set tag to 10 so it doesnt get hidden when select is clicked
  charScrollView.tag = 10;
  
  smallAttBar.alpha = 0.f;
  medAttBar.alpha = 0.f;
  bigAttBar.alpha = 0.f;
  smallDefBar.alpha = 0.f;
  medDefBar.alpha = 0.f;
  bigDefBar.alpha = 0.f;
  titleLabel.alpha = 0.f;
  redGlow.alpha = 0.f;
  greenGlow.alpha = 0.f;
  [self updateArrows];
  [self animatePage];
  _curPage = 0;
  
  submitButton.hidden = YES;
  self.view.alpha = 0.f;
  
  
  // Preload the keyboard so its not super slow
  UITextField *dummyTextField = [[UITextField alloc] init];
  dummyTextField.hidden = YES;
  dummyTextField.userInteractionEnabled = NO;
  [dummyTextField becomeFirstResponder];
  [dummyTextField resignFirstResponder];
  [dummyTextField release];
  
  nameTextField.label.textColor = [UIColor whiteColor];
}

- (void) viewDidAppear:(BOOL)animated {
  [UIView animateWithDuration:5.f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
    self.view.alpha = 1.f;
  } completion:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self didReceiveMemoryWarning];
  [self release];
}

- (int) currentPage {
  return _curPage;
}

- (void) moveToPage:(int)page {
  if (page >= 0 && page < 6 && page != _curPage) {
    _curPage = page;
    [charScrollView setContentOffset:CGPointMake(_pageWidth*page, 0) animated:YES];
  }
}

- (IBAction)leftArrowClicked:(id)sender {
  if (!charScrollView.isDragging && !_isScrolling) {
    [self moveToPage:[self currentPage]-1];
  }
}

- (IBAction)rightArrowClicked:(id)sender {
  if (!charScrollView.isDragging && !_isScrolling) {
    [self moveToPage:[self currentPage]+1];
  }
}

- (void) updateArrows {
  int curPage = [self currentPage];
  if (curPage == 0) {
    leftArrowButton.enabled = NO;
  } else {
    leftArrowButton.enabled = YES;
  }
  
  if (curPage == 5) {
    rightArrowButton.enabled = NO;
  } else {
    rightArrowButton.enabled = YES;
  }
}

- (void) animatePage {
  int page = [self currentPage];
  
  // Pages ordered by current UserType so leverage globals
  NSString *title = [NSString stringWithFormat:@"%@ %@", [Globals factionForUserType:page], [Globals classForUserType:page]];
  titleLabel.text = title;
  
  UIImageView *attBar = nil;
  UIImageView *defBar = nil;
  UIImageView *glow = page/3 == 0 ? greenGlow : redGlow;
  switch (page % 3) {
    case 0:
      attBar = smallAttBar;
      defBar = bigDefBar;
      break;
      
    case 1:
      attBar = medAttBar;
      defBar = medDefBar;
      break;
      
    case 2:
      attBar = bigAttBar;
      defBar = smallDefBar;
      break;
      
    default:
      break;
  }
  
  CGRect r = attBar.frame;
  r.size.width = 0;
  attBar.frame = r;
  attBar.alpha = 1.f;
  
  r = defBar.frame;
  r.size.width = 0;
  defBar.frame = r;
  defBar.alpha = 1.f;
  
  titleLabel.alpha = 0.f;
  
  // In IB, we set the tags of the buttons to page+1
  UIView *view = [bottomBar viewWithTag:page+1];
  glow.center = view.center;
  
  [UIView animateWithDuration:0.1f animations:^{
    CGRect t = attBar.frame;
    t.size.width = _barWidth;
    attBar.frame = t;
    
    t = defBar.frame;
    t.size.width = _barWidth;
    defBar.frame = t;
    
    titleLabel.alpha = 1.f;
    glow.alpha = 1.f;
  }];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  _isScrolling = YES;
  [UIView animateWithDuration:0.1f animations:^{
    titleLabel.alpha = 0.f;
    smallAttBar.alpha = 0.f;
    medAttBar.alpha = 0.f;
    bigAttBar.alpha = 0.f;
    smallDefBar.alpha = 0.f;
    medDefBar.alpha = 0.f;
    bigDefBar.alpha = 0.f;
    greenGlow.alpha = 0.f;
    redGlow.alpha = 0.f;
  }];
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  _isScrolling = NO;
  [self updateArrows];
  [self animatePage];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  _isScrolling = NO;
  _curPage = (int)(charScrollView.contentOffset.x / _pageWidth);
  [self updateArrows];
  [self animatePage];
}

- (IBAction)iconClicked:(UIView *)sender {
  [self moveToPage:sender.tag-1];
}

- (IBAction)selectedClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  // If it is tutorial, show name screen
  // Otherwise send the change user type message
  if (gs.isTutorial) {
    for (UIView *view in self.view.subviews) {
      if (view.tag != 10) {
        view.hidden = YES;
      }
    }
    [self.view addSubview:chooseNameView];
    
    [nameTextField becomeFirstResponder];
  } else {
    [self.loadingView display:self.view];
    [[OutgoingEventController sharedOutgoingEventController] changeUserType:_curPage];
    
    [Analytics typeChange];
    
    [self downloadNecessaryFiles];
  }
}

- (IBAction)backClicked:(id)sender {
  [chooseNameView removeFromSuperview];
  for (UIView *view in self.view.subviews) {
    view.hidden = NO;
  }
}

- (IBAction)submitClicked:(id)sender {
  if (_submitted) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [nameTextField resignFirstResponder];
  
  NSString *realStr = nameTextField.text;
  realStr = [realStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (![gl validateUserName:realStr]) {
    return;
  }
  
  _submitted = YES;
  
  [UIView animateWithDuration:4.f animations:^{
    self.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    
    [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
  }];
  
  FullEquipProto *weapon = nil;
  FullEquipProto *armor = nil;
  
  switch (_curPage) {
    case 0:
    case 3:
      weapon = tc.warriorInitWeapon;
      armor = tc.warriorInitArmor;
      gs.attack = tc.warriorInitAttack;
      gs.defense = tc.warriorInitDefense;
      break;
      
    case 1:
    case 4:
      weapon = tc.archerInitWeapon;
      armor = tc.archerInitArmor;
      gs.attack = tc.archerInitAttack;
      gs.defense = tc.archerInitDefense;
      break;
      
    case 2:
    case 5:
      weapon = tc.mageInitWeapon;
      armor = tc.mageInitArmor;
      gs.attack = tc.mageInitAttack;
      gs.defense = tc.mageInitDefense;
      break;
      
    default:
      break;
  }
  
  gs.name = realStr;
  gs.type = _curPage;
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
  [gLay performSelectorInBackground:@selector(loadTutorialMissionMap) withObject:nil];
  [Analytics tutorialCharChosen];
  
  [self downloadNecessaryFiles];
}

- (void) downloadNecessaryFiles {
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [Globals animatedSpritePrefix:gs.type];
  NSArray *files = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%@AttackLR.plist", prefix],
                    [NSString stringWithFormat:@"%@AttackLR.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@WalkUD.plist", prefix],
                    [NSString stringWithFormat:@"%@WalkUD.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@AttackNF.plist", prefix],
                    [NSString stringWithFormat:@"%@AttackNF.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@AttackUD.plist", prefix],
                    [NSString stringWithFormat:@"%@AttackUD.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@GenericLR.plist", prefix],
                    [NSString stringWithFormat:@"%@GenericLR.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@GenericNF.plist", prefix],
                    [NSString stringWithFormat:@"%@GenericNF.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@GenericUD.plist", prefix],
                    [NSString stringWithFormat:@"%@GenericUD.pvr.ccz", prefix],
                    [NSString stringWithFormat:@"%@WalkLR.plist", prefix],
                    [NSString stringWithFormat:@"%@WalkLR.pvr.ccz", prefix],
                    nil];
  
  for (NSString *file in files) {
    NSString *doubleRes = [CCFileUtils getDoubleResolutionImage:file validate:NO];
    [[Downloader sharedDownloader] asyncDownloadFile:doubleRes completion:nil];
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.goodMageView = nil;
  self.goodArcherView = nil;
  self.goodWarriorView = nil;
  self.badMageView = nil;
  self.badArcherView = nil;
  self.badWarriorView = nil;
  self.leftArrowButton = nil;
  self.rightArrowButton = nil;
  self.charScrollView = nil;
  self.smallAttBar = nil;
  self.medAttBar = nil;
  self.bigAttBar = nil;
  self.smallDefBar = nil;
  self.medDefBar = nil;
  self.bigDefBar = nil;
  self.titleLabel = nil;
  self.greenGlow = nil;
  self.redGlow = nil;
  self.bottomBar = nil;
  self.chooseNameView = nil;
  self.nameTextField = nil;
  self.submitButton = nil;
  self.loadingView = nil;
}

@end
