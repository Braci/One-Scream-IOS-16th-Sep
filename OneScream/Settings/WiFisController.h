//
//  WiFisController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing frequented addresses (WIFI addresses)
//

#import <UIKit/UIKit.h>
#import "CustomDarkButton.h"
#import "CustomButton.h"

@interface WiFisController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    UITextField *activeField;
    UITextField *activeHome;
}

@property bool m_bNew;
@property int m_nWiFiItemIdx;
@property NSString* m_strCurrentWiFiID;

@property bool m_bSelectAddress;
@property bool m_bFromSignup;
@property bool fromMenu;

@property (strong, nonatomic) NSMutableArray *m_arrSuggestion;

@property (weak, nonatomic) IBOutlet UIButton *m_btnBack;
@property (weak, nonatomic) IBOutlet UITableView *m_tableviewWiFis;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_nHeaderPosY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet CustomDarkButton *addbtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (weak, nonatomic) IBOutlet UITextField *home;
@property (weak, nonatomic) IBOutlet UIView *h_view;
@property (weak, nonatomic) IBOutlet UIImageView *h_tittle;
@property (weak, nonatomic) IBOutlet UIPageControl *h_pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h_tableUp;
@property (weak, nonatomic) IBOutlet CustomButton *h_finish;
@property (weak, nonatomic) IBOutlet UILabel *h_discription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h_tableup;

- (IBAction)onAddWiFiItem:(id)sender;
- (IBAction)onDeleteItem:(id)sender;
- (IBAction)onFinished:(id)sender;
@end

