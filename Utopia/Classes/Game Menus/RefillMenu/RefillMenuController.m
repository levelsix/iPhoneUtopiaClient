//
//  RefillMenuControler.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "RefillMenuController.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "SynthesizeSingleton.h"
#import "GoldShoppeViewController.h"

#define POPUP_ANIMATION_DURATION 0.2f

#define REQUIRES_EQUIP_VIEW_OFFSET 5.f
#define EQUIPS_VIEW_SPACING 1.f

@implementation RequiresEquipView

- (id) initWithEquipId:(int)equipId {
  if ((self = [super initWithImage:[Globals imageNamed:@"itemsquare.png"]])) {
    UIImageView *equipView = [[UIImageView alloc] initWithImage:[Globals imageForEquip:equipId]];
    equipView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect r = self.bounds;
    r.origin.x += REQUIRES_EQUIP_VIEW_OFFSET;
    r.origin.y += REQUIRES_EQUIP_VIEW_OFFSET;
    r.size.width -= 2*REQUIRES_EQUIP_VIEW_OFFSET;
    r.size.height -= 2*REQUIRES_EQUIP_VIEW_OFFSET;
    equipView.frame = r;
    
    [self addSubview:equipView];
    [equipView release];
  }
  return self;
}

@end

@implementation RefillMenuController

@synthesize goldView, itemsView, enstView;
@synthesize curGoldLabel, needGoldLabel;
@synthesize enstImageView, enstGoldCostLabel, fillEnstLabel, enstHintLabel;
@synthesize itemsCostView, itemsSilverLabel;
@synthesize itemsScrollView, itemsContainerView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(RefillMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  itemsView.frame = goldView.frame;
  enstView.frame = goldView.frame;
  [self.view addSubview:itemsView];
  [self.view addSubview:enstView];
  itemsView.hidden = YES;
  enstView.hidden = YES;
  goldView.hidden = YES;
  
  NSLog(@"B:%@", [NSValue valueWithCGRect:itemsScrollView.frame]);
}

- (void) displayEnstView:(BOOL)isEnergy {
  Globals *gl = [Globals sharedGlobals];
  
  _isEnergy = isEnergy;
  
  if (isEnergy) {
    enstImageView.highlighted = NO;
    enstGoldCostLabel.text = [NSString stringWithFormat:@"%d", gl.energyRefillCost];
    fillEnstLabel.text = @"FILL ENERGY";
    enstHintLabel.text = @"Hint: Energy refills over time.";
  } else {
    enstImageView.highlighted = YES;
    enstGoldCostLabel.text = [NSString stringWithFormat:@"%d", gl.staminaRefillCost];
    fillEnstLabel.text = @"FILL STAMINA";
    enstHintLabel.text = @"Hint: Stamina refills over time.";
  }
  
  [self openView:enstView];
}

- (void) displayBuyGoldView:(int)needsGold {
  GameState *gs = [GameState sharedGameState];
  
  curGoldLabel.text = [NSString stringWithFormat:@"%d", gs.gold];
  needGoldLabel.text = [NSString stringWithFormat:@"%d", needsGold];
  
  [self openView:goldView];
}

- (void) displayEquipsView:(NSArray *)equipIds {
  if (equipIds.count == 0) {
    return;
  }
  GameState *gs = [GameState sharedGameState];
  
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, itemsScrollView.frame.size.height)];
  [self.itemsContainerView removeFromSuperview];
  self.itemsContainerView = view;
  [self.itemsScrollView addSubview:self.itemsContainerView];
  [view release];
  
  RequiresEquipView *rev;
  int totalCost;
  
  for (int i = 0; i < equipIds.count; i++) {
    int equipId = [[equipIds objectAtIndex:i] intValue];
    rev = [[RequiresEquipView alloc] initWithEquipId:equipId];
    
    CGRect r = rev.frame;
    r.origin.x = i*(r.size.width+EQUIPS_VIEW_SPACING);
    r.origin.y = itemsContainerView.frame.size.height/2-r.size.height/2;
    rev.frame = r;
    
    [self.itemsContainerView addSubview:rev];
    
    FullEquipProto *fep = [gs equipWithId:equipId];
    totalCost = fep.coinPrice;
  }
  CGRect r = self.itemsContainerView.frame;
  r.size.width = CGRectGetMaxX(rev.frame);
  self.itemsContainerView.frame = r;
  
  if (itemsContainerView.frame.size.width > itemsScrollView.frame.size.width) {
    self.itemsScrollView.contentSize = CGSizeMake(itemsContainerView.frame.size.width, itemsScrollView.frame.size.height);
  } else {
    CGRect r = self.itemsContainerView.frame;
    r.origin.x = itemsScrollView.frame.size.width/2-itemsContainerView.frame.size.width/2;
    self.itemsContainerView.frame = r;
    
    self.itemsScrollView.contentSize = CGSizeMake(itemsScrollView.frame.size.width, itemsScrollView.frame.size.height);
  }
  
  NSString *string = [Globals commafyNumber:totalCost];
  itemsSilverLabel.text = string;
  CGSize expectedLabelSize = [string sizeWithFont:itemsSilverLabel.font];
  r = itemsCostView.frame;
  r.size.width = itemsSilverLabel.frame.origin.x+expectedLabelSize.width;
  itemsCostView.frame = r;
  
  NSLog(@"%@", [NSValue valueWithCGRect:itemsScrollView.frame]);
  NSLog(@"%@", [NSValue valueWithCGRect:itemsContainerView.frame]);
  itemsCostView.center = CGPointMake(itemsView.frame.size.width/2, itemsCostView.center.y);
  
  [self openView:itemsView];
}

- (void) openView:(UIView *)view {
  [self.view bringSubviewToFront:view];
  [RefillMenuController displayView];
  
  view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
  view.hidden = NO;
  
  [UIView animateWithDuration:POPUP_ANIMATION_DURATION animations:^{
    view.transform = CGAffineTransformMakeScale(1, 1);
  }];
}

- (void) closeView:(UIView *)view {
  [UIView animateWithDuration:POPUP_ANIMATION_DURATION animations:^{
    view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
  } completion:^(BOOL finished) {
    view.hidden = YES;
    if (goldView.hidden && enstView.hidden && itemsView.hidden) {
      [RefillMenuController removeView];
    }
  }];
}

- (IBAction) refillGoldClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int goldCost = _isEnergy ? gl.energyRefillCost : gl.staminaRefillCost;
  
  if (goldCost > gs.gold) {
    [self displayBuyGoldView:goldCost];
  } else {
    if (_isEnergy) {
      [[OutgoingEventController sharedOutgoingEventController] refillEnergy];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] refillStamina];
    }
    
    [self closeView:enstView];
  }
}

- (IBAction) getMoreGoldClicked:(id)sender {
  [self closeView:goldView];
  [GoldShoppeViewController displayView]; 
}

- (IBAction) closeClicked:(id)sender {
  int tag = [(UIView *)sender tag];
  
  UIView *view;
  if (tag == 1) {
    view = goldView;
  } else if (tag == 2) {
    view = enstView;
  } else if (tag == 3) {
    view = itemsView;
  }
  [self closeView:view];
}

@end
