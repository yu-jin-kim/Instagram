//
//  CommentViewController.m
//  Instagram
//
//  Created by yujinkim on 7/11/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "CommentViewController.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // styling our textview to have rounded borders
    self.commentTextView.layer.borderWidth = 1.0f;
    self.commentTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.commentTextView.clipsToBounds = YES;
    self.commentTextView.layer.cornerRadius = 5.0f;
}

- (IBAction)commentButtonPressed:(id)sender {
    // when comment button is pressed, check if the comment is not empty, append it to our string containing the username, and post it to our server
    if(![self.commentTextView.text isEqualToString:@""]){
        NSString *username = [PFUser currentUser].username;
        NSString *space = @": ";
        NSString *base = [username stringByAppendingString:space];
        NSString *comment = self.commentTextView.text;
        NSString *newComment = [base stringByAppendingString:comment];
        [self.post addObject:newComment forKey:@"comments"];
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
            }}];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        //error message for when comment is empty
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Please enter a comment."
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

//when cancel is pressed, dismiss our view controller without doing anything
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
