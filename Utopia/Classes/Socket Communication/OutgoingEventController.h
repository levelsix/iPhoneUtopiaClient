//
//  OutgoingEventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@interface OutgoingEventController : NSObject

+ (OutgoingEventController *) sharedOutgoingEventController;

- (void) vaultWithdrawal:(int)amount;
- (void) vaultDeposit:(int)amount;

- (void) tasksForCity:(int)cityId;
- (void) taskAction:(int)taskId;

- (void) battle:(int)defender;

- (void) startup;
- (void) inAppPurchase: (NSString *) receipt;

- (void) retrieveMostRecentPosts;
- (void) retrieveMoreMarketplacePosts;
- (void) retrieveMostRecentPostsFromSender;
- (void) retrieveMoreMarketplacePostsFromSender;
- (void) coinPostToMarketplace:(int)coinPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) woodPostToMarketplace:(int)woodPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) diamondPostToMarketplace:(int)dmdPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) equipPostToMarketplace:(int)equipId wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) retractMarketplacePost: (int)postId;
- (void) purchaseFromMarketplace: (int)postId;
- (void) redeemMarketplaceEarnings;

- (void) addAttackSkillPoint;
- (void) addDefenseSkillPoint;
- (void) addEnergySkillPoint;
- (void) addStaminaSkillPoint;
- (void) addHealthSkillPoint;

- (void) refillEnergy;
- (void) refillStamina;

- (void) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y;
- (void) moveNormStruct:(int)userStructId atX:(int)x atY:(int)y;

@end
