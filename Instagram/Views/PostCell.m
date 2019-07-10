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

@end
