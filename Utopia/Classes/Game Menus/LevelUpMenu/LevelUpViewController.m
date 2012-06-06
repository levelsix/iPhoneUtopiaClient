//
//  LevelUpViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LevelUpViewController.h"
#import "Globals.h"
#import "ProfileViewController.h"
#import "GameState.h"
#import "BuildUpgradePopupController.h"
#import "SimpleAudioEngine.h"

@implementation LevelUpViewController

@synthesize congratsLabel;
@synthesize levelUpResponse, itemView;
@synthesize itemLabel, itemIcon, itemBackground, cityUnlocked;
@synthesize staminaView, energyView, statsView;
@synthesize scrollView, glowingStars;
@synthesize mainView, bgdView;

- (id) initWithLevelUpResponse:(LevelUpResponseProto *)lurp {
  if ((self = [super init])) {
    self.levelUpResponse = lurp;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  congratsLabel.text = [NSString stringWithFormat:@"You have reached level %d!", levelUpResponse.newLevel];
  
  _itemViews = [[NSMutableArray alloc] init];
  for (FullCityProto *fcp in levelUpResponse.citiesNewlyAvailableToUserList) {
    [[NSBundle mainBundle] loadNibNamed:@"LevelUpItemView" owner:self options:nil];
    self.cityUnlocked.hidden = NO;
    self.itemBackground.highlighted = YES;
    self.itemLabel.text = [fcp.name lowercaseString];
    [_itemViews addObject:self.itemView];
  }
  
  for (FullEquipProto *fep in levelUpResponse.newlyEquippableEpicsAndLegendariesList) {
    [[NSBundle mainBundle] loadNibNamed:@"LevelUpItemView" owner:self options:nil];
    self.itemLabel.text = [fep.name lowercaseString];
    [Globals loadImageForEquip:fep.equipId toView:self.itemIcon maskedView:nil];
    [_itemViews addObject:self.itemView];
  }
  
  for (FullStructureProto *fsp in levelUpResponse.newlyAvailableStructsList) {
    [[NSBundle mainBundle] loadNibNamed:@"LevelUpItemView" owner:self options:nil];
    self.itemLabel.text = [fsp.name lowercaseString];
    [Globals loadImageForStruct:fsp.structId toView:self.itemIcon masked:NO];
    [_itemViews addObject:self.itemView];
  }
  
  [_itemViews addObject:self.statsView];
  [_itemViews addObject:self.energyView];
  [_itemViews addObject:self.staminaView];
  
#define VERT_SEPARATION 5
#define HORZ_SEPARATION 7
  for (int i = 0; i < _itemViews.count; i++) {
    UIView *view = [_itemViews objectAtIndex:i];
    int x = scrollView.frame.size.width/2 + ((i % 3)-1)*(view.frame.size.width+HORZ_SEPARATION);
    int y = (i/3*(view.frame.size.height+VERT_SEPARATION))+view.frame.size.height/2+VERT_SEPARATION;
    view.center = CGPointMake(x, y);
  }
  
  UIView *view = [_itemViews lastObject];
  scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, CGRectGetMaxY(view.frame)+VERT_SEPARATION);
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [[SimpleAudioEngine sharedEngine] playEffect:@"levelup.m4a"];
  
  UIViewAnimationOptions opt = UIViewAnimationCurveEaseInOut|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse;
  [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
    glowingStars.alpha = 0.4f;
  } completion:nil];
  
  [self popCurrentView];
}

- (void) popCurrentView {
  if (_currentIndex < _itemViews.count) {
    UIView *view = [_itemViews objectAtIndex:_currentIndex];
    [scrollView addSubview:view];
    
    if (scrollView.contentOffset.y+scrollView.frame.size.height < CGRectGetMaxY(view.frame)+VERT_SEPARATION) {
      [scrollView setContentOffset:CGPointMake(0, CGRectGetMaxY(view.frame)+VERT_SEPARATION-scrollView.frame.size.height) animated:YES];
    }
    
    [self popView:view];
    _currentIndex++;
  }
}

- (void) popView:(UIView *)view {
  view.transform = CGAffineTransformMakeScale(.5f, .5f);
  [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationCurveEaseInOut animations:^{
    view.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [self popCurrentView];
  }];
  
  view.alpha = 0.f;
  [UIView animateWithDuration:0.2f animations:^{
    view.alpha = 1.f;
  }];
}

- (IBAction)okayClicked:(id)sender {
  [[ProfileViewController sharedProfileViewController] loadMyProfile];
  [ProfileViewController displayView];
  [[ProfileViewController sharedProfileViewController] openSkillsMenu];
  
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self didReceiveMemoryWarning];
    [self release];
  }];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.levelUpResponse = nil;
  self.congratsLabel = nil;
  self.itemView = nil;
  self.itemLabel = nil;
  self.itemIcon = nil;
  self.itemBackground = nil;
  self.cityUnlocked = nil;
  self.staminaView = nil;
  self.energyView = nil;
  self.statsView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.glowingStars = nil;
  self.scrollView = nil;
}

- (void) dealloc {
  [_itemViews release];
  [super dealloc];
}

@end
