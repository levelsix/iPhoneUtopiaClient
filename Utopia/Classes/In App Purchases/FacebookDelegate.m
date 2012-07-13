//
//  FacebookDelegate.m
//  Utopia
//
//  Created by Kevin Calloway on 5/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FacebookDelegate.h"
#import "InAppPurchaseData.h"

#define FACEBOOK_APP_ID  @"303653176390503" 
#define FACEBOOK_REQ_MSG @"Hey, check out this cool new iPhone game."

@implementation FacebookDelegate
@synthesize facebook;

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  return [facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [facebook handleOpenURL:url]; 
}

#pragma mark FacebookGlobalDelegate
-(void) requestFriendToJoin
{
  NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 FACEBOOK_REQ_MSG,  @"message",
                                 nil];
  
  [facebook dialog:@"apprequests"
         andParams:params
       andDelegate:self];
}

-(BOOL) hasCredentials
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return ([defaults objectForKey:@"FBAccessTokenKey"] 
          && [defaults objectForKey:@"FBExpirationDateKey"]);
}
#import "OperationWaitCounter.h"
-(void) setupAuthentication
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"] 
      && [defaults objectForKey:@"FBExpirationDateKey"]) {
    facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
  }
}

-(void) attemptSignOn
{
  [self setupAuthentication];
  
  if (![facebook isSessionValid]) {
    [facebook authorize:nil];
  }
}

#pragma mark FBDialogDelegate
- (void) dialogCompleteWithUrl:(NSURL*)url
{
  // If we successfully made the friend request.
  if ([url.absoluteString rangeOfString:@"success?request="].location != NSNotFound) {
    id<OperationWaitCounter> waitCounter = [OperationWaitCounter 
                                            createForKey:PREV_FACEBOOK_FRIEND_REQ
                                            andTimeInterval:SECONDS_PER_WEEK];
    // We only want to increase the user's waitCounter if they recieved gold
    if ([waitCounter canPerfomOperation]) {
      [waitCounter performedOperation];
      [waitCounter serialize];      
    }
    [InAppPurchaseData postAdTakeoverResignedNotificationForSender:self];
  } else {

  }
}

#pragma mark FBSessionDelegate
/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
  [defaults synchronize];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{

}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
  [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
  [defaults synchronize];  
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
  
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
  
}

#pragma mark Create/Destroy

+(id<FacebookGlobalDelegate>) createFacebookDelegate
{
  FacebookDelegate *delegate = [[FacebookDelegate alloc] init];
  Facebook *facebk = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID
                                         andDelegate:delegate];
  delegate.facebook = facebk;

  if ([delegate hasCredentials]) {
    [delegate attemptSignOn];
  }
  
  return [delegate autorelease];
}

-(void) dealloc
{
  [facebook release];
  [super dealloc];
}
@end
