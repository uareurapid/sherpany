//
//  UserTableViewCell.h
//  sherpany
//
//  Created by PC Dreams on 06/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblCatchPhrase;

@end
