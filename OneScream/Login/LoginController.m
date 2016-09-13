//
//  LoginController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Login Screen
//

#import "LoginController.h"
#import "SignupController.h"
#import "EngineMgr.h"
//#import "Parse/Parse.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ResetViewController.h"
#import "Tour1UIVViewController.h"
#import "UserAddress.h"
#import "backendless.h"
#import "User.h"
@interface LoginController ()

@end

@implementation LoginController {
    
    UIActivityIndicatorView *activityIndicator;
    CGPoint originalCenter;
    BOOL m_bUIRearrangeNeeded;
    __weak IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
    
    __weak IBOutlet UIButton *forgetPasswordbutton;
    __weak IBOutlet UIButton *createNewAccountButton;



}

@synthesize scrollView;
@synthesize m_etEmail;
@synthesize m_etPassword;


- (void)viewDidLoad {
    [super viewDidLoad];

    // Make Activity Indicator
    originalCenter = self.view.center;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self registerForKeyboardNotifications];
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
    [AppEventTracker trackScreenWithName:@"Login screen"];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (self.view.bounds.size.width ==  320 ){
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if(textField == m_etEmail)
    {
        // [m_etPassword becomeFirstResponder];
    }
    return YES;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onBackgroundClick:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)onLogin:(id)sender {
    
    [m_etEmail resignFirstResponder];
    [m_etPassword resignFirstResponder];

    NSString* strEmail = m_etEmail.text;
    NSString* strPassword = m_etPassword.text;

    if([strEmail isEqualToString:@""] || strEmail.length <5 || ![EngineMgr validateEmailWithString:strEmail])
    {
        [self stopIndicator];
        [self showAlert:@"Invalid Email" alertTag:0];
        return;
    }
    if ([strPassword length] == 0){
        [self stopIndicator];
        [self showAlert:@"Please Enter Password" alertTag:0];
        return;
    }
    [self login:strEmail password:strPassword];
}

- (IBAction)onSignup:(id)sender {
    /*SignupController *nextScr = (SignupController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignupController"];
    [self.navigationController pushViewController:nextScr animated:YES];*/
    
    Tour1UIVViewController *nextScr = (Tour1UIVViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR1"];
    nextScr.fromMenu = NO;
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)forgetPassword:(id)sender {
    ResetViewController *resetVC  = (ResetViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ResetViewController"];
    [self presentViewController:resetVC animated:YES completion:nil];
}

- (IBAction)onFBLogin:(id)sender {
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
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                [self stopIndicator];
                
                if (!error) {
                    NSLog(@"fetched user:%@", result);
                    NSDictionary* dict = (NSDictionary*) result;
                    
                    NSString *strEmail = [dict valueForKey:@"email"];
                    
                    [self login:strEmail password:@"onescream"];
                }
            }];
        }
    }
     ];
}


- (void) login:(NSString*) strEmail password:(NSString*)passsword {
    [self addIndicator];
    
  //  NSString* strPassword = @"onescream";
    [backendless.userService setStayLoggedIn:YES];
    strEmail = [strEmail lowercaseString];
    [backendless.userService login:strEmail password:passsword response:^(BackendlessUser *bk_user2) {
        if (bk_user2) {
            if (bk_user2 != nil){
                
               
                UserAddress *homeAddress =  [bk_user2 getProperty:HOME_ADDRESS_PARSE_COLOUMN];
               // [homeAddress fetchIfNeeded];
                UserAddress *workAddress = [bk_user2 getProperty:WORK_ADDRESS_PARSE_COLOUMN];
               // [workAddress fetchIfNeeded];
                UserAddress *frequentedAddress = [bk_user2 getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
               // [frequentedAddress fetchIfNeeded];
                
                [self stopIndicator];
                [self onLoginSuccess:(User *)bk_user2];
            }else
            {
                [self stopIndicator];
                [self showAlert:@"The email address/password does not match an existing account" alertTag:0];
                [forgetPasswordbutton setTitleColor:[UIColor colorWithRed:227/255.0 green:188/255.0 blue:78/255.0 alpha:1.0] forState:UIControlStateNormal];
                [createNewAccountButton setTitleColor:[UIColor colorWithRed:227/255.0 green:188/255.0 blue:78/255.0 alpha:1.0] forState:UIControlStateNormal];
            }
            
        } else {
            [self stopIndicator];
            [self showAlert:@"Login Failed" alertTag:0];
        }
    } error:^(Fault *error) {
        [self stopIndicator];
        [self showAlert:[error message] alertTag:0] ;
    }];
    
    
//    
//    [PFUser logInWithUsernameInBackground:strEmail password:passsword
//                                    block:^(PFUser *user, NSError *error) {
//                                        if (user) {
//                                            
//                                            if (user != nil){
//                                                
//                                                UserAddress *homeAddress = user[HOME_ADDRESS_PARSE_COLOUMN];
//                                                [homeAddress fetchIfNeeded];
//                                                UserAddress *workAddress = user[WORK_ADDRESS_PARSE_COLOUMN];
//                                                [workAddress fetchIfNeeded];
//                                                UserAddress *frequentedAddress = user[FREQUENTED_ADDRESS_PARSE_COLOUMN];
//                                                [frequentedAddress fetchIfNeeded];
//                                                
//                                                
//                                            }
//                                            [self stopIndicator];
//                                            [self onLoginSuccess:user];
//                                        } else {
//                                            [self stopIndicator];
//                                            [self showAlert:@"The email address/password does not match an existing account" alertTag:0];
//                                            [forgetPasswordbutton setTitleColor:[UIColor colorWithRed:227/255.0 green:188/255.0 blue:78/255.0 alpha:1.0] forState:UIControlStateNormal];
//                                            [createNewAccountButton setTitleColor:[UIColor colorWithRed:227/255.0 green:188/255.0 blue:78/255.0 alpha:1.0] forState:UIControlStateNormal];
//                                        }
//                                    }];
}

- (void)onLoginSuccess : (User*)user {
    
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


    
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"subscribeORTrail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[user getProperty:@"first_name"] forKey:@"User Name"];
    [dic setObject:user.email forKey:@"User Email"];
    //[dic setObject:[NSDate date] forKey:@"User Email"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];

    });
    
    [AppEventTracker onLogin];
//    [AppEventTracker saveAndUpdateUserData:false];
    [AppEventTracker trackEvnetWithName:@"Login" withData:dic];

}

- (void)showAlert:(NSString *)message alertTag:(NSInteger *)tag
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    myalert.tag = (NSInteger)tag;
    [myalert show];
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

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height + 200;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height-100);
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


@end
