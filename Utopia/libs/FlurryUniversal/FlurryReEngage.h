//
//  FlurryReEngage.h
//  FlurryAnalytics
//
//  Created by Akshay Bhandary on 7/18/11.
//  Copyright 2011 Flurry Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FlurryReEngage : NSObject {
    
}

/*
 enable re-engagement ads
 */
+ (void)setReEngagementEnabled:(BOOL)value;


/*
 returns whether there is an app ad available to show
 */
+ (BOOL) reAdIsAvailable:(NSString *)hook;

/*
 refer to FlurryAdDelegate.h for delegate details
 */
+ (void)setReengagementDelegate:(id)delegate;

/* open the fullscreen advertiser incentivized takeover window
 * 
 * @param hook - use a unique hook name
 * @param orientation - controls the takeover orientation. 
 *   The values are @"portrait", @"portraitUpsideDown", @"landscapeRight", and 
 *   @"landscapeLeft". You may pass in nil to let Flurry position the Takeover based
 *   on the current orientation of the device.
 * @param rewardImage - is a transparency enabled png image with dimension of 
 *   137x108 used for the user reward icon image. The default setting is nil.
 * @param rewardQuantity - controls the quantity of the reward offered for apps participating 
 *   in Reengagment Rewards. Pass in nil if there is no reward.
 * @param rewardUnits - controls the units of the reward offered for apps participating 
 *   in Reengagment Rewards. Pass in nil if there is no reward.
 * @param userCookies controls the reward amount, currency, and other incentive 
 *   information for apps participating in Reengagement Rewards. Pass in nil
 *   if you there are no userCookies
 */
+ (void)openTakeover: (NSString *)hook 
         orientation: (NSString *)orientation
         rewardImage: (UIImage *)rewardImage
      rewardQuantity: (NSNumber*) rewardQuantity
         rewardUnits: (NSString *) rewardUnits
         userCookies:(NSDictionary*)userCookies;


/* get re-engagement banner 
 *
 * @param xLoc - x location of the banner
 * @param yLoc - y location of the banner
 * @param bannerIsAtTop - This boolean must correctly reflect the position of
 *   the collapsed banner within the overall screen space and not just the
 *   parent view. It affects the banner expand behavior and expand/collapse 
 *   arrow images for the banner.
 * @param view - parent view (pass in self.view)
 * @param attachToView - controls whether the banner is automatically placed on 
 *   the parent view. 
 * @param orientation - controls the length of the banner. The values are 
 *   @"portrait" and @"landscape". @"portrait" sets the banner dimension at 
 *   728x90 in iPad and 320x48 in iPhone. @"landscape" sets the banner dimension 
 *   at 960x90 in iPad and 480x48 in iPhone. You may pass in nil to let Flurry 
 *   set the Banner size based on the current orientation of the device. In this
 *   case the banner will be resized and repositioned appropriately when the 
 *   device orientation is changed. The default setting is nil
 * @param autoRefresh controls whether the banner will automatically update 
 *   itself with different ads cached on the device. The default setting is YES
 * @param rewardQuantity - controls the quantity of the reward offered for apps participating 
 *   in Reengagment Rewards. The default setting is nil
 * @param rewardUnits - controls the units of the reward offered for apps participating 
 *   in Reengagment Rewards. The default setting is nil
 * @param userCookies controls the reward amount, currency, and other incentive 
 *   information for apps participating in Reengagement Rewards. The default setting is nil
 */
+ (UIView *)getHook:(NSString *)hook 
               xLoc:(int)x 
               yLoc:(int)y 
      bannerIsAtTop:(BOOL) bannerIsAtTop
               view:(UIView *)view 
       attachToView:(BOOL)attachToView 
        orientation:(NSString *)orientation 
        autoRefresh:(BOOL)refresh 
     rewardQuantity: (NSNumber*) rewardQuantity
        rewardUnits: (NSString *) rewardUnits
        userCookies:(NSDictionary*)userCookies;

/* get re-engagement banner (shorter version)
 *
 * @param xLoc - x location of the banner
 * @param yLoc - y location of the banner
 * @param bannerIsAtTop - This boolean must correctly reflect the position of
 *   the collapsed banner within the overall screen space and not just the
 *   parent view. It affects the banner expand behavior and expand/collapse 
 *   arrow images for the banner.
 * @param view - parent view (pass in self.view)
 */
+ (UIView *)getHook:(NSString *)hook 
               xLoc:(int)x 
               yLoc:(int)y 
      bannerIsAtTop:(BOOL) bannerIsAtTop
               view:(UIView *)view;


+ (int) getOfferCount: (NSString *)hook;


// update re-engage banner
+ (void)updateHook:(UIView *)banner;

// remove banner
+ (void)removeHook:(UIView *)banner;

@end
