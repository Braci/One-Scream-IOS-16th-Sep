//
//  ResetViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 24/02/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "ResetViewController.h"
//#import "Parse/Parse.h"
#import "EngineMgr.h"
#import <Backendless.h>
#import <BackendlessUser.h>
@interface ResetViewController ()

{
    UITextField *activeField;
    UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIButton *thanksButton;
    __weak IBOutlet UIButton *resetButton;


    __weak IBOutlet UILabel *subtitleLabel;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIImageView *sepratorLabel;
    
}
@property (weak, nonatomic) IBOutlet UITextField *m_etEmail;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation ResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self setErrorMessageText];

}

-(void)setErrorMessageText{
    
    
    
    NSString *details = @"Oops: We couldn't find that email address.";
    NSMutableAttributedString *detailAtributtedString = [[NSMutableAttributedString alloc] initWithString:details];
    
    NSRange fullRange = NSMakeRange(0, [details length]);
    
    CGFloat fSize = 13;

    UIFont * font = [UIFont fontWithName:@"SanFranciscoDisplay-Bold" size:fSize];
    //UIFont * semiBoldFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:fSize];
    
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [detailAtributtedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:fullRange];
    
    
    
    [detailAtributtedString addAttribute: NSFontAttributeName value:font range: fullRange];
    [detailAtributtedString addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:34/255.0 green:42/255.0 blue:51/255.0 alpha:1.0]  range: fullRange];//
    
    
    
    
    NSRange privacyRange = [details rangeOfString:@"Oops:"];
    [detailAtributtedString addAttribute: NSFontAttributeName value:font range: privacyRange];
    [detailAtributtedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227/255.0 green:187/255.0 blue:78/255.0 alpha:1.0]  range:privacyRange];
    self.errorLabel.attributedText = detailAtributtedString;
    self.errorLabel.adjustsFontSizeToFitWidth = true;
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Reset password screen"];
}

- (IBAction)thanksButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)OKButtonPressed:(id)sender {
    
    if([self.m_etEmail.text isEqualToString:@""] || self.m_etEmail.text.length <5 || ![EngineMgr validateEmailWithString:self.m_etEmail.text])
    {
        [self showAlert:@"Invalid Email" alertTag:0];
        return;
    }
    [self.m_etEmail resignFirstResponder];
    [self addIndicator];
    [backendless.userService restorePassword:self.m_etEmail.text response:^(id response) {
        thanksButton.hidden = false;
        backButton.hidden = true;
        titleLabel.text = @"Success!";
        subtitleLabel.text = @"Your password reset email has been sent.";
        resetButton.hidden = true;
        sepratorLabel.hidden = true;
        _m_etEmail.hidden = true;
        _errorLabel.hidden = true;
        [self stopIndicator];
    } error:^(Fault *error) {
        self.errorLabel.hidden = false;
        [self stopIndicator];
    }];
    
}
     
     - (void)showAlert:(NSString *)message alertTag:(NSInteger *)tag
    {
        UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        myalert.tag = (NSInteger)tag;
        [myalert show];
    }


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    //[self animateViewMoving:self.view direction:YES moveValue:200];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    //[self animateViewMoving:self.view direction:NO moveValue:200];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if(textField == self.m_etEmail)
    {
        // [m_etPassword becomeFirstResponder];
    }
    return YES;
}


// Called when the UIKeyboardDidShowNotification is sent.


-(void)animateViewMoving:(UIView *)toView direction:(BOOL)isUP moveValue:(CGFloat)value{
    
    NSTimeInterval  movementDuration = 0.3;
    CGFloat movement = ( isUP ? -value : value);
    [UIView beginAnimations:@"animateView" context: nil];
    [UIView setAnimationBeginsFromCurrentState:true];
    [UIView setAnimationDuration:movementDuration];
    toView.frame = CGRectOffset(toView.frame, 0,  movement);
    [UIView commitAnimations];
}


- (void)addIndicator
{
    activityIndicator.alpha = 1.0;
    activityIndicator.center = self.view.center;
    activityIndicator.hidesWhenStopped = NO;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}
- (void)stopIndicator
{
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
}


@end
