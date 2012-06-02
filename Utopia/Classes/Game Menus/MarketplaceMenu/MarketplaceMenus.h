//
//  MarketplaceMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/30/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "Protocols.pb.h"
#import "UserData.h"

// My selling is when you have the item on the mktplace.
// Listing is when you own the item but its not on the mktplace.

typedef enum {
  kSellingState = 1,
  kListState,
  kMySellingState,
  kSubmitState
} MarketCellState;

@interface ItemPostView : UITableViewCell {
  MarketCellState _state;
}

@property (nonatomic, retain) IBOutlet UILabel *postTitle;

@property (nonatomic, retain) IBOutlet UIImageView *itemImageView;
@property (nonatomic, retain) IBOutlet UIView *statsView;
@property (nonatomic, retain) IBOutlet UIView *submitView;
@property (nonatomic, retain) IBOutlet UIView *submitButton;
@property (nonatomic, retain) IBOutlet UIView *listButton;
@property (nonatomic, retain) IBOutlet UIView *removeButton;
@property (nonatomic, retain) IBOutlet UIView *buyButton;
@property (nonatomic, retain) IBOutlet NiceFontTextField *priceField;
@property (nonatomic, retain) IBOutlet UIImageView *priceIcon;
@property (nonatomic, retain) IBOutlet UIImageView *submitPriceIcon;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UILabel *attStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *defStatLabel;
@property (nonatomic, retain) IBOutlet UIImageView *quantityBackground;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *leatherBackground;
@property (nonatomic, retain) IBOutlet UILabel *equipTypeLabel;

@property (nonatomic, assign) MarketCellState state;
@property (nonatomic, retain) FullMarketplacePostProto *mktProto;
@property (nonatomic, retain) UserEquip *equip;

- (void) showEquipPost: (FullMarketplacePostProto *)proto;
- (void) showEquipListing: (UserEquip *)proto;

@end

@interface MarketPurchaseView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *classLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *armoryPriceLabel;
@property (nonatomic, retain) IBOutlet UILabel *postedPriceLabel;
@property (nonatomic, retain) IBOutlet UILabel *savePriceLabel;
@property (nonatomic, retain) IBOutlet UIButton *playerNameButton;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *armoryPriceIcon;
@property (nonatomic, retain) IBOutlet UIImageView *postedPriceIcon;
@property (nonatomic, retain) IBOutlet UIImageView *savePriceIcon;
@property (nonatomic, retain) IBOutlet UIView *wrongClassView;
@property (nonatomic, retain) IBOutlet UIView *tooLowLevelView;
@property (nonatomic, retain) IBOutlet UIView *crossOutView;

@property (nonatomic, retain) FullMarketplacePostProto *mktPost;

- (void) updateForMarketPost:(FullMarketplacePostProto *)m;

@end

@interface MarketplaceLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end

@interface MarketplaceBottomBar : UIView {
  BOOL isOpen;
}

@property (nonatomic, retain) IBOutlet UIView *openCloseButton;

@property (nonatomic, retain) IBOutlet UIImageView *weaponIcon;
@property (nonatomic, retain) IBOutlet UIImageView *armorIcon;
@property (nonatomic, retain) IBOutlet UIImageView *amuletIcon;

@property (nonatomic, retain) IBOutlet UILabel *weaponAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *weaponDefenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *armorAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *armorDefenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *amuletAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *amuletDefenseLabel;

- (void) updateLabels;

@end
