//
//  UpgradeController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Upgrade Membership Screen
//

#import "AFNetworking.h"
#import "UpgradeController.h"
#import "ThankyouController.h"
//#import <Parse/Parse.h>
#import <Stripe/Stripe.h>
#import "MBProgressHUD.h"
#import "StripeConstants.h"
#import "EngineMgr.h"
#import <BackendlessUser.h>
#import <Backendless.h>

@interface UpgradeController () <STPPaymentCardTextFieldDelegate>

    @property (weak, nonatomic) STPPaymentCardTextField *paymentTextField;

@end

@implementation UpgradeController {
    bool m_bTextFieldAdded;
    int m_nPayMode;
    
    BOOL m_bUIRearrangeNeeded;
}

#define PAY_MODE_NONE   0
#define PAY_MODE_MONTH  1
#define PAY_MODE_YEAR   2

@synthesize scrollView;
@synthesize m_contentsView;

@synthesize m_btnMonth;
@synthesize m_btnYear;

@synthesize m_etName;
@synthesize m_etCardNumber;
@synthesize m_etExpiryYear;
@synthesize m_etExpiryMonth;
@synthesize m_etCVC;
@synthesize m_etAddress;

@synthesize m_btnPay;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    m_bTextFieldAdded = false;
    
    m_nPayMode = PAY_MODE_NONE;
    
    // update user info
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    
    m_bUIRearrangeNeeded = YES;
    
    [self refreshUI];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Upgrade Screen"];

}

- (void)viewDidLayoutSubviews {
    CGRect rect = [m_etCardNumber frame];
    if (!m_bTextFieldAdded && rect.size.width != 528) {
        // Setup payment view
        
//        STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:        [m_etCardNumber frame]];
//        paymentTextField.delegate = self;
//        self.paymentTextField = paymentTextField;
//        [m_contentsView addSubview:paymentTextField];
        
        m_bTextFieldAdded = true;
    }
    
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

- (IBAction)onBtnMonth:(id)sender {
    m_nPayMode = PAY_MODE_MONTH;
    [self refreshUI];
    
}

- (IBAction)onBtnYear:(id)sender {
    m_nPayMode = PAY_MODE_YEAR;
    [self refreshUI];
}

- (IBAction)onBtnPay:(id)sender {
    [self.paymentTextField resignFirstResponder];
    [m_etCardNumber resignFirstResponder];
    [m_etExpiryYear resignFirstResponder];
    [m_etExpiryMonth resignFirstResponder];
    [m_etCVC resignFirstResponder];
    [m_etAddress resignFirstResponder];
    
    if (m_nPayMode == PAY_MODE_NONE) {
        [self showAlert:@"Please select the plan." alertTag:0];
        return;
    }
    
    int nCurPayMode = PAY_MODE_NONE;
    BackendlessUser *user = backendless.userService.currentUser;
    if ([[user getProperty:@"user_type"] isEqualToString:USER_TYPE_PREMIUM_MONTH]) {
        nCurPayMode = PAY_MODE_MONTH;
    } else if ([[user getProperty:@"user_type"] isEqualToString:USER_TYPE_PREMIUM_MONTH]) {
        nCurPayMode = PAY_MODE_YEAR;
    }

    if (m_nPayMode <= nCurPayMode) {
        [self showAlert:@"Already upgraded." alertTag:0];
        return;
    }
    
    [self payToUpgrade];
}

- (IBAction)onAlreadyPurchased:(id)sender {
    
}

- (void) refreshUI {
    [m_btnMonth setBackgroundColor:[UIColor colorWithRed:0x6b/255.0f green:0x80/255.0f blue:0x96/255.0f alpha:1.0f]];
    [m_btnYear setBackgroundColor:[UIColor colorWithRed:0x6b/255.0f green:0x80/255.0f blue:0x96/255.0f alpha:1.0f]];

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    if (m_nPayMode == PAY_MODE_MONTH) {
        [m_btnMonth setBackgroundColor:[UIColor colorWithRed:0x18/255.0f green:0x1f/255.0f blue:0x27/255.0f alpha:1.0f]];
        
        [dateComponents setMonth:1];
        
    } else if (m_nPayMode == PAY_MODE_YEAR) {
        [m_btnYear setBackgroundColor:[UIColor colorWithRed:0x18/255.0f green:0x1f/255.0f blue:0x27/255.0f alpha:1.0f]];
        
        [dateComponents setYear:1];
    } else {
        [dateComponents setDay:0];
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
    return YES;
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

#pragma mark - STPPaymentCardTextFieldDelegate
- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    
    UIColor *color = [UIColor darkGrayColor];
    if (!textField.isValid) {
        color = [UIColor lightGrayColor];
    }
    
}

- (void) payToUpgrade {
    /*
     *  Paying Process
     */
//    if (![self.paymentTextField isValid]) {
//        return;
//    }
    
    NSString* strCardNumber = [m_etCardNumber text];
    strCardNumber = [[strCardNumber componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if ([strCardNumber length] < 16) {
        [self showAlert:@"Please complete the card number" alertTag:0];
        return;
    }
    
    NSString* strExpiryMonth = [m_etExpiryMonth text];
    int nMonth = [strExpiryMonth intValue];
    
    if (nMonth < 1 || nMonth > 12) {
        [self showAlert:@"Please input valid expiry date" alertTag:0];
        return;
    }
    
    NSString* strExpiryYear = [m_etExpiryYear text];
    int nYear = [strExpiryYear intValue];
    
    if (nYear < 2015 || nYear > 2050) {
        [self showAlert:@"Please input valid expiry date" alertTag:0];
        return;
    }
    
    NSString* strCVC = [m_etCVC text];
    if ([strCVC length] < 3) {
        [self showAlert:@"Please input valid CVC" alertTag:0];
        return;
    }

    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"
                                                    }];
        [self didFinish:error];
        return;
    }

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    STPCardParams *cardParams = [STPCardParams new];
    cardParams.number = strCardNumber;
    cardParams.expYear = nYear - 2000;
    cardParams.expMonth = nMonth;
    cardParams.cvc = strCVC;
    [[STPAPIClient sharedClient] createTokenWithCard:cardParams completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error || token == nil) {
            [self didFinish:error];
        }
        [self createBackendChargeWithToken:token completion:^(NSError *error) {
            if (error) {
                [self didFinish:error];
                return;
            }
            [self didFinish:nil];
        }];
        
    }];
    STPCardParams *cardParams2 = [STPCardParams new];
    cardParams2.number = strCardNumber;
    cardParams2.expMonth = nMonth;
    cardParams2.expYear = nYear - 2000;
    cardParams2.cvc = strCVC;
    [[STPAPIClient sharedClient] createTokenWithCard:cardParams2
          completion:^(STPToken *token, NSError *error) {
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              if (error || token == nil) {
                  [self didFinish:error];
              }
              [self createBackendChargeWithToken:token
                     completion:^(NSError *error) {
                         if (error) {
                             [self didFinish:error];
                             return;
                         }
                         [self didFinish:nil];
                     }];
          }];

}


- (void) didFinish:(NSError *)error {
    if (error) {
        [self presentError:error];
    } else {
        [self paymentSucceeded];
    }
}

- (void)presentError:(NSError *)error {
    NSString *strMessage = @"Error";
    if (error != nil)
        strMessage = [error localizedDescription];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
                                                      message:strMessage
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)paymentSucceeded {
    BackendlessUser *user = backendless.userService.currentUser;
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    if (m_nPayMode == PAY_MODE_MONTH) {
        [dateComponents setMonth:1];
    } else if (m_nPayMode == PAY_MODE_YEAR) {
        [dateComponents setYear:1];
    }

    NSDate* date_expiry = [user getProperty:@"expiry_date"];
    if (date_expiry == nil)
        date_expiry = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *expected_date = [calendar dateByAddingComponents:dateComponents toDate:date_expiry options:0];
    if (m_nPayMode == PAY_MODE_MONTH) {
        [user setProperty:@"user_type" object:USER_TYPE_PREMIUM_MONTH];
    } else if (m_nPayMode == PAY_MODE_YEAR) {
        [user setProperty:@"user_type" object:USER_TYPE_PREMIUM_YEAR];
    }
    [user setProperty:@"expiry_date" object:expected_date];
    [backendless.userService update:user response:^(BackendlessUser *bkUser) {
        
    } error:^(Fault *error) {
        
    }];
    
    m_nPayMode = PAY_MODE_NONE;
    [self refreshUI];
    [self showAlert:@"The period is renewed!" alertTag:0];
}

#pragma mark - STPBackendCharging

- (void)createBackendChargeWithToken:(STPToken *)token completion:(void(^)(NSError*))completion {
    NSString *strAmount = @"";
    if (m_nPayMode == PAY_MODE_MONTH) {
        strAmount = @"99";
    } else if (m_nPayMode == PAY_MODE_YEAR) {
        strAmount = @"999";
    }
    NSDictionary *chargeParams = @{ @"stripeToken": token.tokenId, @"amount": strAmount };
    
    if (!BackendChargeURLString) {
        NSError *error = [NSError
                          errorWithDomain:StripeDomain
                          code:STPInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.stripe.com .",
                                                                 token.tokenId]
                                     }];
        completion(error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:[BackendChargeURLString stringByAppendingString:@"/charge"]
       parameters:chargeParams
          success:^(AFHTTPRequestOperation *operation, id responseObject) { completion(nil); }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(error); }];
}

- (void)showAlert:(NSString *)message alertTag:(NSInteger *)tag
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    myalert.tag = (NSInteger)tag;
    [myalert show];
}

@end
