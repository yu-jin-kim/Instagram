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
    int value = [self.post.likeCount intValue];
    self.post.likeCount = [NSNumber numberWithInt:value + 1];
    NSString *likeCountString = [NSString stringWithFormat:@"%@",self.post.likeCount];
    self.likeCountLabel.text = likeCountString;
}

- (IBAction)commentButtonPressed:(id)sender {
}

- (void)postCell:(PostCell *) postCell didTap: (PFUser *)user{
    [self.delegate postCell:self didTap:self.post.author];
}

@end
