//
//  TimelineViewController.m
//  Instagram
//
//  Created by yujinkim on 7/8/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "TimelineViewController.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "Post.h"
#import "PostCell.h"

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *postArray;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 480.0;

    [self fetchPosts];

}
- (void)fetchPosts{
    // construct query
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts) {
            // do something with the array of object returned by the call
            self.postArray = posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:@"Post"]) { // or whatever your title is
        [self performSegueWithIdentifier:@"postSegue" sender:self];
    }
}

- (IBAction)logoutPressed:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //ask datasource for cellsforrowat
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    Post *post = self.postArray[indexPath.row];
    [post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        cell.postImageView.image = [UIImage imageWithData:data];
    }];
    cell.postCaption.text = post.caption;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //ask datasource for numberofrows
    //returns number of items returned from API
    return self.postArray.count;
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
