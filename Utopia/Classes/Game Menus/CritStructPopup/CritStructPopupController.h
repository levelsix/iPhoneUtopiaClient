//
//  CritStructPopupController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface CritStructPopupController : UIViewController {
  CritStruct *_critStruct;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descLabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;

- (id) initWithCritStruct:(CritStruct *)cs;

@end
