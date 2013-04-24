//
//  MarketplaceViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MarketplaceViewController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "NibUtils.h"
#import "RefillMenuController.h"
#import "ProfileViewController.h"
#import "SoundEngine.h"
#import "GenericPopupController.h"

#define PRICE_DIGITS 7
#define REFRESH_ROWS 20

@implementation MarketplaceViewController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(MarketplaceViewController);
@synthesize navBar, topBar;
@synthesize itemView;
@synthesize postsTableView;
@synthesize selectedCell;
@synthesize removeView;
@synthesize listing;
@synthesize curField;
@synthesize shouldReload;
@synthesize state;
@synthesize coinBar;
@synthesize removePriceLabel, retractPriceIcon, removeDescriptionLabel;
@synthesize doneButton, listAnItemButton;
@synthesize redeemView;
@synthesize redeemGoldLabel, redeemSilverLabel;
@synthesize redeemTitleLabel;
@synthesize ropeView, leftRope, rightRope, leftRopeFirstRow, rightRopeFirstRow;
@synthesize loadingView;
@synthesize purchView;
@synthesize armoryPriceIcon, armoryPriceView, armoryPriceLabel, armoryPriceBottomSubview;
@synthesize bottomBar;
@synthesize topBarLabel;
@synthesize filterView, mainView;

- (void) viewDidLoad {
  [super viewDidLoad];
  
  UITableView *t= [[CancellableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  t.separatorStyle = UITableViewCellSeparatorStyleNone;
  t.delegate = self;
  t.dataSource = self;
  t.backgroundColor = [UIColor clearColor];
  t.frame = CGRectMake(self.mainView.frame.size.width/2-240.f, topBar.frame.origin.y, 480.f, self.mainView.frame.size.height-topBar.frame.origin.y);
  t.showsVerticalScrollIndicator = NO;
  t.rowHeight = 55;
  t.delaysContentTouches = NO;
  self.postsTableView = t;
  [t release];
  [self.mainView insertSubview:t belowSubview:topBar];
  [self.mainView insertSubview:self.redeemView aboveSubview:self.topBar];
  
  
  [super addPullToRefreshHeader:self.postsTableView];
  
  [self.postsTableView addSubview:self.ropeView];
  self.ropeView.center = CGPointMake(self.postsTableView.frame.size.width/2, self.ropeView.center.y);
  
  [self.postsTableView addSubview:self.removeView];
  
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  leftRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(self.postsTableView.frame.size.width/2-225.f, 30, 3, 40)];
  rightRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(self.postsTableView.frame.size.width/2+223.f, 30, 3, 40)];
  leftRopeFirstRow.backgroundColor = c;
  rightRopeFirstRow.backgroundColor = c;
  [self.postsTableView insertSubview:leftRopeFirstRow belowSubview:self.ropeView];
  [self.postsTableView insertSubview:rightRopeFirstRow belowSubview:self.ropeView];
  
  self.redeemView.hidden = YES;
  
  _swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openFilterPage:)];
  [self.view addGestureRecognizer:_swipeGestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Restore filter view defaults without loading nib
  MarketplaceFilterView *m = [[MarketplaceFilterView alloc] init];
  [m restoreDefaults];
  [m release];
  
  self.postsTableView.scrollEnabled = YES;
  
  self.redeemView.frame = self.view.bounds;
  self.purchView.frame = self.view.bounds;
  
  self.postsTableView.frame = CGRectMake(self.mainView.frame.size.width/2-240.f, topBar.frame.origin.y, 480.f, self.mainView.frame.size.height-topBar.frame.origin.y);
  self.ropeView.center = CGPointMake(self.postsTableView.frame.size.width/2, self.ropeView.center.y);
  
  [self.loadingView stop];
  
  [self setState:kEquipBuyingState];
  
  [self refresh];
  
  self.removeView.hidden = YES;
  [self.purchView removeFromSuperview];
  
  self.redeemView.hidden = YES;
  
  CGRect f = self.view.frame;
  self.view.center = CGPointMake(self.view.center.x, f.size.height*3/2);
  [UIView animateWithDuration:FULL_SCREEN_APPEAR_ANIMATION_DURATION animations:^{
    self.view.center = CGPointMake(self.view.center.x, f.size.height/2);
  } completion:^(BOOL finished) {
    [self displayRedeemView];
  }];
  
  [coinBar updateLabels];
  [bottomBar updateLabels];
  
  [[SoundEngine sharedSoundEngine] marketplaceEnter];
  
  [bottomBar reload];
  
  self.armoryPriceView.alpha = 0.f;
}

- (void) searchForEquipId:(int)equipId level:(int)level allowAllAbove:(BOOL)allowAllAbove {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *p = nil;
  for (FullEquipProto *e in gs.mktSearchEquips) {
    if (e.equipId == equipId) {
      p = e;
      break;
    }
  }
  
  [self.filterView restoreDefaults];
  
  if (p) {
    [self.filterView.searchView selectSearchEquip:p];
    
    if (level > 0) {
      [self.filterView.forgeLevelBar movePin:YES toNotch:level-1];
      [self.filterView.forgeLevelBar movePin:NO toNotch:allowAllAbove ? gl.forgeMaxEquipLevel-1 : level-1];
    }
    
    [self.filterView.pickerView setSortOrder:RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsSortingOrderPriceLowToHigh];
  }
  
  [self.filterView saveFilterSettings];
  [self refresh];
  [self.purchView removeFromSuperview];
  [MarketplaceViewController displayView];
}

- (void) displayRedeemView {
  GameState *gs = [GameState sharedGameState];
  if (gs.marketplaceGoldEarnings || gs.marketplaceSilverEarnings) {
    self.redeemView.frame = CGRectMake(0, -self.redeemView.frame.size.height, self.redeemView.frame.size.width, self.redeemView.frame.size.height);
    
    self.postsTableView.userInteractionEnabled = NO;
    self.redeemView.hidden = NO;
    self.redeemGoldLabel.text = [Globals commafyNumber:gs.marketplaceGoldEarnings];
    self.redeemSilverLabel.text = [Globals commafyNumber:gs.marketplaceSilverEarnings];
    
    [UIView animateWithDuration:0.3f animations:^(void) {
      CGRect tmp = self.redeemView.frame;
      tmp.origin.y = CGRectGetMaxY(self.navBar.frame)-13;
      self.redeemView.frame = tmp;
    }];
  }
}

- (void) updateArmoryPopupForEquipId:(UserEquip *)ue {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL sellsForGold = [Globals sellsForGoldInMarketplace:fep];
  int retail = [gl calculateRetailValueForEquip:ue.equipId level:ue.level];
  NSString *price = retail > 0 ? [Globals commafyNumber:retail] : @"N/A";
  
  armoryPriceIcon.highlighted = sellsForGold;
  armoryPriceLabel.text = price;
  
  // Center the bottom subview
  CGSize size = [armoryPriceLabel.text sizeWithFont:armoryPriceLabel.font];
  CGRect rect = armoryPriceBottomSubview.frame;
  rect.size.width = armoryPriceLabel.frame.origin.x + size.width;
  armoryPriceBottomSubview.frame = rect;
  armoryPriceBottomSubview.center = CGPointMake(armoryPriceBottomSubview.superview.frame.size.width/2, armoryPriceBottomSubview.center.y);
}

- (IBAction)backClicked:(id)sender {
  [self close];
}

- (void) close {
  if (self.view.superview) {
    [self.purchView removeFromSuperview];
    
    [[SoundEngine sharedSoundEngine] marketplaceLeave];
    
    CGRect f = self.view.frame;
    [UIView animateWithDuration:FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION animations:^{
      self.view.center = CGPointMake(self.view.center.x, f.size.height*3/2);
    } completion:^(BOOL finished) {
      [MarketplaceViewController removeView];
    }];
    
    [self.view endEditing:YES];
  }
}

- (IBAction)searchBarClicked:(id)sender {
  [Globals popupMessage:@"Sorry, search isn't ready yet. We will be adding it soon!"];
  [Analytics clickedMarketplaceSearch];
}

- (IBAction)listButtonClicked:(id)sender {
  // Need to do 2 superviews: first one gives UITableViewCellContentView, second one gives ItemPostView
  ItemPostView *post = (ItemPostView *)[[[(UIButton *)sender superview] superview] superview];
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:post.equip.equipId];
  Globals *gl = [Globals sharedGlobals];
  [Analytics attemptedPost];
  
  if (gs.numPostsInMarketplace >= gl.maxNumberOfMarketplacePosts) {
    [Globals popupMessage:[NSString stringWithFormat:@"You have %d items in the marketplace. Remove a listing to post.", gs.numPostsInMarketplace]];
    return;
  }
  
  post.state = kSubmitState;
  
  if (self.selectedCell != post && self.selectedCell.state == kSubmitState) {
    self.selectedCell.state = kListState;
  }
  self.selectedCell = post;
  
  if ([Globals sellsForGoldInMarketplace:fep]) {
    post.submitPriceIcon.highlighted = YES;
  } else {
    post.submitPriceIcon.highlighted = NO;
  }
  
  self.removeView.hidden = YES;
  
  [post.priceField becomeFirstResponder];
  
  [self updateArmoryPopupForEquipId:post.equip];
  self.armoryPriceView.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    self.armoryPriceView.alpha = 1.f;
  }];
}

- (IBAction)submitCloseClicked:(id)sender {
  // Need to do 2 superviews: first one gives UITableViewCellContentView, second one gives ItemPostView
  ItemPostView *post = (ItemPostView *)[[(UIButton *)sender superview] superview];
  if (self.selectedCell.state == kSubmitState) {
    self.selectedCell.state = kListState;
  }
  self.selectedCell = post;
  post.state = kListState;
  [self disableEditing];
  
  if (self.postsTableView.contentSize.height < self.postsTableView.frame.size.height) {
    [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
  } else if (self.postsTableView.contentOffset.y+self.postsTableView.frame.size.height > self.postsTableView.contentSize.height) {
    // Screen has scrolled too far down, need to move back up
    [self.postsTableView setContentOffset:CGPointMake(0, self.postsTableView.contentSize.height - self.postsTableView.frame.size.height) animated:YES];
  } else if (0 > self.postsTableView.contentOffset.y) {
    // Screen has scrolled too far up, need to move back down
    [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
  }
}

- (IBAction)submitClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  ItemPostView *post = (ItemPostView *)[[(UIButton *)sender superview] superview];
  if (post.equip) {
    [self disableEditing];
    int amount = [post.priceField.text stringByReplacingOccurrencesOfString:@"," withString:@""].intValue;
    
    if (!amount) {
      post.state = kListState;
    } else if (![gs hasValidLicense]) {
      FullEquipProto *fep = [gs equipWithId:post.equip.equipId];
      NSString *desc = [NSString stringWithFormat:@"Removing this post within %d days will cost %d %@. Post it?", gl.numDaysUntilFreeRetract, (int)ceilf(amount * gl.retractPercentCut), [Globals sellsForGoldInMarketplace:fep] ? @"Gold" : @"Silver"];
      [GenericPopupController displayConfirmationWithDescription:desc title:@"Post Item" okayButton:@"Post" cancelButton:nil target:self selector:@selector(submitItem)];
    } else {
      [self submitItem];
    }
  }
}

- (void) submitItem {
  ItemPostView *post = self.selectedCell;
  [self disableEditing];
  int amount = [post.priceField.text stringByReplacingOccurrencesOfString:@"," withString:@""].intValue;
  [[OutgoingEventController sharedOutgoingEventController] equipPostToMarketplace:post.equip.userEquipId price:amount];
  post.state = kListState;
  
  NSIndexPath *path = [postsTableView numberOfRowsInSection:0] <= 2 ? [NSIndexPath indexPathForRow:0 inSection:0] : nil;
  [postsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[postsTableView indexPathForCell:post], path, nil] withRowAnimation:UITableViewRowAnimationTop];
  
  [Analytics successfulPost:post.equip.equipId];
  [coinBar updateLabels];
  [bottomBar updateLabels];
}

- (IBAction)minusButtonClicked:(id)sender {
  if (!listing) {
    // Need to do 2 superviews: first one gives UITableViewCellContentView, second one gives ItemPostView
    ItemPostView *post = (ItemPostView *)[[(UIButton *)sender superview] superview];
    if (self.selectedCell.state == kSubmitState) {
      self.selectedCell.state = kListState;
    }
    self.selectedCell = post;
    
    CGRect tmp = self.removeView.frame;
    tmp.origin = CGPointMake(postsTableView.frame.origin.x+post.frame.origin.x+70, post.frame.origin.y-5);
    self.removeView.frame = tmp;
    
    self.removeView.hidden = NO;
    
    FullMarketplacePostProto *mkt = post.mktProto;
    Globals *gl = [Globals sharedGlobals];
    
    if ([gl canRetractMarketplacePostForFree:mkt]) {
      removePriceLabel.text = @"0";
      removeDescriptionLabel.text = [NSString stringWithFormat:@"You can remove this item for free."];
      retractPriceIcon.highlighted = mkt.diamondCost > 0;
    } else {
      removeDescriptionLabel.text = [NSString stringWithFormat:@"Removing items incurs a %d%% fee:", (int)(gl.retractPercentCut*100)];
      if (mkt.diamondCost > 0) {
        self.removePriceLabel.text = [Globals commafyNumber:(int)ceilf(mkt.diamondCost * gl.retractPercentCut)];
        self.retractPriceIcon.highlighted = YES;
      } else {
        self. removePriceLabel.text = [Globals commafyNumber:(int)ceilf(mkt.coinCost * gl.retractPercentCut)];
        self.retractPriceIcon.highlighted = NO;
      }
    }
    
    NSIndexPath *indexPath = [self.postsTableView indexPathForCell:post];
    
    if (self.postsTableView.contentOffset.y+self.postsTableView.frame.size.height < CGRectGetMaxY(self.removeView.frame)) {
      // View is at the bottom of the screen
      [self.postsTableView setContentOffset:CGPointMake(0, CGRectGetMaxY(self.removeView.frame) - self.postsTableView.frame.size.height+5) animated:YES];
    } else if (self.postsTableView.contentOffset.y+self.topBar.frame.size.height > self.removeView.frame.origin.y) {
      // View is too far up
      [self.postsTableView setContentOffset:CGPointMake(0, self.removeView.frame.origin.y-self.topBar.frame.size.height-5) animated:YES];
    } else if (self.postsTableView.contentSize.height < self.postsTableView.frame.size.height) {
      [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (self.postsTableView.contentOffset.y+self.postsTableView.frame.size.height > self.postsTableView.contentSize.height && [self.postsTableView numberOfRowsInSection:0]-1 != indexPath.row) {
      // Screen has scrolled too far down, need to move back up
      [self.postsTableView setContentOffset:CGPointMake(0, self.postsTableView.contentSize.height - self.postsTableView.frame.size.height) animated:YES];
    } else if (0 > self.postsTableView.contentOffset.y && 1 != indexPath.row) {
      // Screen has scrolled too far up, need to move back down
      [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    [Analytics viewedRetract];
  }
}

- (IBAction)removeItemClicked:(id)sender {
  FullMarketplacePostProto *fmpp = self.selectedCell.mktProto;
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  [Analytics attemptedRetract];
  
  BOOL canRetract = YES;
  if (![gl canRetractMarketplacePostForFree:fmpp]) {
    if (fmpp.diamondCost > 0) {
      int amount = (int) ceilf(fmpp.diamondCost*gl.retractPercentCut);
      if (gs.gold < amount) {
        canRetract = NO;
        [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:fmpp.diamondCost];
        [Analytics notEnoughGoldForMarketplaceRetract:fmpp.postedEquip.equipId cost:fmpp.diamondCost];
      }
    } else {
      int amount = (int) ceilf(fmpp.coinCost*gl.retractPercentCut);
      if (gs.silver < amount) {
        canRetract = NO;
        [[RefillMenuController sharedRefillMenuController] displayBuySilverView:amount];
        [Analytics notEnoughSilverForMarketplaceRetract:fmpp.postedEquip.equipId cost:fmpp.coinCost];
      }
    }
  }
  
  if (canRetract) {
    [[OutgoingEventController sharedOutgoingEventController] retractMarketplacePost:fmpp.marketplacePostId];
    [Analytics successfulRetract];
    
    [self.loadingView display:self.mainView];
  }
  
  // Looks choppy. change this by finding the correct table cell and updating that alone..
  [self.postsTableView reloadData];
  
  self.removeView.hidden = YES;
  self.selectedCell = nil;
  
  [coinBar updateLabels];
}

- (IBAction)cancelRemoveClicked:(id)sender {
  self.removeView.hidden = YES;
  
  if (self.postsTableView.contentSize.height < self.postsTableView.frame.size.height) {
    [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
  } else if (self.postsTableView.contentOffset.y+self.postsTableView.frame.size.height > self.postsTableView.contentSize.height ) {
    // Screen has scrolled too far down, need to move back up
    [self.postsTableView setContentOffset:CGPointMake(0, self.postsTableView.contentSize.height - self.postsTableView.frame.size.height) animated:YES];
  } else if (0 > self.postsTableView.contentOffset.y) {
    // Screen has scrolled too far up, need to move back down
    [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
  }
  self.selectedCell = nil;
}

- (IBAction)listAnItemClicked:(id)sender {
  if (self.state == kEquipBuyingState) {
    self.state = kEquipSellingState;
  }
  
  [self refresh];
  
  [Analytics clickedListAnItem];
}

- (IBAction)doneClicked:(id)sender{
  if (self.listing) {
    [self disableEditing];
  } else {
    if (self.state == kEquipSellingState) {
      self.state = kEquipBuyingState;
    }
    
    [self refresh];
  }
}

- (IBAction)collectClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] redeemMarketplaceEarnings];
  
  [UIView animateWithDuration:0.5 animations:^(void) {
    CGRect tmp = self.redeemView.frame;
    tmp.origin.y = -tmp.size.height;
    self.redeemView.frame = tmp;
  } completion:^(BOOL finished) {
    if (finished) {
      self.redeemView.hidden = YES;
      self.postsTableView.userInteractionEnabled = YES;
    }
  }];
  
  [coinBar updateLabels];
}

- (IBAction)shortLicenseClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  NSString *desc = [NSString stringWithFormat:@"Would you like to buy a %d Day License for %d gold?", gl.numDaysShortMarketplaceLicenseLastsFor, gl.diamondCostOfShortMarketplaceLicense];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Buy License?" okayButton:@"Buy" cancelButton:@"Cancel" target:self selector:@selector(purchaseShortLicense)];
}

- (void) purchaseShortLicense {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold >= gl.diamondCostOfShortMarketplaceLicense) {
    [[OutgoingEventController sharedOutgoingEventController] purchaseShortMarketplaceLicense];
    [self.loadingView display:self.view];
    [Analytics boughtLicense:@"Short"];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondCostOfShortMarketplaceLicense];
    [Analytics notEnoughGoldForMarketplaceShortLicense];
  }
  
  [coinBar updateLabels];
}

- (IBAction)longLicenseClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  NSString *desc = [NSString stringWithFormat:@"Would you like to buy a %d Day License for %d gold?", gl.numDaysLongMarketplaceLicenseLastsFor, gl.diamondCostOfLongMarketplaceLicense];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Buy License?" okayButton:@"Buy" cancelButton:@"Cancel" target:self selector:@selector(purchaseLongLicense)];
}

- (void) purchaseLongLicense {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold >= gl.diamondCostOfLongMarketplaceLicense) {
    [[OutgoingEventController sharedOutgoingEventController] purchaseLongMarketplaceLicense];
    [self.loadingView display:self.view];
    [Analytics boughtLicense:@"Long"];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondCostOfLongMarketplaceLicense];
    [Analytics notEnoughGoldForMarketplaceLongLicense];
  }
  
  [coinBar updateLabels];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  
  BOOL showsLicenseRow = YES;
  
  NSArray *a = state == kEquipBuyingState ? gs.marketplaceEquipPosts : gs.marketplaceEquipPostsFromSender;
  int extra = state == kEquipSellingState ? [[[GameState sharedGameState] myEquips] count] + showsLicenseRow: 0;
  int rows = a.count+extra+1;
  if (rows > 1) {
    self.leftRope.alpha = 1.f;
    self.rightRope.alpha = 1.f;
    leftRopeFirstRow.hidden = NO;
    rightRopeFirstRow.hidden = NO;
  } else {
    leftRopeFirstRow.hidden = YES;
    rightRopeFirstRow.hidden = YES;
    if (!isDragging && !isLoading) {
      self.leftRope.alpha = 0.f;
      self.rightRope.alpha = 0.f;
    }
  }
  // Never return 1
  return rows == 1 ? 0 : rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  GameState *gs = [GameState sharedGameState];
  BOOL showsLicenseRow = self.state == kEquipSellingState;
  
  NSString *cellId;
  NSString *nibName = nil;
  if ([indexPath row] == 0) {
    cellId = @"Empty";
  } else if (self.state == kEquipSellingState && indexPath.row == 1 && showsLicenseRow) {
    cellId = @"LicenseRow";
    nibName = @"LicenseRow";
  } else {
    cellId = @"ItemPostView";
    nibName = @"ItemPostView";
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    if (nibName) {
      [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
      cell = self.itemView;
    } else {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
  }
  
  if ([cell isKindOfClass:[ItemPostView class]]) {
    NSArray *a = state == kEquipBuyingState ? gs.marketplaceEquipPosts : gs.marketplaceEquipPostsFromSender;
    if (state == kEquipSellingState && indexPath.row > (a.count+showsLicenseRow)) {
      [(ItemPostView *)cell showEquipListing:[[gs myEquips] objectAtIndex:indexPath.row-a.count-showsLicenseRow-1]];
      return cell;
    }
    FullMarketplacePostProto *p = [a objectAtIndex:indexPath.row-showsLicenseRow-1];
    
    switch (state) {
      case kEquipBuyingState:
        [(ItemPostView *)cell showEquipPost:p];
        break;
        
      case kEquipSellingState:
        [(ItemPostView *)cell showEquipPost:p];
        break;
        
      default:
        break;
    }
  } else if ([cell isKindOfClass:[LicenseRow class]]) {
    [(LicenseRow *)cell loadCurrentState];
  }
  return cell;
}

static float mktCellHeight = 0.f;
static float mktLicenseCellHeight = 0.f;

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) return tableView.rowHeight;
  
  BOOL showsLicenseRow = YES;
  if (self.state == kEquipSellingState && indexPath.row == 1 && showsLicenseRow) {
    if (mktLicenseCellHeight == 0.f) {
      UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
      mktLicenseCellHeight = cell.frame.size.height;
    }
    return mktLicenseCellHeight;
  } else if (mktCellHeight == 0.f) {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    mktCellHeight = cell.frame.size.height;
  }
  return mktCellHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.state == kEquipBuyingState) {
    ItemPostView *cell = (ItemPostView *)[tableView cellForRowAtIndexPath:indexPath];
    
    self.selectedCell = cell;
    self.removeView.hidden = YES;
    [self.purchView updateForMarketPost:cell.mktProto];
    [self.view addSubview:self.purchView];
    [Globals bounceView:self.purchView.mainView fadeInBgdView:self.purchView.bgdView];
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Load more rows when we get low enough
  if (scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.frame.size.height-REFRESH_ROWS*self.postsTableView.rowHeight) {
    if (shouldReload) {
      if (self.state == kEquipBuyingState) {
        [[OutgoingEventController sharedOutgoingEventController] retrieveMoreMarketplacePosts:filterView.searchView.searchEquipId];
      } else {
        [[OutgoingEventController sharedOutgoingEventController] retrieveMoreMarketplacePostsFromSender];
      }
      self.shouldReload = NO;
    }
  }
  
  [super scrollViewDidScroll:scrollView];
  if (!self.removeView.hidden) {
    self.refreshHeaderView.alpha = 0.f;
  }
  
  if ([self.postsTableView numberOfRowsInSection:0] == 0) {
    self.leftRope.alpha = self.refreshHeaderView.alpha;
    self.rightRope.alpha = self.refreshHeaderView.alpha;
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [super scrollViewWillBeginDragging:scrollView];
  self.removeView.hidden = YES;
  self.selectedCell = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  ItemPostView *post = (ItemPostView *)[[textField superview] superview];
  
  [self.postsTableView setContentOffset:CGPointMake(0, post.frame.origin.y-self.postsTableView.rowHeight) animated:YES];
  
  if ([textField.text isEqualToString: @"0"]) {
    textField.text = @"";
  } else {
    textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
  }
  
  self.postsTableView.scrollEnabled = NO;
  listing = YES;
  self.curField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if ([textField.text isEqualToString: @""]) {
    textField.text = @"0";
  } else {
    textField.text = [Globals commafyNumber:textField.text.intValue];
  }
  self.curField = nil;
  self.postsTableView.scrollEnabled = YES;
  
  // Close the armory popup
  [UIView animateWithDuration:0.3f animations:^{
    self.armoryPriceView.alpha = 0.f;
  }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > PRICE_DIGITS) {
    return NO;
  }
  return YES;
}

- (void) disableEditing {
  if ([self.curField isFirstResponder]) {
    [self.curField resignFirstResponder];
    self.listing = NO;
    self.curField = nil;
    
    if (self.postsTableView.contentSize.height < self.postsTableView.frame.size.height) {
      [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (self.postsTableView.contentOffset.y+self.postsTableView.frame.size.height > self.postsTableView.contentSize.height) {
      // Screen has scrolled too far down, need to move back up
      [self.postsTableView setContentOffset:CGPointMake(0, self.postsTableView.contentSize.height - self.postsTableView.frame.size.height) animated:YES];
    } else if (0 > self.postsTableView.contentOffset.y) {
      // Screen has scrolled too far up, need to move back down
      [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
  }
}

- (void) setState:(MarketplaceState)s {
  if (state != s) {
    state = s;
    switch (s) {
      case kEquipBuyingState:
        self.listAnItemButton.hidden = NO;
        self.doneButton.hidden = YES;
        self.topBarLabel.text = @"Items for Sale";
        break;
        
      case kEquipSellingState:
        self.listAnItemButton.hidden = YES;
        self.doneButton.hidden = NO;
        Globals *gl = [Globals sharedGlobals];
        self.topBarLabel.text = [NSString stringWithFormat:@"%d%% of your earnings will be taken as tax.", (int)(gl.purchasePercentCut*100)];
        break;
        
      default:
        break;
    }
    self.postsTableView.contentOffset = CGPointMake(0, 0);
    [self resetAllRows];
    self.removeView.hidden = YES;
  }
}

- (void) insertRowsFrom:(int)start {
  //  NSMutableArray *insertRows = [[NSMutableArray alloc] init];
  //  NSMutableArray *reloadRows = [[NSMutableArray alloc] init];
  //
  //  int new = [self tableView:self.postsTableView numberOfRowsInSection:0];
  //  int old = [self.postsTableView numberOfRowsInSection:0];
  //  int numRows = new - old;
  //  NSLog(@"Begin Updates: %d", numRows);
  //  [self.postsTableView beginUpdates];
  //  if (old == 0 && new > 0) {
  //    [self.postsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
  //    start = 1;
  //    numRows -= 1;
  //  }
  //  int i = start;
  //  for (; i < start+numRows && i < start+0; i++) {
  //    [insertRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  //  }
  //  for (; i < start+numRows; i++) {
  //    [reloadRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  //  }
  //
  //  if (insertRows.count > 0) {
  //    [self.postsTableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationTop];
  //  }
  //  if (reloadRows.count > 0) {
  //    [self.postsTableView insertRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
  //  }
  //  [self.postsTableView endUpdates];
  //  NSLog(@"End Updates: %d", numRows);
  //  [insertRows release];
  //  [reloadRows release];
  [self.postsTableView reloadData];
  self.shouldReload = YES;
}

- (void) deleteRows:(int)start {
  _refreshing = YES;
  //  NSMutableArray *arr = [[NSMutableArray alloc] init];
  //
  //  int new = [self tableView:self.postsTableView numberOfRowsInSection:0];
  //  int old = [self.postsTableView numberOfRowsInSection:0];
  //  int numRows = old - new;
  //
  //  if (new == 0) {
  //    start = 0;
  //  }
  //  for (int i = start; i < start+numRows; i++) {
  //    NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
  //    [arr addObject:path];
  //    UITableViewCell *cell = [self.postsTableView cellForRowAtIndexPath:path];
  //    [cell.superview sendSubviewToBack:cell];
  //  }
  //  if (arr.count > 0) {
  //    [self.postsTableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
  //  }
  //  [arr release];
  
  [self disableEditing];
  [self.postsTableView reloadData];
}

- (void) resetAllRows {
  NSMutableArray *delAnim = [[NSMutableArray alloc] init];
  NSMutableArray *delNoAnim = [[NSMutableArray alloc] init];
  NSMutableArray *insAnim = [[NSMutableArray alloc] init];
  NSMutableArray *insNoAnim = [[NSMutableArray alloc] init];
  
  int numRows = [self.postsTableView numberOfRowsInSection:0];
  NSIndexPath *ip = [self.postsTableView indexPathForRowAtPoint:postsTableView.contentOffset];
  for (int i = 0; i < numRows; i++) {
    if (i >= ip.row && i <= ip.row+5) {
      [delAnim addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    } else {
      [delNoAnim addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
  }
  numRows = [self tableView:self.postsTableView numberOfRowsInSection:0];
  for (int i = 0; i < numRows; i++) {
    if (i <= 5) {
      [insAnim addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    } else {
      [insNoAnim addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
  }
  
  [self.postsTableView beginUpdates];
  if (delAnim.count > 0) {
    [self.postsTableView deleteRowsAtIndexPaths:delAnim withRowAnimation:UITableViewRowAnimationTop];
    [self.postsTableView deleteRowsAtIndexPaths:delNoAnim withRowAnimation:UITableViewRowAnimationNone];
  }
  if (insAnim.count > 0) {
    [self.postsTableView insertRowsAtIndexPaths:insAnim withRowAnimation:UITableViewRowAnimationTop];
    [self.postsTableView insertRowsAtIndexPaths:insNoAnim withRowAnimation:UITableViewRowAnimationNone];
  }
  [self.postsTableView endUpdates];
  [delAnim release];
  [delNoAnim release];
  [insAnim release];
  [insNoAnim release];
}

- (void) doneRefreshing {
  _refreshing = NO;
}

- (void) refresh {
  if (self.state == kEquipBuyingState) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePosts: filterView.searchView.searchEquipId];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePostsFromSender];
  }
  [self displayLoading];
//  [self.postsTableView reloadData];
  self.shouldReload = NO;
  _refreshing = YES;
}

- (MarketplaceFilterView *) filterView {
  if (!filterView) {
    Globals *gl = [Globals sharedGlobals];
    NSBundle *bundle = [Globals bundleNamed:gl.downloadableNibConstants.filtersNibName];
    [bundle loadNibNamed:@"MarketplaceFilterView" owner:self options:nil];
  }
  return filterView;
}

#define DRAG_VIEW_TAG 103

- (IBAction) openFilterPage:(id)sender {
  if (!self.filterView.superview) {
    [self.filterView loadFilterSettings];
    [self.view insertSubview:self.filterView atIndex:0];
    
    CGRect r = self.filterView.frame;
    r.origin.y = 0;
    self.filterView.frame = r;
    
    [UIView animateWithDuration:0.3f animations:^{
      self.mainView.center = ccpAdd(self.mainView.center, ccp(self.filterView.frame.size.width, 0));
    }];
    
    MarketplaceDragView *dragView = [[MarketplaceDragView alloc] initWithFrame:self.mainView.bounds];
    [self.mainView addSubview:dragView];
    dragView.tag = DRAG_VIEW_TAG;
    [dragView release];
    
    _swipeGestureRecognizer.enabled = NO;
  }
}

- (IBAction) closeFilterPage:(id)sender {
  [self.filterView saveFilterSettings];
  [self closeFilterPage];
  [self refresh];
}

- (void) closeFilterPage {
  if (self.filterView.superview) {
    [filterView endEditing:YES];
    
    __block CGRect r = self.mainView.frame;
    float dist = r.origin.x;
    r.origin.x = 0;
    [UIView animateWithDuration:dist/1000.f animations:^{
      self.mainView.frame = r;
      
      r = self.filterView.frame;
      r.origin.y = 0;
      self.filterView.frame = r;
    } completion:^(BOOL finished) {
      [self.filterView removeFromSuperview];
      [[self.mainView viewWithTag:DRAG_VIEW_TAG] removeFromSuperview];
    }];
    
    _swipeGestureRecognizer.enabled = YES;
  }
}

- (void) receivedPurchaseMktLicenseResponse:(PurchaseMarketplaceLicenseResponseProto *)p {
  [self.loadingView stop];
  [self.postsTableView reloadData];
  [self.coinBar updateLabels];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if ([self isViewLoaded] && !self.view.superview) {
    self.view = nil;
    self.navBar = nil;
    self.topBar = nil;
    self.itemView = nil;
    self.postsTableView = nil;
    self.selectedCell = nil;
    self.removeView = nil;
    self.curField = nil;
    self.coinBar = nil;
    self.removePriceLabel = nil;
    self.retractPriceIcon = nil;
    self.doneButton = nil;
    self.listAnItemButton = nil;
    self.redeemView = nil;
    self.redeemGoldLabel = nil;
    self.redeemSilverLabel = nil;
    self.redeemTitleLabel = nil;
    self.ropeView = nil;
    self.leftRope = nil;
    self.rightRope = nil;
    self.leftRopeFirstRow = nil;
    self.rightRopeFirstRow = nil;
    self.loadingView = nil;
    self.purchView = nil;
    self.bottomBar = nil;
    self.filterView = nil;
    self.mainView = nil;
    self.removeDescriptionLabel = nil;
    self.removePriceLabel = nil;
    self.retractPriceIcon = nil;
    [_swipeGestureRecognizer release];
  }
}

#pragma mark FILTERMETHODS

- (NSMutableArray *) arrayForCurrentState {
  if (state == kEquipBuyingState) {
    return [[GameState sharedGameState] marketplaceEquipPosts];
  } else if (state == kEquipSellingState) {
    return [[GameState sharedGameState] marketplaceEquipPostsFromSender];
  }
  return nil;
}

@end