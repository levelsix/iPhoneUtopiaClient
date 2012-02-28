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

@implementation ArmoryListing

@synthesize attackLabel, defenseLabel, titleLabel, priceLabel;
@synthesize bgdView, equipIcon, coinIcon;
@synthesize fep;

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
  } else {
    bgdView.highlighted = YES;
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
@synthesize buySellView, sellButton;
@synthesize equipsList;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveEquipStore];
  while (!(self.equipsList = [[GameState sharedGameState] armoryEquips])) {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (int)ceilf(equipsList.count/3.f);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"CarpenterRow";
  
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

- (IBAction)backClicked:(id)sender {
  [ArmoryViewController removeView];
}

@end
