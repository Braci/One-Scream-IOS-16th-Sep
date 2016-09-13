//
//  WiFiDetailController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for editing WiFi address
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface WiFiDetailController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITextField *activeField;
}

@property bool m_bNew;
@property int m_nWiFiItemIdx;
@property NSString* m_strCurrentWiFiID;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *m_lblWiFiID;
@property (weak, nonatomic) IBOutlet UITextField *m_etTitle;
@property (weak, nonatomic) IBOutlet UITextField *m_etAddress;
@property (weak, nonatomic) IBOutlet UITableView *m_tableviewSuggestionList;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRegister;

@property (strong, nonatomic) IBOutlet UIControl *onBackgroundClick;

@property (strong, nonatomic) NSMutableArray *m_arrSuggestion;

- (IBAction)onRegister:(id)sender;
- (IBAction)onBtnBack:(id)sender;

@end

