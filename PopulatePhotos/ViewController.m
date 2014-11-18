//
//  ViewController.m
//  PopulatePhotos
//
//  Created by Brad Kendall on 11/17/14.
//  Copyright (c) 2014 Brad Kendall. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.library = [[ALAssetsLibrary alloc] init];
    self.mediaArray = [[NSMutableArray alloc] init];
    self.albumsToCreate = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)fillPhotos:(id)sender
{
    if ([self.searchTerm.text length] > 0 && [self.totalPhotos.text intValue])
    {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
        self.hud.labelText = @"Doing Stuff";
        
        self.totalPhotosAdded = 0;
        self.currentPaginationInfo = nil;
        [self loadFirstPage];
    }
    else
    {
        if ([self.searchTerm.text length] <= 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must specify a search term!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else if (![self.totalPhotos.text intValue])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Total Photos needs to be a number!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)loadFirstPage
{
    [[InstagramEngine sharedEngine] getMediaWithTagName:self.searchTerm.text count:100 maxId:self.currentPaginationInfo.nextMaxId withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.currentPaginationInfo = paginationInfo;
        [self.mediaArray addObjectsFromArray:media];
        
        self.currentIndex = 0;
        [self doNextPhoto];
        
    } failure:^(NSError *error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Media Search Failed!  Try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];

    }];
}
-(void)loadNextPage
{
    [[InstagramEngine sharedEngine] getPaginatedItemsForInfo:self.currentPaginationInfo withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.currentPaginationInfo = paginationInfo;
        
        [self.mediaArray removeAllObjects];
        [self.mediaArray addObjectsFromArray:media];
        
        self.currentIndex = 0;
        [self doNextPhoto];
        
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Page search error!  Try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];

    }];

}

-(void)saveToAssetLibrary
{
    InstagramMedia *media = [self.mediaArray objectAtIndex:self.currentIndex];
    
    if (!media.isVideo)
    {
        UIImage *theImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:media.standardResolutionImageURL]];
      
        //Save it
        
        [self.library saveImage:theImage toAlbum:[self getAlbumTitle] withCompletionBlock:^(NSError *error) {
            if (error!=nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];

                
                [self doNextPhoto];
            }
            else
            {
                self.totalPhotosAdded = self.totalPhotosAdded + 1;
                //Carry on!
                [self doNextPhoto];
            }
        }];
    }
    else
    {
        //Don't save video to the asset library - just skip it
        [self doNextPhoto];
    }
}

-(void)doNextPhoto
{
    if (self.totalPhotosAdded < [self.totalPhotos.text intValue])
    {
        self.currentIndex = self.currentIndex + 1;
        
        CGFloat progress = (float)self.totalPhotosAdded / [self.totalPhotos.text floatValue];
        self.hud.progress = progress;
        self.hud.labelText = [NSString stringWithFormat:@"Saved %ld / %d", (long)self.totalPhotosAdded, [self.totalPhotos.text intValue]];
        
        if (self.currentIndex >= [self.mediaArray count])
        {
            //Out of photos, download more!
            [self loadNextPage];
        }
        else
        {
            //Save the next photo in the array
            [self saveToAssetLibrary];
        }
    }
    else
    {
        //We are done
        [self.hud hide:YES];
    }
}

-(NSString *)getAlbumTitle
{
    if ([self.albumsToCreate count] == 0)
    {
        //return a blank string to just save directly to the camera roll.
        return @"";
    }
    else
    {
        self.currentAlbumIndex = self.currentAlbumIndex + 1;
        
        if (self.currentAlbumIndex >= [self.albumsToCreate count])
        {
            self.currentAlbumIndex = 0;
        }
        
        return [self.albumsToCreate objectAtIndex:self.currentAlbumIndex];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.albumInput)
    {
        if ([self.albumInput.text length] > 0)
        {
            //Add the album name to the array
            [self.albumsToCreate addObject:self.albumInput.text];
            self.albumInput.text = @"";
            [self.albumInput resignFirstResponder];
            [self.tableView reloadData];
        }
    }
    return YES;
}

//Tableview Stuff
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.albumsToCreate count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.albumsToCreate objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.albumsToCreate removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

@end
