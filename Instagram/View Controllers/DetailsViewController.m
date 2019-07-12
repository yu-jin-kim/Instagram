//
//  DetailsViewController.m
//  Instagram
//
//  Created by yujinkim on 7/9/19.
//  Copyright © 2019 yujinkim. All rights reserved.
//

#import "DetailsViewController.h"
#import "CommentCell.h"
#import "CommentViewController.h"

@interface DetailsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *commentsArray;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // setting our delegate and datasource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //fetch our comments from the server and set our array of comments
    [self fetchComments];
    
    //grab profile image from server and set it to our imageview with circular style
    self.profilePicture.layer.cornerRadius = 17.5f;
    PFFileObject *image = [self.post.author objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.profilePicture.image = [UIImage imageWithData:data];
    }];
    
    //set our like count and username
    NSString *likeCountString = [self.post.likeCount stringValue];
    self.likeCount.text = likeCountString;
    self.username.text = self.post.author.username;
    //grab the post image from server and set it to our imageview
    [self.post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.postImageView.image = [UIImage imageWithData:data];
    }];
    //set our caption
    self.postCaption.text = self.post.caption;
    
    //begin formatting and setting our relative timestamps
    NSDate *createdAt = [self.post createdAt];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *createdAtString = @"";
    // Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"E MMM d HH:mm:ss Z y"];
    NSDate *todayDate = [NSDate date];
    //calculate time since posted to now
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
    self.timestampLabel.text = createdAtString;
    //if the current user has liked a post previously, we want it to show a red heart, otherwise, normal heart
    PFUser *currentUser = [PFUser currentUser];
    NSArray *likedUsers = [[NSArray alloc] init];
    likedUsers = [self.post objectForKey:@"likes"];
    [self.likeButton setImage:[UIImage imageNamed:@"hearticon2.png"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"redhearticon.png"] forState:UIControlStateSelected];
    if(![likedUsers containsObject:currentUser.username]){
        self.likeButton.selected = NO;
        
    }
    else{
        self.likeButton.selected = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    //update our views again in case the user had commented and wants to see updated properties after the comment viewcontroller has been dismissed
    [self fetchComments];
    PFUser *currentUser = [PFUser currentUser];
    NSArray *likedUsers = [[NSArray alloc] init];
    likedUsers = [self.post objectForKey:@"likes"];
    [self.likeButton setImage:[UIImage imageNamed:@"hearticon2.png"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"redhearticon.png"] forState:UIControlStateSelected];
    if(![likedUsers containsObject:currentUser.username]){
        self.likeButton.selected = NO;
    }
    else{
        self.likeButton.selected = YES;
        
    }
}

- (IBAction)likeButtonPressed:(id)sender {
    //keep track of current user's session
    PFUser *currentUser = [PFUser currentUser];
    NSArray *likedUsers = [[NSArray alloc] init];
    likedUsers = [self.post objectForKey:@"likes"];
    if(![likedUsers containsObject:currentUser.username]){
        //if the current user has not liked a post, add the current user to array of liked users, like the post, increment likecount, and set the button to selected
        [self.post addObject:currentUser.username forKey:@"likes"];
        likedUsers = [self.post objectForKey:@"likes"];
        [self.post setObject:@(likedUsers.count) forKey:@"likeCount"];
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
            }}];
        NSString *likeCountString = [NSString stringWithFormat:@"%@",@(likedUsers.count)];
        self.likeCount.text = likeCountString;
        self.likeButton.selected = YES;
        [self.likeButton setImage:[UIImage imageNamed:@"redhearticon.png"] forState:UIControlStateSelected];
    }
    else{
        //otherwise, remove the current user from the array, unlike the post, decrememnt likecount, and set the button to unselected
        [self.post removeObject:currentUser.username forKey:@"likes"];
        likedUsers = [self.post objectForKey:@"likes"];
        [self.post setObject:@(likedUsers.count) forKey:@"likeCount"];
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
            }}];
        NSString *likeCountString = [NSString stringWithFormat:@"%@",@(likedUsers.count)];
        self.likeCount.text = likeCountString;
        self.likeButton.selected = NO;
        [self.likeButton setImage:[UIImage imageNamed:@"hearticon2.png"] forState:UIControlStateNormal];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //ask datasource for cellsforrowat
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    NSString *comment = self.commentsArray[indexPath.row];
    cell.commentLabel.text = comment;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //ask datasource for numberofrows
    return self.commentsArray.count;
}

- (void)fetchComments{
    //taking the comments array of post from server
    self.commentsArray = [self.post objectForKey:@"comments"];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CommentViewController *commentViewController = [segue destinationViewController];
    commentViewController.post = self.post;
}


@end
