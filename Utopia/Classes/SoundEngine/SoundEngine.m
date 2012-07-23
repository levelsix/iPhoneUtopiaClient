//
//  SoundEngine.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "SoundEngine.h"
#import "LNSynthesizeSingleton.h"
#import "SimpleAudioEngine.h"

@implementation SoundEngine

SYNTHESIZE_SINGLETON_FOR_CLASS(SoundEngine);

- (void) playBackgroundMusic:(NSString *)music loop:(BOOL)loop {
  [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music loop:loop];
}

- (int) playEffect:(NSString *)effect {
  return [[SimpleAudioEngine sharedEngine] playEffect:effect];
}

- (void) stopEffect:(int)effect {
  [[SimpleAudioEngine sharedEngine] stopEffect:effect];
}

- (void) playHomeMapMusic {
  if (_curMusic != kHomeMapMusic) {
    _curMusic = kHomeMapMusic;
    [self playBackgroundMusic:@"Game_Music.m4a" loop:YES];
  }
}

- (void) playMissionMapMusic {
  if (_curMusic != kMissionMapMusic) {
    _curMusic = kMissionMapMusic;
    [self playBackgroundMusic:@"Mission_Enemy_song.m4a" loop:YES];
  }
}

- (void) playBattleMusic {
  if (_curMusic != kBattleMusic) {
    _curMusic = kBattleMusic;
    [self playBackgroundMusic:@"Battle_Music.m4a" loop:YES];
  }
}

- (void) playBazaarMusic {
  if (_curMusic != kBazaarMusic) {
    _curMusic = kBazaarMusic;
    [self playBackgroundMusic:@"Medieval Market.m4a" loop:YES];
  }
}

- (void) stopBackgroundMusic {
  if (_curMusic != kNoMusic) {
    _curMusic = kNoMusic;
    [self stopBackgroundMusic];
  }
}

- (void) archerAttack {
  [self playEffect:@"Archer_Attack.m4a"];
}

- (void) legionMageAttack {
  [self playEffect:@"Invoker_Attack.m4a"];
}

- (void) allianceMageAttack {
  [self playEffect:@"Panda_Attack.m4a"];
}

- (void) warriorAttack {
  [self playEffect:@"Warrior_Attack.m4a"];
}

- (void) archerCharge {
  _curChargeUp = [self playEffect:@"Archer_Combo.m4a"];
}

- (void) legionMageCharge {
  _curChargeUp = [self playEffect:@"Invoker_Combo.m4a"];
}

- (void) allianceMageCharge {
  _curChargeUp = [self playEffect:@"Panda_Combo.m4a"];
}

- (void) warriorCharge {
  _curChargeUp = [self playEffect:@"Warrior_Combo.m4a"];
}

- (void) warriorTaskSound {
  [self playEffect:@"Swords_Task.m4a"];
}

- (void) archerTaskSound {
  [self playEffect:@"Archer_Task.m4a"];
}

- (void) mageTaskSound {
  [self playEffect:@"Panda_Punch.m4a"];
}

- (void) genericTaskSound {
  [self playEffect:@"hand_shake.m4a"];
}

- (void) stopCharge {
  [self stopEffect:_curChargeUp];
}

- (void) perfectAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Perfect1.m4a" : @"Standard_Perfect2.m4a";
  [self playEffect:file];
}

- (void) goodAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Good1.m4a" : @"Standard_Good2.m4a";
  [self playEffect:file];
}

- (void) greatAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Great1.m4a" : @"Standard_Great2.m4a";
  [self playEffect:file];
}

- (void) missAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Miss1.m4a" : @"Standard_Miss2.m4a";
  [self playEffect:file];
}

- (void) battleVictory {
  [self playEffect:@"Battle_Success.m4a"];
}

- (void) battleLoss {
  [self playEffect:@"Battle_Loss.m4a"];
}

- (void) coinDrop {
  [self playEffect:@"Coin_drop.m4a"];
}

- (void) coinPickup {
  [self playEffect:@"Coin_Pickup.m4a"];
}

- (void) shinyItem {
  [self playEffect:@"shiny_item.m4a"];
}

- (void) closeDoor {
  [self playEffect:@"DoorClosing_Final.m4a"];
}

- (void) openDoor {
  [self playEffect:@"DoorOpening.m4a"];
}

- (void) levelUp {
  [self playEffect:@"levelup.m4a"];
}

- (void) levelUpPopUp {
  [self playEffect:@"level_up_pop_ups.m4a"];
}

- (void) questComplete {
  [self playEffect:@"QuestCompleted.m4a"];
}

- (void) questAccepted {
  [self playEffect:@"QuestNew.m4a"];
}

- (void) questLogOpened {
  [self playEffect:@"Quest Scroll Open.m4a"];
}

- (void) armoryBuy {
  [self playEffect:@"Armory_Buy.m4a"];
}

- (void) armoryEnter {
  [self playEffect:@"Armory_Enter.m4a"];
}

- (void) armoryLeave {
  [self playEffect:@"Armory_Leave.m4a"];
}

- (void) marketplaceBuy {
  NSString *file = arc4random() % 2 == 0 ? @"Marketplace_Buy.m4a" : @"Marketplace_Buy1.m4a";
  [self playEffect:file];
}

- (void) marketplaceEnter {
  [self playEffect:@"Marketplace_Enter.m4a"];
}

- (void) marketplaceLeave {
  [self playEffect:@"Marketplace_Exit.m4a"];
}

- (void) vaultWithdraw {
  NSString *file = arc4random() % 2 == 0 ? @"Vault_Withdraw1.m4a" : @"Vault_Withdraw2.m4a";
  [self playEffect:file];
}

- (void) vaultDeposit {
  NSString *file = arc4random() % 2 == 0 ? @"Vault_Deposit.m4a" : @"Vault_Deposit1.m4a";
  [self playEffect:file];
}

- (void) vaultEnter {
  [self playEffect:@"Vault_Enter.m4a"];
}

- (void) vaultLeave {
  [self playEffect:@"Vault_Leave.m4a"];
}

- (void) carpenterEnter {
  int rand = arc4random() % 3;
  NSString *file = nil;
  if (rand == 0) {
    file = @"Carpenter_Enter.m4a";
  } else if (rand == 1) {
    file = @"Carpenter_Enter2.m4a";
  } else {
    file = @"Carpenter_Enter3.m4a";
  }
  [self playEffect:file];
}

- (void) carpenterComplete {
  NSString *file = arc4random() % 2 == 0 ? @"Carpenter_Complete.m4a" : @"Carpenter_Complete2.m4a";
  [self playEffect:file];
}

- (void) carpenterPurchase {
  [self playEffect:@"Carpenter_Purchase.m4a"];
}

- (void) notificationAlert {
  [self playEffect:@"notification_alert.m4a"];
}

@end
