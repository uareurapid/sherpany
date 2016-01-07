//
//  AlbumsTableViewController.h
//  sherpany
//
//  Created by PC Dreams on 06/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "User.h"

@interface AlbumsTableViewController : UITableViewController
//album owner
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Album *selectedAlbum;
@property (nonatomic, strong) NSMutableArray *albumsList;


@end
