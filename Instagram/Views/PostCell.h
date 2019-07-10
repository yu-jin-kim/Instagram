//
//  PostCell.h
//  Instagram
//
//  Created by yujinkim on 7/9/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@protocol PostCellDelegate;
@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postCaption;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) Post *post;
@property (nonatomic, weak) id<PostCellDelegate> delegate;

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender;

@end

@protocol PostCellDelegate
- (void)postCell:(PostCell *) postCell didTap: (PFUser *)user;
@end

