//
//  BuildUpgradePopupController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface BuildUpgradePopupController : UIViewController {
  UserStruct *_userStruct;
  
  NSString *_critStruct;
}

@property (nonatomic, retain) IBOutlet UIImageView *structIcon;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UIImageView *star1;
@property (nonatomic, retain) IBOutlet UIImageView *star2;
@property (nonatomic, retain) IBOutlet UIImageView *star3;
@property (nonatomic, retain) IBOutlet UIImageView *star4;
@property (nonatomic, retain) IBOutlet UIImageView *star5;

@property (nonatomic, retain) IBOutlet UIView *normStructView;
@property (nonatomic, retain) IBOutlet UILabel *critStructLabel;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (id) initWithUserStruct:(UserStruct *)us;
- (id) initWithCritStruct:(NSString *)cs;

@end
