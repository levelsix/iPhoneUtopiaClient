//
//  TapJoySponsoredOffer.m
//  Utopia
//
//  Created by Kevin Calloway on 5/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TapJoySponsoredOffer.h"
#import "SimpleAudioEngine.h"
#import "TapjoyConnect.h"
#import "GameViewController.h"

@implementation TapJoySponsoredOffer
@dynamic primaryTitle;
@dynamic secondaryTitle;
@dynamic price;
@dynamic rewardPic;

-(UIImage *) rewardPic
{
  return [Globals imageNamed:@"stack.png"];
}

#pragma InAppPurchaseData
- (BOOL) purchaseAvailable
{
    return YES;
}

-(void) makePurchaseWithViewController:(UIViewController *)controller
{
  if ([self purchaseAvailable]) {
    [TapjoyConnect showOffersWithViewController:[GameViewController
                                                 sharedGameViewController]];
  }
}

-(NSString *) primaryTitle
{
  return primaryTitle;
}

-(NSString *) price
{  
  return price;
}

-(NSString *) secondaryTitle
{  
  if (![self purchaseAvailable]) {
    return NO_CLIPS;
  }

  return secondaryTitle;
}

#pragma mark  Create/Destroy
-(id) initWithPrimaryTitle:(NSString *)primary 
         andSecondaryTitle:(NSString *)secondary
                  andPrice:(NSString *)curPrice
                 andLocale:(NSLocale *) locale
{
  self = [super init];
  if (self) {
    primaryTitle   = primary;
    secondaryTitle = secondary;
    price          = curPrice;
    priceLocale    = locale;
    
    [primaryTitle   retain];
    [secondaryTitle retain];
    [price          retain];
    [priceLocale    retain];
  }
  return self;
}

-(void)dealloc
{
  [primaryTitle   release];
  [secondaryTitle release];
  [price          release];
  [priceLocale    release];
  
  [super dealloc];
}

+(id<InAppPurchaseData>) create
{
  TapJoySponsoredOffer *offer = [[TapJoySponsoredOffer alloc] 
                           initWithPrimaryTitle:@"Complete Free offers"
                           andSecondaryTitle:@"??"
                           andPrice:@"" 
                           andLocale:nil];

  [offer autorelease];
  
  return offer;
}

@end
