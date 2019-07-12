//
//  SignUpViewController.m
//  Instagram
//
//  Created by yujinkim on 7/8/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // rounded border for button
    self.signupButton.layer.cornerRadius = 5.0f;
}

- (IBAction)signupPressed:(id)sender {
    //when signup button pressed register user
    [self registerUser];
}

- (IBAction)loginPressed:(id)sender {
    //when login pressed, dismiss the signup view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.email = self.emailField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            //error when register not successful
            NSLog(@"Error: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Could not register account."
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
        } else {
            NSLog(@"User registered successfully");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


@end
