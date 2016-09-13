//
//  FirstPageController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing Login and Signup button when the user logged out
//

#import "FirstPageController.h"
#import "HowToController.h"
#import "LoginController.h"
#import "SignupController.h"
#import "Tour1UIVViewController.h"
#import "HomeController.h"
#include "EngineMgr.h"
//#import "UIViewController+ECSlidingViewController.h"

@interface FirstPageController ()

@end

@implementation FirstPageController {
    
}

int page = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    if([EngineMgr sharedInstance].isDetecting){
//        
//        NSArray *array = [self.navigationController viewControllers];
//        for (UIViewController *vc in array){
//            if([vc isMemberOfClass:[HomeController class]]){
//                HomeController *hm = (HomeController*) vc;
//                [hm switchDetecting];
//            }
//        }
//
//    }
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipeLeft setNumberOfTouchesRequired:1];
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [self.view addGestureRecognizer:swipeLeft];
//    [self.view addGestureRecognizer:swipeRight];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [AppEventTracker trackScreenWithName:@"Landing screen"];
}

- (IBAction)onLogin:(id)sender {
    LoginController *nextScr = (LoginController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)onSignup:(id)sender {
   /* if (self.m_bFirst) {
//        HowToController *nextScr = (HowToController *) [self.storyboard instantiateViewControllerWithIdentifier:@"HowToController"];
//        [self.navigationController pushViewController:nextScr animated:YES];
        Tour1UIVViewController *nextScr = (Tour1UIVViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR1"];
        nextScr.fromMenu = NO;
        [self.navigationController pushViewController:nextScr animated:YES];
    } else {
        SignupController *nextScr = (SignupController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignupController"];
        [self.navigationController pushViewController:nextScr animated:YES];
    }*/
    
    Tour1UIVViewController *nextScr = (Tour1UIVViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR1"];
    nextScr.fromMenu = NO;
    [self.navigationController pushViewController:nextScr animated:YES];
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        Tour1UIVViewController *nextScr = (Tour1UIVViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR1"];
        nextScr.fromMenu = NO;
        [self.navigationController pushViewController:nextScr animated:YES];
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Right Swipe");
        if (page == 0){
            
        }
    }
    
}

- (IBAction)unwindToFirstViewController:(UIStoryboardSegue *)unwindSegue
{
}

@end
