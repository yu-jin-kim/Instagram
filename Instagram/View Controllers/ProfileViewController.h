//
//  ProfileViewController.h
//  Instagram
//
//  Created by yujinkim on 7/10/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PostCollectionViewCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) PFUser *user;

@end

NS_ASSUME_NONNULL_END
