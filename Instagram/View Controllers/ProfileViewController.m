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

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) bool isMoreDataLoading;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //setting our datasource and delgate
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    //hide our edit profile button unless self.user is currentuser so that no one else can edit others' profiles
    self.editButton.hidden = YES;
    if(self.user == nil){
        self.user = [PFUser currentUser];
        self.editButton.hidden = NO;
    }
    //fetch our posts from the server and set it to our array of posts
    [self fetchPosts];
    
    //styling our edit button to have rounded borders
    self.editButton.layer.borderWidth = 1.0f;
    self.editButton.layer.borderColor = [[UIColor grayColor] CGColor];
    self.editButton.layer.cornerRadius = 5.0f;
    
    //circular profile image
    self.profileImageView.layer.cornerRadius = 50.0f;
    
    //making sure our collection view has three picture per row
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    CGFloat imagesPerLine = 3;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (imagesPerLine - 1)) / imagesPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    //fetching the user's profile image from server and setting it to our imageview
    PFFileObject *image = [self.user objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.profileImage = [UIImage imageWithData:data];
        self.profileImageView.image = self.profileImage;
    }];
    
    //set the rest of our user information to corresponding labels
    self.username.text = self.user.username;
    NSString *userBio = [self.user objectForKey:@"userBio"];
    self.bioLabel.text = userBio;
    self.postCountLabel.text = [NSString stringWithFormat:@"%lu", self.postArray.count];
}

- (void)viewDidAppear:(BOOL)animated{
    //update these properties again in case the user edited profile and wants to see updated changes once editviewcontroller is dismissed
    [self fetchPosts];
    PFFileObject *image = [self.user objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.profileImage = [UIImage imageWithData:data];
        self.profileImageView.image = self.profileImage;
    }];
    NSString *userBio = [self.user objectForKey:@"userBio"];
    self.bioLabel.text = userBio;
    self.postCountLabel.text = [NSString stringWithFormat:@"%lu", self.postArray.count];
}

- (void)fetchPosts{
    // construct query
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:self.user];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts) {
            self.postArray = posts;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //populate our collection view cells with the data we fetched
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCollectionViewCell" forIndexPath:indexPath];
    Post *post = self.postArray[indexPath.row];
    cell.post = post;
    [post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        cell.postImageView.image = [UIImage imageWithData:data];
    }];
   
    return cell;
    
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.postArray.count;
}

@end
