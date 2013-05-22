//
//  PAStatsTracker.h
//  The Pixel Addicts
//
//  Created by Ryan Bertrand on 4/17/13.
//
//

#import <Foundation/Foundation.h>

/*!
 @class PAStatsTracker
 
 @abstract
 The `PAStatsTracker` class is used to track when a user launches the app for the first time, logins, makes an in-app purchase.
 
 @discussion
 PAStatsTracker should be used in the following senarios. 
    1. When the user first launches the app(creating a new account).
    2. When the user launches the app anytime after the intial first launch.
    3. On every in-app purchase once it has been verified by Apple's servers.
 
 
 Device Identifiers used by our Stats Tracker to track Retention, ARPu, DAU, etc.
 
 - OpenUDID
    - https://github.com/ylechelle/OpenUDID
 -MAC Address
    - http://stackoverflow.com/questions/677530/how-can-i-programmatically-get-the-mac-address-of-an-iphone
 - Apple IFA
    - Available iOS 6 and later
    - WARNING: This class is not available prior to iOS6. Please make sure to only call this method on iOS 6 and later devices)
    - http://developer.apple.com/library/ios/#documentation/AdSupport/Reference/ASIdentifierManager_Ref/ASIdentifierManager.html
 - ODIN
    - https://github.com/beniciojunior/ODIN-IOS
 
 */

@interface PAStatsTracker : NSObject

/*!
 @method
 
 @abstract
 Notifies our server asynchronously of the new user.
 
 @param openUDID    The user's OpenUDID (Required)
 @param macAddress  The user's MAC Address (Optional but advised)
 @param ifa         The user's Apple IFA (Optional but advised)
 @param odin        The user's ODIN (Optional but advised)
 
 
 @discussion
 It is required that any first app launch (user creation) must call this method.  Please do not call this method more than once.  It should only be called 1 time per install.
 */

+(void)createUserWithOpenUDID:(NSString *)openUDID macAddress:(NSString *)macAddress appleIFA:(NSString *)ifa odin:(NSString *)odin;


/*!
 @method
 
 @abstract
 Notifies our server asynchronously of the user's launch of the app.
 
 @param openUDID    The user's OpenUDID (Required)
 @param macAddress  The user's MAC Address (Optional but advised)
 @param ifa         The user's Apple IFA (Optional but advised)
 @param odin        The user's ODIN (Optional but advised)
 
 
 @discussion
 It is required that any app launches after the user's first app launch call this method.  This should be called anytime the user launches the app.  This method should be called in the following delegate callbacks in your AppDelegate.  Failure to do so in both methods will result in significantly erroneous stats.
        1. application:didFinishLaunchingWithOptions:
        2. applicationWillEnterForeground:
 */
+(void)loginUserWithOpenUDID:(NSString *)openUDID macAddress:(NSString *)mac appleIFA:(NSString *)ifa odin:(NSString *)odin;

/*!
 @method
 
 @abstract
 Notifies our server asynchronously of the user's purchase of a verified in-app purchase.
 
 @param openUDID    The user's OpenUDID (Required)
 @param macAddress  The user's MAC Address (Optional but advised)
 @param ifa         The user's Apple IFA (Optional but advised)
 @param odin        The user's ODIN (Optional but advised)
 @param price       The GROSS price in USD of the in-app purchase
 
 
 @discussion
 It is required that any in-app purchase notify our servers once the in-app purchase receipt has been verified by Apple's servers. Failure to verify in-app purchase receipts will result in significantly erroneous stats.
 The Price should be the total price the user paid NOT your cut.  For example, if the user bought the $99.99 pack of gold, pass a NSNumber object with 99.99
 */
+(void)purchaseInAppWithOpenUDID:(NSString *)openUDID macAddress:(NSString *)mac appleIFA:(NSString *)ifa odin:(NSString *)odin price:(NSNumber *)price;

@end
