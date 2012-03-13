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

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  charScrollView = [[UIScrollView alloc] initWithFrame:badArcherView.frame];
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
  
  nameTextField.font = [UIFont fontWithName:@"Requiem Text-HTF-SmallCaps" size:17];
  
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
  NSLog(@"submit");
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  return YES;//str.length < [Globals sharedGlobals] max
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
