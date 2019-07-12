//
//  PostCell.m
//  Instagram
//
//  Created by yujinkim on 7/9/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // gesture recognizer on profile picture for navigating to user profile view controller
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePictureView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePictureView setUserInteractionEnabled:YES];
}

//calling delegate method to pass user as sender when profile picture is tapped
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate postCell:self didTap:self.post.author];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (IBAction)likeButtonPressed:(id)sender {
    // keeping track of current user activity
    PFUser *currentUser = [PFUser currentUser];
    NSArray *likedUsers = [[NSArray alloc] init];
    likedUsers = [self.post objectForKey:@"likes"];
    //if our post's array of liked users does not contain our current user we add it to the array, like the post, and set our like button to be red in its selected state
    if(![likedUsers containsObject:currentUser.username]){
        [self.post addObject:currentUser.username forKey:@"likes"];
        likedUsers = [self.post objectForKey:@"likes"];
        [self.post setObject:@(likedUsers.count) forKey:@"likeCount"];
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];
        NSString *likeCountString = [NSString stringWithFormat:@"%@",@(likedUsers.count)];
        self.likeCountLabel.text = likeCountString;
        self.likeButton.selected = YES;
        [self.likeButton setImage:[UIImage imageNamed:@"redhearticon.png"] forState:UIControlStateSelected];
    }
    //otherwise, we remove the current user from the array, making the button unselected and unliking the post
    else{
        [self.post removeObject:currentUser.username forKey:@"likes"];
        likedUsers = [self.post objectForKey:@"likes"];
        [self.post setObject:@(likedUsers.count) forKey:@"likeCount"];
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){}];
        NSString *likeCountString = [NSString stringWithFormat:@"%@",@(likedUsers.count)];
        self.likeCountLabel.text = likeCountString;
        self.likeButton.selected = NO;
        [self.likeButton setImage:[UIImage imageNamed:@"hearticon2.png"] forState:UIControlStateNormal];
    }
    
}


@end
