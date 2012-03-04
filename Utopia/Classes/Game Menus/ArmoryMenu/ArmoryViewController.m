//
//  ArmoryViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ArmoryViewController.h"
#import "SynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"

#define BUY_SELL_Y_OFFSET 1.f
#define BUY_SELL_ANIMATION_DURATION 0.4f

@implementation ArmoryBar

@synthesize weaponButton, armorButton, amuletButton;
@synthesize weaponButtonClicked, armorButtonClicked, amuletButtonClicked;

- (void) awakeFromNib {
  _clickedButtons = 0;
}

- (void) clickButton:(ArmoryBarButton)button {
  switch (button) {
    case kWeaponButton:
      weaponButtonClicked.hidden = NO;
      _clickedButtons |= kWeaponButton;
      break;
      
    case kArmorButton:
      armorButtonClicked.hidden = NO;
      _clickedButtons |= kArmorButton;
      break;
      
    case kAmuletButton:
      amuletButtonClicked.hidden = NO;
      _clickedButtons |= kAmuletButton;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(ArmoryBarButton)button {
  switch (button) {
    case kWeaponButton:
      weaponButtonClicked.hidden = YES;
      _clickedButtons &= ~kWeaponButton;
      break;
      
    case kArmorButton:
      armorButtonClicked.hidden = YES;
      _clickedButtons &= ~kArmorButton;
      break;
      
    case kAmuletButton:
      amuletButtonClicked.hidden = YES;
      _clickedButtons &= ~kAmuletButton;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:weaponButtonClicked];
  if (!(_clickedButtons & kWeaponButton) && [weaponButtonClicked pointInside:pt withEvent:nil]) {
    _trackingWeapon = YES;
    [self clickButton:kWeaponButton];
  }
  
  pt = [touch locationInView:armorButtonClicked];
  if (!(_clickedButtons & kArmorButton) && [armorButtonClicked pointInside:pt withEvent:nil]) {
    _trackingArmor = YES;
    [self clickButton:kArmorButton];
  }
  
  pt = [touch locationInView:amuletButtonClicked];
  if (!(_clickedButtons & kAmuletButton) && [amuletButtonClicked pointInside:pt withEvent:nil]) {
    _trackingAmulet = YES;
    [self clickButton:kAmuletButton];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:weaponButtonClicked];
  if (_trackingWeapon) {
    if ([weaponButtonClicked pointInside:pt withEvent:nil]) {
      [self clickButton:kWeaponButton];
    } else {
      [self unclickButton:kWeaponButton];
    }
  }
  
  pt = [touch locationInView:armorButtonClicked];
  if (_trackingArmor) {
    if ([armorButtonClicked pointInside:pt withEvent:nil]) {
      [self clickButton:kArmorButton];
    } else {
      [self unclickButton:kArmorButton];
    }
  }
  
  pt = [touch locationInView:amuletButtonClicked];
  if (_trackingAmulet) {
    if ([amuletButtonClicked pointInside:pt withEvent:nil]) {
      [self clickButton:kAmuletButton];
    } else {
      [self unclickButton:kAmuletButton];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:weaponButtonClicked];
  if (_trackingWeapon) {
    if ([weaponButtonClicked pointInside:pt withEvent:nil]) {
      [[ArmoryViewController sharedArmoryViewController] setState:kWeaponState];
      [self clickButton:kWeaponButton];
      [self unclickButton:kAmuletButton];
      [self unclickButton:kArmorButton];
    } else {
      [self unclickButton:kWeaponButton];
    }
  }
  
  pt = [touch locationInView:armorButtonClicked];
  if (_trackingArmor) {
    if ([armorButtonClicked pointInside:pt withEvent:nil]) {
      [[ArmoryViewController sharedArmoryViewController] setState:kArmorState];
      [self clickButton:kArmorButton];
      [self unclickButton:kWeaponButton];
      [self unclickButton:kAmuletButton];
    } else {
      [self unclickButton:kArmorButton];
    }
  }
  
  pt = [touch locationInView:amuletButtonClicked];
  if (_trackingAmulet) {
    if ([amuletButtonClicked pointInside:pt withEvent:nil]) {
      [[ArmoryViewController sharedArmoryViewController] setState:kAmuletState];
      [self clickButton:kAmuletButton];
      [self unclickButton:kWeaponButton];
      [self unclickButton:kArmorButton];
    } else {
      [self unclickButton:kAmuletButton];
    }
  }
  _trackingWeapon = NO;
  _trackingArmor = NO;
  _trackingAmulet = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kWeaponButton];
  [self unclickButton:kArmorButton];
  [self unclickButton:kAmuletButton];
  _trackingWeapon = NO;
  _trackingArmor = NO;
  _trackingAmulet = NO;
}

@end


@implementation ArmoryListing

@synthesize attackLabel, defenseLabel, titleLabel, priceLabel;
@synthesize bgdView, equipIcon, maskedEquipIcon, coinIcon;
@synthesize fep;
@synthesize darkOverlay;

- (void) awakeFromNib {
  int offset = 5;
  CGRect rect = CGRectMake(offset, offset, self.bounds.size.width-2*offset, self.bounds.size.height-2*offset);
  darkOverlay = [[UIView alloc] initWithFrame:rect];
  darkOverlay.layer.cornerRadius = 5.f;
  darkOverlay.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
  [self addSubview:darkOverlay];
  darkOverlay.hidden = YES;
}

- (void) setFep:(FullEquipProto *)newFep {
  if (fep != newFep) {
    [fep release];
    fep = [newFep retain];
  }
  
  if (!fep) {
    self.hidden = YES;
    return;
  }
  self.hidden = NO;
  
  titleLabel.text = fep.name;
  titleLabel.textColor = [Globals colorForRarity:fep.rarity];
  attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
  
  if (fep.coinPrice) {
    priceLabel.text = [Globals commafyNumber:fep.coinPrice];
    coinIcon.highlighted = NO;
  } else if (fep.diamondPrice) {
    priceLabel.text = [Globals commafyNumber:fep.diamondPrice];
    coinIcon.highlighted = YES;
  } else {
    [Globals popupMessage:@"Error: Found equip with no price.."];
  }
  
  equipIcon.image = [Globals imageForEquip:fep.equipId];
  
  if ([Globals canEquip:fep]) {
    bgdView.highlighted = NO;
    maskedEquipIcon.hidden = YES;
  } else {
    bgdView.highlighted = YES;
    maskedEquipIcon.image = [Globals maskImage:equipIcon.image withColor:[Globals colorForUnequippable]];
    maskedEquipIcon.hidden = NO;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (![[ArmoryViewController sharedArmoryViewController] equipClicked]) {
    darkOverlay.hidden = NO;
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (![[ArmoryViewController sharedArmoryViewController] equipClicked]) {
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    if ([self pointInside:loc withEvent:event]) {
      darkOverlay.hidden = NO;
    } else {
      darkOverlay.hidden = YES;
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (![[ArmoryViewController sharedArmoryViewController] equipClicked]) {
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    if ([self pointInside:loc withEvent:event]) {
      [[ArmoryViewController sharedArmoryViewController] armoryListingClicked:self];
      darkOverlay.hidden = NO;
      [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    darkOverlay.hidden = YES;
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (![[ArmoryViewController sharedArmoryViewController] equipClicked]) {
    darkOverlay.hidden = YES;
  }
}

- (void) dealloc {
  self.fep = nil;
  [super dealloc];
}

@end

@implementation ArmoryListingContainer

@synthesize armoryListing;

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"ArmoryListing" owner:self options:nil];
  [self addSubview:self.armoryListing];
  [self setBackgroundColor:[UIColor clearColor]];
}

@end

@implementation ArmoryRow

@synthesize listing1, listing2, listing3;

@end

@implementation ArmoryViewController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ArmoryViewController);

@synthesize armoryTableView, armoryRow;
@synthesize buySellView, sellButton, buyButton;
@synthesize numOwnedLabel, equipDescriptionLabel;
@synthesize cantEquipView, cantEquipLabel;
@synthesize equipClicked;
@synthesize armoryBar;
@synthesize state = _state;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveEquipStore];
  
  buyButton.text = @"Buy";
  sellButton.text = @"Sell";
  _originalBuySellSize = buySellView.frame.size;
  
  equipDescriptionLabel.adjustsFontSizeToFitWidth = YES;
}

- (void) viewDidAppear:(BOOL)animated {
  [self buySellClosed];
  self.armoryTableView.contentOffset = CGPointMake(0,0);
  self.state = kWeaponState;
}

- (void) setState:(ArmoryState)state {
  if (state != _state) {
    _state = state;
    
    [self refresh];
  }
}

- (NSArray *)equipListForCurrentState {
  GameState *gs = [GameState sharedGameState];
  NSArray *equipsList = nil;
  switch (_state) {
    case kWeaponState:
      equipsList = gs.armoryWeapons;
      break;
      
    case kArmorState:
      equipsList = gs.armoryArmor;
      break;
      
    case kAmuletState:
      equipsList = gs.armoryAmulets;
      break;
      
    default:
      NSLog(@"Undefined state in armory.");
      break;
  }
  return equipsList;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *equipsList = [self equipListForCurrentState];
  return (int)ceilf(equipsList.count/3.f);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"ArmoryRow";
  NSArray *equipsList = [self equipListForCurrentState];
  
  ArmoryRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    NSLog(@"New Arm Row");
    [[NSBundle mainBundle] loadNibNamed:@"ArmoryRow" owner:self options:nil];
    cell = self.armoryRow;
  }
  
  int baseIndex = 3*indexPath.row;
  int count = equipsList.count;
  cell.listing1.armoryListing.fep = baseIndex<count ? [equipsList objectAtIndex:baseIndex] : nil;
  cell.listing2.armoryListing.fep = baseIndex+1<count ? [equipsList objectAtIndex:baseIndex+1] : nil;
  cell.listing3.armoryListing.fep = baseIndex+2<count ? [equipsList objectAtIndex:baseIndex+2] : nil;
  
  return cell;
}

- (void) refresh {
  [self.armoryTableView reloadData];
  [self.armoryTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void) loadBuySellViewForEquip:(FullEquipProto *)fep {
  GameState *gs = [GameState sharedGameState];
  
  equipDescriptionLabel.text = fep.description;
  
  if (![Globals canEquip:fep]) {
    if (fep.classType != gs.type % 3) {
      cantEquipLabel.text = [NSString stringWithFormat:@"This item can only be used by a %@", [Globals stringForEquipType:fep.equipType]];
    }
    else if (fep.minLevel > gs.level) {
      cantEquipLabel.text = [NSString stringWithFormat:@"Requires Level %d to Equip", fep.minLevel];
    } else {
      cantEquipLabel.text = @"Unable to equip for unknown reason";
    }
    cantEquipView.hidden = NO;
  } else {
    cantEquipView.hidden = YES;
  }
  
  UserEquip *ue = nil;
  for (UserEquip *f in [[GameState sharedGameState] myEquips]) {
    if (f.equipId == fep.equipId) {
      ue = f;
      break;
    }
  }
  
  if (ue) {
    numOwnedLabel.text = [NSString stringWithFormat:@"%d", ue.quantity];
    if (fep.diamondPrice != 0) {
      sellButton.enabled = NO;
    } else {
      sellButton.enabled = YES;
    }
  } else {
    numOwnedLabel.text = @"0";
    sellButton.enabled = NO;
  }
  
  if (fep.coinPrice > gs.silver || fep.diamondPrice > gs.gold) {
    buyButton.enabled = NO;
  } else {
    buyButton.enabled = YES;
  }
}

- (void) armoryListingClicked:(ArmoryListing *)al {
  // Get the row so we can animate everything
  UIView *rowContentView = al.superview.superview;
  ArmoryRow *row = (ArmoryRow *)rowContentView.superview;
  
  // Center this row
  [armoryTableView setContentOffset:CGPointMake(0, CGRectGetMidY(row.frame)-armoryTableView.frame.size.height/2) animated:YES];
  
  CGRect rect = al.superview.frame;
  rect.origin.y -= BUY_SELL_Y_OFFSET;
  rect.size.width -= 4;
  buySellView.frame = rect;
  buySellView.hidden = NO;
  [self loadBuySellViewForEquip:al.fep];
  [rowContentView bringSubviewToFront:al.superview];
  [rowContentView insertSubview:buySellView belowSubview:al.superview];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:BUY_SELL_ANIMATION_DURATION];
  
  if (al != row.listing1.armoryListing) {
    row.listing1.armoryListing.alpha = 0.f;
  }
  if (al != row.listing2.armoryListing) {
    row.listing2.armoryListing.alpha = 0.f;
  }
  if (al != row.listing3.armoryListing) {
    row.listing3.armoryListing.alpha = 0.f;
  }
  _clickedAl = al;
  _oldClickedRect = al.superview.frame;
  al.superview.frame = row.listing1.frame;
  al.userInteractionEnabled = YES;
  // These constants are there to a) make sure close button shows and b) make it look good
  buySellView.frame = CGRectMake(row.listing1.frame.origin.x, row.listing1.frame.origin.y-BUY_SELL_Y_OFFSET, _originalBuySellSize.width, _originalBuySellSize.height);
  
  armoryTableView.scrollEnabled = NO;
  self.equipClicked = YES;
  
  [UIView commitAnimations];
  
  armoryBar.userInteractionEnabled = NO;
}

- (IBAction) closeBuySellViewClicked:(id)sender {
  if (sender) {
    // Check if this was a result of a button click, or programmatic call
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:BUY_SELL_ANIMATION_DURATION];
  }
  
  ArmoryRow *row = (ArmoryRow *)_clickedAl.superview.superview.superview;
  _clickedAl.superview.frame = _oldClickedRect;
  CGRect rect = _clickedAl.superview.frame;
  rect.origin.y -= BUY_SELL_Y_OFFSET;
  rect.size.width -= 4;
  buySellView.frame = rect;
  
  row.listing1.armoryListing.alpha = 1.f;
  row.listing2.armoryListing.alpha = 1.f;
  row.listing3.armoryListing.alpha = 1.f;
  
  if (sender) {
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(buySellClosed)];
    
    [UIView commitAnimations];
    
    // Put tableview back
    if (armoryTableView.contentOffset.y < 0) {
      [armoryTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (armoryTableView.contentOffset.y > armoryTableView.contentSize.height-armoryTableView.frame.size.height) {
      [armoryTableView setContentOffset:CGPointMake(0, armoryTableView.contentSize.height-armoryTableView.frame.size.height) animated:YES];
    }
  } else {
    [self buySellClosed];
  }
}

- (void) buySellClosed {
  [buySellView removeFromSuperview];
  armoryBar.userInteractionEnabled = YES;
  armoryTableView.scrollEnabled = YES;
  _clickedAl.userInteractionEnabled = YES;
  self.equipClicked = NO;
}

- (IBAction)buyClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = _clickedAl.fep;
  
  int updatedQuantity = [[OutgoingEventController sharedOutgoingEventController] buyEquip:fep.equipId];
  numOwnedLabel.text = [NSString stringWithFormat:@"%d", updatedQuantity];
  
  if (updatedQuantity > 0) {
    sellButton.enabled = YES;
  }
  
  if (fep.coinPrice > gs.silver || fep.diamondPrice > gs.gold) {
    buyButton.enabled = NO;
  } else {
    buyButton.enabled = YES;
  }
}

- (IBAction)sellClicked:(id)sender {
  FullEquipProto *fep = _clickedAl.fep;
  
  int updatedQuantity = [[OutgoingEventController sharedOutgoingEventController] sellEquip:fep.equipId];
  numOwnedLabel.text = [NSString stringWithFormat:@"%d", updatedQuantity];
  
  if (updatedQuantity == 0) {
    sellButton.enabled = NO;
  }
}

- (IBAction)backClicked:(id)sender {
  [ArmoryViewController removeView];
}

@end
