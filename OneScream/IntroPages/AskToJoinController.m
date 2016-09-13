//
//  AskToJoinController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class to ask to join in One Scream
//

#import "AskToJoinController.h"
#import "EngineMgr.h"
//#import <Parse/Parse.h>
#import <Backendless.h>
#import <BackendlessUser.h>
@interface AskToJoinController ()

@end

@implementation AskToJoinController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)onYesPlease:(id)sender {
    /**
     * Yes, Please. -> Notify to the home screen to go to upgrade screen
     */
    [EngineMgr sharedInstance].isNeedToSubscribe = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNotNow:(id)sender {
    
    /**
     * Not now -> make the app scilence until the date is expire.
     */
    BackendlessUser *user = backendless.userService.currentUser;
    NSString *strKey = [NSString stringWithFormat:@"%@_ask", [EngineMgr convertEmailToChannelStr:user.email]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [EngineMgr sharedInstance].isAutoStartProtecting = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
