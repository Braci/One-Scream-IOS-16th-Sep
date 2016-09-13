//
//  FirstPageController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing Login and Signup button when the user logged out
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface FirstPageController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet CustomButton *m_btnLogin;
@property (weak, nonatomic) IBOutlet CustomButton *m_btnSignup;

@property BOOL m_bFirst;

- (IBAction)onLogin:(id)sender;
- (IBAction)onSignup:(id)sender;

@end

