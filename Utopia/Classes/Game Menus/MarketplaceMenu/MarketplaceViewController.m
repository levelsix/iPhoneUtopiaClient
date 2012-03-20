//
//  MarketplaceViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MarketplaceViewController.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "NibUtils.h"
#import "RefillMenuController.h"

#define PRICE_DIGITS 7
#define REFRESH_ROWS 20

@implementation ItemPostView

@synthesize postTitle;
@synthesize itemImageView;
@synthesize statsView;
@synthesize submitView, submitPriceIcon;
@synthesize submitButton;
@synthesize buyButton;
@synthesize listButton;
@synthesize removeButton;
@synthesize priceField;
@synthesize priceLabel, priceIcon;
@synthesize attStatLabel, defStatLabel;
@synthesize state = _state;
@synthesize mktProto, equip;

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.buyButton.frame = self.listButton.frame;
  self.removeButton.frame = self.listButton.frame;
  self.submitButton.frame = self.listButton.frame;
  [self addSubview:buyButton];
  [self addSubview:removeButton];
  [self addSubview:submitButton];
  
  self.submitView.frame = self.statsView.frame;
  [self addSubview:submitView];
  
  [self setState:kSellingState];
}

- (void) setState:(MarketCellState)state {
  if (_state != state) {
    _state = state;
    switch (state) {
      case kListState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = NO;
        removeButton.hidden = YES;
        buyButton.hidden = YES;
        submitButton.hidden = YES;
        priceIcon.hidden = YES;
        priceLabel.hidden = YES;
        break;
        
      case kSellingState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = YES;
        buyButton.hidden = NO;
        submitButton.hidden = YES;
        priceIcon.hidden = NO;
        priceLabel.hidden = NO;
        break;
        
      case kMySellingState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = NO;
        buyButton.hidden = YES;
        submitButton.hidden = YES;
        priceIcon.hidden = NO;
        priceLabel.hidden = NO;
        break;
        
      case kSubmitState:
        statsView.hidden = YES;
        submitView.hidden = NO;
        priceField.text = @"0";
        listButton.hidden = YES;
        removeButton.hidden = YES;
        buyButton.hidden = YES;
        submitButton.hidden = NO;
        
        self.priceField.label.textColor = [UIColor whiteColor];
        break;
        
      default:
        break;
    }
  }
}

- (void) showEquipPost: (FullMarketplacePostProto *)proto {
  if ([proto posterId] == [[GameState sharedGameState] userId]) {
    self.state = kMySellingState;
  } else {
    self.state = kSellingState;
  }
  if (proto.coinCost) {
    self.priceIcon.highlighted = NO;
    self.priceLabel.text = [Globals commafyNumber:proto.coinCost];
  } else {
    self.priceIcon.highlighted = YES;
    self.priceLabel.text = [Globals commafyNumber:proto.diamondCost];
  }
  self.attStatLabel.text = [NSString stringWithFormat:@"%d", proto.postedEquip.attackBoost];
  self.defStatLabel.text = [NSString stringWithFormat:@"%d", proto.postedEquip.defenseBoost];
  self.postTitle.text = proto.postedEquip.name;
  self.postTitle.textColor = [Globals colorForRarity:proto.postedEquip.rarity];
  self.itemImageView.image = [Globals imageForEquip:proto.postedEquip.equipId];
  self.mktProto = proto;
  self.equip = nil;
}

- (void) showEquipListing:(UserEquip *)eq {
  self.state = kListState;
  
  FullEquipProto *fullEq = [[GameState sharedGameState] equipWithId:eq.equipId];
  self.postTitle.text = fullEq.name;
  self.postTitle.textColor = [Globals colorForRarity:fullEq.rarity];
  self.itemImageView.image = [Globals imageForEquip:fullEq.equipId];
  self.mktProto = nil;
  self.equip = eq;
  self.attStatLabel.text = [NSString stringWithFormat:@"%d", fullEq.attackBoost];
  self.defStatLabel.text = [NSString stringWithFormat:@"%d", fullEq.defenseBoost];
}

- (void) dealloc {
  self.mktProto = nil;
  self.equip = nil;
  self.postTitle = nil;
  self.itemImageView = nil;
  self.statsView = nil;
  self.submitView = nil;
  self.listButton = nil;
  self.removeButton = nil;
  self.priceField = nil;
  self.priceLabel = nil;
  self.priceIcon = nil;
  self.attStatLabel = nil;
  self.defStatLabel = nil;
  [super dealloc];
}

@end

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
@synthesize removePriceLabel;
@synthesize doneButton, listAnItemButton;
@synthesize redeemView, purchLicenseView;
@synthesize redeemGoldLabel, redeemSilverLabel;
@synthesize redeemTitleLabel;
@synthesize ropeView, leftRope, rightRope, leftRopeFirstRow, rightRopeFirstRow;
@synthesize shortLicenseCost, shortLicenseLength, longLicenseCost, longLicenseLength;

- (void) viewDidLoad {
  [super viewDidLoad];
  
  UITableView *t= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  t.separatorStyle = UITableViewCellSeparatorStyleNone;
  t.delegate = self;
  t.dataSource = self;
  t.backgroundColor = [UIColor clearColor];
  t.frame = CGRectMake(0, topBar.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-topBar.frame.origin.y);
  t.showsVerticalScrollIndicator = NO;
  t.rowHeight = 55;
  self.postsTableView = t;
  [t release];
  [self.view insertSubview:t belowSubview:topBar];
  [self.view insertSubview:self.redeemView aboveSubview:self.topBar];
  
  [super addPullToRefreshHeader:self.postsTableView];
  [self.postsTableView addSubview:self.ropeView];
  
  [self.postsTableView addSubview:self.removeView];
  
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"marketrope.png"]];
  leftRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(15, 30, 3, 90)];
  rightRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(463, 30, 3, 90)];
  leftRopeFirstRow.backgroundColor = c;
  rightRopeFirstRow.backgroundColor = c;
  [self.postsTableView insertSubview:leftRopeFirstRow belowSubview:self.ropeView];
  [self.postsTableView insertSubview:rightRopeFirstRow belowSubview:self.ropeView];
  
  self.redeemView.hidden = YES;
  
  Globals *gl = [Globals sharedGlobals];
  shortLicenseCost.text = [NSString stringWithFormat:@"%d", gl.diamondCostOfShortMarketplaceLicense];
  longLicenseCost.text = [NSString stringWithFormat:@"%d", gl.diamondCostOfLongMarketplaceLicense];
  shortLicenseLength.text = [NSString stringWithFormat:@"%d days", gl.numDaysShortMarketplaceLicenseLastsFor];
  longLicenseLength.text = [NSString stringWithFormat:@"%d days", gl.numDaysLongMarketplaceLicenseLastsFor];
  
  self.purchLicenseView.center = self.view.center;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPosts];
  self.postsTableView.scrollEnabled = YES;
  
  [self setState:kEquipBuyingState];
  
  self.removeView.hidden = YES;
  self.postsTableView.contentOffset = CGPointZero;
  
  self.view.alpha = 0.f;
  [UIView animateWithDuration:1.f animations:^{
    self.view.alpha = 1.f;
  } completion:^(BOOL finished) {
    [self displayRedeemView];
  }];
}

- (void) displayRedeemView {
  GameState *gs = [GameState sharedGameState];
  if (gs.marketplaceGoldEarnings || gs.marketplaceSilverEarnings) {
    self.redeemView.frame = CGRectMake(0, -self.redeemView.frame.size.height, self.redeemView.frame.size.width, self.redeemView.frame.size.height);
    
    self.postsTableView.userInteractionEnabled = NO;
    self.redeemView.hidden = NO;
    self.redeemGoldLabel.text = [Globals commafyNumber:gs.marketplaceGoldEarnings];
    self.redeemSilverLabel.text = [Globals commafyNumber:gs.marketplaceSilverEarnings];
    
    CGRect tmp = self.redeemView.frame;
    tmp.origin.y = CGRectGetMaxY(self.navBar.frame)-13;
    [UIView animateWithDuration:0.5 animations:^(void) {self.redeemView.frame = tmp;}];
  }
}

- (IBAction)backClicked:(id)sender {
  [UIView animateWithDuration:1.f animations:^{
    self.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [MarketplaceViewController removeView];
  }];
}

- (IBAction)listButtonClicked:(id)sender {
  // Need to do 2 superviews: first one gives UITableViewCellContentView, second one gives ItemPostView
  ItemPostView *post = (ItemPostView *)[[[(UIButton *)sender superview] superview] superview];
  GameState *gs = [GameState sharedGameState];
  
  if (gs.hasValidLicense) {
    post.state = kSubmitState;
    
    if (self.selectedCell != post && self.selectedCell.state == kSubmitState) {
      self.selectedCell.state = kListState;
    }
    self.selectedCell = post;
    
    self.removeView.hidden = YES;
    
    [post.priceField becomeFirstResponder];
  } else {
    [self.view addSubview:self.purchLicenseView];
    
    purchLicenseView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    purchLicenseView.hidden = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
      purchLicenseView.transform = CGAffineTransformMakeScale(1, 1);
    }];
  }
}

- (IBAction)closePurchLicenseView:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    purchLicenseView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
  } completion:^(BOOL finished) {
    [purchLicenseView removeFromSuperview];
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
  ItemPostView *post = (ItemPostView *)[[(UIButton *)sender superview] superview];
  if (post.equip) {
    [self disableEditing];
    int amount = [post.priceField.text stringByReplacingOccurrencesOfString:@"," withString:@""].intValue;
    [[OutgoingEventController sharedOutgoingEventController] equipPostToMarketplace:post.equip.equipId price:amount];
  }
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
    tmp.origin = CGPointMake(post.frame.origin.x+216, post.frame.origin.y-26);
    self.removeView.frame = tmp;
    
    self.removeView.hidden = NO;
    
    FullMarketplacePostProto *mkt = post.mktProto;
    Globals *gl = [Globals sharedGlobals];
    self.removePriceLabel.text = [Globals commafyNumber:(int)ceilf(mkt.diamondCost * gl.retractPercentCut)];
    
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
  }
}

- (IBAction)removeItemClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] retractMarketplacePost:self.selectedCell.mktProto.marketplacePostId];
  self.removeView.hidden = YES;
  self.selectedCell = nil;
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
  if (!_refreshing) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPostsFromSender];
    
    if (self.state == kEquipBuyingState) {
      self.state = kEquipSellingState;
    }
  }
}

- (IBAction)doneClicked:(id)sender{
  if (!_refreshing) {
    if (self.listing) {
      [self disableEditing];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPosts];
      
      if (self.state == kEquipSellingState) {
        self.state = kEquipBuyingState;
      }
    }
  }
}

- (IBAction)buyClicked:(id)sender {
  ItemPostView *post = (ItemPostView *)[[sender superview] superview];
  FullMarketplacePostProto *proto = post.mktProto;
  GameState *gs = [GameState sharedGameState];
  
  if (proto.coinCost > gs.silver) {
    [[RefillMenuController sharedRefillMenuController] displayBuySilverView];
  } else if (proto.diamondCost > gs.gold) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:proto.diamondCost];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] purchaseFromMarketplace:proto.marketplacePostId];
    self.selectedCell = nil;
  }
}

- (IBAction)collectClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] redeemMarketplaceEarnings];
  CGRect tmp = self.removeView.frame;
  tmp.origin.y -= tmp.size.height;
  [UIView animateWithDuration:0.5 animations:^(void) {self.redeemView.frame = tmp;} completion:^(BOOL finished) {
    self.redeemView.hidden = YES;
    self.postsTableView.userInteractionEnabled = YES;
  }];
}

- (IBAction)shortLicenseClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold >= gl.diamondCostOfShortMarketplaceLicense) {
    [[OutgoingEventController sharedOutgoingEventController] purchaseShortMarketplaceLicense];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondCostOfShortMarketplaceLicense];
  }
  
  if (gs.hasValidLicense) {
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (IBAction)longLicenseClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold >= gl.diamondCostOfLongMarketplaceLicense) {
    [[OutgoingEventController sharedOutgoingEventController] purchaseLongMarketplaceLicense];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondCostOfLongMarketplaceLicense];
  }
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *a = [self postsForState];
  int extra = state == kEquipSellingState ? [[[GameState sharedGameState] myEquips] count] + ![[GameState sharedGameState] hasValidLicense]: 0;
  int rows = [a count]+extra+1;
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
  return rows == 1? 0:rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  GameState *gs = [GameState sharedGameState];
  BOOL displayLicense = self.state == kEquipSellingState ? ![gs hasValidLicense] : 0;
  
  NSString *cellId;
  NSString *nibName = nil;
  if ([indexPath row] == 0) {
    cellId = @"Empty";
  } else if (self.state == kEquipSellingState && indexPath.row == 1 && displayLicense) {
    cellId = @"License";
    nibName = @"LicenseRow";
  } else {
    cellId = @"Cell";
    nibName = @"ItemPostView";
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    if (nibName) {
      [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
      cell = self.itemView;
      if ([nibName isEqualToString:@"LicenseRow"]) {
        Globals *gl = [Globals sharedGlobals];
        shortLicenseCost.text = [NSString stringWithFormat:@"%d", gl.diamondCostOfShortMarketplaceLicense];
        longLicenseCost.text = [NSString stringWithFormat:@"%d", gl.diamondCostOfLongMarketplaceLicense];
        shortLicenseLength.text = [NSString stringWithFormat:@"%d days", gl.numDaysShortMarketplaceLicenseLastsFor];
        longLicenseLength.text = [NSString stringWithFormat:@"%d days", gl.numDaysLongMarketplaceLicenseLastsFor];
      }
    } else {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
  }
  
  if ([cell isKindOfClass:[ItemPostView class]]) {
    NSArray *a = [self postsForState];
    if (state == kEquipSellingState && indexPath.row > (a.count+displayLicense)) {
      [(ItemPostView *)cell showEquipListing:[[gs myEquips] objectAtIndex:indexPath.row-a.count-displayLicense-1]];
      return cell;
    }
    
    FullMarketplacePostProto *p = [a objectAtIndex:indexPath.row-displayLicense-1];
    switch (state) {
      case kEquipBuyingState:
      case kEquipSellingState:
        [(ItemPostView *)cell showEquipPost:p];
        break;
        
      default:
        break;
    }
  }
  return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Refresh table when we get low enough
  if (scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.frame.size.height-REFRESH_ROWS*self.postsTableView.rowHeight) {
    if (shouldReload) {
      if (self.state == kEquipBuyingState) {
        [[OutgoingEventController sharedOutgoingEventController] retrieveMoreMarketplacePosts];
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
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > PRICE_DIGITS) {
    return NO;
  }
  [[(NiceFontTextField *)textField label] setText:str];
  return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.listing) {
    [self disableEditing];
  } else if ([self.topBar pointInside:[[touches anyObject] locationInView:self.topBar] withEvent:event]) {
    [self.postsTableView setContentOffset: CGPointZero animated:YES];
    self.removeView.hidden = YES;
  }
}

- (void) disableEditing {
  [self.curField resignFirstResponder];
  self.postsTableView.scrollEnabled = YES;
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

- (void) setState:(MarketplaceState)s {
  if (state != s) {
    state = s;
    switch (s) {
      case kEquipBuyingState:
        self.listAnItemButton.hidden = NO;
        self.doneButton.hidden = YES;
        break;
        
      case kEquipSellingState:
        self.listAnItemButton.hidden = YES;
        self.doneButton.hidden = NO;
        break;
        
      default:
        break;
    }
    [self stopLoading];
    self.postsTableView.contentOffset = CGPointMake(0, 0);
    [self resetAllRows];
    self.removeView.hidden = YES;
  }
}

- (void) insertRowsFrom:(int)start {
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  
  int new = [self tableView:self.postsTableView numberOfRowsInSection:0];
  int old = [self.postsTableView numberOfRowsInSection:0];
  int numRows = new - old;
  [self.postsTableView beginUpdates];
  if (old ==  0) {
    [self.postsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    start = 1;
    numRows -= 1;
  }
  for (int i = start; i < start+numRows; i++) {
    [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }
  
  if (arr.count > 0) {
    [self.postsTableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationTop];
  }
  [self.postsTableView endUpdates];
  [arr release];
  self.shouldReload = YES;
  _refreshing = NO;
}

- (void) deleteRows:(int)start {
  _refreshing = YES;
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  
  int new = [self tableView:self.postsTableView numberOfRowsInSection:0];
  int old = [self.postsTableView numberOfRowsInSection:0];
  int numRows = old - new;
  
  if (new == 0) {
    start = 0;
  }
  for (int i = start; i < start+numRows; i++) {
    [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }
  if (arr.count > 0) {
    [self.postsTableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationBottom];
  }
  [arr release];
}

- (void) resetAllRows {
  NSMutableArray *del = [[NSMutableArray alloc] init];
  NSMutableArray *ins = [[NSMutableArray alloc] init];
  
  int numRows = [self.postsTableView numberOfRowsInSection:0];
  for (int i = 0; i < numRows; i++) {
    [del addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }
  numRows = [self tableView:self.postsTableView numberOfRowsInSection:0];
  for (int i = 0; i < numRows; i++) {
    [ins addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }
  
  [self.postsTableView beginUpdates];
  if (del.count > 0) {
    [self.postsTableView deleteRowsAtIndexPaths:del withRowAnimation:UITableViewRowAnimationTop];
  }
  if (ins.count > 0) {
    [self.postsTableView insertRowsAtIndexPaths:ins withRowAnimation:UITableViewRowAnimationTop];
  }
  [self.postsTableView endUpdates];
  [del release];
  [ins release];
  
  _refreshing = NO;
}

- (NSMutableArray *) postsForState {
  if (state == kEquipBuyingState) {
    return [[GameState sharedGameState] marketplaceEquipPosts];
  } else if (state == kEquipSellingState) {
    return [[GameState sharedGameState] marketplaceEquipPostsFromSender];
  }
  return nil;
}

- (void) refresh {
  if (self.state == kEquipBuyingState) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPosts];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPostsFromSender];
  }
  [self.postsTableView reloadData];
  self.shouldReload = YES;
}

- (void) dealloc {
  self.selectedCell = nil;
  self.curField = nil;
  self.itemView = nil;
  self.leftRopeFirstRow = nil;
  self.rightRopeFirstRow = nil;
  [super dealloc];
}

@end

@implementation UITextField (DisableCopyPaste)

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{    
  [UIMenuController sharedMenuController].menuVisible = NO;
  return NO;
}

@end