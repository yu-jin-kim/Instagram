//
//  PostCell.h
//  Instagram
//
//  Created by yujinkim on 7/9/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postCaption;

@end

NS_ASSUME_NONNULL_END
