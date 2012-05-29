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
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "GoldShoppeViewController.h"

@implementation IAPHelper

@synthesize products = _products;
@synthesize request = _request;

SYNTHESIZE_SINGLETON_FOR_CLASS(IAPHelper);

- (id)init {
  if ((self = [super init])) {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  return self;
}

- (void)requestProducts {
  NSSet *productIds = [NSSet setWithArray:[[[Globals sharedGlobals] productIdentifiers] allKeys]];
  
  if (productIds.count > 0) {
    self.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:productIds] autorelease];
    _request.delegate = self;
    [_request start];
  }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  LNLog(@"Received products results for %d products...", response.products.count);
  
  self.products = response.products;
  self.request = nil;
  
  LNLog(@"Invalid product ids: %@", response.invalidProductIdentifiers);
  
//  if (response.products.count == 0) {
//    [self requestProducts];
//  }
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

- (NSString *) priceForProduct:(SKProduct *)product {
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [numberFormatter setLocale:product.priceLocale];
  NSString *str = [numberFormatter stringFromNumber:product.price];
  [numberFormatter release];
  return str;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  LNLog(@"completeTransaction...");
  
  NSString *encodedReceipt = [self base64forData:transaction.transactionReceipt];
  [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:encodedReceipt];
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  
  NSNumber *goldAmt = [[[Globals sharedGlobals] productIdentifiers] objectForKey:transaction.payment.productIdentifier];
  GameState *gs = [GameState sharedGameState];
  gs.gold += goldAmt.intValue;
  
  // Find the SKProduct so we can send it in to analytics
  SKProduct *product = nil;
  for (SKProduct *p in self.products) {
    if ([p.productIdentifier isEqualToString:transaction.payment.productIdentifier]) {
      product = p;
      break;
    }
  }
  float price = [[[self priceForProduct:product] substringFromIndex:1] floatValue];
  [Analytics purchasedGoldPackage:product.productIdentifier price:price goldAmount:goldAmt.intValue];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  
  if (transaction.error.code != SKErrorPaymentCancelled)
  {
    LNLog(@"Transaction error: %@", transaction.error.localizedDescription);
  } else {
    // Transaction was cancelled
    [[GoldShoppeViewController sharedGoldShoppeViewController] stopLoading];
    [Analytics cancelledGoldPackage:transaction.payment.productIdentifier];
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
  
  LNLog(@"Buying %@...", product.debugDescription);
  
  SKPayment *payment = [SKPayment paymentWithProduct:product];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
  
}

- (void)dealloc
{
  [_products release];
  _products = nil;
  [_request release];
  _request = nil;
  [super dealloc];
}

@end
