//
//  LoginViewController.m
//  Instagram
//
//  Created by yujinkim on 7/8/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // rounded buttons and hidden text in password text field
    self.loginButton.layer.cornerRadius = 5.0f;
    self.passwordField.secureTextEntry = YES;
}

- (IBAction)signupPressed:(id)sender {
    //when signup pressed, segue into signupviewcontroller
    [self performSegueWithIdentifier:@"signupSegue" sender:nil];
}

- (IBAction)loginPressed:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    //check if username and password matches a user in our server
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            //error message when login failed
            NSLog(@"User log in failed: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Incorrect username / password."
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
            //when login successful, segue into home page
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            // display view controller that needs to shown after successful login
        }
    }];
}


@end
