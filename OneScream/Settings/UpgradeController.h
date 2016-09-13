//
//  UpgradeController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Upgrade Membership Screen
//


#import <UIKit/UIKit.h>

@interface UpgradeController : UIViewController <UITextFieldDelegate> {
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *m_contentsView;
@property (weak, nonatomic) IBOutlet UIButton *m_btnMonth;
@property (weak, nonatomic) IBOutlet UIButton *m_btnYear;
@property (weak, nonatomic) IBOutlet UITextField *m_etName;
@property (weak, nonatomic) IBOutlet UITextField *m_etCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *m_etExpiryYear;
@property (weak, nonatomic) IBOutlet UITextField *m_etExpiryMonth;
@property (weak, nonatomic) IBOutlet UITextField *m_etCVC;

@property (weak, nonatomic) IBOutlet UITextField *m_etAddress;
@property (weak, nonatomic) IBOutlet UIButton *m_btnPay;

- (IBAction)onBackgroundClick:(id)sender;

- (IBAction)onBtnMonth:(id)sender;
- (IBAction)onBtnYear:(id)sender;
- (IBAction)onBtnPay:(id)sender;
- (IBAction)onAlreadyPurchased:(id)sender;


@end

