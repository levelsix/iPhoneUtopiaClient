//
//  PAStatsTracker.m
//  The Pixel Addicts
//
//  Created by Ryan Bertrand on 4/17/13.
//
//

#import "PAStatsTracker.h"

#define KPublisherTrackingURL @"http://public.pxladdicts.com/track/"

@interface PAStatsTracker ()

+(NSString *)bundleID;
+(NSURL *)urlWithAction:(NSString *)action params:(NSDictionary *)params;
+(void)sendAsynchronousRequestWithURL:(NSURL *)requestURL;

@end

@implementation PAStatsTracker

+(void)createUserWithOpenUDID:(NSString *)openUDID macAddress:(NSString *)mac appleIFA:(NSString *)ifa odin:(NSString *)odin{
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  if(openUDID){
    [params setObject:openUDID forKey:@"open_udid"];
  }
  if(mac){
    [params setObject:mac forKey:@"mac_address"];
  }
  if(ifa){
    [params setObject:ifa forKey:@"apple_ifa"];
  }
  if(odin){
    [params setObject:odin forKey:@"odin"];
  }
  
  NSURL *URL = [self urlWithAction:@"create" params:params];
  [self sendAsynchronousRequestWithURL:URL];
  [params release];
}

+(void)loginUserWithOpenUDID:(NSString *)openUDID macAddress:(NSString *)mac appleIFA:(NSString *)ifa odin:(NSString *)odin{
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  if(openUDID){
    [params setObject:openUDID forKey:@"open_udid"];
  }
  if(mac){
    [params setObject:mac forKey:@"mac_address"];
  }
  if(ifa){
    [params setObject:ifa forKey:@"apple_ifa"];
  }
  if(odin){
    [params setObject:odin forKey:@"odin"];
  }
  
  NSURL *URL = [self urlWithAction:@"login" params:params];
  [self sendAsynchronousRequestWithURL:URL];
  [params release];
}

+(void)purchaseInAppWithOpenUDID:(NSString *)openUDID macAddress:(NSString *)mac appleIFA:(NSString *)ifa odin:(NSString *)odin price:(NSNumber *)price{
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  if(openUDID){
    [params setObject:openUDID forKey:@"open_udid"];
  }
  if(mac){
    [params setObject:mac forKey:@"mac_address"];
  }
  if(ifa){
    [params setObject:ifa forKey:@"apple_ifa"];
  }
  if(odin){
    [params setObject:odin forKey:@"odin"];
  }
  if(price){
    CGFloat ourCut = [price floatValue] * 0.70f;
    [params setObject:[NSString stringWithFormat:@"%.2f", ourCut] forKey:@"amount"];
  }
  
  NSURL *URL = [self urlWithAction:@"purchaseinapp" params:params];
  [self sendAsynchronousRequestWithURL:URL];
  [params release];
}

#pragma mark - Helpers

+(NSString *)bundleID{
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  return bundleIdentifier;
}

+(NSURL *)urlWithAction:(NSString *)action params:(NSDictionary *)params{
  NSMutableString *url = [[NSMutableString alloc] init];
  [url appendString:KPublisherTrackingURL];
  [url appendString:action];
  
  for (NSString *key in [params allKeys]) {
    NSString *value = [params objectForKey:key];
    if(value){
      NSString *fullParamWithValue = [NSString stringWithFormat:@"/%@/%@", key, value];
      [url appendString:fullParamWithValue];
    }
  }
  
  NSString *bundle = [self bundleID];
  if(bundle){
    [url appendString:@"/"];
    [url appendString:@"app_bundle_id/"];
    [url appendString:bundle];
  }
  
  
  NSURL *theURL = [NSURL URLWithString:url];
  [url autorelease];
  return theURL;
}

+(void)sendAsynchronousRequestWithURL:(NSURL *)requestURL{
  return;
  NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
  
  dispatch_queue_t requestQueue = dispatch_queue_create("com.pixeladdicts.publisherstatsqueue", NULL);
  dispatch_async(requestQueue, ^{
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    if(receivedData){
      //It worked
    }
  });
  dispatch_release(requestQueue);
}

@end
