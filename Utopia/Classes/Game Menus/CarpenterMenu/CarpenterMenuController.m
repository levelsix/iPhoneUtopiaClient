//
//  CarpenterMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CarpenterMenuController.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"
#import "Protocols.pb.h"
#import "GameState.h"
#import "Globals.h"
#import "HomeMap.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"

#define ROW_HEIGHT 215

#define TICKER_SEPERATION 1
#define TICKER_MIDDLE_SEPARATION 5

@implementation CarpBar

@synthesize incomeLabel, functionalLabel;
@synthesize incomeButtonClicked, functionalButtonClicked;

- (void) awakeFromNib {
  _clickedButtons = 0;
}

- (void) clickButton:(CarpBarButton)button {
  switch (button) {
    case kIncomeButton:
      incomeButtonClicked.hidden = NO;
      _clickedButtons |= kIncomeButton;
      incomeLabel.highlighted = NO;
      break;
      
    case kFunctionalButton:
      functionalButtonClicked.hidden = NO;
      _clickedButtons |= kFunctionalButton;
      functionalLabel.highlighted = NO;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(CarpBarButton)button {
  switch (button) {
    case kIncomeButton:
      incomeButtonClicked.hidden = YES;
      _clickedButtons &= ~kIncomeButton;
      incomeLabel.highlighted = YES;
      break;
      
    case kFunctionalButton:
      functionalButtonClicked.hidden = YES;
      _clickedButtons &= ~kFunctionalButton;
      functionalLabel.highlighted = YES;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:incomeButtonClicked];
  if (!(_clickedButtons & kIncomeButton) && [incomeButtonClicked pointInside:pt withEvent:nil]) {
    _trackingIncome = YES;
    [self clickButton:kIncomeButton];
  }
  
  pt = [touch locationInView:functionalButtonClicked];
  if (!(_clickedButtons & kFunctionalButton) && [functionalButtonClicked pointInside:pt withEvent:nil]) {
    _trackingFunctional = YES;
    [self clickButton:kFunctionalButton];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:incomeButtonClicked];
  if (_trackingIncome) {
    if (CGRectContainsPoint(CGRectInset(incomeButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kIncomeButton];
    } else {
      [self unclickButton:kIncomeButton];
    }
  }
  
  pt = [touch locationInView:functionalButtonClicked];
  if (_trackingFunctional) {
    if (CGRectContainsPoint(CGRectInset(functionalButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kFunctionalButton];
    } else {
      [self unclickButton:kFunctionalButton];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:incomeButtonClicked];
  if (_trackingIncome) {
    if (CGRectContainsPoint(CGRectInset(incomeButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [[CarpenterMenuController sharedCarpenterMenuController] setState:kIncomeCarp];
      [self clickButton:kIncomeButton];
      [self unclickButton:kFunctionalButton];
    } else {
      [self unclickButton:kIncomeButton];
    }
  }
  
  pt = [touch locationInView:functionalButtonClicked];
  if (_trackingFunctional) {
    if (CGRectContainsPoint(CGRectInset(functionalButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [[CarpenterMenuController sharedCarpenterMenuController] setState:kFunctionalCarp];
      [self clickButton:kFunctionalButton];
      [self unclickButton:kIncomeButton];
    } else {
      [self unclickButton:kFunctionalButton];
    }
  }
  _trackingIncome = NO;
  _trackingFunctional = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kIncomeButton];
  [self unclickButton:kFunctionalButton];
  _trackingIncome = NO;
  _trackingFunctional = NO;
}

@end

@implementation CarpenterTicker

@synthesize string;

- (void) awakeFromNib {
  _tickerImage = [[Globals imageNamed:@"timetickerbg.png"] retain];
  self.string = @"02:00";
  _font = [[UIFont fontWithName:@"Archer" size:11] retain];
}

- (void) setString:(NSString *)s {
  if (s == nil) {
    [string release];
    string = nil;
  } else if (![s isEqualToString:string] && s.length == 5 && [s characterAtIndex:2] == ':') {
    [string release];
    string = [s retain];
    [self setNeedsDisplay];
  }
}

- (void) drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBFillColor(context, 79/256.f, 49/256.f, 6/256.f, 1.f);
  UIColor *shadowColor = [UIColor colorWithWhite:1.f alpha:0.5f];
  CGSize shadowOffset = CGSizeMake(0, 1);
  
  CGContextSetShadow(context, CGSizeMake(0, 0), 0.f);
  CGRect curRect = CGRectMake(0, self.frame.size.height/2-_tickerImage.size.height/2, _tickerImage.size.width, _tickerImage.size.height);
  [_tickerImage drawInRect:curRect];
  NSRange curRange = NSMakeRange(0, 1);
  NSString *curChar = [self.string substringWithRange:curRange];
  CGContextSetShadowWithColor(context, shadowOffset, 0.f, shadowColor.CGColor);
  [curChar drawInRect:curRect withFont:_font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
  
  CGContextSetShadow(context, CGSizeMake(0, 0), 0.f);
  curRect.origin.x += _tickerImage.size.width+TICKER_SEPERATION;
  [_tickerImage drawInRect:curRect];
  curRange.location++;
  curChar = [self.string substringWithRange:curRange];
  CGContextSetShadowWithColor(context, shadowOffset, 0.f, shadowColor.CGColor);
  [curChar drawInRect:curRect withFont:_font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
  
  CGContextSetShadow(context, CGSizeMake(0, 0), 0.f);
  CGRect midRect = curRect;
  midRect.origin.x += _tickerImage.size.width;
  midRect.size.width = TICKER_MIDDLE_SEPARATION;
  curRange.location++;
  curChar = [self.string substringWithRange:curRange];
  CGContextSetShadowWithColor(context, shadowOffset, 0.f, shadowColor.CGColor);
  [curChar drawInRect:midRect withFont:_font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
  
  CGContextSetShadow(context, CGSizeMake(0, 0), 0.f);
  curRect.origin.x += _tickerImage.size.width+TICKER_MIDDLE_SEPARATION;
  [_tickerImage drawInRect:curRect];
  curRange.location++;
  curChar = [self.string substringWithRange:curRange];
  CGContextSetShadowWithColor(context, shadowOffset, 0.f, shadowColor.CGColor);
  [curChar drawInRect:curRect withFont:_font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
  
  CGContextSetShadow(context, CGSizeMake(0, 0), 0.f);
  curRect.origin.x += _tickerImage.size.width+TICKER_SEPERATION;
  [_tickerImage drawInRect:curRect];
  curRange.location++;
  curChar = [self.string substringWithRange:curRange];
  CGContextSetShadowWithColor(context, shadowOffset, 0.f, shadowColor.CGColor);
  [curChar drawInRect:curRect withFont:_font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

- (void) dealloc {
  [_tickerImage release];
  [_font release];
  self.string = nil;
  [super dealloc];
}

@end

@implementation CarpenterListing

@synthesize titleLabel, priceLabel, priceView, incomeLabel, buildingIcon, tickerView, priceIcon;
@synthesize lockIcon, lockedPriceLabel, lockedCollectsLabel, lockedIncomeLabel;
@synthesize availableLabel;
@synthesize darkOverlay, backgroundImg;
@synthesize state = _state;
@synthesize fsp, critStruct;

- (void) awakeFromNib { 
  self.state = kDisappear;
}

- (UIImageView *) darkOverlay {
  // Can't do this in awakeFromNib because server side image will not be loaded yet.
  if (!darkOverlay.image) {
    UIImage *darkOverlayImg = [Globals maskImage:backgroundImg.image withColor:[UIColor colorWithWhite:0.f alpha:0.3f]];
    darkOverlay.image = darkOverlayImg;
  }
  return darkOverlay;
}

- (void) setState:(ListingState)state {
  if (state != _state) {
    _state = state;
    switch (state) {
      case kIncomeAvailable:
        self.hidden = NO;
        priceView.hidden = NO;
        incomeLabel.hidden = NO;
        tickerView.hidden = NO;
        lockIcon.hidden = YES;
        availableLabel.hidden = YES;
        lockedPriceLabel.hidden = YES;
        lockedCollectsLabel.hidden = YES;
        lockedIncomeLabel.hidden = YES;
        self.darkOverlay.hidden = YES;
        break;
        
      case kIncomeLocked:
        self.hidden = NO;
        priceView.hidden = YES;
        incomeLabel.hidden = YES;
        tickerView.hidden = YES;
        lockIcon.hidden = NO;
        availableLabel.hidden = YES;
        lockedPriceLabel.hidden = NO;
        lockedCollectsLabel.hidden = NO;
        lockedIncomeLabel.hidden = NO;
        self.darkOverlay.hidden = NO;
        lockedCollectsLabel.text = @"Unknown";
        lockedIncomeLabel.text = @"Unknown";
        break;
        
      case kFunctionalAvailable:
        self.hidden = NO;
        priceView.hidden = YES;
        incomeLabel.hidden = YES;
        tickerView.hidden = YES;
        lockIcon.hidden = YES;
        availableLabel.hidden = NO;
        lockedPriceLabel.hidden = YES;
        lockedCollectsLabel.hidden = NO;
        lockedIncomeLabel.hidden = NO;
        lockedCollectsLabel.text = @"N/A";
        lockedIncomeLabel.text = @"N/A";
        self.darkOverlay.hidden = YES;
        break;
        
      case kFunctionalLocked:
        self.hidden = NO;
        priceView.hidden = YES;
        incomeLabel.hidden = YES;
        tickerView.hidden = YES;
        lockIcon.hidden = YES;
        availableLabel.hidden = YES;
        lockedPriceLabel.hidden = NO;
        lockedCollectsLabel.hidden = NO;
        lockedIncomeLabel.hidden = NO;
        lockedCollectsLabel.text = @"N/A";
        lockedIncomeLabel.text = @"N/A";
        self.darkOverlay.hidden = NO;
        break;
        
      case kDisappear:
        self.hidden = YES;
        
      default:
        break;
    }
  }
}

- (void) setFsp:(FullStructureProto *)f {
  if (fsp != f) {
    [fsp release];
    fsp = [f retain];
  }
  
  if (!fsp) {
    self.state = kDisappear;
    return;
  }
  
  titleLabel.text = fsp.name;
  _structId = fsp.structId;
  
  if ([GameState sharedGameState].level >= fsp.minLevel) {
    incomeLabel.text = [Globals commafyNumber:fsp.income];
    
    if (fsp.coinPrice > 0) {
      // Highlighted image is the gold icon.
      priceIcon.highlighted = NO;
      priceLabel.text = [Globals commafyNumber:fsp.coinPrice];
    } else {
      priceIcon.highlighted = YES;
      priceLabel.text = [Globals commafyNumber:fsp.diamondPrice];
    }
    
    int mins = fsp.minutesToGain;
    tickerView.string = [NSString stringWithFormat:@"%02d:%02d", (mins/60)%100, mins%60];
    [Globals loadImageForStruct:fsp.structId toView:buildingIcon masked:NO];
    
    self.state = kIncomeAvailable;
  } else {
    [Globals loadImageForStruct:fsp.structId toView:buildingIcon masked:YES];
    lockedPriceLabel.text = [NSString stringWithFormat:@"Unlock at Level %d", fsp.minLevel];
    self.state = kIncomeLocked;
  }
}

- (void) setCritStruct:(CritStruct *)cs {
  if (cs != critStruct) {
    [critStruct release];
    critStruct = [cs retain];
  }
  
  if (!critStruct) {
    self.state = kDisappear;
    return;
  }
  
  titleLabel.text = critStruct.name;
  
  if ([GameState sharedGameState].level >= critStruct.minLevel) {
    [Globals imageNamed:[cs.name stringByAppendingString:@".png"] withImageView:buildingIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleGray];
    self.state = kFunctionalAvailable;
  } else {
    [Globals imageNamed:[cs.name stringByAppendingString:@".png"] withImageView:buildingIcon maskedColor:[UIColor colorWithWhite:0.f alpha:0.7f] indicator:UIActivityIndicatorViewStyleGray];
    lockedPriceLabel.text = [NSString stringWithFormat:@"Unlock at Level %d", critStruct.minLevel];
    self.state = kFunctionalLocked;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == kIncomeAvailable || self.state == kFunctionalAvailable) {
    self.darkOverlay.hidden = NO;
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:self];
  if (self.state == kIncomeAvailable || self.state == kFunctionalAvailable) {
    if ([self pointInside:loc withEvent:event]) {
      self.darkOverlay.hidden = NO;
    } else {
      self.darkOverlay.hidden = YES;
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:self];
  if (self.state == kIncomeAvailable || self.state == kFunctionalAvailable) {
    if ([self pointInside:loc withEvent:event]) {
      [[CarpenterMenuController sharedCarpenterMenuController] carpListingClicked:self];
      self.darkOverlay.hidden = NO;
      [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    self.darkOverlay.hidden = YES;
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == kIncomeAvailable) {
    self.darkOverlay.hidden = YES;
  }
}

- (void) dealloc {
  [_lockedBuildingColor release];
  self.titleLabel = nil;
  self.priceLabel = nil;
  self.priceView = nil;
  self.incomeLabel = nil;
  self.buildingIcon = nil;
  self.tickerView = nil;
  self.priceIcon = nil;
  self.darkOverlay = nil;
  self.backgroundImg = nil;
  self.fsp = nil;
  self.critStruct = nil;
  self.lockedIncomeLabel = nil;
  self.lockedPriceLabel = nil;
  self.lockedCollectsLabel = nil;
  self.availableLabel = nil;
  [super dealloc];
}

@end

@implementation CarpenterListingContainer

@synthesize carpListing;

- (void) awakeFromNib {
  [super awakeFromNib];
  [[NSBundle mainBundle] loadNibNamed:@"CarpenterListing" owner:self options:nil];
  [self addSubview:self.carpListing];
  [self setBackgroundColor:[UIColor clearColor]];
}

- (void) dealloc {
  self.carpListing = nil;
  [super dealloc];
}

@end

@implementation CarpenterRow

@synthesize listing1, listing2, listing3;

- (void) dealloc {
  self.listing1 = nil;
  self.listing2 = nil;
  self.listing3 = nil;
  [super dealloc];
}

@end

@implementation CarpenterMenuController

@synthesize carpRow, carpTable;
@synthesize structsList, critStructsList;
@synthesize state;
@synthesize carpBar, coinBar;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(CarpenterMenuController);

- (void) viewDidLoad {
  self.structsList = [NSMutableArray array];
  self.critStructsList = [NSMutableArray array];
  
  // Add rope to the very top
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  UIView *leftRope = [[UIView alloc] initWithFrame:CGRectMake(15, -150, 3, 150)];
  UIView *rightRope = [[UIView alloc] initWithFrame:CGRectMake(463, -150, 3, 150)];
  leftRope.backgroundColor = c;
  rightRope.backgroundColor = c;
  [self.carpTable addSubview:leftRope];
  [self.carpTable addSubview:rightRope];
  [leftRope release];
  [rightRope release];
}

- (void) viewWillAppear:(BOOL)animated {
  if (structsList.count <= 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveStructStore];
  }
  
  [self reloadCarpenterStructs];
  
  if (_critStructAvail) {
    self.state = kFunctionalCarp;
    
    [self.carpBar clickButton:kFunctionalButton];
    [self.carpBar unclickButton:kIncomeButton];
  } else {
    self.state = kIncomeCarp;
    
    [self.carpBar clickButton:kIncomeButton];
    [self.carpBar unclickButton:kFunctionalButton];
  }
  
  [coinBar updateLabels];
}

- (void) reloadCarpenterStructs {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  _critStructAvail = NO;
  
  [structsList removeAllObjects];
  [critStructsList removeAllObjects];
  
  NSArray *structs = [gs carpenterStructs];
  
  int max = [gl maxRepeatedNormStructs];
  for (FullStructureProto *fsp in structs) {
    int count = 0;
    for (FullUserStructureProto *fusp in [gs myStructs]) {
      if (fusp.structId == fsp.structId) {
        count++;
      }
      if (count >= max) {
        break;
      }
    }
    if (count < max) {
      [structsList addObject:fsp];
    }
  }
  
  BOOL hasMarketplace = NO;
  BOOL hasVault = NO;
  BOOL hasArmory = NO;
  
  for (UserCritStruct *ucs in gs.myCritStructs) {
    if (ucs.type == CritStructTypeMarketplace) {
      hasMarketplace = YES;
    } else if (ucs.type == CritStructTypeVault) {
      hasVault = YES;
    } else if (ucs.type == CritStructTypeArmory) {
      hasArmory = YES;
    }
  }
  
  // This should be in the order of min levels
  if (!hasArmory) {
    CritStruct *cs = [[CritStruct alloc] initWithType:CritStructTypeArmory];
    [critStructsList addObject:cs];
    [cs release];
    
    if (gs.level >= cs.minLevel) {
      _critStructAvail = YES;
    }
  }
  if (!hasVault) {
    CritStruct *cs = [[CritStruct alloc] initWithType:CritStructTypeVault];
    [critStructsList addObject:cs];
    [cs release];
    
    if (gs.level >= cs.minLevel) {
      _critStructAvail = YES;
    }
  }
  if (!hasMarketplace) {
    CritStruct *cs = [[CritStruct alloc] initWithType:CritStructTypeMarketplace];
    [critStructsList addObject:cs];
    [cs release];
    
    if (gs.level >= cs.minLevel) {
      _critStructAvail = YES;
    }
  }
  
  [self.carpTable reloadData];
}

- (void) setState:(CarpState)s {
  if (state != s) {
    state = s;
    
    [self.carpTable reloadData];
  }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *list = self.state == kIncomeCarp ? structsList : critStructsList;
  int rows = (int)ceilf(list.count/3.f);
  tableView.scrollEnabled = rows != 0;
  return rows;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"CarpenterRow";
  
  CarpenterRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"CarpenterRow" owner:self options:nil];
    cell = self.carpRow;
  }
  
  if (self.state == kIncomeCarp) {
    int baseIndex = 3*indexPath.row;
    int count = structsList.count;
    cell.listing1.carpListing.fsp = baseIndex<count ? [structsList objectAtIndex:baseIndex] : nil;
    cell.listing2.carpListing.fsp = baseIndex+1<count ? [structsList objectAtIndex:baseIndex+1] : nil;
    cell.listing3.carpListing.fsp = baseIndex+2<count ? [structsList objectAtIndex:baseIndex+2] : nil;
  } else {
    int baseIndex = 3*indexPath.row;
    int count = critStructsList.count;
    cell.listing1.carpListing.critStruct = baseIndex<count ? [critStructsList objectAtIndex:baseIndex] : nil;
    cell.listing2.carpListing.critStruct = baseIndex+1<count ? [critStructsList objectAtIndex:baseIndex+1] : nil;
    cell.listing3.carpListing.critStruct = baseIndex+2<count ? [critStructsList objectAtIndex:baseIndex+2] : nil;
  }
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  [CarpenterMenuController removeView];
}

- (void) carpListingClicked:(CarpenterListing *)carp {
  if (self.state == kIncomeCarp) {
    // Buy the Income building
    GameState *gs = [GameState sharedGameState];
    if (gs.silver >= carp.fsp.coinPrice && gs.gold >= carp.fsp.diamondPrice) {
      [[HomeMap sharedHomeMap] preparePurchaseOfStruct:carp.fsp.structId];
      [CarpenterMenuController removeView];
    } else {
      if (carp.fsp.coinPrice) {
        [[RefillMenuController sharedRefillMenuController] displayBuySilverView];
        [Analytics notEnoughSilverInCarpenter:carp.fsp.structId];
      } else {
        [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:carp.fsp.diamondPrice];
        [Analytics notEnoughGoldInCarpenter:carp.fsp.structId];
      }
    }
    [coinBar updateLabels];
  } else {
    // Buy the Functional building
    [[HomeMap sharedHomeMap] preparePurchaseOfCritStruct:carp.critStruct];
    [CarpenterMenuController removeView];
  }
}

- (void) viewDidUnload {
  [super viewDidUnload];
  self.carpRow = nil;
  self.coinBar = nil;
  self.carpTable = nil;
  self.structsList = nil;
}

@end
