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
    //set our user to be the current user and retrieve their information including profile picture and bio
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
    
    // use an image picker to change the profile picture
    self.imagePickerVC = [UIImagePickerController new];
    self.imagePickerVC.delegate = self;
    self.imagePickerVC.allowsEditing = YES;
    //if camera is available we will use the camera, otherwise, use photo gallery
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //styling our bio text view to have rounded borders
    self.bioTextView.layer.borderWidth = 1.0f;
    self.bioTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bioTextView.clipsToBounds = YES;
    self.bioTextView.layer.cornerRadius = 5.0f;
    //set our bio to already contain the current bio
    NSString *userBio = [self.user objectForKey:@"userBio"];
    self.bioTextView.text = userBio;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    PFUser *user = [PFUser currentUser];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    //use the edited image and resize it to fit our profile picture
    self.profileImage = [self resizeImage:editedImage withSize:CGSizeMake(400, 400)];
    self.profileImageView.image = self.profileImage;
    //save the picture to the user class in our server
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

//our resize image function
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

//present our photo picker when change photo button is pressed
- (IBAction)changePhotoPressed:(id)sender {
     [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}

//when save is pressed, save the entered bio text to user class in our server and dismiss view controller
- (IBAction)savePressed:(id)sender {
    self.user = [PFUser currentUser];
    NSString *bio = self.bioTextView.text;
    [self.user setObject:bio forKey:@"userBio"];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
        }}];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
