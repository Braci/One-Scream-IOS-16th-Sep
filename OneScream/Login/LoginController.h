//
//  LoginController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Login Screen
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController <UITextFieldDelegate>
{
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *m_etEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_etPassword;


- (IBAction)onBackgroundClick:(id)sender;

- (IBAction)onLogin:(id)sender;
- (IBAction)onSignup:(id)sender;
- (IBAction)onFBLogin:(id)sender;

@end

