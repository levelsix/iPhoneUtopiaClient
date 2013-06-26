//
//  ResetStaminaView.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"
#import "cocos2d.h"

@interface ResetStaminaView : UIView

@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *popupView;
@property (nonatomic, retain) IBOutlet UIView *dialogueView;

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

- (void) display;

@end

@interface GemView : UIView {
  int _itemId;
}

@property (nonatomic, assign) int itemId;
@property (nonatomic, assign) int quantity;

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) UIImageView *maskedItemIcon;

- (void) loadForGemId:(int)gemId hasGem:(BOOL)hasGem;

@end

@interface CityGemsPrizeView : UIView {
  NSArray *oldRects;
}

@property (nonatomic, retain) IBOutlet UIImageView *imgView1;
@property (nonatomic, retain) IBOutlet UIImageView *imgView2;
@property (nonatomic, retain) IBOutlet UIImageView *imgView3;
@property (nonatomic, retain) IBOutlet UIImageView *imgView4;
@property (nonatomic, retain) IBOutlet UIImageView *imgView5;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) beginPrizeAnimationForImageView:(NSArray *)startImgViews prize:(FullUserEquipProto *)fuep;

@end

@interface CityGemsView : UIView {
  int _cityId;
}

@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) IBOutlet UILabel *chestLabel;
@property (nonatomic, retain) IBOutlet UILabel *hintlabel;
@property (nonatomic, retain) IBOutlet UIView *redeemButtonView;
@property (nonatomic, retain) IBOutletCollection(GemView) NSArray *gemViews;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;
@property (nonatomic, retain) IBOutlet CityGemsPrizeView *prizeView;

@property (nonatomic, copy) NSArray *gems;

- (void) animateGem:(UIImageView *)gem withGemId:(int)gemId andGems:(NSArray *)gems andCityId:(int)cityId;
- (void) displayWithGems:(NSArray *)gems andCityId:(int)cityId;
- (IBAction)closeClicked:(id)sender;

- (void) receivedRedeemGemsResponse:(RedeemUserCityGemsResponseProto *)proto withUpdatedGems:(NSArray *)gems;

@end

@interface GemTutorialView : UIView {
  int _curLine;
  CCSprite *_arrow;
  NSArray *_curLines;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *girlImageView;

@property (nonatomic, retain) NSArray *gemLines;
@property (nonatomic, retain) NSArray *rankupLines;
@property (nonatomic, retain) NSArray *bossLines;

- (void) beginGemTutorial;
- (void) beginBossTutorial;
- (void) beginRankupTutorial;

- (IBAction) displayNextLine;

@end
