//
//  EditViewController.h
//  Instagram
//
//  Created by yujinkim on 7/10/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *changePhotoButton;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) PFUser *user;
@end


