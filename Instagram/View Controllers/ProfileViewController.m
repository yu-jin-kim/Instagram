//
//  ProfileViewController.m
//  Instagram
//
//  Created by yujinkim on 7/10/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "ProfileViewController.h"
#import "TimelineViewController.h"
#import "PostCell.h"
#import "Post.h"
#import <Parse/Parse.h>

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@property (strong, nonatomic) UIImage *profileImage;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.user == nil){
        self.user = [PFUser currentUser];
    }
    self.profileImageView.layer.cornerRadius = 50.0f;
    self.imagePickerVC = [UIImagePickerController new];
    self.imagePickerVC.delegate = self;
    self.imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    PFFileObject *image = [self.user objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.profileImage = [UIImage imageWithData:data];
        self.profileImageView.image = self.profileImage;
    }];
    self.username.text = self.user.username;
    
}
- (IBAction)profileImagePressed:(id)sender {
    if (self.user == [PFUser currentUser]){
        [self presentViewController:self.imagePickerVC animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    //UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    PFUser *user = [PFUser currentUser];
    // Do something with the images (based on your use case)

    self.profileImage = [self resizeImage:editedImage withSize:CGSizeMake(400, 400)];
    self.profileImageView.image = self.profileImage;
    NSData *imageData = UIImageJPEGRepresentation(self.profileImage, 1.0);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"img.png" data:imageData];
    [imageFile saveInBackground];
    [user setObject:imageFile forKey:@"profileImage"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
        }}];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
