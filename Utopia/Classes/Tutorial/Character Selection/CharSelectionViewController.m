//
//  CharSelectionViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CharSelectionViewController.h"
#import "SynthesizeSingleton.h"
#import "Globals.h"
#import "TutorialConstants.h"
#import "TutorialBattleLayer.h"
#import "GameLayer.h"
#import "TutorialHomeMap.h"
#import "GameState.h"
#import "DialogMenuController.h"
#import "TutorialTopBar.h"

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
  [[CCDirector sharedDirector] pause];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[CCDirector sharedDirector] resume];
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
  for (UIView *view in self.view.subviews) {
    if (view.tag != 10) {
      view.hidden = YES;
    }
  }
  [self.view addSubview:chooseNameView];
  
  [nameTextField becomeFirstResponder];
}

- (IBAction)backClicked:(id)sender {
  [chooseNameView removeFromSuperview];
  for (UIView *view in self.view.subviews) {
    view.hidden = NO;
  }
}

- (IBAction)submitClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [nameTextField resignFirstResponder];
  
  NSString *realStr = nameTextField.text;
  realStr = [realStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  // make sure length is okay
  if (realStr.length < tc.minNameLength || realStr.length > tc.maxNameLength) {
    return;
  }
  
  // make sure there are no obvious swear words
  NSString *lowerStr = [realStr lowercaseString];
  NSArray *swearWords = [NSArray arrayWithObjects:@"fuck", @"shit", @"bitch", nil];
  for (NSString *swear in swearWords) {
    if ([lowerStr rangeOfString:swear].location != NSNotFound) {
      [Globals popupMessage:@"Please refrain from using vulgar language within this game."];
      return;
    }
  }
  
  [UIView animateWithDuration:4.f animations:^{
    self.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    [self didReceiveMemoryWarning];
    [self release];
    
    GameState *gs = [GameState sharedGameState];
    NSString *str = [NSString stringWithFormat:[[TutorialConstants sharedTutorialConstants] beforeBlinkText], gs.name];
    [DialogMenuController displayViewForText:str callbackTarget:self action:@selector(runGameLayer)];
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
  gs.weaponEquipped = weapon.equipId;
  gs.armorEquipped = armor.equipId;
  gs.type = _curPage;
  tc.enemyType = gs.type < 3 ? 3 : 0;
  
  [(TutorialTopBar *)[TutorialTopBar sharedTopBar] updateIcon];
  
  [[DialogMenuController sharedDialogMenuController].girlImageView awakeFromNib];
  
  [gs changeQuantityForEquip:weapon.equipId by:1];
  [gs changeQuantityForEquip:armor.equipId by:1];
  
  GameLayer *gLay = [GameLayer sharedGameLayer];
  [gLay performSelectorInBackground:@selector(loadTutorialMissionMap) withObject:nil];
  [Analytics tutorialCharChosen];
}

- (void) runGameLayer {
  [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (![string isEqualToString:@"\n"]) {
    NSString *oldStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *str = [oldStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length < [[TutorialConstants sharedTutorialConstants] minNameLength]) {
      self.submitButton.hidden = YES;
    } else {
      self.submitButton.hidden = NO;
    }
    
    if (str.length <= [[TutorialConstants sharedTutorialConstants] maxNameLength]) {
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
}

@end
