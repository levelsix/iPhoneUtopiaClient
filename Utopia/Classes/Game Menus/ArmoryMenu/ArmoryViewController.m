//
//  ArmoryViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ArmoryViewController.h"
#import "SynthesizeSingleton.h"

@implementation ArmoryItemView

@end

@implementation ArmoryViewController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ArmoryViewController);

@synthesize scrollView, itemView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"storebackbg.png"]];
  
  UINib *nib = [UINib nibWithNibName:@"ArmoryItemView" bundle:nil];
  for (int i = 0; i < 10; i++) {
    // Make a new itemView for each product
    [nib instantiateWithOwner:self options:nil];
    
    self.itemView.frame = CGRectMake(i*self.itemView.frame.size.width,63, self.itemView.frame.size.width, self.itemView.frame.size.height);
    
    [self.scrollView addSubview:self.itemView];
  }
  self.scrollView.contentSize = CGSizeMake(10*self.itemView.frame.size.width, self.itemView.frame.size.height);
}

- (IBAction)backClicked:(id)sender {
  [ArmoryViewController removeView];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated {
  [[CCDirector sharedDirector] openGLView].userInteractionEnabled = NO;
  [[CCDirector sharedDirector] pause];
  [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[CCDirector sharedDirector] openGLView].userInteractionEnabled = YES;
  [[CCDirector sharedDirector] resume];
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
