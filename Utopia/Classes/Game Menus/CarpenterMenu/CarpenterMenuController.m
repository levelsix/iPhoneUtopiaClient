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

#define ROW_HEIGHT 215

#define TICKER_SEPERATION 1
#define TICKER_MIDDLE_SEPARATION 5

@implementation CarpenterTicker

@synthesize string;

- (void) awakeFromNib {
  _tickerImage = [[UIImage imageNamed:@"timetickerbg.png"] retain];
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
@synthesize darkOverlay, backgroundImg;
@synthesize state = _state;
@synthesize fsp;

- (void) awakeFromNib { 
  self.state = kDisappear;
  
  UIImage *darkOverlayImg = [self maskImage:backgroundImg.image withColor:[UIColor colorWithWhite:0.f alpha:0.3f]];
  darkOverlay.image = darkOverlayImg;
  
  _lockedBuildingColor = [[UIColor colorWithWhite:0.f alpha:0.7f] retain];
}

- (UIImage*) maskImage:(UIImage *)image withColor:(UIColor *)color {
  
  CGImageRef alphaImage = CGImageRetain(image.CGImage);
  float width = CGImageGetWidth(alphaImage);
  float height = CGImageGetHeight(alphaImage);
  
  UIGraphicsBeginImageContext(CGSizeMake(width, height));
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (!context) {
    UIGraphicsGetCurrentContext();
    return nil;
  }
  
	CGRect r = CGRectMake(0, 0, width, height);
	CGContextTranslateCTM(context, 0.0, r.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
  CGContextSetFillColorWithColor(context, color.CGColor);
  
	// You can also use the clip rect given to scale the mask image
	CGContextClipToMask(context, CGRectMake(0.0, 0.0, width, height), alphaImage);
	// As above, not being careful with bounds since we are clipping.
	CGContextFillRect(context, r);
  
  UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  // return the image
  return theImage;
}

- (void) setState:(ListingState)state {
  if (state != _state) {
    _state = state;
    switch (state) {
      case kAvailable:
        self.hidden = NO;
        priceView.hidden = NO;
        incomeLabel.hidden = NO;
        tickerView.hidden = NO;
        lockIcon.hidden = YES;
        lockedPriceLabel.hidden = YES;
        lockedCollectsLabel.hidden = YES;
        lockedIncomeLabel.hidden = YES;
        darkOverlay.hidden = YES;
        break;
        
      case kLocked:
        self.hidden = NO;
        priceView.hidden = YES;
        incomeLabel.hidden = YES;
        tickerView.hidden = YES;
        lockIcon.hidden = NO;
        lockedPriceLabel.hidden = NO;
        lockedCollectsLabel.hidden = NO;
        lockedIncomeLabel.hidden = NO;
        darkOverlay.hidden = NO;
        break;
        
      case kDisappear:
        self.hidden = YES;
        
      default:
        break;
    }
  }
}

- (void) setFsp:(FullStructureProto *)f {
  [fsp release];
  fsp = [f retain];
  
  if (!fsp) {
    self.state = kDisappear;
    return;
  }
  
  titleLabel.text = fsp.name;
  _structId = fsp.structId;
  
  if ([GameState sharedGameState].level > fsp.minLevel) {
    incomeLabel.text = [Globals commafyNumber:fsp.income];
    
    if (fsp.coinPrice > 0) {
      // Highlighted image is the gold icon.
      priceIcon.highlighted = NO;
      priceLabel.text = [Globals commafyNumber:fsp.coinPrice];
    } else {
      priceIcon.highlighted = YES;
      priceLabel.text = [Globals commafyNumber:fsp.diamondPrice];
    }
    
    int mins = fsp.minutesToBuild;
    tickerView.string = [NSString stringWithFormat:@"%02d:%02d", (mins/60)%100, mins%60];
    buildingIcon.image = [UIImage imageNamed:[Globals imageNameForStruct:fsp.structId]];
    
    self.state = kAvailable;
  } else {
    buildingIcon.image = [self maskImage:[UIImage imageNamed:[Globals imageNameForStruct:fsp.structId]] withColor:_lockedBuildingColor];
    lockedPriceLabel.text = [NSString stringWithFormat:@"Unlock at Level %d", fsp.minLevel];
    self.state = kLocked;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == kAvailable) {
    darkOverlay.hidden = NO;
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:self];
  if (self.state == kAvailable) {
    if ([self pointInside:loc withEvent:event]) {
      darkOverlay.hidden = NO;
    } else {
      darkOverlay.hidden = YES;
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:self];
  if (self.state == kAvailable) {
    darkOverlay.hidden = NO;
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    darkOverlay.hidden = YES;
    if ([self pointInside:loc withEvent:event]) {
      [[HomeMap sharedHomeMap] preparePurchaseOfStruct:_structId];
      [CarpenterMenuController removeView];
    }
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == kAvailable) {
    darkOverlay.hidden = YES;
  }
}

- (void) dealloc {
  [_lockedBuildingColor release];
  [super dealloc];
}

@end

@implementation CarpenterListingContainer

@synthesize carpListing;

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"CarpenterListing" owner:self options:nil];
  [self addSubview:self.carpListing];
  [self setBackgroundColor:[UIColor clearColor]];
}

@end

@implementation CarpenterRow

@synthesize listing1, listing2, listing3;

@end

@implementation CarpenterMenuController

@synthesize carpRow, carpTable;
@synthesize structsList;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(CarpenterMenuController);

- (void) viewDidLoad {
  self.structsList = [NSMutableArray arrayWithCapacity:[[Globals sharedGlobals] maxStructId]];
  [[OutgoingEventController sharedOutgoingEventController] retrieveStructStore];
}

- (void) viewDidAppear:(BOOL)animated {
  [structsList removeAllObjects];
  
  NSArray *structs = [[GameState sharedGameState] carpenterStructs];
  while (structs.count == 0) {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  }
  
  int max = [[Globals sharedGlobals] maxRepeatedNormStructs];
  for (FullStructureProto *fsp in structs) {
    int count = 0;
    for (FullUserStructureProto *fusp in [[GameState sharedGameState] myStructs]) {
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
  [self.carpTable reloadData];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (int)ceilf(structsList.count/3.f);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"CarpenterRow";
  
  CarpenterRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    NSLog(@"New Carp Row");
    [[NSBundle mainBundle] loadNibNamed:@"CarpenterRow" owner:self options:nil];
    cell = self.carpRow;
  }
  
  int baseIndex = 3*indexPath.row;
  int count = structsList.count;
  cell.listing1.carpListing.fsp = baseIndex<count ? [structsList objectAtIndex:baseIndex] : nil;
  cell.listing2.carpListing.fsp = baseIndex+1<count ? [structsList objectAtIndex:baseIndex+1] : nil;
  cell.listing3.carpListing.fsp = baseIndex+2<count ? [structsList objectAtIndex:baseIndex+2] : nil;
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  [CarpenterMenuController removeView];
}

@end
