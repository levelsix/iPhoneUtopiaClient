//
//  LevelUpViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LevelUpViewController.h"
#import "Globals.h"
#import "ProfileViewController.h"

@implementation LevelUpViewController

@synthesize congratsLabel;
@synthesize levelUpResponse, itemView;
@synthesize itemLabel, itemIcon;

- (id) initWithLevelUpResponse:(LevelUpResponseProto *)lurp {
  if ((self = [super init])) {
    self.levelUpResponse = lurp;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  congratsLabel.text = [NSString stringWithFormat:@"You have reached level %d!", levelUpResponse.newLevel];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIImageView *headerView = [[[UIImageView alloc] initWithImage:[Globals imageNamed:@"unlockedheader.png"]] autorelease];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 400, headerView.frame.size.height)];
  label.textColor = [UIColor colorWithRed:236/255.f green:230/255.f blue:195/255.f alpha:1.f];
  label.font = [UIFont fontWithName:@"Trajan Pro" size:12];
  label.backgroundColor = [UIColor clearColor];
  [headerView addSubview:label];
  
  if (section == 0) {
    label.text = @"New Cities";
  } else if (section == 1) {
    label.text = @"New Epic & Legendary Equipment";
  } else if (section == 2) {
    label.text = @"New Buildings";
  }
  
  return headerView;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];;
  if (indexPath.section == 0) {
    if (levelUpResponse.citiesNewlyAvailableToUserList.count != 0) {
      FullCityProto *fcp = [levelUpResponse.citiesNewlyAvailableToUserList objectAtIndex:indexPath.row];
      cell.textLabel.text = @"New!";
      cell.textLabel.font = [UIFont fontWithName:@"Requiem Text-HTF-SmallCaps" size:17];
      cell.textLabel.textColor = [UIColor redColor];
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55,0,200,tableView.rowHeight)];
      label.text = fcp.name;
      label.textColor = [UIColor whiteColor];
      label.font = [UIFont fontWithName:@"Requiem Text-HTF-SmallCaps" size:17];
      label.backgroundColor = [UIColor clearColor];
      [cell.contentView addSubview:label];
    } else {
      cell.textLabel.text = @"No New Cities";
      cell.textLabel.font = [UIFont fontWithName:@"Requiem Text-HTF-SmallCaps" size:17];
      cell.textLabel.textColor = [UIColor whiteColor];
    }
  } else if (indexPath.section == 1) {
    if (levelUpResponse.newlyEquippableEpicsAndLegendariesList.count != 0) {
      FullEquipProto *fep = [levelUpResponse.newlyEquippableEpicsAndLegendariesList objectAtIndex:indexPath.row];
      [[NSBundle mainBundle] loadNibNamed:@"LevelUpItemView" owner:self options:nil];
      self.itemIcon.image = [Globals imageForEquip:fep.equipId];
      self.itemLabel.textColor = [Globals colorForRarity:fep.rarity];
      self.itemLabel.text = fep.name;
      self.itemView.center = CGPointMake(tableView.frame.size.width/2, tableView.rowHeight/2);
      [cell.contentView addSubview:self.itemView];
      self.itemIcon = nil;
      self.itemLabel = nil;
      self.itemView = nil;
    } else {
      cell.textLabel.text = @"No New Equipment";
      cell.textLabel.font = [UIFont fontWithName:@"Requiem Text-HTF-SmallCaps" size:17];
      cell.textLabel.textColor = [UIColor whiteColor];
    }
  } else if (indexPath.section == 2) {
    if (levelUpResponse.newlyAvailableStructsList.count != 0) {
      FullStructureProto *fsp = [levelUpResponse.newlyAvailableStructsList objectAtIndex:indexPath.row];
      [[NSBundle mainBundle] loadNibNamed:@"LevelUpItemView" owner:self options:nil];
      self.itemIcon.image = [Globals imageForStruct:fsp.structId];
      self.itemLabel.text = fsp.name;
      [cell.contentView addSubview:self.itemView];
      self.itemIcon = nil;
      self.itemLabel = nil;
      self.itemView = nil;
    } else {
      cell.textLabel.text = @"No New Buildings";
      cell.textLabel.font = [UIFont fontWithName:@"Requiem Text-HTF-SmallCaps" size:17];
      cell.textLabel.textColor = [UIColor whiteColor];
    }
  }
  
  return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 21.f;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return MAX(1, levelUpResponse.citiesNewlyAvailableToUserList.count);
  } else if (section == 1) {
    return MAX(1, levelUpResponse.newlyEquippableEpicsAndLegendariesList.count);
  } else if (section == 2) {
    return MAX(1, levelUpResponse.newlyAvailableStructsList.count);
  }
  return 0;
}

- (IBAction)okayClicked:(id)sender {
  [self.view removeFromSuperview];
  [[ProfileViewController sharedProfileViewController] loadMyProfile];
  [ProfileViewController displayView];
  [[ProfileViewController sharedProfileViewController] openSkillsMenu];
  [self release];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.levelUpResponse = nil;
  self.congratsLabel = nil;
  self.itemView = nil;
  self.itemLabel = nil;
  self.itemIcon = nil;
}

@end
