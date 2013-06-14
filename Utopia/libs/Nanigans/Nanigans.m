//
//  Nanigans.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/22/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Nanigans.h"
#import "AppDelegate.h"
#import "GameState.h"
#import <AdSupport/AdSupport.h>

#define NANIGANS_VERSION_KEY @"NanigansVersionKey"

#ifdef DEBUG
#define NanLog(str, ...) NSLog(str, ##__VA_ARGS__)
#else
#define NanLog(str, ...)
#endif

static NSString* NAN_FB_APP_ID = FACEBOOK_APP_ID;

@implementation Nanigans

+ (NSString *) userId {
  GameState *gs = [GameState sharedGameState];
  return gs.kabamNaid;
}

+ (void) trackInstall {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  float versionNum = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
  
  if (![userDefaults valueForKey:NANIGANS_VERSION_KEY] || [userDefaults floatForKey:NANIGANS_VERSION_KEY] != versionNum )
  {
    [self trackNanigansEvent:[self userId] type:@"install" name:@"normal"];
    
    // Update version number to NSUserDefaults for other versions:
    [userDefaults setFloat:versionNum forKey:NANIGANS_VERSION_KEY];
  }
}

+ (void) trackTutorialComplete {
  [self trackNanigansEvent:[self userId] type:@"user" name:@"tutorial"];
}

+ (void) trackVisit {
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
  if (!ad.hasTrackedVisit) {
    ad.hasTrackedVisit = YES;
    [self trackNanigansEvent:[self userId] type:@"visit" name:@"dau"];
    NSLog(@"Tracked Visit");
  } else {
    
    NSLog(@"Did NotTracked Visit");
  }
}

+ (void) trackPurchase:(int)cents {
  [self trackNanigansEvent:[self userId] type:@"purchase" name:@"main" extraParams:@{@"nan_pid":[NSString stringWithFormat:@"%d", cents]}];
}

+ (void)trackNanigansEvent:(NSString *)uid type:(NSString *)type name:(NSString *)name
{
  [self trackNanigansEvent:uid type:type name:name extraParams:nil];
}

+ (void)trackNanigansEvent:(NSString *)uid type:(NSString *)type name:(NSString *)name value:(NSString *)value
{
  [self trackNanigansEvent:uid type:type name:name extraParams:@{@"value":value}];
}

+ (void)trackNanigansEvent:(NSString *)uid type:(NSString *)type name:(NSString *)name extraParams:(NSDictionary *)extraParams
{
#ifdef LEGENDS_OF_CHAOS
  return;
#endif
  
  if (type == nil || [type length] == 0) {NanLog(@"TRACK EVENT ERROR: tyoe required"); return;}
  if (name == nil || [name length] == 0) {NanLog(@"TRACK EVENT ERROR: name required"); return;}
  
  NSString* nanApiVersion = @"1.0";
  
  NSString *attributionID = nil;
  if ([type caseInsensitiveCompare:@"install"] == NSOrderedSame || [type caseInsensitiveCompare:@"visit"] == NSOrderedSame) {
    if (NSClassFromString(@"UIPasteboard") != nil) {
      UIPasteboard *pb = [UIPasteboard pasteboardWithName:@"fb_app_attribution"
                                                   create:NO];
      if (pb) {
        attributionID = pb.string;
        if (attributionID == nil || [attributionID length] == 0) {
          NanLog(@"TRACK EVENT: attribution is null/empty?!");
        }
      } else {
        NanLog(@"TRACK EVENT ERROR: attribution id could not be found?!");
      }
    } else {
      NanLog(@"TRACK EVENT ERROR: can not load attribution id on this version of iOS");
    }
  }
  
  //fetch nan UUID
  NSString *nanHash = [[NSUserDefaults standardUserDefaults] objectForKey:@"nanHash"];
  if (!nanHash) {
    //generate nan UUID
    CFUUIDRef nanUuid = CFUUIDCreate(NULL);
    NSString *tempNanUuidStr = (NSString *)CFUUIDCreateString(NULL, nanUuid);
    CFRelease(nanUuid);
    nanHash = [[tempNanUuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    [tempNanUuidStr release];
    //store nan UUID
    [[NSUserDefaults standardUserDefaults] setValue:nanHash forKey:@"nanHash"];
  }
  
  NSString *advertisingId = nil;
  if (NSClassFromString(@"ASIdentifierManager") != nil) {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
      advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
  }
  if (advertisingId == nil || [advertisingId length] == 0) {
    NanLog(@"TRACK EVENT: can not obtain advertising identifier");
  }
  
  //generate unquie event ID
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  NSString *tempUuidStr = (NSString *)CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);
  NSString *uuidStr = [[tempUuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
  [tempUuidStr release];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  if (!(uid == nil || [uid length] == 0)) {
    [params setObject:uid forKey:@"user_id"];
  }
  [params setObject:@"iOS" forKey:@"nan_dt"];
  [params setObject:[UIDevice currentDevice].systemVersion forKey:@"nan_os"];
  [params setObject:[[NSTimeZone localTimeZone] name] forKey:@"nan_tz"];
  [params setObject:type forKey:@"type"];
  [params setObject:name forKey:@"name"];
  [params setObject:nanHash forKey:@"nan_hash"];
  if (advertisingId != nil) {
    [params setObject:advertisingId forKey:@"advertising_id"];
  }
  [params setObject:NAN_FB_APP_ID forKey:@"fb_app_id"];
  if (!(attributionID == nil || [attributionID length] == 0)) {
    [params setObject:attributionID forKey:@"fb_attr_id"];
  }
  [params setObject:uuidStr forKey:@"unique"];
  [params setObject:nanApiVersion forKey:@"avers"];
  [params addEntriesFromDictionary:extraParams];
  
  NSMutableString *getString = [[NSMutableString alloc] initWithString:@""];
  for (NSString* key in params) {
    NSArray *currentValues;
    NSString *currentKey;
    
    id obj = [params objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
      currentValues = obj;
      currentKey = [NSString stringWithFormat:@"%@[]",key];
    } else if ([obj isKindOfClass:[NSString class]]) {
      currentValues = @[obj];
      currentKey = key;
    } else {
      continue;
    }
    
    for (NSString* currentValue in currentValues) {
      NSString* currentValueEnc = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      kCFAllocatorDefault,
                                                                                      (CFStringRef)currentValue,
                                                                                      NULL,
                                                                                      (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                                                                      kCFStringEncodingUTF8);
      
      [getString appendString:([getString length] > 0 ? @"&" : @"?")];
      [getString appendString:currentKey];
      [getString appendString:@"="];
      [getString appendString:currentValueEnc];
      [currentValueEnc release];
    }
    
  }
  NSString *url = [NSString stringWithFormat:@"https://api.nanigans.com/mobile.php%@", getString];
  NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:60.0];
  
  dispatch_async(dispatch_queue_create("com.nanigans.tracking", 0), ^{
    NSURLResponse* response = nil;
    NSError *error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    if (data) {
      NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
      NanLog(@"TRACK EVENT REQUEST %@, RESPONSE: %@", url, receivedString);
      [receivedString release];
    } else {
      NanLog(@"TRACK EVENT REQUEST %@, ERROR: %@", url, [error localizedDescription]);
    }
  });
  
  [getString release];
}

@end
