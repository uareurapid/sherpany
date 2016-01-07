//
//  UsersTableViewController.h
//  sherpany
//
//  Created by PC Dreams on 05/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UsersTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *usersList;
@property (assign, nonatomic) User *selectedUser;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (IBAction)exitClicked:(id)sender;

@end
