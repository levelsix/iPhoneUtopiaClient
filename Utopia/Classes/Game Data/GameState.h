//
//  GameState.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Info.pb.h"
#import <CoreLocation/CoreLocation.h>

@interface GameState : NSObject {
  BOOL _connected;
  int _userId;
  NSString *_name;
  UserType _type;
  int _level;
  int _defense;
  int _attack;
  int _currentEnergy;
  int _maxEnergy;
  int _currentStamina;
  int _maxStamina;
  int _health;
  int _maxHealth;
  int _diamonds;
  int _coins;
  int _vaultBalance;
  NSString *_armyCode;
  int _battlesWon;
  int _battlesLost;
  int _hourlyCoins;
  CLLocationCoordinate2D _location;
  int _skillPoints;
  int _experience;
  int _tasksCompleted;
  int _numReferrals;
  
  NSMutableArray *_marketplacePosts;
}

@property (assign) BOOL connected;
@property (assign) int userId;
@property (retain) NSString *name;
@property (assign) UserType type;
@property (assign) int level;
@property (assign) int defense;
@property (assign) int attack;
@property (assign) int currentEnergy;
@property (assign) int maxEnergy;
@property (assign) int currentStamina;
@property (assign) int maxStamina;
@property (assign) int health;
@property (assign) int maxHealth;
@property (assign) int diamonds;
@property (assign) int coins;
@property (assign) int vaultBalance;
@property (retain) NSString *armyCode;
@property (assign) int battlesWon;
@property (assign) int battlesLost;
@property (assign) int hourlyCoins;
@property (assign) CLLocationCoordinate2D location;
@property (assign) int skillPoints;
@property (assign) int experience;
@property (assign) int tasksCompleted;
@property (assign) int numReferrals;

@property (retain) NSMutableArray *_marketplacePosts;

+ (GameState *) sharedGameState;
+ (NSString *) font;

@end
