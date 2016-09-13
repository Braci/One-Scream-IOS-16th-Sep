//
//  SignupController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Signup Screen



/* 
 
 "SFUIText-LightItalic",
 "SFUIText-Bold",
 "SFUIText-Regular",
 "SFUIText-Italic",
 "SFUIText-Light",
 "SFUIText-Semibold",
 "SFUIText-BoldItalic"
 
 */
//

#import "FirstPageController.h"
#import "SignupController.h"
#import "LoginController.h"
#import "TermsController.h"
#import "WiFisController.h"
#import "ThankyouController.h"
#import "PrivacyController.h"
#import "EngineMgr.h"
//#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FrequentAddressViewController.h"
#import "Backendless.h"
#import "User.h"
@interface SignupController ()
{
    __weak IBOutlet UIButton *m_privicyButton;
    __weak IBOutlet UIButton *m_TermAndConditionButton;
    __weak IBOutlet NSLayoutConstraint *privicyButtonWidthConstraint;

    __weak IBOutlet NSLayoutConstraint *termAndConditionButtonWidthConstraint;
    __weak IBOutlet CustomButton *createButton;
    
    __weak IBOutlet UITextField *m_password;
    __weak IBOutlet UITextField *m_reTypePassword;
    __weak IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
}
@end

@implementation SignupController {
    UIActivityIndicatorView *activityIndicator;
    BOOL m_bUIRearrangeNeeded;
}

@synthesize scrollView;
@synthesize m_etFirstName;
@synthesize m_etPhoneNumber;
@synthesize m_etEmail;



- (void)viewDidLoad {
    [super viewDidLoad];

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self registerForKeyboardNotifications];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
    }];
    
    m_TermAndConditionButton.titleLabel.numberOfLines = 1;
    m_TermAndConditionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    m_TermAndConditionButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    m_privicyButton.titleLabel.numberOfLines = 1;
    m_privicyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    m_privicyButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    m_etPhoneNumber.format = @"XXX XXXX XXXX";

    

    
    
    NSString *statementString = @"By tapping to \"Create account\", you are indicating that you have read the Privacy Policy and agree to the Terms of Service.";
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:statementString];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSRange fullRange = NSMakeRange(0, [stringText length]);
    [stringText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:fullRange];
    
    CGFloat fSize = 9.55;
    if (self.view.frame.size.width == 320){
        fSize = 7.5;
    }
    
    UIFont * font = [UIFont fontWithName:@"SanFranciscoText-Medium" size:fSize];
    [stringText addAttribute: NSFontAttributeName value:font range: fullRange];
    [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:107/255.0 green:128/255.0 blue:150/255.0 alpha:1.0] range: fullRange];
    
    //NSLog (@"Font families: %@", [UIFont familyNames]);
    

    UIFont * semiBoldFont = [UIFont fontWithName:@"SanFranciscoText-Bold" size:fSize];
    
    
    NSRange privacyRange = [statementString rangeOfString:@"Privacy Policy"];
    [stringText addAttribute: NSFontAttributeName value:semiBoldFont range: privacyRange];
    [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:52/255.0 green:66/255.0 blue:81/255.0 alpha:1.0] range:privacyRange];
    
    
    NSRange termsRange = [statementString rangeOfString:@"Terms of Service"];
    [stringText addAttribute: NSFontAttributeName value:semiBoldFont range:termsRange];
    [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:52/255.0 green:66/255.0 blue:81/255.0 alpha:1.0] range:termsRange];
    
    

    
    self.termAndCondtionLabel.attributedText = stringText;
    self.termAndCondtionLabel.numberOfLines = 2;
    self.termAndCondtionLabel.minimumScaleFactor = 0.5;
    self.termAndCondtionLabel.adjustsFontSizeToFitWidth = YES;
    self.termAndCondtionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.termAndCondtionLabel setSelectableRange:privacyRange];
    [self.termAndCondtionLabel setSelectableRange:termsRange];


    // to respond to links being touched by the user.
    
    __weak SignupController * wSelf = self;
    self.termAndCondtionLabel.selectionHandler = ^(NSRange range, NSString *string) {
        if ([string isEqualToString:@"Privacy Policy"]){
            [wSelf onPrivacyPolicy:nil];
        }else{
            [wSelf onTermsOfService:nil];
        
        }
    };
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    m_bUIRearrangeNeeded = YES;
    
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Ready?"];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (self.view.bounds.size.width ==  320 ){
        privicyButtonWidthConstraint.constant = 65;
        termAndConditionButtonWidthConstraint.constant = 85;
        contentViewHeightConstraint.constant = 800;
    }else{
        contentViewHeightConstraint.constant = self.view.frame.size.height;
    }
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    
    if (activeField != nil)
        return;
    
    if (m_bUIRearrangeNeeded) {
        m_bUIRearrangeNeeded = NO;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    [super viewDidLayoutSubviews];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    if(textField == m_etFirstName) {
        
        [m_etPhoneNumber becomeFirstResponder];
    } else if(textField == m_etPhoneNumber) {
        
        [m_etEmail becomeFirstResponder];
    } else if(textField == m_etEmail) {
        [m_password becomeFirstResponder];
    } else if (textField == m_password){
        [m_reTypePassword becomeFirstResponder];
    }else{
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (IBAction)onBackgroundClick:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)onBtnBack:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//    
//    FirstPageController *nextScr = (FirstPageController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPageController"];
//    [[UIApplication sharedApplication].keyWindow setRootViewController:nextScr];
    
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)onSignup:(id)sender {
    [m_etEmail resignFirstResponder];
    
    NSString *strFirstName = m_etFirstName.text;
    NSString *strPhone = m_etPhoneNumber.unformattedText;
    NSString *strEmail = [[[NSString alloc]initWithString:m_etEmail.text] lowercaseString];
    NSString *password = m_password.text;
    NSString *reTypePassword = m_reTypePassword.text;

    
    
    if ([strFirstName length] == 0) {
        [self showAlert:@"Please provide both your first and last name" alertTag:0];
        return;
    }
    if ([strFirstName componentsSeparatedByString:@" "].count < 2) {
        [self showAlert:@"Please input your first and last name" alertTag:0];
        return;

    }
    if ([[strFirstName componentsSeparatedByString:@" "] objectAtIndex:1].length < 2){
        [self showAlert:@"Please input your first and last name" alertTag:0];
        return;
    }
    
    if ([strPhone length] == 0) {
        [self showAlert:@"Please input a mobile number r" alertTag:0];
        return;
    }
    
    if ([strPhone length] != 11) {
        [self showAlert:@"Please verify your mobile number is correct" alertTag:0];
        return;
    }
    
    if([strEmail isEqualToString:@""] || strEmail.length <5 || ![EngineMgr validateEmailWithString:strEmail])
    {
        [self showAlert:@"Please verify your email address is correct" alertTag:0];
        return;
    }
    if ([password length] == 0 || [reTypePassword length] == 0) {
        [self showAlert:@"Please chose a password" alertTag:0];
        return;
    }
    if (![password isEqualToString:reTypePassword]) {
        [self showAlert:@"Your passwords do not match" alertTag:0];
        return;
    }
    
    [self signup:strFirstName email:strEmail phone:strPhone fbId:@"" password:password];
}

- (IBAction)onUsingFacebook:(id)sender {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [self addIndicator];
    bool bShouldBackgroundRunning = [EngineMgr sharedInstance].shouldBackgroundRunning;
    [EngineMgr sharedInstance].shouldBackgroundRunning = true;
    [login logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        [EngineMgr sharedInstance].shouldBackgroundRunning = bShouldBackgroundRunning;
        
        [self stopIndicator];
        if (error) {
            NSLog(@"Process error");
        } else if (result.isCancelled) {
            NSLog(@"Cancelled");
        } else {
            NSLog(@"Facebook Logged in");
            [self addIndicator];
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"email, name, id"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                [self stopIndicator];
                
                if (!error) {
                    NSLog(@"fetched user:%@", result);
                                        
                    NSDictionary* dict = (NSDictionary*) result;
                    
                    NSString *strName = [dict valueForKey:@"name"];
                    NSString *strPhone = @"";
                    NSString *strEmail = [dict valueForKey:@"email"];
                    NSString *strFbId = [dict valueForKey:@"id"];
                    
                    [self signup:strName email:strEmail phone:strPhone fbId:strFbId password:@"onescream"];
                }
            }];
        }
        }
     ];
    
}

- (IBAction)onPrivacyPolicy:(id)sender {

    PrivacyController *nextScr = (PrivacyController *) [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)onTermsOfService:(id)sender {
    TermsController *nextScr = (TermsController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TermsController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}


- (void) gotoFrequentedAddressController {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /*WiFisController *nextScr = (WiFisController *) [self.storyboard instantiateViewControllerWithIdentifier:@"WiFisController"];
        nextScr.m_bFromSignup = true;
        [self.navigationController pushViewController:nextScr animated:YES];*/
        
        FrequentAddressViewController *nextScr = (FrequentAddressViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FrequentAddressViewController"];
         [self.navigationController pushViewController:nextScr animated:YES];
    });

}

- (void) gotoThankyouController {
    ThankyouController *nextScr = (ThankyouController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ThankyouController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+70, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, (activeField.frame.origin.y-kbSize.height));
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (void) signup:(NSString*) strName email:(NSString*) strEmail phone:(NSString*) strPhone fbId:(NSString*)strFbId  password:(NSString*)password{
    [m_etEmail resignFirstResponder];
    
    //NSString *strPassword = @"onescream";
    
//    User *user = [User user];
//    user.password = password;
//    user.email = strEmail;
//    NSString *strUserType = USER_TYPE_FREE;
//    NSArray *name = [NSArray arrayWithObject:strEmail];
//    [user setProperty:@"name" object:name];
//    [user setProperty:@"os" object:@"iOS"];
//    [user setProperty:@"user_type" object:strUserType];
//    [user setProperty:@"first_name" object:strName];
//    [user setProperty:@"last_name" object:@""];
//    [user setProperty:@"postcode" object:@""];
//    [user setProperty:@"phone" object:strPhone];
//    [user setProperty:@"facebook_id" object:strFbId];
//    
//    
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    [dateComponents setDay:14];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDate *expiry_date = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
//    [user setProperty:@"expiry_date" object:expiry_date];
//    
//    NSLog(@"%@", expiry_date);
//
//    // other fields can be set just like with PFObject
//    
//    [self addIndicator];
//    
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            [self stopIndicator];
//            if (succeeded) {
//                // Signup Success.
//                [self addIndicator];
//                
//                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                
//                    if (succeeded) {
//                        [PFUser logInWithUsernameInBackground:strEmail password:password
//                                                        block:^(PFUser *user, NSError *error) {
//                                                            
//                                                            [self stopIndicator];
//                                                            if (user) {
//                                                                [self onLoginSuccess:user];
//                                                            } else {
//                                                                [self showAlert:@"Login Failed" alertTag:0];
//                                                            }
//                                                        }];
//                    } else {
//                        [self stopIndicator];
//                        NSString *errorString = [error userInfo][@"error"];
//                        [self showAlert:errorString alertTag:0];
//                    }
//                }];
//                
//            } else {
//                NSString *errorString = [error userInfo][@"error"];
//                [self showAlert:errorString alertTag:0];
//            }
//        } else {
//            [self stopIndicator];
//            NSString *errorString = [error userInfo][@"error"];
//            [self showAlert:errorString alertTag:0] ;
//        }
//    }];
    
    User *bk_user = [User new];
    bk_user.email = strEmail;
    bk_user.password = password;
    [bk_user setProperty:@"name" object:strEmail];
    [bk_user setProperty:@"os" object:@"iOS"];
    [bk_user setProperty:@"user_type" object:USER_TYPE_FREE];
    [bk_user setProperty:@"first_name" object:strName];
    [bk_user setProperty:@"last_name" object:@""];
    [bk_user setProperty:@"postcode" object:@""];
    [bk_user setProperty:@"phone" object:strPhone];
    [bk_user setProperty:@"facebook_id" object:strFbId];
    [bk_user setProperty:@"password" object:password];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:14];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *expiry_date = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    [bk_user setProperty:@"expiry_date" object:expiry_date];
    [self addIndicator];
    [backendless.userService registering:bk_user response:^(BackendlessUser * user) {
        [self stopIndicator];
        
            // Signup Success.
            [self addIndicator];
        
        [backendless.userService login:user.email password:user.password?user.password:password response:^(BackendlessUser *bk_user2) {
                if (user) {
                    [self onLoginSuccess:bk_user];
                } else {
                    [self showAlert:@"Login Failed" alertTag:0];
                }
            } error:^(Fault *error) {
                [self stopIndicator];
                [self showAlert:[error message] alertTag:0] ;
            }];
        
            
        

    } error:^(Fault * error) {
        [self stopIndicator];
        [self showAlert:[error message] alertTag:0] ;
    }];
}

- (void)onLoginSuccess : (BackendlessUser*)user {
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"vibrationAlert"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"flashLightAlert"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    
    NSString *userObjectId =  user.objectId;
    [[NSUserDefaults standardUserDefaults]setObject:userObjectId forKey:@"userObjectId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    currentInstallation.channels = @[[EngineMgr convertEmailToChannelStr:[user username]]];
//    [currentInstallation addUniqueObject:[EngineMgr convertEmailToChannelStr:[user username]] forKey:@"channels"];
//    currentInstallation[@"user"] = [PFUser currentUser];
//    [currentInstallation saveInBackground];
    
    // Save user data to local
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:user.email forKey:@"email"];
    [userDefaults setObject:user.password forKey:@"password"];
    
    [userDefaults setObject:[user getProperty:@"first_name"] forKey:@"first_name"];
    [userDefaults setObject:[user getProperty:@"last_name"] forKey:@"last_name"];
    [userDefaults setObject:[user getProperty:@"postcode"] forKey:@"postcode"];
    [userDefaults setObject:[user getProperty:@"phone"] forKey:@"phone"];
    [userDefaults setObject:[user getProperty:@"user_type"] forKey:@"user_type"];
    [userDefaults synchronize];
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[user getProperty:@"first_name"] forKey:@"User Name"];
    [dic setObject:user.email forKey:@"User Email"];
//FIXME: Check why previous developer has stored date in User Email key
    [dic setObject:[NSDate date] forKey:@"User Email"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"subscribeORTrail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [AppEventTracker onLogin];
    [self performSelector:@selector(delayedTasks:) withObject:dic afterDelay:10];
    [self gotoFrequentedAddressController];
}
-(void)delayedTasks:(NSDictionary *)dic
{
    [AppEventTracker saveAndUpdateUserData:YES];
    [AppEventTracker trackEvnetWithName:@"Sign up" withData:dic];
}

- (void)showAlert:(NSString *)message alertTag:(NSInteger *)tag
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    myalert.tag = (NSInteger)tag;
    [myalert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1)
    {
        if(buttonIndex == 0)
        {
            LoginController *nextScr = (LoginController *) [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
            [self.navigationController pushViewController:nextScr animated:YES];
        }
    }
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
