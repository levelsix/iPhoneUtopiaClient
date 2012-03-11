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

@interface LabelButton : UIButton {
  UILabel *_label;
  NSString *_text;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *text;

@end

@interface NiceFontTextField : UITextField

@property (nonatomic, retain) UILabel *label;

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
