//
//  NibUtils.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NiceFontLabel : UILabel 
@end

@interface NiceFontLabel2 : UILabel 
@end

@interface NiceFontLabel3 : UILabel 
@end

@interface NiceFontLabel4 : UILabel 
@end

@interface NiceFontLabel5 : UILabel 
@end

@interface NiceFontLabel6 : UILabel 
@end

@interface NiceFontLabel7 : UILabel 
@end

@interface NiceFontButton : UIButton
@end

@interface LabelButton : UIButton {
  UILabel *_label;
  NSString *_text;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *text;

@end

@interface NiceFontTextFieldDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, retain) id<UITextFieldDelegate> otherDelegate;

@end

@interface NiceFontTextField : UITextField

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NiceFontTextFieldDelegate *nfDelegate;

@end

@interface FlipImageView : UIImageView

@end

@interface FlipButton : UIButton

@end

@interface ServerImageView : UIImageView 

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *highlightedPath;

@end

@interface ServerButton : UIButton 

@property (nonatomic, retain) NSString *path;

@end

@interface RopeView : UIView

@end

@interface TutorialGirlImageView : UIImageView

@end

@interface CancellableTableView : UITableView
@end

@interface EquipButton : UIImageView

@property (nonatomic, assign) int equipId;
@property (nonatomic, retain) UIImageView *darkOverlay;

- (void) equipClicked;

@end

@interface EquipLevelIcon : UIImageView

@property (nonatomic, assign) int level;

@end

@interface ProgressBar : UIImageView

@property (nonatomic, assign) float percentage;

@end

@interface LoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end
