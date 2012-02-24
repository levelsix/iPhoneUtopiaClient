//
//  OutgoingEventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "UserData.h"

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
- (void) equipPostToMarketplace:(int)equipId wood:(int)wood silver:(int)silver gold:(int)gold;
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

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (void) sellNormStruct:(UserStruct *)userStruct;
- (void) instaBuild:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct;
- (void) normStructWaitComplete:(UserStruct *)userStruct;
- (void) upgradeNormStruct:(UserStruct *)userStruct;


- (void) retrieveAllStaticData;
- (void) retrieveStructStore;
- (void) retrieveEquipStore;

- (void) loadPlayerCity:(int)userId;

@end
