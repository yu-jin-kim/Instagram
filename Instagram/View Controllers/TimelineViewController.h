//
//  TimelineViewController.h
//  Instagram
//
//  Created by yujinkim on 7/8/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCell.h"
#import "Post.h"

@interface TimelineViewController : UIViewController<PostCellDelegate>

- (void)didPost:(Post *)post;

@end
