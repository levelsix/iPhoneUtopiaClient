//
//  CritStructPopupController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CritStructPopupController.h"

@implementation CritStructPopupController

@synthesize titleLabel, descLabel, buttonLabel;

- (id) initWithCritStruct:(CritStruct *)cs {
  if ((self = [super init])) {
    _critStruct = [cs retain];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  titleLabel.text = [NSString stringWithFormat:@"The %@", _critStruct.name];
  buttonLabel.text = [NSString stringWithFormat:@"Enter %@", _critStruct.name];
  
  NSString *desc = nil;
  switch (_critStruct.type) {
    case CritStructTypeArmory:
      desc = @"The armory allows users to buy and sell equipment at set prices.";
      break;
      
    case CritStructTypeVault:
      desc = @"The vault allows users to keep their money safe from attack by other players.";
      break;
      
    case CritStructTypeMarketplace:
      desc = @"The marketplace allows users to buy and sell items within the community.";
      
    default:
      break;
  }
  descLabel.text = desc;
}

- (IBAction)okayClicked:(id)sender {
  [self.view removeFromSuperview];
  [_critStruct openMenu]; 
  [self didReceiveMemoryWarning];
  [self release];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.titleLabel = nil;
  self.descLabel = nil;
  self.buttonLabel = nil;
  [_critStruct release];
}
@end
