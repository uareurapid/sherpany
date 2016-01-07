//
//  PhotosTableViewController.m
//  sherpany
//
//  Created by PC Dreams on 06/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "Photo.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "PhotoTableViewCell.h"
//handle async download and cache of the images
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"

@interface PhotosTableViewController ()

@end

@implementation PhotosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photosList = [[NSMutableArray alloc] init];
    
    [self loadPhotos];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    
}

#pragma core data
-(void) loadPhotos {
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:ALWAYS_LOAD_FROM_REMOTE]) {
       [self getPhotosListForAlbum: self.album.identifier];
    }
    else {
        NSArray * fetchedObjects = [self fetchPhotosFromContext: self.album.identifier];
        //loaded more than one
        if(fetchedObjects.count>0) {
            NSLog(@"adding %lu photos from local store",(unsigned long)fetchedObjects.count);
            [self addObjectsToTable: fetchedObjects];
        }
        else {
            [self getPhotosListForAlbum: self.album.identifier];
        }
    }
    
    
}

- (void) getPhotosListForAlbum: (NSNumber*) albumId{
    
    NSString *requestPath = @"/photos";
    
    
    //Here is my custom header code
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    //the album mappings
    RKEntityMapping *photoMapping = [RKEntityMapping mappingForEntityForName:@"Photo" inManagedObjectStore:objectManager.managedObjectStore];
    [photoMapping addAttributeMappingsFromDictionary:@{
                                                       @"albumId" : @"albumId",
                                                       @"id" : @"identifier",
                                                       @"url" : @"url",
                                                       @"title" : @"title",
                                                       @"thumbnailUrl" : @"thumbnailUrl"}];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:photoMapping method:RKRequestMethodAny pathPattern:@"/photos" keyPath:nil statusCodes:statusCodes];
    
    //****************** GET PHOTOS ******************************
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [objectManager
     getObjectsAtPath:requestPath
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //all albums have been saved in core data by now
         NSArray *fetchedObjects = [self fetchPhotosFromContext: self.album.identifier];
         // loop through every element and find the ones for this user
         //cause the REST API does not retrieve the photos of a single album
         for (Photo  *item in fetchedObjects) {
             
             if(item.albumId == self.album.identifier) {
                 //NSLog(@"adding photo with title: %@", item.title);
                 [self.photosList addObject:item];
             }
         }
         //reload the table
         [self.tableView reloadData];
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
     }
     ];
    
}

//load them from core data
- (NSArray *) fetchPhotosFromContext: (NSNumber*) albumId {
    
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"albumId == %@", albumId];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
    
}

//ass the objects to the list
-(void) addObjectsToTable: (NSArray *) fetchedObjects {
    [self.photosList addObjectsFromArray:fetchedObjects];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.photosList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Photo *photo = [self.photosList objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    cell.imgThumbnail.image = [UIImage imageNamed:@"placeholder.png"];
    cell.lblTitle.text = photo.title;
    
    NSURL *url = [NSURL URLWithString:photo.thumbnailUrl];
    
    //SDWebImage could take more time on first load but it caches stuff when we scroll, unlike the approach of the NSURLSessionTask task
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [cell.imgThumbnail sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    /*
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imgThumbnail.image = image;
                });
            }
        }
    }];
    [task resume];*/
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
