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

#define PRICE_DIGITS 7
#define REFRESH_ROWS 20

@implementation ItemPostView

@synthesize postTitle;
@synthesize itemImageView;
@synthesize statsView;
@synthesize priceView;
@synthesize submitView;
@synthesize itemView;
@synthesize listButton;
@synthesize removeButton;
@synthesize goldField, silverField, woodField;
@synthesize goldLabel, silverLabel, woodLabel;
@synthesize attStatLabel, defStatLabel;
@synthesize state = _state;
@synthesize mktProto, equip;

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.submitView.frame = self.itemView.frame;
  [self addSubview:self.submitView];
  
  [self setState:kSellingEquipState];
  
  [Globals adjustFontSizeForUIViewsWithDefaultSize:self.goldField, self.silverField, self.woodField, self.goldLabel, self.silverLabel, self.woodLabel, self.attStatLabel, self.defStatLabel, self.postTitle, nil];
}

- (void) setState:(MarketCellState)state {
  if (_state != state) {
    _state = state;
    switch (state) {
      case kListState:
        itemView.hidden = NO;
        submitView.hidden = YES;
        priceView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = NO;
        removeButton.hidden = YES;
        break;
        
      case kSellingCurrencyState:
        itemView.hidden = NO;
        submitView.hidden = YES;
        priceView.hidden = NO;
        statsView.hidden = YES;
        listButton.hidden = YES;
        removeButton.hidden = YES;
        break;
        
      case kSellingEquipState:
        itemView.hidden = NO;
        submitView.hidden = YES;
        priceView.hidden = NO;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = YES;
        break;
        
      case kMySellingEquipState:
        itemView.hidden = NO;
        submitView.hidden = YES;
        priceView.hidden = NO;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = NO;
        break;
        
      case kMySellingCurrencyState:
        itemView.hidden = NO;
        submitView.hidden = YES;
        priceView.hidden = NO;
        statsView.hidden = YES;
        listButton.hidden = YES;
        removeButton.hidden = NO;
        break;
        
      case kSubmitState:
        itemView.hidden = YES;
        submitView.hidden = NO;
        goldField.text = @"0";
        silverField.text = @"0";
        woodField.text = @"0";
        break;
        
      default:
        break;
    }
  }
}

- (void) showEquipPost: (FullMarketplacePostProto *)proto {
  if ([proto posterId] == [[GameState sharedGameState] userId]) {
    self.state = kMySellingEquipState;
  } else {
    self.state = kSellingEquipState;
  }
  self.goldLabel.text = [self truncateInt:[proto diamondCost]];
  self.silverLabel.text = [self truncateInt:[proto coinCost]];
  self.attStatLabel.text = [NSString stringWithFormat:@"%d", proto.postedEquip.attackBoost];
  self.defStatLabel.text = [NSString stringWithFormat:@"%d", proto.postedEquip.defenseBoost];
  self.postTitle.text = proto.postedEquip.name;
  self.mktProto = proto;
  self.equip = nil;
}

- (void) showEquipListing:(UserEquip *)eq {
  self.state = kListState;
  
  FullEquipProto *fullEq = [[GameState sharedGameState] equipWithId:eq.equipId];
  self.postTitle.text = fullEq.name;
  self.mktProto = nil;
  self.equip = eq;
  self.attStatLabel.text = [NSString stringWithFormat:@"%d", fullEq.attackBoost];
  self.defStatLabel.text = [NSString stringWithFormat:@"%d", fullEq.defenseBoost];
}

- (NSString *) truncateInt:(int)num {
  NSString *s = [NSString stringWithFormat:@"%d", num];
  
  if (s.length > 3) {
    NSString *t = [s substringToIndex:3];
    NSString *end;
    
    if ([t characterAtIndex:2] == '0') {
      t = [t substringToIndex:2];
      if ([t characterAtIndex:1] == '0') {
        t = [t substringToIndex:1];
      }
    }
    NSMutableString *sig = [NSMutableString stringWithString:t];
    
    // Get end character
    if (s.length > 6) {
      end = @"M";
    } else {
      end = @"K";
    }
    
    if (s.length % 3 == 1 && sig.length > 1) {
      [sig insertString:@"." atIndex:1];
    } else if (s.length % 3 == 2 && sig.length > 2) {
      [sig insertString:@"." atIndex:2];
    }
    
    [sig appendString:end];
    
    s = sig;
  }
  return s;
}

- (void) dealloc {
  self.mktProto = nil;
  self.equip = nil;
  [super dealloc];
}

@end

@implementation MarketplaceViewController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(MarketplaceViewController);
@synthesize navBar, topBar;
@synthesize axeButton, coinButton;
@synthesize itemView;
@synthesize postsTableView;
@synthesize buyButtonView;
@synthesize selectedCell;
@synthesize removeView;
@synthesize listing;
@synthesize curField;
@synthesize shouldReload;
@synthesize state;
@synthesize removeGoldLabel, removeWoodLabel, removeSilverLabel;
@synthesize doneButton, listAnItemButton;
@synthesize redeemView;
@synthesize redeemGoldLabel, redeemWoodLabel, redeemSilverLabel;
@synthesize redeemTitleLabel, redeemCollectLabel, redeemYouHaveLabel;
@synthesize ropeView, leftRope, rightRope, leftRopeFirstRow, rightRopeFirstRow;

- (void) viewDidLoad {
  [super viewDidLoad];
  
  UITableView *t= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  t.separatorStyle = UITableViewCellSeparatorStyleNone;
  t.delegate = self;
  t.dataSource = self;
  t.backgroundColor = [UIColor clearColor];
  t.frame = CGRectMake(0, topBar.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-topBar.frame.origin.y);
  t.scrollIndicatorInsets = UIEdgeInsetsMake(10, 0, 0, 0);
  t.rowHeight = 55;
  self.postsTableView = t;
  [t release];
  [self.view insertSubview:t belowSubview:topBar];
  [self.view insertSubview:self.redeemView aboveSubview:self.topBar];
  
  [super addPullToRefreshHeader:self.postsTableView];
  [self.postsTableView addSubview:self.ropeView];
  
  [self.postsTableView addSubview:self.buyButtonView];
  self.buyButtonView.hidden = YES;
  
  [self.postsTableView addSubview:self.removeView];
  self.buyButtonView.hidden = YES;
  
  UIColor *c = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marketrope.png"]];
  self.leftRope.backgroundColor = c;
  self.rightRope.backgroundColor = c;
  leftRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(15, 30, 3, 34)];
  rightRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(463, 30, 3, 34)];
  leftRopeFirstRow.backgroundColor = c;
  rightRopeFirstRow.backgroundColor = c;
  [self.postsTableView insertSubview:leftRopeFirstRow belowSubview:self.ropeView];
  [self.postsTableView insertSubview:rightRopeFirstRow belowSubview:self.ropeView];
  
  [Globals adjustFontSizeForUIViewsWithDefaultSize:self.removeGoldLabel, self.removeSilverLabel, self.removeWoodLabel, self.redeemGoldLabel, self.redeemSilverLabel, self.redeemWoodLabel, self.redeemCollectLabel, self.redeemYouHaveLabel, nil];
  [Globals adjustFontSizeForSize:self.redeemTitleLabel.font.pointSize withUIView:self.redeemTitleLabel];
  [Globals adjustFontSizeForSize:self.refreshLabel.font.pointSize withUIView:self.refreshLabel];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPosts];
  self.postsTableView.scrollEnabled = YES;
  
  [self setState:kEquipBuyingState];
  
  self.buyButtonView.hidden = YES;
  self.removeView.hidden = YES;
  self.postsTableView.contentOffset = CGPointZero;
  [self displayRedeemView];
}

- (void) displayRedeemView {
  GameState *gs = [GameState sharedGameState];
  if (gs.marketplaceGoldEarnings || gs.marketplaceSilverEarnings) {
    self.redeemView.frame = CGRectMake(0, -self.redeemView.frame.size.height, self.redeemView.frame.size.width, self.redeemView.frame.size.height);
    
    self.postsTableView.userInteractionEnabled = NO;
    self.redeemView.hidden = NO;
    self.redeemGoldLabel.text = [self truncateInt:gs.marketplaceGoldEarnings];
    self.redeemSilverLabel.text = [self truncateInt:gs.marketplaceSilverEarnings];
    
    CGRect tmp = self.redeemView.frame;
    tmp.origin.y = CGRectGetMaxY(self.navBar.frame)-13;
    [UIView animateWithDuration:0.5 animations:^(void) {self.redeemView.frame = tmp;}];
  }
}

- (IBAction)backClicked:(id)sender {
  [MarketplaceViewController removeView];
}

- (IBAction)listButtonClicked:(id)sender {
  // Need to do 2 superviews: first one gives UITableViewCellContentView, second one gives ItemPostView
  ItemPostView *post = (ItemPostView *)[[[(UIButton *)sender superview] superview] superview];
  post.state = kSubmitState;
  
  if (self.selectedCell != post && self.selectedCell.state == kSubmitState) {
    self.selectedCell.state = kListState;
  }
  self.selectedCell = post;
  
  self.removeView.hidden = YES;
  self.buyButtonView.hidden = YES;
  
  [post.silverField becomeFirstResponder];
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
    int wood = [self untruncateString:post.woodField.text];
    int silver = [self untruncateString:post.silverField.text];
    int gold = [self untruncateString:post.goldField.text];
    [[OutgoingEventController sharedOutgoingEventController] equipPostToMarketplace:post.equip.equipId wood:wood silver:silver gold:gold];
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
    self.buyButtonView.hidden = YES;
    
    FullMarketplacePostProto *mkt = post.mktProto;
    Globals *gl = [Globals sharedGlobals];
    self.removeGoldLabel.text = [post truncateInt:(int)ceilf(mkt.diamondCost * gl.retractPercentCut)];
    self.removeSilverLabel.text = [post truncateInt:(int)ceilf(mkt.coinCost * gl.retractPercentCut)];
    
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
  [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPostsFromSender];
  
  if (self.state == kEquipBuyingState) {
    self.state = kEquipSellingState;
  } else if (self.state == kCurrencyBuyingState) {
    self.state = kCurrencySellingState;
  }
}

- (IBAction)doneClicked:(id)sender{
  if (self.listing) {
    [self disableEditing];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPosts];
    
    if (self.state == kEquipSellingState) {
      self.state = kEquipBuyingState;
    } else if (self.state == kCurrencySellingState) {
      self.state = kCurrencyBuyingState;
    }
  }
}

- (IBAction)buyClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] purchaseFromMarketplace:self.selectedCell.mktProto.marketplacePostId];
  self.buyButtonView.hidden = YES;
  self.selectedCell = nil;
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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *a = [self postsForState];
  int extra = state == kEquipSellingState ? [[[GameState sharedGameState] myEquips] count] : 0;
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
  NSString *cellId;
  NSString *nibName = nil;
  if ([indexPath row] == 0) {
    cellId = @"Empty";
  } else {
    cellId = @"Cell";
    nibName = @"ItemPostView";
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    if (nibName) {
      [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
      cell = self.itemView;
    } else {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
  }
  
  if ([cell isKindOfClass:[ItemPostView class]]) {
    NSArray *a = [self postsForState];
    if (state == kEquipSellingState && indexPath.row > a.count) {
      [(ItemPostView *)cell showEquipListing:[[[GameState sharedGameState] myEquips] objectAtIndex:indexPath.row-a.count-1]];
      return cell;
    }
    
    FullMarketplacePostProto *p = [a objectAtIndex:indexPath.row-1];
    switch (state) {
      case kEquipBuyingState:
      case kEquipSellingState:
        [(ItemPostView *)cell showEquipPost:p];
        break;
        
      case kCurrencyBuyingState:
      case kCurrencySellingState:
        [(ItemPostView *)cell showCurrencyPost:p];
        break;
        
      default:
        break;
    }
  }
  return cell;
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (!listing) {
    UITableViewCell *cell = [t cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ItemPostView class]] && (((ItemPostView *)cell).state == kSellingEquipState || ((ItemPostView *)cell).state == kSellingCurrencyState)) {
      if (self.selectedCell != cell && self.selectedCell.state == kSubmitState) {
        self.selectedCell.state = kListState;
      }
      self.selectedCell = (ItemPostView *)cell;
      CGRect tmp = self.buyButtonView.frame;
      tmp.origin = CGPointMake(cell.frame.origin.x+324, cell.frame.origin.y+36);
      self.buyButtonView.frame = tmp;
      self.buyButtonView.hidden = NO;
      self.removeView.hidden = YES;
      
      float y = -1;
      if (!CGRectContainsRect(self.postsTableView.bounds, self.buyButtonView.frame)) {
        // Button is at the bottom of the screen
        y = CGRectGetMaxY(self.buyButtonView.frame) - self.postsTableView.frame.size.height+5;
      } else if (self.postsTableView.contentOffset.y+self.topBar.frame.size.height > t.rowHeight*indexPath.row) {
        // Button is too far up
        y = cell.frame.origin.y-self.topBar.frame.size.height;
      } else if (self.postsTableView.contentSize.height < self.postsTableView.frame.size.height) {
        [self.postsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
      } else if (self.postsTableView.contentOffset.y+self.postsTableView.frame.size.height > self.postsTableView.contentSize.height && [t numberOfRowsInSection:0]-1 != indexPath.row) {
        // Screen has scrolled too far down, need to move back up
        y = self.postsTableView.contentSize.height - self.postsTableView.frame.size.height;
      } else if (0 > self.postsTableView.contentOffset.y) {
        // Screen has scrolled too far up, need to move back down
        y = 0;
      }
      
      if (y != -1) {
        [self.postsTableView setContentOffset:CGPointMake(0, y) animated:YES];
      }
    }
  } else {
    [self disableEditing];
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Refresh table when we get low enough
  if (scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.frame.size.height-REFRESH_ROWS*self.postsTableView.rowHeight) {
    if (shouldReload) {
      if (self.state == kCurrencyBuyingState || self.state == kEquipBuyingState) {
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
  self.buyButtonView.hidden = YES;
  self.removeView.hidden = YES;
  self.selectedCell = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  ItemPostView *post = (ItemPostView *)[[textField superview] superview];
  
  [self.postsTableView setContentOffset:CGPointMake(0, post.frame.origin.y-self.postsTableView.rowHeight) animated:YES];
  
  if ([textField.text isEqualToString: @"0"]) {
    textField.text = @"";
  } else {
    textField.text = [NSString stringWithFormat:@"%d", [self untruncateString:textField.text]];
  }
  
  self.postsTableView.scrollEnabled = NO;
  listing = YES;
  self.curField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if ([textField.text isEqualToString: @""]) {
    textField.text = @"0";
  } else {
    textField.text = [self truncateString:textField.text];
  }
  self.curField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  //  NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
  //  NSString *t = [s stringByReplacingOccurrencesOfString:@"," withString:@""];
  //  NSString *u = [t length] > PRICE_DIGITS ? [t substringToIndex:PRICE_DIGITS] : t;
  //  NSNumber *n = [NSNumber numberWithInt:[u intValue]];
  //  textField.text = [NSNumberFormatter localizedStringFromNumber:n numberStyle:NSNumberFormatterDecimalStyle];
  
  if ([[textField.text stringByReplacingCharactersInRange:range withString:string] length] > PRICE_DIGITS) {
    return NO;
  }
  return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.listing) {
    [self disableEditing];
  } else if ([self.topBar pointInside:[[touches anyObject] locationInView:self.topBar] withEvent:event]) {
    [self.postsTableView setContentOffset: CGPointZero animated:YES];
    self.removeView.hidden = YES;
    self.buyButtonView.hidden = YES;
  }
  
  if ((self.state != kEquipSellingState || self.state != kEquipBuyingState) && [self.axeButton pointInside:[[touches anyObject] locationInView:self.axeButton] withEvent:event]) {
    [self setState:kEquipBuyingState];
  }
  
  if ((self.state != kCurrencySellingState || self.state != kCurrencyBuyingState) && [self.coinButton pointInside:[[touches anyObject] locationInView:self.coinButton] withEvent:event]) {
    [self setState:kCurrencyBuyingState];
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
        self.axeButton.highlighted = YES;
        self.coinButton.highlighted = NO;
        self.listAnItemButton.hidden = NO;
        self.doneButton.hidden = YES;
        break;
        
      case kEquipSellingState:
        self.axeButton.highlighted = YES;
        self.coinButton.highlighted = NO;
        self.listAnItemButton.hidden = YES;
        self.doneButton.hidden = NO;
        break;
        
      case kCurrencyBuyingState:
        self.axeButton.highlighted = NO;
        self.coinButton.highlighted = YES;
        self.listAnItemButton.hidden = NO;
        self.doneButton.hidden = YES;
        break;
        
      case kCurrencySellingState:
        self.axeButton.highlighted = NO;
        self.coinButton.highlighted = YES;
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
    self.buyButtonView.hidden = YES;
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
}

- (void) deleteRows:(int)start {
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
}

- (NSMutableArray *) postsForState {
  if (state == kEquipBuyingState) {
    return [[GameState sharedGameState] marketplaceEquipPosts];
  } else if (state == kCurrencyBuyingState) {
    return [[GameState sharedGameState] marketplaceCurrencyPosts];
  } else if (state == kEquipSellingState) {
    return [[GameState sharedGameState] marketplaceEquipPostsFromSender];
  } else if (state == kCurrencySellingState) {
    return [[GameState sharedGameState] marketplaceCurrencyPostsFromSender];
  }
  return nil;
}

- (void) refresh {
  if (self.state == kEquipBuyingState || self.state == kCurrencyBuyingState) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPosts];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentPostsFromSender];
  }
  [self.postsTableView reloadData];
  self.shouldReload = YES;
}

- (NSString *) truncateString:(NSString *)num {
  if (num.length > 3) {
    NSMutableString *sig = [NSMutableString stringWithString:[num substringToIndex:3]];
    NSString *end;
    
    // Get end character
    if (num.length > 6) {
      end = @"M";
    } else {
      end = @"K";
    }
    
    if (num.length % 3 == 1) {
      [sig insertString:@"." atIndex:1];
    } else if (num.length % 3 == 2) {
      [sig insertString:@"." atIndex:2];
    }
    
    [sig appendString:end];
    
    num = sig;
  }
  return num;
}

- (int) untruncateString:(NSString *)trunc {
  char x = [trunc characterAtIndex:[trunc length]-1];
  int mult = 1;
  int charAtEnd = 0;
  if (x == 'K') {
    mult = 1000;
    charAtEnd = 1;
  } else if (x == 'M') {
    mult = 1000000;
    charAtEnd = 1;
  } 
  
  float y = [[trunc substringToIndex:[trunc length]-charAtEnd] floatValue];
  return (int)(mult*y);
  //[NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:(int)(mult*y)] numberStyle:NSNumberFormatterDecimalStyle];
}

- (NSString *) truncateInt:(int)num {
  NSString *s = [NSString stringWithFormat:@"%d", num];
  
  if (s.length > 3) {
    NSString *t = [s substringToIndex:3];
    NSString *end;
    
    if ([t characterAtIndex:2] == '0') {
      t = [t substringToIndex:2];
      if ([t characterAtIndex:1] == '0') {
        t = [t substringToIndex:1];
      }
    }
    NSMutableString *sig = [NSMutableString stringWithString:t];
    
    // Get end character
    if (s.length > 6) {
      end = @"M";
    } else {
      end = @"K";
    }
    
    if (s.length % 3 == 1 && sig.length > 1) {
      [sig insertString:@"." atIndex:1];
    } else if (s.length % 3 == 2 && sig.length > 2) {
      [sig insertString:@"." atIndex:2];
    }
    
    [sig appendString:end];
    
    s = sig;
  }
  return s;
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