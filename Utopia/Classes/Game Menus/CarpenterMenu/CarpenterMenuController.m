//
//  CarpenterMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CarpenterMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Protocols.pb.h"
#import "GameState.h"
#import "Globals.h"
#import "HomeMap.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "SoundEngine.h"

#define NUM_ENTRIES_PER_ROW 2

#define ROW_HEIGHT 215

#define TICKER_SEPERATION 1
#define TICKER_MIDDLE_SEPARATION 5

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
@synthesize fsp;

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
    [Globals loadImageForStruct:fsp.structId toView:buildingIcon masked:NO indicator:UIActivityIndicatorViewStyleGray];
    
    self.state = kIncomeAvailable;
  } else {
    [Globals loadImageForStruct:fsp.structId toView:buildingIcon masked:YES indicator:UIActivityIndicatorViewStyleGray];
    lockedPriceLabel.text = [NSString stringWithFormat:@"Unlock at Level %d", fsp.minLevel];
    self.state = kIncomeLocked;
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
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
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
  self.titleLabel = nil;
  self.priceLabel = nil;
  self.priceView = nil;
  self.incomeLabel = nil;
  self.buildingIcon = nil;
  self.tickerView = nil;
  self.priceIcon = nil;
  self.lockIcon = nil;
  self.darkOverlay = nil;
  self.backgroundImg = nil;
  self.fsp = nil;
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

@synthesize listing1, listing2;

- (void) dealloc {
  self.listing1 = nil;
  self.listing2 = nil;
  [super dealloc];
}

@end

@implementation CarpenterMenuController

@synthesize carpRow, carpTable;
@synthesize structsList;
@synthesize coinBar;
@synthesize mainView, bgdView;
@synthesize spinner;
@synthesize arrow;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(CarpenterMenuController);

- (void) viewDidLoad {
  self.structsList = [NSMutableArray array];
  
  // Add rope to the very top
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  UIView *leftRope = [[UIView alloc] initWithFrame:CGRectMake(12, -150, 3, 150)];
  UIView *rightRope = [[UIView alloc] initWithFrame:CGRectMake(306, -150, 3, 150)];
  leftRope.backgroundColor = c;
  rightRope.backgroundColor = c;
  [self.carpTable addSubview:leftRope];
  [self.carpTable addSubview:rightRope];
  [leftRope release];
  [rightRope release];
  
  arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
}

- (void) viewWillAppear:(BOOL)animated {
  if (structsList.count <= 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveStructStore];
  }
  
  [self reloadCarpenterStructs];
  
  [coinBar updateLabels];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self performSelector:@selector(scrollToStruct) withObject:nil afterDelay:0.1f];
  
  [[SoundEngine sharedSoundEngine] carpenterEnter];
}

- (void) scrollToStruct {
  if (_structIdToDisplayArrow > 0) {
    for (int i = 0; i < structsList.count; i++) {
      FullStructureProto *fsp = [structsList objectAtIndex:i];
      if (fsp.structId == _structIdToDisplayArrow) {
        [self.carpTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i/NUM_ENTRIES_PER_ROW inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
      }
    }
  }
}

- (void) viewDidDisappear:(BOOL)animated {
  _structIdToDisplayArrow = 0;
}

- (void) reloadCarpenterStructs {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  [structsList removeAllObjects];
  
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
  
  [structsList sortUsingComparator:^NSComparisonResult(FullStructureProto *obj1, FullStructureProto *obj2) {
    if (obj1.minLevel < obj2.minLevel) {
      return NSOrderedAscending;
    } else if (obj1.minLevel > obj2.minLevel) {
      return NSOrderedDescending;
    } else {
      if (obj1.structId < obj2.structId) {
        return NSOrderedAscending;
      }
      return NSOrderedDescending;
    }
  }];
  
  [self.carpTable reloadData];
  
  if (self.view.superview) {
    [self performSelector:@selector(scrollToStruct) withObject:nil afterDelay:0.1f];
  }
}

- (void) displayArrowOnNextOpen:(int)structId {
  _structIdToDisplayArrow = structId;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *list = structsList;
  int rows = (int)ceilf((float)list.count/NUM_ENTRIES_PER_ROW);
  
  if (rows > 0) {
    tableView.scrollEnabled = YES;
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
  } else {
    tableView.scrollEnabled = NO;
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
  }
  
  return rows;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CarpenterRow *cell = [tableView dequeueReusableCellWithIdentifier:@"CarpenterRow"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"CarpenterRow" owner:self options:nil];
    cell = self.carpRow;
  }
  
  int baseIndex = NUM_ENTRIES_PER_ROW*indexPath.row;
  int count = structsList.count;
  
  FullStructureProto *fsp1 = baseIndex<count ? [structsList objectAtIndex:baseIndex] : nil;
  FullStructureProto *fsp2 = baseIndex+1<count ? [structsList objectAtIndex:baseIndex+1] : nil;
  cell.listing1.carpListing.fsp = fsp1;
  cell.listing2.carpListing.fsp = fsp2;
  
  if (_structIdToDisplayArrow) {
    if (fsp1.structId == _structIdToDisplayArrow) {
      [cell.listing1.superview addSubview:arrow];
      arrow.center = CGPointMake(CGRectGetMaxX(cell.listing1.frame)+arrow.frame.size.width/2-5.f, cell.listing1.center.y);
      [Globals animateUIArrow:arrow atAngle:M_PI];
    } else if (fsp2.structId == _structIdToDisplayArrow) {
      [cell.listing2.superview addSubview:arrow];
      arrow.center = CGPointMake(CGRectGetMinX(cell.listing2.frame)-arrow.frame.size.width/2+5.f, cell.listing1.center.y);
      [Globals animateUIArrow:arrow atAngle:0];
    } else if (arrow.superview == cell.listing1.superview) {
      [arrow removeFromSuperview];
    }
  } else {
    [arrow removeFromSuperview];
  }
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  if (self.view.superview) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [CarpenterMenuController removeView];
    }];
  }
}

- (void) carpListingClicked:(CarpenterListing *)carp {
  GameState *gs = [GameState sharedGameState];
  if (gs.silver >= carp.fsp.coinPrice && gs.gold >= carp.fsp.diamondPrice) {
    [[HomeMap sharedHomeMap] preparePurchaseOfStruct:carp.fsp.structId];
    [self closeClicked:nil];
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
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  self.carpRow = nil;
  self.coinBar = nil;
  self.carpTable = nil;
  self.structsList = nil;
  self.arrow = nil;
}

@end
