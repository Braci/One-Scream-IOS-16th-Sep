//
//  LicenseController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for License Screen after signing up
//

#import "LicenseController.h"
#import "TermsController.h"
#import "PrivacyController.h"
#import "ThankyouController.h"

@interface LicenseController ()

@end

@implementation LicenseController

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

- (IBAction)onTermsAndConditions:(id)sender {
    TermsController *nextScr = (TermsController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TermsController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)onPrivacyPolicy:(id)sender {
    PrivacyController *nextScr = (PrivacyController *) [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)onAgree:(id)sender {
    ThankyouController *nextScr = (ThankyouController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ThankyouController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}
@end
