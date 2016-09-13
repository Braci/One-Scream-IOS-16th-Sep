//
//  ThankyouController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for last Screen of first tour
//

#import "ThankyouController.h"
#import "UpgradeController.h"
#import "EngineMgr.h"

@interface ThankyouController ()<UIGestureRecognizerDelegate>

@end

@implementation ThankyouController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.fromMenu) {
        self.back.hidden = NO;
        [self.back setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
        self.trail.hidden = YES;
        self.subscribe.hidden = YES;
        self.control.numberOfPages = 4;
        self.control.currentPage = 3;


    }else {
        self.control.numberOfPages = 6;
        self.control.currentPage = 5;

        self.back.hidden = YES;

        self.trail.hidden = NO;
        self.subscribe.hidden = NO;
        [self.back setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];

    }
    

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.delegate = self;

    
    // Setting the swipe direction.
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    
    [swipeRight setNumberOfTouchesRequired:1];
    // Adding the swipe gesture on image view
    [self.view addGestureRecognizer:swipeRight];
    // Do any additional setup after loading the view, typically from a nib.
    [swipeRight setCancelsTouchesInView:NO];
    [self.view bringSubviewToFront:self.subscribe];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"One More thing screen"];

}

- (IBAction)onFreeTrial:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"subscribeORTrail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onSubscribe:(id)sender {
   /* [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"subscribeORTrail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [EngineMgr sharedInstance].isNeedToSubscribe = YES;
    [self.navigationController popToRootViewControllerAnimated:NO];*/
    
}
- (IBAction)backButtonPressed:(id)sender {
    
    if (self.fromMenu){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        
//        ThankyouController *nextScr = (ThankyouController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ThankyouController"];
//        nextScr.fromMenu = self.fromMenu;
//        [self.navigationController pushViewController:nextScr animated:YES];
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Right Swipe");
        
        [self.navigationController popViewControllerAnimated:YES];

        
    }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"%@",NSStringFromClass([gestureRecognizer class]));
    
    CGPoint location = [touch locationInView:touch.view];
    
    if (CGRectContainsPoint(_subscribe.frame,location)) {//change it to your condition
        [self onSubscribe:_subscribe];
        return NO;
    }
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

@end
