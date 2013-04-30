//
//  BattleMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NibUtils.h"
#import "Protocols.pb.h"
#import "UserData.h"

@class BattleSummaryView;
@class BattleAnalysisView;

@interface BattleSummaryEquipView : UIView

@property (nonatomic, retain) IBOutlet UILabel *rarityLabel;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *equipLevelIcon;
@property (nonatomic, retain) IBOutlet EnhancementLevelIcon *enhanceLevelIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;

- (void) updateForUserEquip:(UserEquip *)ue;

@end

@interface BattleTutorialView : UIView

@property (nonatomic, retain) IBOutlet UILabel *speechLabel;
@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *girlImageView;
@property (nonatomic, retain) IBOutlet UIView *buttonView;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;

@property (nonatomic, retain) BattleSummaryView *summaryView;
@property (nonatomic, retain) BattleAnalysisView *analysisView;

- (void) displayInitialViewWithSummaryView:(BattleSummaryView *)summaryView andAnalysisView:(BattleAnalysisView *)analysisView;
- (void) displayGoToAnalysisView;

@end

@interface BattleAnalysisView : UIView {
  BOOL _isForTutorial;
  UIImageView *_arrow;
}

@property (nonatomic, retain) IBOutlet UIImageView *leftBar1;
@property (nonatomic, retain) IBOutlet UIImageView *rightBar1;
@property (nonatomic, retain) IBOutlet UIImageView *leftBar2;
@property (nonatomic, retain) IBOutlet UIImageView *rightBar2;
@property (nonatomic, retain) IBOutlet UIImageView *leftBar3;
@property (nonatomic, retain) IBOutlet UIImageView *rightBar3;

@property (nonatomic, retain) IBOutlet UILabel *weaponLabel;
@property (nonatomic, retain) IBOutlet UILabel *armorLabel;
@property (nonatomic, retain) IBOutlet UILabel *amuletLabel;

@property (nonatomic, retain) IBOutlet UIImageView *speechGirlImage;
@property (nonatomic, retain) IBOutlet UIView *speechView;
@property (nonatomic, retain) IBOutlet UIView *speechBubble;

@property (nonatomic, retain) IBOutlet UILabel *topLabel1;
@property (nonatomic, retain) IBOutlet UILabel *topLabel2;
@property (nonatomic, retain) IBOutlet UILabel *topLabel3;
@property (nonatomic, retain) IBOutlet UIView *topLabelView;
@property (nonatomic, retain) IBOutlet UILabel *botLabel1;
@property (nonatomic, retain) IBOutlet UILabel *botLabel2;
@property (nonatomic, retain) IBOutlet UILabel *botLabel3;
@property (nonatomic, retain) IBOutlet UIView *botLabelView;

@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UIView *buttonView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) loadForEnemy:(FullUserProto *)enemy;
- (IBAction)closeClicked:(id)sender;
- (void) performTutorialPhase;
- (void) endTutorialPhase;

@end

@interface BattleSummaryView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *titleImage;

@property (nonatomic, retain) IBOutlet UIButton *leftNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftLevelLabel;
@property (nonatomic, retain) IBOutlet UIButton *leftPlayerIcon;
@property (nonatomic, retain) IBOutlet UILabel *leftAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftDefenseLabel;
@property (nonatomic, retain) IBOutlet UIImageView *leftBgdImage;
@property (nonatomic, retain) IBOutlet UIImageView *leftCircleIcon;
@property (nonatomic, retain) IBOutlet UIButton *rightNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightLevelLabel;
@property (nonatomic, retain) IBOutlet UIButton *rightPlayerIcon;
@property (nonatomic, retain) IBOutlet UILabel *rightAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightDefenseLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rightBgdImage;
@property (nonatomic, retain) IBOutlet UIImageView *rightCircleIcon;

@property (nonatomic, retain) IBOutlet UILabel *coinsGainedLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinsLostLabel;
@property (nonatomic, retain) IBOutlet UILabel *expGainedLabel;
@property (nonatomic, retain) IBOutlet UIView *winLabelsView;
@property (nonatomic, retain) IBOutlet UIView *defeatLabelsView;

@property (nonatomic, retain) IBOutlet UIView *analysisButtonView;
@property (nonatomic, retain) IBOutlet UIButton *analysisButton;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet BattleSummaryEquipView *equipView;
@property (nonatomic, retain) IBOutlet AutoScrollingScrollView *leftScrollView;
@property (nonatomic, retain) IBOutlet AutoScrollingScrollView *rightScrollView;
@property (nonatomic, retain) NSArray *leftEquipViews;
@property (nonatomic, retain) NSArray *rightEquipViews;

- (void) loadBattleSummaryForBattleResponse:(BattleResponseProto *)brp enemy:(FullUserProto *)fup;
- (void) close;

@end

@interface StolenEquipView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;
@property (nonatomic, retain) IBOutlet EnhancementLevelIcon *enhanceIcon;

@property (nonatomic, retain) IBOutlet UIView *statsView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) loadForEquip:(FullUserEquipProto *)fuep;
- (void) loadForLockBox:(int)eventId;

@end