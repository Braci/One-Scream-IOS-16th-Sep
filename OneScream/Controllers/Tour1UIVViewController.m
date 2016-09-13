//
//  Tour1UIVViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 28/01/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "Tour1UIVViewController.h"
#import "Tour2ViewController.h"

@interface Tour1UIVViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *gestureContainer;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation Tour1UIVViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.fromMenu) {
        self.back.hidden = NO;
    }else {
        self.control.numberOfPages = 6;
    }
    
    //[self.bottomUp constant] =
    

    
    // Adding the swipe gesture on image view
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.delegate = self;

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe1:)];
    swipeRight.delegate = self;

    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeLeft setNumberOfTouchesRequired:1];
    [swipeRight setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
    [self setTourText];
    
    [self.view setUserInteractionEnabled:YES];

    

}

-(void)setTourText{
    
    
    NSString *details = @"We hope you'll never need One Scream.\n\nBut if you are in danger and can not phone for help, we will hear your scream and send an automated message to 999, telling them who you are and where to find you.\n\nOne Scream has been scientifically developed to only respond to genuine panic screams. Just as your own ear hears real distress, our app can also distinguish a true panic scream from other screams and sounds.";
    NSMutableAttributedString *detailAtributtedString = [[NSMutableAttributedString alloc] initWithString:details];
    
    NSRange fullRange = NSMakeRange(0, [details length]);
    
    CGFloat fSize = 14.39;
    if (self.view.frame.size.width == 320){
        fSize = 12.5;
    }// SFUIText-Regular
    UIFont * font = [UIFont fontWithName:@"ProximaNova-Semibold" size:fSize];
    UIFont * semiBoldFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:fSize];


    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [detailAtributtedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:fullRange];
    

    
    [detailAtributtedString addAttribute: NSFontAttributeName value:semiBoldFont range: fullRange];
    [detailAtributtedString addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:52/255.0 green:66/255.0 blue:81/255.0 alpha:1.0]  range: fullRange];//
    
    
    
    
    NSRange privacyRange = [details rangeOfString:@"One Scream has been scientifically developed to only respond to genuine panic screams. Just as your own ear hears real distress, our app can also distinguish a true panic scream from other screams and sounds."];
    [detailAtributtedString addAttribute: NSFontAttributeName value:font range: privacyRange];
    [detailAtributtedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:109/255.0 green:130/255.0 blue:152/255.0 alpha:1.0]  range:privacyRange];
    self.detailLabel.attributedText = detailAtributtedString;
    self.detailLabel.adjustsFontSizeToFitWidth = true;
    
    
    
    
        

}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Tour Screen 1"];

    
 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSwipe:(UIGestureRecognizer *)swipeGuesture {
    
    if ([swipeGuesture isKindOfClass:[UISwipeGestureRecognizer class]]){
    
        UISwipeGestureRecognizer * swipe = (UISwipeGestureRecognizer *)swipeGuesture;
        if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
            NSLog(@"Left Swipe");
            
            Tour2ViewController *nextScr = (Tour2ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR2"];
            nextScr.fromMenu = self.fromMenu;
            [self.navigationController pushViewController:nextScr animated:YES];
        }
        
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"Right Swipe");
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }

    
}
- (void)handleSwipe1:(UIGestureRecognizer *)swipeGuesture {
    
    if ([swipeGuesture isKindOfClass:[UISwipeGestureRecognizer class]]){
        
        UISwipeGestureRecognizer * swipe = (UISwipeGestureRecognizer *)swipeGuesture;
        if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
            NSLog(@"Left Swipe");
            
            Tour2ViewController *nextScr = (Tour2ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR2"];
            nextScr.fromMenu = self.fromMenu;
            [self.navigationController pushViewController:nextScr animated:YES];
        }
        
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"Right Swipe");
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    NSLog(@"%@",NSStringFromClass([gestureRecognizer class]));
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
        
        //[self handleSwipe:gestureRecognizer];
    }
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)unwindToTour1:(UIStoryboardSegue *)unwindSegue
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
