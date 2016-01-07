//
//  UsersTableViewController.m
//  sherpany
//
//  Created by PC Dreams on 05/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import "UsersTableViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "UserTableViewCell.h"
#import "Company.h"
#import "AlbumsTableViewController.h"
#import "Constants.h"

@interface UsersTableViewController ()

@end

@implementation UsersTableViewController

//TODO implement search: http://www.appcoda.com/search-bar-tutorial-ios7/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"usersTitle", @"usersTitle");
    //[self.navigationController.navigationBar.topItem setTitle:NSLocalizedString(@"usersTitle", @"usersTitle")];
    
    self.usersList = [[NSMutableArray alloc] init];
    self.searchResults = [[NSMutableArray alloc] init];
    
    self.searchDisplayController.searchBar.delegate = self;
    //load the users list
    [self loadUsersList];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    
    
    if(self.searchResults.count>0) {
        [self.searchResults removeAllObjects];
        if(self.searchDisplayController.active) {
            [self.searchDisplayController setActive:false];
            [self.searchDisplayController.searchBar resignFirstResponder];
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
        
    }
    return self.usersList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void) getUsersList {
    
    //NSString *requestPath = @"/users";
    
    //Here is my custom manager
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    //GEO
    RKEntityMapping *geoMapping = [RKEntityMapping mappingForEntityForName:@"Geo" inManagedObjectStore:objectManager.managedObjectStore];
    [geoMapping addAttributeMappingsFromDictionary:@{
                                                     @"lat" : @"lat",
                                                     @"lng" : @"lng"}];//mappings are in the following form "remote_name" : "local_name"
    
    //Address
    RKEntityMapping *addressMapping = [RKEntityMapping mappingForEntityForName:@"Address" inManagedObjectStore:objectManager.managedObjectStore];
    [addressMapping addAttributeMappingsFromDictionary:@{
                                                         @"city" : @"city",
                                                         @"street" : @"street",
                                                         @"suite" : @"suite",
                                                         @"zipcode" : @"zipcode"}];
    //address contains geo
    [addressMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"geo" toKeyPath:@"geo" withMapping:geoMapping]];
    
    //Company
    RKEntityMapping *companyMapping = [RKEntityMapping mappingForEntityForName:@"Company" inManagedObjectStore:objectManager.managedObjectStore];
    [companyMapping addAttributeMappingsFromDictionary:@{
                                                         @"name" : @"name",
                                                         @"catchPhrase" : @"catchphrase",
                                                         @"bs" : @"bs"}];
    
    //User
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:objectManager.managedObjectStore];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"identifier",
                                                      @"phone" : @"phone",
                                                      @"website" : @"website",
                                                      @"username" : @"username",
                                                      @"email" : @"email",
                                                      @"name" : @"name"}];
    userMapping.identificationAttributes = @[@"identifier"];
    [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:addressMapping]];
    [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"company" toKeyPath:@"company" withMapping:companyMapping]];
    
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodAny pathPattern:@"/users" keyPath:nil statusCodes:statusCodes];
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://jsonplaceholder.typicode.com/users"]];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    operation.managedObjectContext = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    operation.managedObjectCache = objectManager.managedObjectStore.managedObjectCache;
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        NSLog(@"Correctly received %lu users", (unsigned long)result.count);
        
        //get all users on the table view, that have been saved in core data by now
        NSArray *fetchedObjects = [self fetchUsersFromContext];
        //add them to the table
        [self addObjectsToTable:fetchedObjects];
        
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
    
    
    
    //****************** GET Users ******************************
    /*[objectManager addResponseDescriptor:responseDescriptor];
    
    [objectManager
     getObjectsAtPath:requestPath
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //get all users, that have been saved in core data by now
         NSArray *fetchedObjects = [self fetchUsersFromContext];
         NSLog(@"added %lu users from remote url",fetchedObjects.count);
         [self addObjectsToTable:fetchedObjects];
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
     }
     ];*/
    
}

//load them from core data
- (NSArray *) fetchUsersFromContext {
    
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
    
}

//ass the objects to the list
-(void) addObjectsToTable: (NSArray *) fetchedObjects {
    [self.usersList addObjectsFromArray:fetchedObjects];
    [self.tableView reloadData];
}

-(void) loadUsersList {
    
    //always load from remote?
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:ALWAYS_LOAD_FROM_REMOTE]) {
       [self getUsersList];
    }
    else {
        //try locally first
        NSArray * fetchedObjects = [self fetchUsersFromContext];
        //lhave something locally?
        if(fetchedObjects.count>0) {
            NSLog(@"adding from local store %lu",(unsigned long)fetchedObjects.count);
            [self addObjectsToTable: fetchedObjects];
        }
        else {
            //fallback
            [self getUsersList];
        }
    }
    
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserTableViewCell *cell = (UserTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    
    User *user;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        user = [self.usersList objectAtIndex:indexPath.row];
    }
    
    
    // Configure the cell...

    cell.lblName.text = user.name;
    cell.lblEmail.text = user.email;
    cell.lblCatchPhrase.text = user.company.catchphrase;
    
    return cell;
}

#pragma table delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    self.selectedUser = [self.usersList objectAtIndex:indexPath.row];
    NSLog(@"selected user with name: %@",self.selectedUser.name);
    [self performSegueWithIdentifier:@"showAlbums" sender:self];
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
#pragma search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchResults = [NSMutableArray arrayWithArray:[self.usersList filteredArrayUsingPredicate:resultPredicate]];
}
//this is ddeprectaed but that´s ok i think
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
 
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.

        AlbumsTableViewController* cvc = segue.destinationViewController;
        NSIndexPath *indexPath = nil;
    
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            self.selectedUser = [self.searchResults objectAtIndex:indexPath.row];
        } //else {
            // NO NEED
            //indexPath = [self.tableView indexPathForSelectedRow];
            //self.selectedUser = [self.usersList objectAtIndex:indexPath.row];
        //}

        cvc.user = self.selectedUser;
    
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:self.selectedUser.name style:     UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;

    
}


- (IBAction)exitClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
