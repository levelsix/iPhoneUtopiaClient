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

- (void) playHomeMapMusic {
  if (_curMusic != kHomeMapMusic) {
    _curMusic = kHomeMapMusic;
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Game_Music.m4a" loop:YES];
  }
}

- (void) playMissionMapMusic {
  if (_curMusic != kMissionMapMusic) {
    _curMusic = kMissionMapMusic;
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Mission_Enemy_song.m4a" loop:YES];
  }
}

- (void) playBattleMusic {
  if (_curMusic != kBattleMusic) {
    _curMusic = kBattleMusic;
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Battle_Music.m4a" loop:YES];
  }
}

- (void) playBazaarMusic {
  if (_curMusic != kBazaarMusic) {
    _curMusic = kBazaarMusic;
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Medieval Market.m4a" loop:YES];
  }
}

- (void) stopBackgroundMusic {
  if (_curMusic != kNoMusic) {
    _curMusic = kNoMusic;
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
  }
}

- (void) archerAttack {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Archer_Attack.m4a"];
}

- (void) legionMageAttack {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Invoker_Attack.m4a"];
}

- (void) allianceMageAttack {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Panda_Attack.m4a"];
}

- (void) warriorAttack {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Warrior_Attack.m4a"];
}

- (void) archerCharge {
  _curChargeUp = [[SimpleAudioEngine sharedEngine] playEffect:@"Archer_Combo.m4a"];
}

- (void) legionMageCharge {
  _curChargeUp = [[SimpleAudioEngine sharedEngine] playEffect:@"Invoker_Combo.m4a"];
}

- (void) allianceMageCharge {
  _curChargeUp = [[SimpleAudioEngine sharedEngine] playEffect:@"Panda_Combo.m4a"];
}

- (void) warriorCharge {
  _curChargeUp = [[SimpleAudioEngine sharedEngine] playEffect:@"Warrior_Combo.m4a"];
}

- (void) warriorTaskSound {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Swords_Task.m4a"];
}

- (void) archerTaskSound {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Archer_Task.m4a"];
}

- (void) mageTaskSound {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Panda_Punch.m4a"];
}

- (void) genericTaskSound {
  [[SimpleAudioEngine sharedEngine] playEffect:@"hand_shake.m4a"];
}

- (void) stopCharge {
  [[SimpleAudioEngine sharedEngine] stopEffect:_curChargeUp];
}

- (void) perfectAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Perfect1.m4a" : @"Standard_Perfect2.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) goodAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Good1.m4a" : @"Standard_Good2.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) greatAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Great1.m4a" : @"Standard_Great2.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) missAttack {
  NSString *file = arc4random() % 2 == 0 ? @"Standard_Miss1.m4a" : @"Standard_Miss2.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) battleVictory {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Battle_Success.m4a"];
}

- (void) battleLoss {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Battle_Loss.m4a"];
}

- (void) coinDrop {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Coin_drop.m4a"];
}

- (void) coinPickup {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Coin_Pickup.m4a"];
}

- (void) shinyItem {
  [[SimpleAudioEngine sharedEngine] playEffect:@"shiny_item.m4a"];
}

- (void) closeDoor {
  [[SimpleAudioEngine sharedEngine] playEffect:@"DoorClosing_Final.m4a"];
}

- (void) openDoor {
  [[SimpleAudioEngine sharedEngine] playEffect:@"DoorOpening.m4a"];
}

- (void) levelUp {
  [[SimpleAudioEngine sharedEngine] playEffect:@"levelup.m4a"];
}

- (void) levelUpPopUp {
  [[SimpleAudioEngine sharedEngine] playEffect:@"level_up_pop_ups.m4a"];
}

- (void) questComplete {
  [[SimpleAudioEngine sharedEngine] playEffect:@"QuestCompleted.m4a"];
}

- (void) questAccepted {
  [[SimpleAudioEngine sharedEngine] playEffect:@"QuestNew.m4a"];
}

- (void) questLogOpened {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Quest Scroll Open.m4a"];
}

- (void) armoryBuy {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Armory_Buy.m4a"];
}

- (void) armoryEnter {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Armory_Enter.m4a"];
}

- (void) armoryLeave {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Armory_Leave.m4a"];
}

- (void) marketplaceBuy {
  NSString *file = arc4random() % 2 == 0 ? @"Marketplace_Buy.m4a" : @"Marketplace_Buy1.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) marketplaceEnter {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Marketplace_Enter.m4a"];
}

- (void) marketplaceLeave {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Marketplace_Exit.m4a"];
}

- (void) vaultWithdraw {
  NSString *file = arc4random() % 2 == 0 ? @"Vault_Withdraw1.m4a" : @"Vault_Withdraw2.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) vaultDeposit {
  NSString *file = arc4random() % 2 == 0 ? @"Vault_Deposit.m4a" : @"Vault_Deposit1.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) vaultEnter {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Vault_Enter.m4a"];
}

- (void) vaultLeave {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Vault_Leave.m4a"];
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
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) carpenterComplete {
  NSString *file = arc4random() % 2 == 0 ? @"Carpenter_Complete.m4a" : @"Carpenter_Complete2.m4a";
  [[SimpleAudioEngine sharedEngine] playEffect:file];
}

- (void) carpenterPurchase {
  [[SimpleAudioEngine sharedEngine] playEffect:@"Carpenter_Purchase.m4a"];
}

- (void) notificationAlert {
  [[SimpleAudioEngine sharedEngine] playEffect:@"notification_alert.m4a"];
}

@end
