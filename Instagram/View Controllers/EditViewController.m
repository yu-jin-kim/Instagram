//
//  EditViewController.m
//  Instagram
//
//  Created by yujinkim on 7/10/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@property (strong, nonatomic) UIImage *profileImage;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [PFUser currentUser];
    PFFileObject *image = [self.user objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.profileImage = [UIImage imageWithData:data];
        self.profileImageView.image = self.profileImage;
    }];
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
    self.bioTextView.layer.borderWidth = 1.0f;
    self.bioTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bioTextView.clipsToBounds = YES;
    self.bioTextView.layer.cornerRadius = 5.0f;
    NSString *userBio = [self.user objectForKey:@"userBio"];
    self.bioTextView.text = userBio;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    //UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    PFUser *user = [PFUser currentUser];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
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
- (IBAction)changePhotoPressed:(id)sender {
     [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}
- (IBAction)savePressed:(id)sender {
    self.user = [PFUser currentUser];
    NSString *bio = self.bioTextView.text;
    [self.user setObject:bio forKey:@"userBio"];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
        }}];
    [self dismissViewControllerAnimated:YES completion:nil];
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
