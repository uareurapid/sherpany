//
//  ViewController.h
//  sherpany
//
//  Created by PC Dreams on 05/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *alwaysLoadRemote;
- (IBAction)alwaysLoadRemoteChanged:(id)sender;
@end

