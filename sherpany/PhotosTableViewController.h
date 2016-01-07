//
//  PhotosTableViewController.h
//  sherpany
//
//  Created by PC Dreams on 06/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface PhotosTableViewController : UITableViewController
@property (strong, nonatomic) NSMutableArray *photosList;
@property (strong, nonatomic) Album *album;

@end
