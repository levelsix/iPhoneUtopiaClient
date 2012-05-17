//
//  BazaarMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "GameMap.h"

@interface CritStructMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@end

@interface BazaarMap : GameMap

+ (BazaarMap *) sharedBazaarMap;

@property (nonatomic, retain) IBOutlet CritStructMenu *csMenu;

- (void) moveToCritStruct:(CritStructType)type;

@end
