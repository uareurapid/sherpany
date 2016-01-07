//
//  ViewController.m
//  sherpany
//
//  Created by PC Dreams on 05/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import "Constants.h"
#import "UsersTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    self.alwaysLoadRemote.on = [defaults boolForKey:ALWAYS_LOAD_FROM_REMOTE];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//always load from remote url, or fetch from local data?
- (IBAction)alwaysLoadRemoteChanged:(id)sender{
    
        
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:self.alwaysLoadRemote.on forKey:ALWAYS_LOAD_FROM_REMOTE];
    
}


@end
