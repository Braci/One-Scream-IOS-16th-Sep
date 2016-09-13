//
//  Tour2ViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 28/01/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "Tour2ViewController.h"
#import "Tour3ViewController.h"

@interface Tour2ViewController ()<UIGestureRecognizerDelegate>

@end

@implementation Tour2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.fromMenu) {
        self.back.hidden = NO;
    }else {
        self.control.numberOfPages = 6;
    }
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.delegate = self;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.delegate = self;

    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeLeft setNumberOfTouchesRequired:1];
    [swipeRight setNumberOfTouchesRequired:1];
    // Adding the swipe gesture on image view
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Tour Screen 2"];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        
        Tour3ViewController *nextScr = (Tour3ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR3"];
        nextScr.fromMenu = self.fromMenu;
        [self.navigationController pushViewController:nextScr animated:YES];
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Right Swipe");
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"%@",NSStringFromClass([gestureRecognizer class]));
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

- (IBAction)unwindToTour2:(UIStoryboardSegue *)unwindSegue
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
