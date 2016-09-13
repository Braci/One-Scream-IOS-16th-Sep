//
//  SignupController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Signup Screen
//

#import <UIKit/UIKit.h>
#import "MZSelectableLabel.h"
#import "REFormattedNumberField.h"

@interface SignupController : UIViewController <UITextFieldDelegate> {
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet MZSelectableLabel *termAndCondtionLabel;
@property (weak, nonatomic) IBOutlet UITextField *m_etFirstName;
@property (weak, nonatomic) IBOutlet REFormattedNumberField *m_etPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *m_etEmail;


- (IBAction)onBackgroundClick:(id)sender;
- (IBAction)onBtnBack:(id)sender;

- (IBAction)onSignup:(id)sender;
- (IBAction)onUsingFacebook:(id)sender;

- (IBAction)onPrivacyPolicy:(id)sender;
- (IBAction)onTermsOfService:(id)sender;

@end

