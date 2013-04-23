//
//  Nanigans.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/22/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nanigans : NSObject

+ (void) trackInstall;
+ (void) trackTutorialComplete;
+ (void) trackVisit;
+ (void) trackPurchase:(int)cents;

+ (void)trackNanigansEvent:(NSString *)uid type:(NSString *)type name:(NSString *)name;
+ (void)trackNanigansEvent:(NSString *)uid type:(NSString *)type name:(NSString *)name value:(NSString *)value;
+ (void)trackNanigansEvent:(NSString *)uid type:(NSString *)type name:(NSString *)name extraParams:(NSDictionary *)extraParams;

@end
