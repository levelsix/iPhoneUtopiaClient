//
//  MarketplaceFilterView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MarketplaceFilterView.h"
#import "Globals.h"
#import "GameState.h"
#import "MarketplaceViewController.h"

#define EQUIP_LEVEL_NOTCH_LEVEL_DIFF 5

@implementation FilterBar

@synthesize amuIcon, amuButtonClicked, weapIcon,weapButtonClicked,armIcon,armButtonClicked, allButton, allButtonClicked;

- (void) awakeFromNib {
  _clickedButtons = 0;
  
  [self clickButton:kAllButton];
  allButtonClicked.hidden = NO;
  [self unclickButton:kArmButton];
  [self unclickButton:kAmuButton];
  [self unclickButton:kWeapButton];
}

- (int) clickedButton {
  // 0 = All, 1 = weap, 2 = armor, 3 = amulet
  if (_clickedButtons & kAllButton) {
    return 0;
  } else if (_clickedButtons & kWeapButton) {
    return 1;
  } else if (_clickedButtons & kArmButton) {
    return 2;
  } else if (_clickedButtons & kAmuButton) {
    return 3;
  }
  return 0;
}

- (void) clickButton:(MarketPlaceFilterButton)button{
  switch (button) {
    case kAllButton:
      allButtonClicked.hidden = NO;
      allButton.highlighted = NO;
      _clickedButtons |= kAllButton;
      break;
      
    case kArmButton:
      armButtonClicked.hidden = NO;
      armIcon.highlighted = YES;
      _clickedButtons |= kArmButton;
      break;
      
    case kWeapButton:
      weapButtonClicked.hidden = NO;
      weapIcon.highlighted = YES;
      _clickedButtons |= kWeapButton;
      break;
      
    case kAmuButton:
      amuButtonClicked.hidden = NO;
      amuIcon.highlighted = YES;
      _clickedButtons |= kAmuButton;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(MarketPlaceFilterButton)button{
  switch (button) {
    case kAllButton:
      allButtonClicked.hidden = YES;
      allButton.highlighted = YES;
      _clickedButtons &= ~kAllButton;
      break;
      
    case kArmButton:
      armButtonClicked.hidden = YES;
      armIcon.highlighted = NO;
      _clickedButtons &= ~kArmButton;
      break;
      
    case kWeapButton:
      weapButtonClicked.hidden = YES;
      weapIcon.highlighted = NO;
      _clickedButtons &= ~kWeapButton;
      break;
      
    case kAmuButton:
      amuButtonClicked.hidden = YES;
      amuIcon.highlighted = NO;
      _clickedButtons &= ~kAmuButton;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:allButton];
  if (!(_clickedButtons & kAllButton) && [allButtonClicked pointInside:pt withEvent:nil]) {
    _trackingAll = YES;
    [self clickButton:kAllButton];
  }
  
  pt = [touch locationInView:weapButtonClicked];
  if (!(_clickedButtons & kWeapButton) && [weapButtonClicked pointInside:pt withEvent:nil]) {
    _trackingWeapon = YES;
    [self clickButton:kWeapButton];
  }
  
  pt = [touch locationInView:armButtonClicked];
  if (!(_clickedButtons & kArmButton) && [armButtonClicked pointInside:pt withEvent:nil]) {
    _trackingArmor = YES;
    [self clickButton:kArmButton];
  }
  
  pt = [touch locationInView:amuButtonClicked];
  if (!(_clickedButtons & kAmuButton) && [amuButtonClicked pointInside:pt withEvent:nil]) {
    _trackingAmulet = YES;
    [self clickButton:kAmuButton];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:weapButtonClicked];
  if (_trackingWeapon) {
    if (CGRectContainsPoint(CGRectInset(weapButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kWeapButton];
    } else {
      [self unclickButton:kWeapButton];
    }
  }
  
  pt = [touch locationInView:armButtonClicked];
  if (_trackingArmor) {
    if (CGRectContainsPoint(CGRectInset(armButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kArmButton];
    } else {
      [self unclickButton:kArmButton];
    }
  }
  
  pt = [touch locationInView:amuButtonClicked];
  if (_trackingAmulet) {
    if (CGRectContainsPoint(CGRectInset(amuButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kAmuButton];
    } else {
      [self unclickButton:kAmuButton];
    }
  }
  
  pt = [touch locationInView:allButtonClicked];
  if (_trackingAll) {
    if (CGRectContainsPoint(CGRectInset(allButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kAllButton];
    } else {
      [self unclickButton:kAllButton];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:weapButtonClicked];
  if(_trackingWeapon) {
    if (CGRectContainsPoint(CGRectInset(weapButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kWeapButton];
      [self unclickButton:kAmuButton];
      [self unclickButton:kArmButton];
      [self unclickButton:kAllButton];
      
      [[MarketplaceViewController sharedMarketplaceViewController] setCurrentFilter:kWeaponFilter2];
    } else {
      [self unclickButton:kWeapButton];
    }
  }
  
  pt = [touch locationInView:armButtonClicked];
  if(_trackingArmor){
    if (CGRectContainsPoint(CGRectInset(armButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kArmButton];
      [self unclickButton:kAmuButton];
      [self unclickButton:kWeapButton];
      [self unclickButton:kAllButton];
      
      [[MarketplaceViewController sharedMarketplaceViewController] setCurrentFilter:kArmorFilter2];
    } else {
      [self unclickButton:kArmButton];
    } 
  }
  
  pt = [touch locationInView:amuButtonClicked];
  if(_trackingAmulet){
    if (CGRectContainsPoint(CGRectInset(amuButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kAmuButton];
      [self unclickButton:kArmButton];
      [self unclickButton:kWeapButton];
      [self unclickButton:kAllButton];
      
      [[MarketplaceViewController sharedMarketplaceViewController] setCurrentFilter:kAmuletFilter2];
    } else {
      [self unclickButton:kAmuButton];
    } 
  }
  
  pt = [touch locationInView:allButtonClicked];
  if(_trackingAll){
    if (CGRectContainsPoint(CGRectInset(allButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kAllButton];
      [self unclickButton:kAmuButton];
      [self unclickButton:kWeapButton];
      [self unclickButton:kArmButton];
      
      [[MarketplaceViewController sharedMarketplaceViewController] setCurrentFilter:kAllFilter2];
    } else {
      [self unclickButton:kAllButton];
    } 
  }
  _trackingAll = NO;
  _trackingArmor = NO;
  _trackingAmulet = NO;
  _trackingWeapon = NO;
  
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
  [self unclickButton:kWeapButton];
  [self unclickButton:kArmButton];
  [self unclickButton:kAmuButton];
  [self unclickButton:kAllButton];
  _trackingAll = NO;
  _trackingArmor = NO;
  _trackingAmulet = NO;
  _trackingWeapon = NO;
}

@end

@implementation RarityTab

@synthesize check;

- (void) tick {
  check.hidden = NO;
}

- (void) untick {
  check.hidden = YES;
}

- (BOOL) isTicked {
  return !check.hidden;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  if (CGRectContainsPoint(CGRectInset(self.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
    check.hidden = !check.hidden;
  }
}

- (void) dealloc {
  self.check = nil;
  [super dealloc];
}

@end

@implementation RarityBar

@synthesize comTab, uncTab, rareTab, epicTab, legTab;

- (int) serializeSettings {
  int i = 1;
  if ([self.legTab isTicked]) i |= 1 << 1;
  if ([self.epicTab isTicked]) i |= 1 << 2;
  if ([self.rareTab isTicked]) i |= 1 << 3;
  if ([self.uncTab isTicked]) i |= 1 << 4;
  if ([self.comTab isTicked]) i |= 1 << 5;
  return i;
}

- (void) deserializeSettings:(int)val {
  // Check that it isn't first time
  if (val & 1) {
    if (val & (1 << 1)) [self.legTab tick]; else [self.legTab untick];
    if (val & (1 << 2)) [self.epicTab tick]; else [self.epicTab untick];
    if (val & (1 << 3)) [self.rareTab tick]; else [self.rareTab untick];
    if (val & (1 << 4)) [self.uncTab tick]; else [self.uncTab untick];
    if (val & (1 << 5)) [self.comTab tick]; else [self.comTab untick];
  } else {
    [self.legTab tick];
    [self.epicTab tick];
    [self.rareTab tick];
    [self.uncTab tick];
    [self.comTab tick];
  }
}

- (void) dealloc {
  self.comTab = nil;
  self.uncTab = nil;
  self.rareTab = nil;
  self.epicTab = nil;
  self.legTab = nil;
  [super dealloc];
}

@end

@implementation SwitchButton

@synthesize handle, darkHandle, isOn;

- (void) awakeFromNib {
  isOn = YES;
  
  darkHandle = [[UIImageView alloc] initWithFrame:handle.bounds];
  [handle addSubview:darkHandle];
  darkHandle.image = [Globals maskImage:handle.image withColor:[UIColor colorWithWhite:0.f alpha:0.2f]];
  darkHandle.hidden = YES;
}

- (void) setIsOn:(BOOL)i {
  isOn = i;
  
  CGRect r = handle.frame;
  float oldX = r.origin.x;
  r.origin.x = isOn ? self.frame.size.width-r.size.width : 0;
  float dur = ABS(oldX-r.origin.x)/self.frame.size.width*0.3f;
  [UIView animateWithDuration:dur delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    handle.frame = r;
  } completion:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  self.darkHandle.hidden = NO;
  _initialTouch = pt;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  CGRect r = handle.frame;
  float maxX = self.frame.size.width-r.size.width;
  float originalX = isOn ? maxX : 0;
  float diff = pt.x-_initialTouch.x;
  float newX = clampf(originalX+diff, 0.f, maxX);
  r.origin.x = newX;
  handle.frame = r;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  float dist = ccpDistance(pt, _initialTouch);
  
  self.darkHandle.hidden = YES;
  
  if (dist > 1.f) {
    if (handle.center.x < self.frame.size.width/2) {
      self.isOn = NO;
    } else {
      self.isOn = YES;
    }
  } else {
    self.isOn = !isOn;
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  self.darkHandle.hidden = YES;
  self.isOn = isOn;
}

- (void) dealloc {
  self.handle = nil;
  self.darkHandle = nil;
  [super dealloc];
}

@end

@implementation SliderBar

@synthesize leftPin, rightPin, bar;
@synthesize numNotches;

- (void) awakeFromNib {
  leftPin.isLeft = YES;
  rightPin.isLeft = NO;
}

- (void) setNumNotches:(int)n {
  if (numNotches != n) {
    numNotches = n;
    
    [leftPin movedToNotch:0];
    [rightPin movedToNotch:numNotches-1];
  }
}

- (void) movePin:(BOOL)isLeft toNotch:(int)notch {
  float totalWidth = self.frame.size.width-leftPin.frame.size.width/2-rightPin.frame.size.width/2;
  float notchSize = totalWidth/(numNotches-1);
  
  float start = leftPin.frame.size.width/2;
  float newX = start+notch*notchSize;
  
  UIView *v = isLeft ? leftPin : rightPin;
  CGPoint c = v.center;
  c.x = newX;
  v.center = c;
  
  CGRect r = bar.frame;
  r.origin.x = leftPin.center.x;
  r.size.width = rightPin.center.x-leftPin.center.x;
  bar.frame = r;
  
  SliderPin *pin = isLeft ? leftPin : rightPin;
  [pin movedToNotch:notch];
}

- (void) movePin:(BOOL)isLeft withTouchLoc:(CGPoint)pt fromPos:(CGPoint)initialTouch startX:(float)startX {
  float totalWidth = self.frame.size.width-leftPin.frame.size.width/2-rightPin.frame.size.width/2;
  float notchSize = totalWidth/(numNotches-1);
  
  float minX = isLeft ? leftPin.frame.size.width/2 : leftPin.center.x+notchSize;
  float maxX = isLeft ? rightPin.center.x-notchSize : self.frame.size.width-rightPin.frame.size.width/2;
  float diff = pt.x-initialTouch.x;
  float newX = clampf(startX+diff, minX, maxX);
  
  // Find nearest notch
  float start = leftPin.frame.size.width/2;
  int notchNum = (int)roundf((newX-start)/notchSize);
  [self movePin:isLeft toNotch:notchNum];
}

- (void) dealloc {
  self.leftPin = nil;
  self.rightPin = nil;
  self.bar = nil;
  [super dealloc];
}

@end

@implementation SliderPin

@synthesize darkOverlay, isLeft;

- (void) clicked {
  self.darkOverlay.hidden = NO;
}

- (void) unclicked {
  self.darkOverlay.hidden = YES;
}

- (void) movedToNotch:(int)notch {
  // Override this
}

- (int) currentValue {
  return _curVal;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  // Use self.superview because it won't be moving so pt will have a static
  CGPoint pt = [touch locationInView:self.superview];
  
  _initialTouch = pt;
  
  _originalX = self.center.x;
  [self clicked];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  // Use self.superview because it won't be moving
  CGPoint pt = [touch locationInView:self.superview];
  SliderBar *bar = (SliderBar *)self.superview;
  
  [bar movePin:isLeft withTouchLoc:pt fromPos:_initialTouch startX:_originalX];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclicked];
}

- (void) dealloc {
  self.darkOverlay = nil;
  [super dealloc];
}

@end

@implementation EquipLevelPin

@synthesize levelLabel, backgroundImg;

- (void) awakeFromNib {
  self.darkOverlay = [[[UIImageView alloc] initWithFrame:backgroundImg.frame] autorelease];
  self.darkOverlay.image = [Globals maskImage:self.backgroundImg.image 
                                    withColor:[UIColor colorWithWhite:0.f alpha:0.3f]];
  [self addSubview:self.darkOverlay];
  
  [self unclicked];
}

- (void) movedToNotch:(int)notch {
  int level = 0;
  
  if (self.isLeft) {
    level = MAX(1, notch*EQUIP_LEVEL_NOTCH_LEVEL_DIFF);
  } else {
    level = notch*EQUIP_LEVEL_NOTCH_LEVEL_DIFF-1;
  }
  
  self.levelLabel.text = [NSString stringWithFormat:@"%d", level];
  _curVal = level;
}

- (void) dealloc {
  self.levelLabel = nil;
  self.backgroundImg = nil;
  [super dealloc];
}

@end

@implementation ForgeLevelPin

@synthesize levelIcon;

- (void) awakeFromNib {
  self.darkOverlay = [[[UIImageView alloc] initWithFrame:levelIcon.frame] autorelease];
  self.darkOverlay.image = [Globals maskImage:self.levelIcon.image 
                                    withColor:[UIColor colorWithWhite:0.f alpha:0.3f]];
  
  [self addSubview:self.darkOverlay];
  
  [self unclicked];
}

- (void) movedToNotch:(int)notch {
  self.levelIcon.level = notch+1;
  _curVal = notch+1;
}

- (void) dealloc {
  self.levelIcon = nil;
  [super dealloc];
}

@end

@implementation MarketplacePickerView

@synthesize sortOrder, sortOrderLabel, pickerView, sortOrderStrings;

- (void) awakeFromNib {
  self.sortOrderStrings = [NSArray arrayWithObjects:
                           @"Posts: Most Recent",
                           @"Price: Low to High",
                           @"Price: High to Low",
                           @"Attack: High to Low",
                           @"Defense: High to Low",
                           @"Total Stats: High to Low", nil];
}

- (void) setSortOrder:(RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsSortingOrder)s {
  sortOrder = s;
  self.sortOrderLabel.text = [self.sortOrderStrings objectAtIndex:s];
  [self.pickerView selectRow:s inComponent:0 animated:NO];
}

- (int) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.sortOrderStrings.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  return [self.sortOrderStrings objectAtIndex:row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  self.sortOrder = row;
}

- (void) dealloc {
  self.sortOrderLabel = nil;
  self.pickerView = nil;
  self.sortOrderStrings = nil;
  [super dealloc];
}

@end

@implementation MarketplaceFilterView

@synthesize filterBar, rarityBar, switchButton, equipLevelBar, forgeLevelBar, pickerView;

- (void) awakeFromNib {
  Globals *gl = [Globals sharedGlobals];
  self.equipLevelBar.numNotches = gl.maxLevelForUser/EQUIP_LEVEL_NOTCH_LEVEL_DIFF+2;
  self.forgeLevelBar.numNotches = gl.forgeMaxEquipLevel;
}

#define FILTER_BAR_USER_DEFAULTS_KEY @"FilterBarButtonMarketplace"
#define RARITY_BAR_USER_DEFAULTS_KEY @"RarityBarButtonMarketplace"
#define SWITCH_BUTTON_USER_DEFAULTS_KEY @"SwitchButtonMarketplace"
#define EQUIP_LEVEL_MIN_USER_DEFAULTS_KEY @"EquipLevelMinMarketplace"
#define EQUIP_LEVEL_MAX_USER_DEFAULTS_KEY @"EquipLevelMaxMarketplace"
#define FORGE_LEVEL_MIN_USER_DEFAULTS_KEY @"ForgeLevelMinMarketplace"
#define FORGE_LEVEL_MAX_USER_DEFAULTS_KEY @"ForgeLevelMaxMarketplace"
#define SORT_ORDER_USER_DEFAULTS_KEY @"SortOrderMarketplace"

- (void) loadFilterSettings {
  Globals *gl = [Globals sharedGlobals];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  int filterBarButton = [defaults integerForKey:FILTER_BAR_USER_DEFAULTS_KEY];
  int rarityBarButton = [defaults integerForKey:RARITY_BAR_USER_DEFAULTS_KEY];
  BOOL switchButtonOn = [defaults boolForKey:SWITCH_BUTTON_USER_DEFAULTS_KEY];
  int equipMin = [defaults integerForKey:EQUIP_LEVEL_MIN_USER_DEFAULTS_KEY];
  int equipMax = [defaults integerForKey:EQUIP_LEVEL_MAX_USER_DEFAULTS_KEY];
  int forgeMin = [defaults integerForKey:FORGE_LEVEL_MIN_USER_DEFAULTS_KEY];
  int forgeMax = [defaults integerForKey:FORGE_LEVEL_MAX_USER_DEFAULTS_KEY];
  int sortOrder = [defaults integerForKey:SORT_ORDER_USER_DEFAULTS_KEY];
  
  MarketPlaceFilterButton button = kAllButton;
  switch (filterBarButton) {
    case 1:
      button = kWeapButton;
      break;
    case 2:
      button = kArmButton;
      break;
    case 3:
      button = kAmuButton;
      break;
    default:
      break;
  }
  button == kWeapButton ? [filterBar clickButton:kWeapButton] : [filterBar unclickButton:kWeapButton];
  button == kArmButton ? [filterBar clickButton:kArmButton] : [filterBar unclickButton:kArmButton];
  button == kAmuButton ? [filterBar clickButton:kAmuButton] : [filterBar unclickButton:kAmuButton];
  button == kAllButton ? [filterBar clickButton:kAllButton] : [filterBar unclickButton:kAllButton];
  
  [self.rarityBar deserializeSettings:rarityBarButton];
  
  self.switchButton.isOn = switchButtonOn;
  
  if (equipMin == 0) equipMin = 1;
  if (equipMax == 0) equipMax = gl.maxLevelForUser/5*5+4;
  [self.equipLevelBar movePin:YES toNotch:equipMin/EQUIP_LEVEL_NOTCH_LEVEL_DIFF];
  [self.equipLevelBar movePin:NO toNotch:(equipMax+1)/EQUIP_LEVEL_NOTCH_LEVEL_DIFF];
  
  if (forgeMin == 0) forgeMin = 1;
  if (forgeMax == 0) forgeMax = gl.forgeMaxEquipLevel;
  [self.forgeLevelBar movePin:YES toNotch:forgeMin-1];
  [self.forgeLevelBar movePin:NO toNotch:forgeMax-1];
  
  [self.pickerView setSortOrder:sortOrder];
}

- (void) saveFilterSettings {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setInteger:[self.filterBar clickedButton] forKey:FILTER_BAR_USER_DEFAULTS_KEY];
  [defaults setInteger:[self.rarityBar serializeSettings] forKey:RARITY_BAR_USER_DEFAULTS_KEY];
  [defaults setBool:self.switchButton.isOn forKey:SWITCH_BUTTON_USER_DEFAULTS_KEY];
  [defaults setInteger:self.equipLevelBar.leftPin.currentValue forKey:EQUIP_LEVEL_MIN_USER_DEFAULTS_KEY];
  [defaults setInteger:self.equipLevelBar.rightPin.currentValue forKey:EQUIP_LEVEL_MAX_USER_DEFAULTS_KEY];
  [defaults setInteger:self.forgeLevelBar.leftPin.currentValue forKey:FORGE_LEVEL_MIN_USER_DEFAULTS_KEY];
  [defaults setInteger:self.forgeLevelBar.rightPin.currentValue forKey:FORGE_LEVEL_MAX_USER_DEFAULTS_KEY];
  [defaults setInteger:self.pickerView.sortOrder forKey:SORT_ORDER_USER_DEFAULTS_KEY];
}

- (IBAction)restoreDefaults:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:FILTER_BAR_USER_DEFAULTS_KEY];
  [defaults removeObjectForKey:RARITY_BAR_USER_DEFAULTS_KEY];
  [defaults removeObjectForKey:SWITCH_BUTTON_USER_DEFAULTS_KEY];
  [defaults removeObjectForKey:EQUIP_LEVEL_MIN_USER_DEFAULTS_KEY];
  [defaults removeObjectForKey:EQUIP_LEVEL_MAX_USER_DEFAULTS_KEY];
  [defaults removeObjectForKey:FORGE_LEVEL_MIN_USER_DEFAULTS_KEY];
  [defaults removeObjectForKey:FORGE_LEVEL_MAX_USER_DEFAULTS_KEY];
  [defaults removeObjectForKey:SORT_ORDER_USER_DEFAULTS_KEY];
  
  [self loadFilterSettings];
}

- (IBAction)openSortOrder:(id)sender {
  [pickerView.pickerView selectRow:pickerView.sortOrder inComponent:0 animated:NO];
  [UIView animateWithDuration:0.3f animations:^{
    CGRect r = self.frame;
    r.origin.y = -(r.size.height-self.superview.frame.size.height);
    self.frame = r;
  }];
}

- (IBAction)closeSortOrder:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    CGRect r = self.frame;
    r.origin.y = 0;
    self.frame = r;
  }];
}

- (void) dealloc {
  [self saveFilterSettings];
  
  self.filterBar = nil;
  self.rarityBar = nil;
  self.switchButton = nil;
  self.equipLevelBar = nil;
  self.forgeLevelBar = nil;
  self.pickerView = nil;
  [super dealloc];
}

@end

@implementation MarketplaceDragView

- (void) didMoveToSuperview {
  [super didMoveToSuperview];
  _initialX = self.superview.frame.origin.x;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  _passedThreshold = NO;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  // Use superview's superview as basis view because it remains static
  UITouch *touch = [touches anyObject];
  UIView *view = self.superview;
  CGPoint pt = [touch locationInView:view.superview];
  
  if (pt.x < _initialX) {
    CGRect r = view.frame;
    
    // If moving left or staying still, we want it to default to going back
    if (pt.x < r.origin.x) {
      _passedThreshold = NO;
    } else {
      _passedThreshold = YES;
    }
    
    r.origin.x = pt.x;
    view.frame = r;
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  UIView *view = self.superview;
  CGPoint pt = [touch locationInView:view.superview];
  
  if (!_passedThreshold || pt.x < _initialX/2) {
    [[MarketplaceViewController sharedMarketplaceViewController] closeFilterPage:nil];
  } else {
    CGRect r = view.frame;
    float dist = r.origin.x;
    r.origin.x = _initialX;
    [UIView animateWithDuration:dist/1000.f animations:^{
      view.frame = r;
    }];
  }
}

@end
