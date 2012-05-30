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
@synthesize quantityLabel, quantityBackground;
@synthesize leatherBackground;

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
        quantityBackground.hidden = NO;
        quantityLabel.hidden = NO;
        break;
        
      case kSellingState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = YES;
        buyButton.hidden = NO;
        submitButton.hidden = YES;
        quantityBackground.hidden = YES;
        quantityLabel.hidden = YES;
        break;
        
      case kMySellingState:
        statsView.hidden = NO;
        submitView.hidden = YES;
        statsView.hidden = NO;
        listButton.hidden = YES;
        removeButton.hidden = NO;
        buyButton.hidden = YES;
        submitButton.hidden = YES;
        quantityBackground.hidden = YES;
        quantityLabel.hidden = YES;
        break;
        
      case kSubmitState:
        statsView.hidden = YES;
        submitView.hidden = NO;
        priceField.text = @"0";
        listButton.hidden = YES;
        removeButton.hidden = YES;
        buyButton.hidden = YES;
        submitButton.hidden = NO;
        quantityBackground.hidden = NO;
        quantityLabel.hidden = NO;
        
        self.priceField.label.textColor = [UIColor whiteColor];
        break;
        
      default:
        break;
    }
  }
}

- (void) showEquipPost: (FullMarketplacePostProto *)proto {
  if (proto.poster.userId == [[GameState sharedGameState] userId]) {
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
  [Globals loadImageForEquip:proto.postedEquip.equipId toView:self.itemImageView maskedView:nil];
  self.mktProto = proto;
  self.equip = nil;
  
  if ([Globals canEquip:proto.postedEquip]) {
    self.leatherBackground.highlighted = NO;
  } else {
    self.leatherBackground.highlighted = YES;
  }
}

- (void) showEquipListing:(UserEquip *)eq {
  self.state = kListState;
  
  FullEquipProto *fullEq = [[GameState sharedGameState] equipWithId:eq.equipId];
  self.postTitle.text = fullEq.name;
  self.postTitle.textColor = [Globals colorForRarity:fullEq.rarity];
  self.quantityLabel.text = [NSString stringWithFormat:@"x%d", eq.quantity];
  self.quantityLabel.textColor = [Globals colorForRarity:fullEq.rarity];
  //  self.itemImageView.image = [Globals imageForEquip:fullEq.equipId];
  [Globals loadImageForEquip:fullEq.equipId toView:self.itemImageView maskedView:nil];
  self.mktProto = nil;
  self.equip = eq;
  self.attStatLabel.text = [NSString stringWithFormat:@"%d", fullEq.attackBoost];
  self.defStatLabel.text = [NSString stringWithFormat:@"%d", fullEq.defenseBoost];
  
  if ([Globals canEquip:fullEq]) {
    self.leatherBackground.highlighted = NO;
  } else {
    self.leatherBackground.highlighted = YES;
  }
}

- (void) dealloc {
  self.postTitle = nil;
  self.itemImageView = nil;
  self.statsView = nil;
  self.submitView = nil;
  self.submitPriceIcon = nil;
  self.submitButton = nil;
  self.buyButton = nil;
  self.listButton = nil;
  self.removeButton = nil;
  self.priceField = nil;
  self.priceLabel = nil;
  self.priceIcon = nil;
  self.attStatLabel = nil;
  self.defStatLabel = nil;
  self.mktProto = nil;
  self.equip = nil;
  self.quantityLabel = nil;
  self.quantityBackground = nil;
  self.leatherBackground = nil;
  [super dealloc];
}

@end

@implementation MarketPurchaseView

@synthesize titleLabel, crossOutView, classLabel, attackLabel, defenseLabel;
@synthesize typeLabel, levelLabel, playerNameButton;
@synthesize equipIcon, wrongClassView, tooLowLevelView;
@synthesize armoryPriceIcon, armoryPriceLabel;
@synthesize postedPriceIcon, postedPriceLabel;
@synthesize savePriceIcon, savePriceLabel;
@synthesize mainView, bgdView;
@synthesize mktPost;

- (void) updateForMarketPost:(FullMarketplacePostProto *)m {
  GameState *gs = [GameState sharedGameState];
  
  self.mktPost = m;
  
  FullEquipProto *fep = mktPost.postedEquip;
  
  titleLabel.text = fep.name;
  titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  classLabel.text = [Globals stringForEquipClassType:fep.classType];
  typeLabel.text = [Globals stringForEquipType:fep.equipType];
  attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
  levelLabel.text = [NSString stringWithFormat:@"%d", fep.minLevel];
  [playerNameButton setTitle:m.poster.name forState:UIControlStateNormal];
  
  if ([Globals sellsForGoldInMarketplace:fep]) {
    armoryPriceIcon.highlighted = YES;
    postedPriceIcon.highlighted = YES;
    savePriceIcon.highlighted = YES;
    postedPriceLabel.text = [Globals commafyNumber:mktPost.diamondCost];
    
    if (fep.diamondPrice > 0) {
      crossOutView.hidden = NO;
      armoryPriceLabel.text = [Globals commafyNumber:fep.diamondPrice];
      savePriceLabel.text = [NSString stringWithFormat:@"%@ (%@%%)", 
                             [Globals commafyNumber:fep.diamondPrice-mktPost.diamondCost], 
                             [Globals commafyNumber:(int)roundf((fep.diamondPrice-mktPost.diamondCost)/((float)fep.diamondPrice)*100)]];
      
      if (mktPost.diamondCost < fep.diamondPrice) {
        postedPriceLabel.textColor = [Globals greenColor];
        savePriceLabel.textColor = [Globals greenColor];
      } else {
        postedPriceLabel.textColor = [Globals redColor];
        savePriceLabel.textColor = [Globals redColor];
      }
      
    } else {
      armoryPriceLabel.text = @"N/A";
      savePriceLabel.text = @"N/A";
      postedPriceLabel.textColor = [Globals creamColor];
      savePriceLabel.textColor = [Globals creamColor];
      crossOutView.hidden = YES;
    }
  } else {
    armoryPriceIcon.highlighted = NO;
    postedPriceIcon.highlighted = NO;
    savePriceIcon.highlighted = NO;
    postedPriceLabel.text = [Globals commafyNumber:mktPost.coinCost];
    
    if (fep.coinPrice > 0) {
      crossOutView.hidden = NO;
      armoryPriceLabel.text = [Globals commafyNumber:fep.coinPrice];
      savePriceLabel.text = [NSString stringWithFormat:@"%@ (%@%%)", 
                             [Globals commafyNumber:fep.coinPrice-mktPost.coinCost], 
                             [Globals commafyNumber:(int)roundf((fep.coinPrice-mktPost.coinCost)/((float)fep.coinPrice)*100)]];
      
      if (mktPost.coinCost < fep.coinPrice) {
        postedPriceLabel.textColor = [Globals greenColor];
        savePriceLabel.textColor = [Globals greenColor];
      } else {
        postedPriceLabel.textColor = [Globals redColor];
        savePriceLabel.textColor = [Globals redColor];
      }
    } else {
      armoryPriceLabel.text = @"N/A";
      savePriceLabel.text = @"N/A";
      postedPriceLabel.textColor = [Globals creamColor];
      savePriceLabel.textColor = [Globals creamColor];
      crossOutView.hidden = YES;
    }
  }
  
  equipIcon.equipId = fep.equipId;
  
  if ([Globals class:gs.type canEquip:fep.classType]) {
    wrongClassView.hidden = YES;
  } else {
    wrongClassView.hidden = NO;
  }
  
  if (gs.level >= fep.minLevel) {
    tooLowLevelView.hidden = YES;
  } else {
    tooLowLevelView.hidden = NO;
  }
  
  CGSize size = [armoryPriceLabel.text sizeWithFont:armoryPriceLabel.font];
  CGRect r = crossOutView.frame;
  r.size.width = size.width;
  crossOutView.frame = r;
}

- (IBAction)wrongClassClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable by %@s.", titleLabel.text, classLabel.text]];
}

- (IBAction)profileButtonClicked:(id)sender {
  [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:mktPost.poster withState:kEquipState];
}

- (IBAction)tooLowLevelClicked:(id)sender {
  [Globals popupMessage:[NSString stringWithFormat:@"The %@ is only equippable at Level %@.", titleLabel.text, levelLabel.text]];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
    [self removeFromSuperview];
  }];
}

- (IBAction)buyClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  MarketplaceViewController *mvc = [MarketplaceViewController sharedMarketplaceViewController];
  
  [Analytics attemptedPurchase];
  
  if (gs.userId == mktPost.poster.userId) {
    [Globals popupMessage:@"You can't purchase your own item!"];
  } else if (mktPost.coinCost > gs.silver) {
    [[RefillMenuController sharedRefillMenuController] displayBuySilverView];
    [Analytics notEnoughSilverForMarketplaceBuy:mktPost.postedEquip.equipId cost:mktPost.coinCost];
  } else if (mktPost.diamondCost > gs.gold) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:mktPost.diamondCost];
    [Analytics notEnoughGoldForMarketplaceBuy:mktPost.postedEquip.equipId cost:mktPost.diamondCost];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] purchaseFromMarketplace:mktPost.marketplacePostId];
    [Analytics successfulPurchase:mktPost.postedEquip.equipId];
    [mvc displayLoadingView];
  }
  
  [mvc.coinBar updateLabels];
}

- (void) dealloc {
  self.titleLabel = nil;
  self.crossOutView = nil;
  self.classLabel = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.typeLabel = nil;
  self.levelLabel = nil;
  self.playerNameButton = nil;
  self.equipIcon = nil;
  self.armoryPriceLabel = nil;
  self.armoryPriceIcon = nil;
  self.postedPriceLabel = nil;
  self.postedPriceIcon = nil;
  self.savePriceLabel = nil;
  self.savePriceIcon = nil;
  self.wrongClassView = nil;
  self.tooLowLevelView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  [super dealloc];
}

@end

@implementation MarketplaceLoadingView

@synthesize darkView, actIndView;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) dealloc {
  self.darkView = nil;
  self.actIndView = nil;
  
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
@synthesize coinBar;
@synthesize removePriceLabel, retractPriceIcon;
@synthesize doneButton, listAnItemButton;
@synthesize redeemView, purchLicenseView;
@synthesize redeemGoldLabel, redeemSilverLabel;
@synthesize redeemTitleLabel;
@synthesize ropeView, leftRope, rightRope, leftRopeFirstRow, rightRopeFirstRow;
@synthesize shortLicenseCost, shortLicenseLength, longLicenseCost, longLicenseLength;
@synthesize loadingView;
@synthesize purchView;
@synthesize licenseBgdView, licenseMainView;
@synthesize armoryPriceIcon, armoryPriceView, armoryPriceLabel, armoryPriceBottomSubview;

- (void) viewDidLoad {
  [super viewDidLoad];
  
  UITableView *t= [[CancellableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  t.separatorStyle = UITableViewCellSeparatorStyleNone;
  t.delegate = self;
  t.dataSource = self;
  t.backgroundColor = [UIColor clearColor];
  t.frame = CGRectMake(0, topBar.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-topBar.frame.origin.y);
  t.showsVerticalScrollIndicator = NO;
  t.rowHeight = 55;
  t.delaysContentTouches = NO;
  self.postsTableView = t;
  [t release];
  [self.view insertSubview:t belowSubview:topBar];
  [self.view insertSubview:self.redeemView aboveSubview:self.topBar];
  
  [super addPullToRefreshHeader:self.postsTableView];
  [self.postsTableView addSubview:self.ropeView];
  
  [self.postsTableView addSubview:self.removeView];
  
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  leftRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(15, 30, 3, 40)];
  rightRopeFirstRow = [[UIView alloc] initWithFrame:CGRectMake(463, 30, 3, 40)];
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
  
  UILabel *retractLabel = (UILabel *)[self.view viewWithTag:15];
  retractLabel.text = [NSString stringWithFormat:@"Removing items incurs a %d%% fee", (int)([[Globals sharedGlobals] retractPercentCut]*100)];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePosts];
  self.postsTableView.scrollEnabled = YES;
  
  [self setState:kEquipBuyingState];
  
  self.removeView.hidden = YES;
  [self.purchView removeFromSuperview];
  self.postsTableView.contentOffset = CGPointZero;
  
  self.redeemView.hidden = YES;
  CGRect f = self.view.frame;
  self.view.center = CGPointMake(f.size.width/2, f.size.height*3/2);
  [UIView animateWithDuration:FULL_SCREEN_APPEAR_ANIMATION_DURATION animations:^{
    self.view.center = CGPointMake(f.size.width/2, f.size.height/2);
  } completion:^(BOOL finished) {
    [self displayRedeemView];
  }];
  
  [coinBar updateLabels];
  
  [Globals playEnterBuildingSound];
  
  self.armoryPriceView.alpha = 0.f;
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

- (void) updateArmoryPopupForEquipId:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  
  if (fep.diamondPrice > 0) {
    armoryPriceIcon.highlighted = YES;
    armoryPriceLabel.text = [Globals commafyNumber:fep.diamondPrice];
  } else if (fep.coinPrice > 0) {
    armoryPriceIcon.highlighted = NO;
    armoryPriceLabel.text = [Globals commafyNumber:fep.coinPrice];
  } else {
    armoryPriceIcon.highlighted = [Globals sellsForGoldInMarketplace:fep];
    armoryPriceLabel.text = @"N/A";
  }
  
  // Center the bottom subview
  CGSize size = [armoryPriceLabel.text sizeWithFont:armoryPriceLabel.font];
  CGRect rect = armoryPriceBottomSubview.frame;
  rect.size.width = armoryPriceLabel.frame.origin.x + size.width;
  armoryPriceBottomSubview.frame = rect;
  armoryPriceBottomSubview.center = CGPointMake(armoryPriceBottomSubview.superview.frame.size.width/2, armoryPriceBottomSubview.center.y);
}

- (IBAction)backClicked:(id)sender {
  [self.purchView removeFromSuperview];
  
  CGRect f = self.view.frame;
  [UIView animateWithDuration:FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION animations:^{
    self.view.center = CGPointMake(f.size.width/2, f.size.height*3/2);
  } completion:^(BOOL finished) {
    [MarketplaceViewController removeView];
  }];
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
    [Globals popupMessage:@"You already have %d items in the marketplace. Remove a listing to post a new item."];
    return;
  }
  
  if (gs.hasValidLicense) {
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
    
    [self updateArmoryPopupForEquipId:fep.equipId];
    self.armoryPriceView.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
      self.armoryPriceView.alpha = 1.f;
    }];
  } else {
    [self.view addSubview:self.purchLicenseView];
    [Globals bounceView:self.licenseMainView fadeInBgdView:self.licenseBgdView];
    
    [Analytics licensePopup];
  }
}

- (IBAction)closePurchLicenseView:(id)sender {
  [Globals popOutView:self.licenseMainView fadeOutBgdView:self.licenseBgdView completion:^(void) {
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
    post.state = kListState;
    if (post.equip.quantity == 0) {
      [postsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[postsTableView indexPathForCell:post]] withRowAnimation:UITableViewRowAnimationTop];
    } else {
      [post showEquipListing:post.equip];
    }
    
    [Analytics successfulPost:post.equip.equipId];
  }
  [coinBar updateLabels];
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
    tmp.origin = CGPointMake(post.frame.origin.x+70, post.frame.origin.y-5);
    self.removeView.frame = tmp;
    
    self.removeView.hidden = NO;
    
    FullMarketplacePostProto *mkt = post.mktProto;
    Globals *gl = [Globals sharedGlobals];
    
    if (mkt.diamondCost > 0) {
      self.removePriceLabel.text = [Globals commafyNumber:(int)ceilf(mkt.diamondCost * gl.retractPercentCut)];
      self.retractPriceIcon.highlighted = YES;
    } else {
      self.removePriceLabel.text = [Globals commafyNumber:(int)ceilf(mkt.coinCost * gl.retractPercentCut)];
      self.retractPriceIcon.highlighted = NO;
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
  
  if (fmpp.diamondCost > 0) {
    int amount = (int) ceilf(fmpp.diamondCost*gl.retractPercentCut);
    if (gs.gold >= amount) {
      [[OutgoingEventController sharedOutgoingEventController] retractMarketplacePost:fmpp.marketplacePostId];
      [Analytics successfulRetract];
    } else {
      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:fmpp.diamondCost];
      [Analytics notEnoughGoldForMarketplaceRetract:fmpp.postedEquip.equipId cost:fmpp.diamondCost];
    }
  } else {
    int amount = (int) ceilf(fmpp.coinCost*gl.retractPercentCut);
    if (gs.silver >= amount) {
      [[OutgoingEventController sharedOutgoingEventController] retractMarketplacePost:fmpp.marketplacePostId];
      [Analytics successfulRetract];
    } else {
      [[RefillMenuController sharedRefillMenuController] displayBuySilverView];
      [Analytics notEnoughSilverForMarketplaceRetract:fmpp.postedEquip.equipId cost:fmpp.coinCost];
    }
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
  if (!_refreshing) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePostsFromSender];
    
    if (self.state == kEquipBuyingState) {
      self.state = kEquipSellingState;
    }
    [Analytics clickedListAnItem];
  }
}

- (IBAction)doneClicked:(id)sender{
  if (!_refreshing) {
    if (self.listing) {
      [self disableEditing];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePosts];
      
      if (self.state == kEquipSellingState) {
        self.state = kEquipBuyingState;
      }
    }
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
  
  [coinBar updateLabels];
}

- (IBAction)shortLicenseClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold >= gl.diamondCostOfShortMarketplaceLicense) {
    [[OutgoingEventController sharedOutgoingEventController] purchaseShortMarketplaceLicense];
    [self licensePurchaseSuccessful];
    [Analytics boughtLicense:@"Short"];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondCostOfShortMarketplaceLicense];
    [Analytics notEnoughGoldForMarketplaceShortLicense];
  }
  
  [coinBar updateLabels];
}

- (IBAction)longLicenseClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gold >= gl.diamondCostOfLongMarketplaceLicense) {
    [[OutgoingEventController sharedOutgoingEventController] purchaseLongMarketplaceLicense];
    [self licensePurchaseSuccessful];
    [Analytics boughtLicense:@"Long"];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondCostOfLongMarketplaceLicense];
    [Analytics notEnoughGoldForMarketplaceLongLicense];
  }
  
  [coinBar updateLabels];
}

- (void) licensePurchaseSuccessful {
  self.purchLicenseView.hidden = YES;
  
  GameState *gs = [GameState sharedGameState];
  if (gs.hasValidLicense) {
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.listing) {
    [self disableEditing];
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
  [self.postsTableView setContentOffset:ccp(0,0) animated:NO];
  [delAnim release];
  [delNoAnim release];
  [insAnim release];
  [insNoAnim release];
}

- (NSMutableArray *) postsForState {
  if (state == kEquipBuyingState) {
    return [[GameState sharedGameState] marketplaceEquipPosts];
  } else if (state == kEquipSellingState) {
    return [[GameState sharedGameState] marketplaceEquipPostsFromSender];
  }
  return nil;
}

- (void) doneRefreshing {
  _refreshing = NO;
}

- (void) refresh {
  if (self.state == kEquipBuyingState) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePosts];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] retrieveMostRecentMarketplacePostsFromSender];
  }
  [self.postsTableView reloadData];
  self.shouldReload = YES;
}

- (void) displayLoadingView {
  [loadingView.actIndView startAnimating];
  
  [self.view addSubview:loadingView];
  _isDisplayingLoadingView = YES;
}

- (void) removeLoadingView {
  if (_isDisplayingLoadingView) {
    [loadingView.actIndView stopAnimating];
    [loadingView removeFromSuperview];
    _isDisplayingLoadingView = NO;
  }
}

- (void) viewDidUnload {
  [super viewDidUnload];
  [self removeLoadingView];
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
  self.purchLicenseView = nil;
  self.redeemGoldLabel = nil;
  self.redeemSilverLabel = nil;
  self.redeemTitleLabel = nil;
  self.ropeView = nil;
  self.leftRope = nil;
  self.rightRope = nil;
  self.leftRopeFirstRow = nil;
  self.rightRopeFirstRow = nil;
  self.shortLicenseCost = nil;
  self.shortLicenseLength = nil;
  self.longLicenseCost = nil;
  self.longLicenseLength = nil;
  self.loadingView = nil;
  self.purchView = nil;
  self.licenseBgdView = nil;
  self.licenseMainView = nil;
}

@end

@implementation UITextField (DisableCopyPaste)

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{    
  [UIMenuController sharedMenuController].menuVisible = NO;
  return NO;
}

@end