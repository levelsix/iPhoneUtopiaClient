//
//  BattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "BattleLayer.h"
#import "GameState.h"
#import "Globals.h"
#import "SynthesizeSingleton.h"
#import "GameLayer.h"

#define HEALTH_BAR_VELOCITY 120.f

#define ATTACK_BUTTON_ANIMATION 4.f

#define MIN_COMBO_BAR_DURATION 1.f
#define MAX_COMBO_BAR_DURATION 1.8f

#define BIG_HEALTH_FONT 14.f
#define SMALL_HEALTH_FONT 10.f

#define ATTACK_SKILL_POINT_TO_EQUIP_ATTACK_RATIO 2
#define DEFENSE_SKILL_POINT_TO_EQUIP_DEFENSE_RATIO 2
#define LOCATION_BAR_MAX 75.f
#define MAX_ATTACK_MULTIPLIER 1.5
#define MIN_PERCENT_OF_ENEMY_HEALTH .05
#define MAX_PERCENT_OF_ENEMY_HEALTH .5

@implementation BattleLayer

SYNTHESIZE_SINGLETON_FOR_CLASS(BattleLayer);

static CCScene *scene = nil;

+(CCScene *) scene
{
  if (!scene) {
    // 'scene' is an autorelease object.
    scene = [[CCScene node] retain];
    
    CCSprite *sprite = [CCSprite spriteWithFile:@"battlebackground1.png"];
    sprite.anchorPoint = ccp(0,0);
    [scene addChild:sprite];
    
    // 'layer' is an autorelease object.
    BattleLayer *layer = [BattleLayer sharedBattleLayer];
    
    // add layer as a child to scene
    [scene addChild: layer];
  }
	
	// return the scene
	return scene;
}

- (id) init {
  if ((self = [super init])) {
    _left = [CCSprite spriteWithFile:@"goodarcher.png"];
    _right = [CCSprite spriteWithFile:@"badarcher.png"];
    
    _left.position = ccp(-_left.contentSize.width/2, _left.contentSize.height/2);
    _right.position = ccp([[CCDirector sharedDirector] winSize].width+_left.contentSize.width/2, _right.contentSize.height/2);
    
    [self addChild:_left z:1];
    [self addChild:_right z:1];
    
    CCSprite *leftHealthBarBg = [CCSprite spriteWithFile:@"healthbarbg.png"];
    leftHealthBarBg.position = ccp(leftHealthBarBg.contentSize.width/2, self.contentSize.height-leftHealthBarBg.contentSize.height/2);
    [self addChild:leftHealthBarBg];
    
    _leftHealthBar = [CCSprite spriteWithFile:@"healthbar.png"];
    _leftHealthBar.anchorPoint = ccp(0, 0.5f);
    _leftHealthBar.position = ccp(0, leftHealthBarBg.contentSize.height/2);
    [leftHealthBarBg addChild:_leftHealthBar];
    
    CCSprite *rightHealthBarBg = [CCSprite spriteWithTexture:leftHealthBarBg.texture];
    rightHealthBarBg.flipX = YES;
    rightHealthBarBg.position = ccp(self.contentSize.width-leftHealthBarBg.contentSize.width/2, self.contentSize.height-leftHealthBarBg.contentSize.height/2);
    [self addChild:rightHealthBarBg];
    
    _rightHealthBar = [CCSprite spriteWithTexture:_leftHealthBar.texture];
    _rightHealthBar.anchorPoint = ccp(1, 0.5f);
    _rightHealthBar.position = ccp(rightHealthBarBg.contentSize.width, rightHealthBarBg.contentSize.height/2);
    _rightHealthBar.flipX = YES;
    [rightHealthBarBg addChild:_rightHealthBar];
    
    _attackButton = [CCSprite spriteWithFile:@"attackbg.png"];
    _attackButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:_attackButton];
    
    _attackProgressTimer = [CCProgressTimer progressWithFile:@"yellowtimer.png"];
    _attackProgressTimer.position = ccp(_attackButton.contentSize.width/2, _attackButton.contentSize.height/2);
    _attackProgressTimer.type = kCCProgressTimerTypeRadialCCW;
    _attackProgressTimer.percentage = 42;
    [_attackButton addChild:_attackProgressTimer];
    
    CCSprite *attackImage = [CCSprite spriteWithFile:@"circleattackbutton.png"];
    CCMenuItemSprite *attackImageButton = [CCMenuItemSprite itemFromNormalSprite:attackImage selectedSprite:nil target:self selector:@selector(attackStart)];
    
    CCMenu *menu = [CCMenu menuWithItems:attackImageButton,nil];
    [_attackButton addChild:menu];
    menu.position = ccp(_attackButton.contentSize.width/2, _attackButton.contentSize.height/2);
    
    _comboBar = [CCSprite spriteWithFile:@"attackcirclebg.png"];
    _comboBar.position = ccp(100, self.contentSize.height/2);
    [self addChild:_comboBar];
    
    _comboProgressTimer = [CCProgressTimer progressWithFile:@"attackchecks.png"];
    _comboProgressTimer.position = ccp(_comboBar.contentSize.width/2-2, _comboBar.contentSize.height/2);
    _comboProgressTimer.type = kCCProgressTimerTypeRadialCW;
    _comboProgressTimer.percentage = 75;
    _comboProgressTimer.rotation = 180;
    [_comboBar addChild:_comboProgressTimer];
    
    CCSprite *max = [CCSprite spriteWithFile:@"max.png"];
    max.position = ccp(_comboBar.contentSize.width+max.contentSize.width/2, _comboBar.contentSize.height/2);
    [_comboBar addChild:max];
    
    CCSprite *pause = [CCSprite spriteWithFile:@"pause.png"];
    CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemFromNormalSprite:pause selectedSprite:nil target:self selector:@selector(pauseClicked)];
    pauseButton.anchorPoint = ccp(1, 0);
    
    CCSprite *flee = [CCSprite spriteWithFile:@"flee.png"];
    CCMenuItemSprite *fleeButton = [CCMenuItemSprite itemFromNormalSprite:flee selectedSprite:nil target:self selector:@selector(fleeClicked)];
    fleeButton.anchorPoint = ccp(0,0);
    
    _bottomMenu = [CCMenu menuWithItems:pauseButton, fleeButton, nil];
    _bottomMenu.position = ccp(self.contentSize.width/2, 0);
    [self addChild:_bottomMenu];
    
    int yOffset = 5.f;
    _leftMaxHealthLabel = [CCLabelTTF labelWithString:@" / 100" fontName:@"DINCond-Black" fontSize:10];
    _leftMaxHealthLabel.anchorPoint = ccp(0,0);
    _leftMaxHealthLabel.position = ccp(leftHealthBarBg.contentSize.width/2, yOffset);
    [leftHealthBarBg addChild:_leftMaxHealthLabel];
    _leftCurHealthLabel = [CCLabelTTF labelWithString:@"100" fontName:@"DINCond-Black" fontSize:14];
    _leftCurHealthLabel.anchorPoint = ccp(1,0);
    _leftCurHealthLabel.position = ccp(leftHealthBarBg.contentSize.width/2, yOffset);
    [leftHealthBarBg addChild:_leftCurHealthLabel];
    
    _rightMaxHealthLabel = [CCLabelTTF labelWithString:@" / 100" fontName:@"DINCond-Black" fontSize:10];
    _rightMaxHealthLabel.anchorPoint = ccp(0,0);
    _rightMaxHealthLabel.position = ccp(rightHealthBarBg.contentSize.width/2, yOffset);
    [rightHealthBarBg addChild:_rightMaxHealthLabel];
    _rightCurHealthLabel = [CCLabelTTF labelWithString:@"100" fontName:@"DINCond-Black" fontSize:14];
    _rightCurHealthLabel.anchorPoint = ccp(1,0);
    _rightCurHealthLabel.position = ccp(rightHealthBarBg.contentSize.width/2, yOffset);
    [rightHealthBarBg addChild:_rightCurHealthLabel];
    
    self.isTouchEnabled = YES;
  }
  return self;
}

- (void) beginBattleAgainst:(FullUserProto *)user {
  GameState *gs = [GameState sharedGameState];
  
  _leftCurrentHealth = gs.maxHealth;
  _leftMaxHealth = gs.maxHealth;
  _rightMaxHealth = user.healthMax;
  _rightCurrentHealth = user.healthMax;
  
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
  _rightMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _rightMaxHealth];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
  _leftMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _leftMaxHealth];
  
  [[CCDirector sharedDirector] pushScene:[BattleLayer scene]];
  [self startMyTurn];
}

- (void) setLeftHealthBarPercentage:(float)percentage {
  // Anchor point is (0,0.5)
  CGPoint finalPt;
  SEL afterAction;
  float width = _leftHealthBar.contentSize.width;
  if (percentage > 0) {
    float endPos = width * percentage / 100;
    finalPt = ccp(endPos-width, _leftHealthBar.position.y);
    afterAction = @selector(startMyTurn);
  } else {
    finalPt = ccp(-width, _leftHealthBar.position.y);
    afterAction = @selector(myLoss);
  }
  
  float dist = ccpDistance(finalPt, _leftHealthBar.position);
  [_leftHealthBar runAction:[CCSequence actions:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt],
                             [CCCallFuncN actionWithTarget:self selector:@selector(doneWithLeftHealthBar)],
                             [CCCallFunc actionWithTarget:self selector:afterAction], nil]];
  [self schedule:@selector(updateLeftLabel)];
}

- (void) setRightHealthBarPercentage:(float)percentage {
  // Anchor point is (1,0.5)
  CGPoint finalPt;
  SEL afterAction;
  float width = _rightHealthBar.contentSize.width;
  if (percentage > 0) {
    float endPos = width * percentage / 100;
    finalPt = ccp(_rightHealthBar.parent.contentSize.width+width-endPos, _rightHealthBar.position.y);
    afterAction = @selector(startEnemyTurn);
  } else {
    finalPt = ccp(_rightHealthBar.parent.contentSize.width+width, _rightHealthBar.position.y);
    afterAction = @selector(myWin);
  }
  float dist = ccpDistance(finalPt, _rightHealthBar.position);
  [_rightHealthBar runAction:[CCSequence actions:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt],
                              [CCCallFuncN actionWithTarget:self selector:@selector(doneWithRightHealthBar)],
                              [CCCallFunc actionWithTarget:self selector:afterAction], nil]];
  [self schedule:@selector(updateRightLabel)];
}

- (void) updateLeftLabel {
  float width = _leftHealthBar.contentSize.width;
  float pos = _leftHealthBar.position.x;
  float percentage = (pos+width)*100.f/width;
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", (int)(percentage/100*_leftMaxHealth)];
}

- (void) updateRightLabel {
  float width = _rightHealthBar.contentSize.width;
  float pos = _rightHealthBar.position.x;
  float percentage = (_rightHealthBar.parent.contentSize.width+width-pos)*100.f/width;
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", (int)(percentage/100*_rightMaxHealth)];
}

- (void) doneWithLeftHealthBar {
  [self unschedule:@selector(updateLeftLabel)];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
}

- (void) doneWithRightHealthBar {
  [self unschedule:@selector(updateRightLabel)];
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
}

- (void) myWin {
  NSLog(@"My Win");
  [[CCDirector sharedDirector] popScene];
}

- (void) myLoss {
  NSLog(@"My Loss");
  [[CCDirector sharedDirector] popScene];
}

- (void) fleeClicked {
  NSLog(@"flee");
}

- (void) pauseClicked {
  NSLog(@"pause");
}

- (void) attackStart {
  [_attackProgressTimer stopAllActions];
  
  _bottomMenu.visible = NO;
  _attackButton.visible = NO;
  _comboBar.visible = YES;
  _comboBarMoving = YES;
  
  float duration = (((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION))+MIN_COMBO_BAR_DURATION;
  [_comboProgressTimer runAction:[CCSequence actionOne:[CCEaseIn actionWithAction:[CCProgressFromTo actionWithDuration:duration from:0 to:100] rate:2.5]
                                                   two:[CCCallFunc actionWithTarget:self selector:@selector(comboMissed)]]];
}

- (void) comboBarClicked {
  if (_comboBarMoving) {
    [_comboProgressTimer stopAllActions];
    _comboBarMoving = NO;
    _comboPercentage = _comboProgressTimer.percentage;
    NSLog(@"Clicked at percent: %f", _comboProgressTimer.percentage);
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5] two:[CCCallFunc actionWithTarget:self selector:@selector(doAttackAnimation)]]];
  }
}

- (void) comboMissed {
  _comboBarMoving = NO;
  [self startEnemyTurn];
}

- (void) startMyTurn {
  _attackButton.visible = YES;
  _comboBar.visible = NO;
  _bottomMenu.visible = YES;
  
  [_attackProgressTimer runAction:[CCSequence actionOne:[CCProgressFromTo actionWithDuration:ATTACK_BUTTON_ANIMATION from:100 to:0]
                                                    two:[CCCallFunc actionWithTarget:self selector:@selector(turnMissed)]]];
}

- (void) startEnemyTurn {
  [self doEnemyAttackAnimation];
}

- (void) turnMissed {
  [self startEnemyTurn];
  NSLog(@"Turn missed.");
}

- (int) calculateMyDamageForPercentage:(float)percent {
  int multiplerWeightForSecondHalf = LOCATION_BAR_MAX / (100-LOCATION_BAR_MAX);
  double amountWorseThanMax = (percent <= LOCATION_BAR_MAX) ? (LOCATION_BAR_MAX-percent)*MAX_ATTACK_MULTIPLIER/LOCATION_BAR_MAX : (percent-LOCATION_BAR_MAX)*multiplerWeightForSecondHalf*MAX_ATTACK_MULTIPLIER/LOCATION_BAR_MAX;
  
  
  //assumes linearity from 0-BAR_MAX and BAR_MAX-100 (diff slope magnitudes for each) to calculate attack value
  double attackMultiplier = MAX_ATTACK_MULTIPLIER - amountWorseThanMax;
  
  double attackStat = _leftAttack * attackMultiplier;
  double defenseStat = _rightDefense;
  
  int minDamage = (int) (_rightMaxHealth * MIN_PERCENT_OF_ENEMY_HEALTH);
  int maxDamage = (int) (_rightMaxHealth * MAX_PERCENT_OF_ENEMY_HEALTH);
  
  return (int)MIN(maxDamage, MAX(minDamage, attackStat-defenseStat));

}

- (int) calculateEnemyDamageForPercentage:(float)percent {
  int multiplerWeightForSecondHalf = LOCATION_BAR_MAX / (100-LOCATION_BAR_MAX);
  double amountWorseThanMax = (percent <= LOCATION_BAR_MAX) ? (LOCATION_BAR_MAX-percent)*MAX_ATTACK_MULTIPLIER/LOCATION_BAR_MAX : (percent-LOCATION_BAR_MAX)*multiplerWeightForSecondHalf*MAX_ATTACK_MULTIPLIER/LOCATION_BAR_MAX;
  
  
  //assumes linearity from 0-BAR_MAX and BAR_MAX-100 (diff slope magnitudes for each) to calculate attack value
  double attackMultiplier = MAX_ATTACK_MULTIPLIER - amountWorseThanMax;
  
  double attackStat = _leftAttack * attackMultiplier;
  double defenseStat = _rightDefense;
  
  int minDamage = (int) (_rightMaxHealth * MIN_PERCENT_OF_ENEMY_HEALTH);
  int maxDamage = (int) (_rightMaxHealth * MAX_PERCENT_OF_ENEMY_HEALTH);
  
  return (int)MIN(maxDamage, MAX(minDamage, attackStat-defenseStat));
}

- (void) attackAnimationDone {
  int damage = [self calculateMyDamageForPercentage:_comboPercentage];
  _rightCurrentHealth -= damage;
  [self setRightHealthBarPercentage:((float)_rightCurrentHealth)/_rightMaxHealth*100];
}

- (void) doAttackAnimation {
  self.visible = YES;
  _left.position = ccp(-_left.contentSize.width/2, _left.contentSize.height/2);
  _left.opacity = 255;
  _left.scale = 1;
  _right.position = ccp([[CCDirector sharedDirector] winSize].width+_left.contentSize.width/2, _right.contentSize.height/2);
  
  [_left runAction: [CCSequence actions: 
                     // Move to position
                     [CCMoveBy actionWithDuration:0.4 position:ccp(3*_left.contentSize.width/4,0)], 
                     // Wait for _right sprite to move
                     [CCDelayTime actionWithDuration:0.7],
                     // Move a little back to ready an attack
                     [CCMoveBy actionWithDuration:0.2 position:ccp(-50, 0)],
                     // Delay so it looks like we're ready
                     [CCDelayTime actionWithDuration:0.1],
                     // ATTACK!!
                     [CCMoveBy actionWithDuration:0.02 position:ccp(50, 0)],
                     // Wait for _right sprite to move away
                     [CCDelayTime actionWithDuration:0.5],
                     // Fade out and scale, attack done
                     [CCSpawn actions:
                      [CCScaleBy actionWithDuration:0.1 scale:1.2],
                      [CCFadeOut actionWithDuration:0.1],
                      nil],
                     // Set this layer to invisible
                     [CCCallFunc actionWithTarget:self selector:@selector(attackAnimationDone)],
                     nil]];
  
  [_right runAction: [CCSequence actions: 
                      [CCDelayTime actionWithDuration:0.4],
                      [CCMoveBy actionWithDuration:0.5 position:ccp(-3*_right.contentSize.width/4,0)],
                      [CCDelayTime actionWithDuration:0.65],
                      [CCMoveBy actionWithDuration:0.2 position:ccp(3*_right.contentSize.width/4, 0)],
                      nil]];
}

- (void) enemyAttackDone {
  int damage = [self calculateEnemyDamageForPercentage:_comboPercentage];
  _leftCurrentHealth -= damage;
  [self setLeftHealthBarPercentage:((float)_leftCurrentHealth)/_leftMaxHealth*100];
}

- (void) doEnemyAttackAnimation {
  [self enemyAttackDone];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_comboBarMoving) {
    [self comboBarClicked];
  }
}

@end
