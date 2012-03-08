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
#import <CoreLocation/CoreLocation.h>

@interface OutgoingEventController : NSObject

+ (OutgoingEventController *) sharedOutgoingEventController;

- (void) vaultWithdrawal:(int)amount;
- (void) vaultDeposit:(int)amount;

- (BOOL) taskAction:(int)taskId;

- (void) battle:(int)defender;
- (int) buyEquip:(int)equipId;
- (int) sellEquip:(int)equipId;
- (BOOL) wearEquip:(int)equipId;
- (void) generateAttackList:(int)numEnemies bounds:(CGRect)bounds;

- (void) startup;
- (void) inAppPurchase: (NSString *) receipt;

- (void) retrieveMostRecentPosts;
- (void) retrieveMoreMarketplacePosts;
- (void) retrieveMostRecentPostsFromSender;
- (void) retrieveMoreMarketplacePostsFromSender;
- (void) equipPostToMarketplace:(int)equipId silver:(int)silver gold:(int)gold;
- (void) retractMarketplacePost: (int)postId;
- (void) purchaseFromMarketplace: (int)postId;
- (void) redeemMarketplaceEarnings;

- (void) addAttackSkillPoint;
- (void) addDefenseSkillPoint;
- (void) addEnergySkillPoint;
- (void) addStaminaSkillPoint;
- (void) addHealthSkillPoint;

- (void) refillEnergyWaitComplete;
- (void) refillStaminaWaitComplete;
- (void) refillEnergyWithDiamonds;
- (void) refillStaminaWithDiamonds;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (void) rotateNormStruct:(UserStruct *)userStruct to:(StructOrientation)orientation;
- (void) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) sellNormStruct:(UserStruct *)userStruct;
- (void) instaBuild:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct;
- (void) normStructWaitComplete:(UserStruct *)userStruct;
- (void) upgradeNormStruct:(UserStruct *)userStruct;

- (void) retrieveAllStaticData;
- (void) retrieveStructStore;
- (void) retrieveEquipStore;

- (void) loadPlayerCity:(int)userId;
- (void) loadNeutralCity:(FullCityProto *)city;

- (void) levelUp;

- (void) changeUserLocationWithCoordinate:(CLLocationCoordinate2D)coord;

- (void) acceptQuest:(int)questId;
- (void) redeemQuest:(int)questId;
- (void) retrieveQuestLog;

@end
