//
//  SoundEngine.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  kNoMusic = 0,
  kHomeMapMusic,
  kMissionMapMusic,
  kBattleMusic
} BackgroundMusic;

@interface SoundEngine : NSObject {
  BackgroundMusic _curMusic;
  
  int _curChargeUp;
}

+ (SoundEngine *)sharedSoundEngine;

- (void) playHomeMapMusic;
- (void) playMissionMapMusic;
- (void) playBattleMusic;
- (void) stopBackgroundMusic;

- (void) archerAttack;
- (void) legionMageAttack;
- (void) allianceMageAttack;
- (void) warriorAttack;
- (void) archerCharge;
- (void) legionMageCharge;
- (void) allianceMageCharge;
- (void) warriorCharge;
- (void) stopCharge;
- (void) perfectAttack;
- (void) goodAttack;
- (void) greatAttack;
- (void) missAttack;
- (void) battleVictory;
- (void) battleLoss;

- (void) coinDrop;
- (void) coinPickup;
- (void) shinyItem;

- (void) closeDoor;
- (void) openDoor;

- (void) levelUp;

- (void) questComplete;
- (void) questAccepted;
- (void) questLogOpened;

- (void) armoryBuy;
- (void) armoryEnter;
- (void) armoryLeave;

- (void) marketplaceBuy;
- (void) marketplaceEnter;
- (void) marketplaceLeave;

- (void) vaultWithdraw;
- (void) vaultDeposit;
- (void) vaultEnter;
- (void) vaultLeave;

@end
