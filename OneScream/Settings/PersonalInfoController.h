//
//  PersonalInfoController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Your details Screen
//

#import <UIKit/UIKit.h>
#import "REFormattedNumberField.h"
@interface PersonalInfoController : UIViewController <UITextFieldDelegate> {
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *m_etName;
@property (weak, nonatomic) IBOutlet REFormattedNumberField *m_etPhone;
@property (weak, nonatomic) IBOutlet UITextField *m_etEmail;

@property (weak, nonatomic) IBOutlet UILabel *m_lblProductionPlan;
@property (weak, nonatomic) IBOutlet UILabel *m_lblRemainedDays;

- (IBAction)onBackgroundClick:(id)sender;

- (IBAction)onUpgrade:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onWiFiAddresses:(id)sender;

@end

