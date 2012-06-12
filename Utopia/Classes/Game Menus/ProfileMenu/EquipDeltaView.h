//
//  EquipDeltaView.h
//  Utopia
//
//  Created by Kevin Calloway on 6/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EquipDeltaView <NSObject>

@end

@interface EquipDeltaView : UIView <EquipDeltaView> {
  
}
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UILabel *upperLabel;//NiceFontLabel2
@property (nonatomic, retain) IBOutlet UILabel *lowerLabel;
+(UIView *)createForUpperString:(NSString *)upper 
                 andLowerString:(NSString *)lower
                      andCenter:(CGPoint)curCenter;
@end
