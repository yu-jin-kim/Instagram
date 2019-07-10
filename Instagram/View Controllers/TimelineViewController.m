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

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *postArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) bool isMoreDataLoading;

@end

@implementation TimelineViewController

bool isMoreDataLoading = false;
InfiniteScrollActivityView* loadingMoreView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 542.0;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self fetchPosts];
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
            
            // Update position of loadingMoreView, and start loading indicator
            CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            loadingMoreView.frame = frame;
            [loadingMoreView startAnimating];
            
            // Code to load more results
            [self loadMoreData];
        }
    }
}

-(void)loadMoreData{
    Post *lastPost = [self.postArray lastObject];
    NSString *lastObjStrID = lastPost.postID;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSNumber *lastObjID = [f numberFromString:lastObjStrID];
    long lastObjLong = [lastObjID longValue];
    long finalID = lastObjLong -1;
    NSNumber *finalIDNum = @(finalID);
    
    
}

- (void)fetchPosts{
    // construct query
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"user"];
    postQuery.limit = 20;
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts) {
            self.postArray = posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}


- (IBAction)logoutPressed:(id)sender {
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
    [post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        cell.postImageView.image = [UIImage imageWithData:data];
    }];
    cell.postCaption.text = post.caption;
    NSDate *createdAt = [cell.post createdAt];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *createdAtString = @"";
    // Configure the input format to parse the date string
    
    //convert string to date
    // Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"E MMM d HH:mm:ss Z y"];
    NSDate *todayDate = [NSDate date];
    //NSLog(@"%@", convertedDate);
    //NSLog(@"%@", todayDate);
    double ti = [createdAt timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    //NSLog(@"%f",ti);
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
    cell.profilePictureView.layer.cornerRadius = 17.5f;
    PFFileObject *image = [cell.post.author objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        cell.profilePictureView.image = [UIImage imageWithData:data];
    }];
    NSString *likeCountString = [post.likeCount stringValue];
    cell.likeCountLabel.text = likeCountString;
    cell.username.text = cell.post.author.username;
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //ask datasource for numberofrows
    //returns number of items returned from API
    return self.postArray.count;
}

- (void)postCell:(PostCell *)postCell didTap:(PFUser *)user{
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"profileSegue"]){
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = sender;
    } else {
        PostCell *tappedCell = sender;
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.post = tappedCell.post;
    }
}


@end
