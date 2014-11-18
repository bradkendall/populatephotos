//
//  ViewController.h
//  PopulatePhotos
//
//  Created by Brad Kendall on 11/17/14.
//  Copyright (c) 2014 Brad Kendall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "InstagramKit.h"
#import "MBProgressHUD.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) InstagramPaginationInfo *currentPaginationInfo;
@property (strong, atomic) ALAssetsLibrary* library;
@property NSInteger currentIndex;
@property NSMutableArray *mediaArray;
@property NSMutableArray *albumsToCreate;
@property NSInteger currentAlbumIndex;
@property NSInteger totalPhotosAdded;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *albumInput;
@property (nonatomic, strong) IBOutlet UITextField *totalPhotos;
@property (nonatomic, strong) IBOutlet UITextField *searchTerm;
@property MBProgressHUD *hud;

-(IBAction)fillPhotos:(id)sender;
@end

