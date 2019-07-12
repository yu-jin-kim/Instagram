//
//  CameraViewController.m
//  Instagram
//
//  Created by yujinkim on 7/9/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "CameraViewController.h"
#import "Post.h"
#import "TimelineViewController.h"

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@property (strong, nonatomic) UIImage *photo;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set our delegate
    self.captionView.delegate = self;
    //add rounded borders to our text view
    self.captionView.layer.borderWidth = 1.0f;
    self.captionView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.captionView.clipsToBounds = YES;
    self.captionView.layer.cornerRadius = 5.0f;
    //set our image picker
    self.imagePickerVC = [UIImagePickerController new];
    self.imagePickerVC.delegate = self;
    self.imagePickerVC.allowsEditing = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    // resize and set our imageview to the selected photo
    self.photo = [self resizeImage:editedImage withSize:CGSizeMake(400, 400)];
    self.photoView.image = self.photo;
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    //resize image function
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)cameraPressed:(id)sender {
    //if the camera button is pressed we check that the camera is available; if it is, use camera, if not use photo gallery
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}

- (IBAction)galleryPressed:(id)sender {
    //if gallery button is chosen, we use photo gallery as our source
    self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}
- (IBAction)cancelPressed:(id)sender {
    //dismiss view controller and go back to timeline without doing anything
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)postButtonPressed:(id)sender {
    if(self.photo){
        //if a photo was selected, post it to our server with the caption
        [Post postUserImage:self.photo withCaption:self.captionView.text withCompletion:nil];
        self.photoView.image = nil;
        [self.captionView setText:@""];
        [self.tabBarController setSelectedIndex:0];
    }
    else{
        //error message for when a photo was not selected
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Please select a photo."
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                         }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
    
}

@end
