//
//  MentorChatView.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Protocols.pb.h"

@interface MentorChatView : UIView {
  int _mentorUserId;
}

@property (nonatomic, retain) IBOutlet UILabel *badgeLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *titleView;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIView *firstChatView;
@property (nonatomic, retain) IBOutlet UIButton *firstNameButton;
@property (nonatomic, retain) IBOutlet UILabel *firstTextLabel;
@property (nonatomic, retain) IBOutlet UIButton *firstTypeIcon;
@property (nonatomic, retain) IBOutlet UIImageView *firstGlow;

@property (nonatomic, retain) IBOutlet UIView *secondChatView;
@property (nonatomic, retain) IBOutlet UIButton *secondNameButton;
@property (nonatomic, retain) IBOutlet UILabel *secondTextLabel;
@property (nonatomic, retain) IBOutlet UIButton *secondTypeIcon;
@property (nonatomic, retain) IBOutlet UIImageView *secondGlow;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) displayForMentor:(MinimumUserProto *)mup;

@end
