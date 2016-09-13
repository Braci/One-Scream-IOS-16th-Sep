//
//  Tour3ViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 28/01/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "Tour3ViewController.h"
#import "SignupController.h"
#import "ThankyouController.h"

@interface Tour3ViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation Tour3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.fromMenu) {
        self.back.hidden = NO;
        self.tahtsIt.hidden = YES;
    }else {
        self.control.numberOfPages = 6;
    }
    
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.delegate = self;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.delegate = self;
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeLeft setNumberOfTouchesRequired:1];
    [swipeRight setNumberOfTouchesRequired:1];
    // Adding the swipe gesture on image view
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
    
    [self setTourText];
    
    
   
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Tour Screen 3"];

}
-(void)setTourText{
    
    
    NSString *details = @"Your phone is switched off\n\nYou are on a call\n\nYou are at a concert or riding a roller coaster\n\nYou are using other voice-activated apps\n\nThe good news is One Scream can hear you from a distance, and you will still be protected if your phone is buried in your bag.";
    NSMutableAttributedString *detailAtributtedString = [[NSMutableAttributedString alloc] initWithString:details];
    
    NSRange fullRange = NSMakeRange(0, [details length]);
    
    CGFloat fSize = 14.39;
    if (self.view.frame.size.width == 320){
        fSize = 10.5;
    }
   // UIFont * font = [UIFont fontWithName:@"SFUIText-Regular" size:fSize];
    UIFont * semiBoldFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:fSize];
    
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [detailAtributtedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:fullRange];
    
    
    
    [detailAtributtedString addAttribute: NSFontAttributeName value:semiBoldFont range: fullRange];
    [detailAtributtedString addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:52/255.0 green:66/255.0 blue:81/255.0 alpha:1.0]  range: fullRange];//
    
    
    
    
    NSRange privacyRange = [details rangeOfString:@"The good news is One Scream can hear you from a distance, and you will still be protected if your phone is buried in your bag."];
    [detailAtributtedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:109/255.0 green:130/255.0 blue:152/255.0 alpha:1.0]  range:privacyRange];
    self.detailLabel.attributedText = detailAtributtedString;
    
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        
        
        if (_fromMenu){
            ThankyouController *nextScr = (ThankyouController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ThankyouController"];
            nextScr.fromMenu = self.fromMenu;
            nextScr.hidebtn = YES;
            [self.navigationController pushViewController:nextScr animated:YES];
        }else{
            
            
            SignupController * spVC = (SignupController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignupController"];
            [self.navigationController pushViewController:spVC animated:true];
        }
        

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

- (IBAction)ThatsIt:(id)sender {
    SignupController *nextScr = (SignupController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignupController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)unwindToTour3:(UIStoryboardSegue *)unwindSegue
{
}


@end
