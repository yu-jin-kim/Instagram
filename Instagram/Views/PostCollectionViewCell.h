//
//  PostCollectionViewCell.h
//  Instagram
//
//  Created by yujinkim on 7/10/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) Post *post;
@end

NS_ASSUME_NONNULL_END
