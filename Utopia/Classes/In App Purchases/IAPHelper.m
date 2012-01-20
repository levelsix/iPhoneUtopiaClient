//
//  IAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "IAPHelper.h"
#import "Protocols.pb.h"
#import "SocketCommunication.h"

@implementation IAPHelper

@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize request = _request;

static IAPHelper * _sharedHelper;

+ (IAPHelper *) sharedIAPHelper {
  
  if (_sharedHelper != nil) {
    return _sharedHelper;
  }
  _sharedHelper = [[IAPHelper alloc] init];
  return _sharedHelper;
  
}

- (id)init {
  if ((self = [super init])) {
    self.productIdentifiers = [NSSet setWithObjects:
                               @"com.lvl6.utopia.fewdiamonds",
                               @"com.lvl6.utopia.morediamonds",
                               @"com.lvl6.utopia.quitesomediamonds",
                               @"com.lvl6.utopia.rackdiamonds",
                               @"com.lvl6.utopia.shittondiamonds",
                               @"com.lvl6.utopia.toomanydiamonds",
                               nil];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  return self;
}

- (void)requestProducts {
  
  self.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers] autorelease];
  _request.delegate = self;
  [_request start];
  
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  
  NSLog(@"Received products results...");   
  self.products = response.products;
  self.request = nil;
}

- (NSString*)base64forData:(NSData*)theData {
  const uint8_t* input = (const uint8_t*)[theData bytes];
  NSInteger length = [theData length];
  
  static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  
  NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
  uint8_t* output = (uint8_t*)data.mutableBytes;
  
  NSInteger i;
  for (i=0; i < length; i += 3) {
    NSInteger value = 0;
    NSInteger j;
    for (j = i; j < (i + 3); j++) {
      value <<= 8;
      
      if (j < length) {
        value |= (0xFF & input[j]);
      }
    }
    
    NSInteger theIndex = (i / 3) * 4;
    output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
    output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
    output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
    output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
  }
  
  return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  
  NSLog(@"completeTransaction...");
  
  NSString *encodedReceipt = [self base64forData:transaction.transactionReceipt];
  [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:encodedReceipt];
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  
}



- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  
  if (transaction.error.code != SKErrorPaymentCancelled)
  {
    NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
  }
  
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction *transaction in transactions)
  {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
      default:
        break;
    }
  }
}

- (void)buyProductIdentifier:(SKProduct *)product {
  
  NSLog(@"Buying %@...", product);
  
  SKPayment *payment = [SKPayment paymentWithProduct:product];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
  
}

- (void)dealloc
{
  [_productIdentifiers release];
  _productIdentifiers = nil;
  [_products release];
  _products = nil;
  [_request release];
  _request = nil;
  [super dealloc];
}

@end
