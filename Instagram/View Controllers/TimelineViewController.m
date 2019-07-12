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
#import "DetailsViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "Post.h"
#import "PostCell.h"
#import "AppDelegate.h"
#import "InfiniteScrollActivityView.h"
#import "CommentViewController.h"


@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) bool isMoreDataLoading;

@end

@implementation TimelineViewController

//for infinite scroll
bool isMoreDataLoading = false;
InfiniteScrollActivityView* loadingMoreView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set our delegate;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //auto layout table view height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //adding our pull to refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    //fetch our posts from the server and set it to our array of posts
    [self fetchPosts];
    //infinite scroll at the bottom
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    loadingMoreView.hidden = true;
    [self.tableView addSubview:loadingMoreView];
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            isMoreDataLoading = true;
            Post *lastPost = [self.postArray lastObject];
            NSDate *lastDate = lastPost.createdAt;
            // Update position of loadingMoreView, and start loading indicator
            CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            loadingMoreView.frame = frame;
            [loadingMoreView startAnimating];
            // Code to load more results
            [self fetchPostsWithFilter:lastDate];
        }
    }
}

- (void) fetchPosts{
    //fetch posts without filter on date
    [self fetchPostsWithFilter:nil];
}

- (void) fetchPostsWithFilter: (NSDate *) lastDate {
    //for fetching older posts after bottom has been reached and we want to scroll down to load more
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    if (lastDate) {
        [postQuery whereKey:@"createdAt" lessThan:lastDate];
    }
    postQuery.limit = 20;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if ([posts count] != 0) {
            if (lastDate) {
                self.isMoreDataLoading = false;
                [self.postArray addObjectsFromArray:posts];
            } else {
                self.postArray = posts;
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
        //progress HUD for when screen is loading
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


- (IBAction)logoutPressed:(id)sender {
    //log the current user out and go back to loginviewcontroller
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(PFUser.currentUser == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            appDelegate.window.rootViewController = loginViewController;
            
            NSLog(@"User logged out successfully");
        } else {
            NSLog(@"Error logging out: %@", error);
        }
    }];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //ask datasource for cellsforrowat
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    Post *post = self.postArray[indexPath.row];
    cell.post = post;
    //grab our post image from server and set it to our imageview
    [post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        cell.postImageView.image = [UIImage imageWithData:data];
    }];
    //set our caption label
    cell.postCaption.text = post.caption;
    //begin setting our relative timestamps
    NSDate *createdAt = [cell.post createdAt];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *createdAtString = @"";
    // Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"E MMM d HH:mm:ss Z y"];
    NSDate *todayDate = [NSDate date];
    //calculate time since posted until now
    double ti = [createdAt timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if (ti < 60) {
        int diff = ti;
        createdAtString = [NSString stringWithFormat:@"%ds", diff];
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        createdAtString = [NSString stringWithFormat:@"%dm", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        createdAtString = [NSString stringWithFormat:@"%dh", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        createdAtString = [NSString stringWithFormat:@"%dd", diff];
    } else {
        createdAtString = [formatter stringFromDate:createdAt];
    }
    cell.timestampLabel.text = createdAtString;
    //circular profile picture
    cell.profilePictureView.layer.cornerRadius = 17.5f;
    //grab profile image of user from server
    PFFileObject *image = [cell.post.author objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        cell.profilePictureView.image = [UIImage imageWithData:data];
    }];
    //set our other properties and make sure like button is configured correctly according to whether current user has liked the post or not
    NSString *likeCountString = [post.likeCount stringValue];
    cell.likeCountLabel.text = likeCountString;
    cell.username.text = cell.post.author.username;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.likeButton setImage:[UIImage imageNamed:@"hearticon2.png"] forState:UIControlStateNormal];
    [cell.likeButton setImage:[UIImage imageNamed:@"redhearticon.png"] forState:UIControlStateSelected];
    PFUser *currentUser = [PFUser currentUser];
    NSArray *likedUsers = [[NSArray alloc] init];
    likedUsers = [cell.post objectForKey:@"likes"];
    if(![likedUsers containsObject:currentUser.username]){
        cell.likeButton.selected = NO;
    }else{
        cell.likeButton.selected = YES;
    }
    //set our cell delegate for segueing
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //ask datasource for numberofrows
    return self.postArray.count;
}

- (void)postCell:(PostCell *)postCell didTap:(PFUser *)user{
    //delegate method
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"profileSegue"]){
        //when profile picture tapped we want to segue to user profile
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = sender;
    }
    else if ([[segue identifier] isEqualToString:@"commentSegue"]){
        //when comment button is tapped we want to segue into commenting
        PostCell *tappedCell = sender;
        CommentViewController *commentViewController = [segue destinationViewController];
        commentViewController.post = tappedCell.post;
    }
    else{
        //when the cell is tapped, we want to segue into details
        PostCell *tappedCell = sender;
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.post = tappedCell.post;
    }
}

@end
