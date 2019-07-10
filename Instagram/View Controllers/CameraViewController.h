//
//  CameraViewController.h
//  Instagram
//
//  Created by yujinkim on 7/9/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN


@interface CameraViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UITextView *captionView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;


@end

NS_ASSUME_NONNULL_END
