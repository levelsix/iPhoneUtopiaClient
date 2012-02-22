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

#define ROW_HEIGHT 215

@implementation CarpenterListing

@synthesize titleLabel, priceLabel, priceView, incomeLabel, buildingIcon;
@synthesize lockIcon, lockedPriceLabel, lockedCollectsLabel, lockedIncomeLabel;
@synthesize darkOverlay;
@synthesize state = _state;

- (void) awakeFromNib {
  buildingIcon.image = [UIImage imageNamed:@"academy.png"];
  self.state = kAvailable;
}

- (UIImage*) maskImage:(UIImage *)image {
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  UIImage *maskImage = [UIImage imageNamed:@"mask.png"];
  CGImageRef maskImageRef = [maskImage CGImage];
  
  // create a bitmap graphics context the size of the image
  CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
  CGContextSetRGBFillColor(mainViewContentContext, 0.f, 0.f, 0.f, 0.3f);
  if (mainViewContentContext==NULL)
    return NULL;
  
  CGFloat ratio = 0;
  ratio = maskImage.size.width/ image.size.width;
  
  if (ratio * image.size.height < maskImage.size.height) {
    ratio = maskImage.size.height/ image.size.height;
  }
  
  CGRect rect1  = {{0, 0}, {maskImage.size.width, maskImage.size.height}};
  CGRect rect2  = {{-((image.size.width*ratio)-maskImage.size.width)/2 , -((image.size.height*ratio)-maskImage.size.height)/2}, {image.size.width*ratio, image.size.height*ratio}};
  CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
  CGContextDrawImage(mainViewContentContext, rect2, image.CGImage);
  
  // Create CGImageRef of the main view bitmap content, and then
  // release that bitmap context
  CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
  CGContextRelease(mainViewContentContext);
  UIImage *theImage = [UIImage imageWithCGImage:newImage];
  CGImageRelease(newImage);
  
  // return the image
  return theImage;
}

- (void) setState:(ListingState)state {
  if (state != _state) {
    _state = state;
    switch (state) {
      case kAvailable:
        priceView.hidden = NO;
        incomeLabel.hidden = NO;
        lockIcon.hidden = YES;
        lockedPriceLabel.hidden = YES;
        lockedCollectsLabel.hidden = YES;
        lockedIncomeLabel.hidden = YES;
        darkOverlay.hidden = YES;
        break;
        
      case kLocked:
        priceView.hidden = YES;
        incomeLabel.hidden = YES;
        lockIcon.hidden = NO;
        lockedPriceLabel.hidden = NO;
        lockedCollectsLabel.hidden = NO;
        lockedIncomeLabel.hidden = NO;
        darkOverlay.hidden = NO;
        buildingIcon.image = [self maskImage:buildingIcon.image];
        break;
        
        
      default:
        break;
    }
  }
}

@end

@implementation CarpenterListingContainer

@synthesize carpListing;

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"CarpenterListing" owner:self options:nil];
  [self addSubview:self.carpListing];
  [self setBackgroundColor:[UIColor clearColor]];
  if (arc4random()%2 == 1) {
    self.carpListing.state = kLocked;
  }
}

@end

@implementation CarpenterRow

@end

@implementation CarpenterMenuController

@synthesize carpRow, carpTable;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(CarpenterMenuController);

- (void) viewDidLoad {
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"CarpenterRow";
  
  CarpenterRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
      [[NSBundle mainBundle] loadNibNamed:@"CarpenterRow" owner:self options:nil];
      cell = self.carpRow;
  }
  return cell;
}

@end
