//
//  PersonalInfoController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Your details Screen
//

#import "PersonalInfoController.h"
#import "UpgradeController.h"
#import "WiFisController.h"
//#import <Parse/Parse.h>
#import "EngineMgr.h"
#import "UpdateFrequentedAddressesViewController.h"
#import <Backendless.h>
#import <BackendlessUser.h>
@interface PersonalInfoController ()

@end

@implementation PersonalInfoController {
    UIActivityIndicatorView *activityIndicator;
    BOOL m_bUIRearrangeNeeded;
}

#define ALERT_VIEW_UPDATE_USERINFO 10001

@synthesize scrollView;
@synthesize m_etName;
@synthesize m_etPhone;
@synthesize m_etEmail;
@synthesize m_lblProductionPlan;
@synthesize m_lblRemainedDays;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // update user info
    BackendlessUser *user = backendless.userService.currentUser;
//    PFUser *user = [PFUser currentUser];
//    if (user) {
//        [user fetchInBackground];
//    }
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // for UI changing when the keyboard is showed.
    [self registerForKeyboardNotifications];
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)];
    [cancel setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
    [save setTintColor:[UIColor whiteColor]];

    numberToolbar.items = @[cancel,
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],save
                            ];
    [numberToolbar sizeToFit];
    m_etPhone.inputAccessoryView = numberToolbar;
    m_etPhone.format = @"XXX XXXX XXXX";
    
    UIColor *borderColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    m_etName.layer.cornerRadius = 3.0;
    m_etName.layer.borderColor = borderColor.CGColor;
    m_etName.layer.borderWidth = 2;
    
    CGRect rect = CGRectMake(0, 0,25, m_etName.frame.size.height);
    
    UIView  *paddingView = [[UIView alloc]initWithFrame:rect];
    m_etName.leftView = paddingView;
    m_etName.leftViewMode = UITextFieldViewModeAlways;
    
    
    m_etPhone.layer.cornerRadius = 3.0;
    m_etPhone.layer.borderColor = borderColor.CGColor;
    m_etPhone.layer.borderWidth = 2;
    
    rect = CGRectMake(0, 0,25, m_etPhone.frame.size.height);
    
    paddingView = [[UIView alloc]initWithFrame:rect];
    m_etPhone.leftView = paddingView;
    m_etPhone.leftViewMode = UITextFieldViewModeAlways;
    
    
    m_etEmail.layer.cornerRadius = 3.0;
    m_etEmail.layer.borderColor = borderColor.CGColor;
    m_etEmail.layer.borderWidth = 2;
    
    rect = CGRectMake(0, 0,25, m_etEmail.frame.size.height);
    
    paddingView = [[UIView alloc]initWithFrame:rect];
    m_etEmail.leftView = paddingView;
    m_etEmail.leftViewMode = UITextFieldViewModeAlways;
    
}
-(void)cancelNumberPad{
    [m_etPhone resignFirstResponder];
}

-(void)doneWithNumberPad{
    //NSString *numberFromTheKeyboard = m_etPhone.text;
    [m_etPhone resignFirstResponder];
    [self updatePersonalInfo];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];

    m_bUIRearrangeNeeded = YES;
    [self refreshUI];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Personal information Frequented addresses"];

}

- (void) refreshUI {
    [m_etEmail setEnabled:false];
    //[m_etName setEnabled:false];
    //[m_etPhone setEnabled:false];

    BackendlessUser *user = backendless.userService.currentUser;
    NSString *strName = [user getProperty:@"first_name"];
    NSString *strPhone= [user getProperty:@"phone"];
    NSString *strEmail = user.email;
    
    NSDate *date_expiry = [user getProperty:@"expiry_date"];
    NSDate *now = [NSDate date];
    if (date_expiry == nil)
        date_expiry = now;
    
    [m_etName setText:strName];
    [m_etPhone setText:[strPhone re_stringWithNumberFormat:@"(X) XXX XXX XXXX"]];
    [m_etEmail setText:strEmail];
    
    NSString *strPayStatus = @"Expired";;
    double seconds = [date_expiry timeIntervalSinceDate:now];
    int days = seconds / (24 * 3600) + 0.5;
    if (seconds >= 0) {
        if ([[user getProperty:@"user_type"] isEqualToString:USER_TYPE_PREMIUM_MONTH]) {
            strPayStatus = [NSString stringWithFormat:@"ANNUAL PLAN"];
        } else if ([[user getProperty:@"user_type"] isEqualToString:USER_TYPE_PREMIUM_YEAR]) {
            strPayStatus = [NSString stringWithFormat:@"MONTHLY PLAN"];
        } else {
            strPayStatus = [NSString stringWithFormat:@"TRIAL PLAN"];
        }
    }
    
    [m_lblProductionPlan setText:strPayStatus];
    if (days < 0) {
        [m_lblRemainedDays setText:[NSString stringWithFormat:@"(%d days Left)", 0]];

    }else{
        [m_lblRemainedDays setText:[NSString stringWithFormat:@"(%d days Left)", days]];

    }
}

- (void)viewDidLayoutSubviews {
    if (m_bUIRearrangeNeeded) {
        m_bUIRearrangeNeeded = NO;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    [super viewDidLayoutSubviews];
}

- (IBAction)onBackgroundClick:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onUpgrade:(id)sender {
    UpgradeController *nextScr = (UpgradeController *) [self.storyboard instantiateViewControllerWithIdentifier:@"UpgradeController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)onDone:(id)sender {
    
    if ([m_etPhone.unformattedText length] != 11) {
        [self showAlert:@"Invalid phone number" alertTag:0];
        return;

    }
    [self showUpdateInfoAlert];
}

- (IBAction)onWiFiAddresses:(id)sender {
    UpdateFrequentedAddressesViewController *nextScr = (UpdateFrequentedAddressesViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"UpdateFrequentedAddressesViewController"];
    [self.navigationController pushViewController:nextScr animated:YES];
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
    
    if(textField == m_etName) {
        
        [self updatePersonalInfo];
        //[m_etPhone becomeFirstResponder];
        
    }
    
    return YES;
}
/*- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}*/


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
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
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



- (void)showUpdateInfoAlert
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:@"Do you really update personal information?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    myalert.tag = (NSInteger)ALERT_VIEW_UPDATE_USERINFO;
    [myalert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_VIEW_UPDATE_USERINFO)
    {
        if(buttonIndex == 1)
        {
            [self updatePersonalInfo];
        }
    }
}

- (void) updatePersonalInfo {
    //[self.navigationController popViewControllerAnimated:YES];
    [self addIndicator];
    NSString *strName = m_etName.text;
    NSString *strPhone = m_etPhone.text;
    
    BackendlessUser *user = backendless.userService.currentUser;
    [user setProperty:@"first_name" object:strName];
    [user setProperty:@"phone" object:strPhone];
    [backendless.userService update:user response:^(BackendlessUser *bkuser) {
        [self stopIndicator];
        
    } error:^(Fault *eror) {
        [self stopIndicator];
        [self showAlert:eror.message alertTag:0] ;
    }];
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

@end
