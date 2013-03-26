//
//  FacebookDelegate.h
//  Utopia
//
//  Created by Kevin Calloway on 5/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

#define PREV_FACEBOOK_FRIEND_REQ @"PREV_FACEBOOK_FRIEND_REQ"

@protocol FacebookGlobalDelegate <NSObject, FBSessionDelegate>
  -(void) attemptSignOn;
  -(void) requestFriendToJoin;
  -(BOOL)application:(UIApplication *)application 
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation;
- (void) postToFacebookWithString:(NSString *)str;
@end

@interface FacebookDelegate : NSObject <FacebookGlobalDelegate, FBDialogDelegate> {
  Facebook *facebook;
}

-(void) attemptSignOn;

#pragma mark FBSessionDelegate
/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled;

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt;

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout;

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated;

#pragma mark Create/Destroy
+(id<FacebookGlobalDelegate>) createFacebookDelegate;

#pragma mark properties
@property (nonatomic, retain) Facebook *facebook;
@end
