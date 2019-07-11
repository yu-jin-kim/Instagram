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
    // Initialization code
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePictureView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePictureView setUserInteractionEnabled:YES];
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    // TODO: Call method on delegate
    [self.delegate postCell:self didTap:self.post.author];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (IBAction)likeButtonPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    NSArray *likedUsers = [[NSArray alloc] init];
    likedUsers = [self.post objectForKey:@"likes"];
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

- (IBAction)commentButtonPressed:(id)sender {
    
}

@end
