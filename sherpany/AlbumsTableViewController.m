//
//  AlbumsTableViewController.m
//  sherpany
//
//  Created by PC Dreams on 06/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import "AlbumsTableViewController.h"
#include "PhotosTableViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "Album.h"
#import "User.h"
#import "Constants.h"
#import "AlbumTableViewCell.h"

@interface AlbumsTableViewController ()


@end

@implementation AlbumsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.albumsList = [[NSMutableArray alloc] init];
    
    [self loadAlbums];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    //[self.navigationItem.backBarButtonItem setTitle:self.user.name];
    
}

-(void) loadAlbums {
    
    //always load from remote?
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:ALWAYS_LOAD_FROM_REMOTE]) {
        [self getAlbumsListForUser: self.user.identifier];
    }
    else {
        NSArray * fetchedObjects = [self fetchAlbumsFromContext: self.user.identifier];
        //loaded more than one
        if(fetchedObjects.count>0) {
            NSLog(@"adding %lu devices from local store",(unsigned long)fetchedObjects.count);
            [self addObjectsToTable: fetchedObjects];
        }
        else {
            [self getAlbumsListForUser: self.user.identifier];
        }
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    NSLog(@"name selected is: %@",self.user.name);
}

- (void) getAlbumsListForUser: (NSNumber*) userId{
    
    NSString *requestPath = @"/albums";
    
    
    //Here is my custom header code
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    //the album mappings
    RKEntityMapping *albumMapping = [RKEntityMapping mappingForEntityForName:@"Album" inManagedObjectStore:objectManager.managedObjectStore];
    [albumMapping addAttributeMappingsFromDictionary:@{
                                                       @"userId" : @"userId",
                                                       @"title" : @"title",
                                                       @"id" : @"identifier"}];
    
     NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:albumMapping method:RKRequestMethodAny pathPattern:@"/albums" keyPath:nil statusCodes:statusCodes];
    
    //****************** GET ALBUMS ******************************
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [objectManager
     getObjectsAtPath:requestPath
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //all albums have been saved in core data by now
         NSArray *fetchedObjects = [self fetchAlbumsFromContext: self.user.identifier];
         // loop through every element and find the ones for this user
         //cause the REST API does not retrieve the albums of a single user
         for (Album  *item in fetchedObjects) {

             if(item.userId == self.user.identifier) {
                 //NSLog(@"adding album title: %@", item.title);
                 [self.albumsList addObject:item];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.albumsList.count;
}

//load them from core data
- (NSArray *) fetchAlbumsFromContext: (NSNumber*) userId {
    
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
    
}

//ass the objects to the list
-(void) addObjectsToTable: (NSArray *) fetchedObjects {
    [self.albumsList addObjectsFromArray:fetchedObjects];
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Album *album = [self.albumsList objectAtIndex:indexPath.row];
    AlbumTableViewCell *cell = (AlbumTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    
    // Configure the cell...
    
    cell.lblTitle.text = album.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    self.selectedAlbum = [self.albumsList objectAtIndex:indexPath.row];
    NSLog(@"selected album with title: %@",self.selectedAlbum.title);
    [self performSegueWithIdentifier:@"showPhotos" sender:self];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    //UINavigationController *navController = segue.destinationViewController;
    PhotosTableViewController* cvc = segue.destinationViewController;//[navController childViewControllers].firstObject;
    
    cvc.album = self.selectedAlbum;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:self.selectedAlbum.title style:     UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    

}


@end
