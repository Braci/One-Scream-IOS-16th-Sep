//
//  SettingsController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Settings Screen
//

#import "SettingsController.h"
#import "SettingsHeaderTVC.h"
#import "SettingsSubmenuTVC.h"
#import "FaqController.h"
#import "ContactUsController.h"
#import "FoundersController.h"
#import "PersonalInfoController.h"
#import "HowToController.h"
#import "TermsController.h"
#import "PrivacyController.h"
#import "HowItWorksController.h"
#import "FirstPageController.h"
//#import <Parse/Parse.h>
#import <BackendlessUser.h>
#import <Backendless.h>

@interface SettingsController ()

@property (strong, nonatomic) NSArray *m_arrSectionTitles;
@property (strong, nonatomic) NSArray *m_arrSection1;
@property (strong, nonatomic) NSArray *m_arrSection2;

@end

@implementation SettingsController {
    UIActivityIndicatorView *activityIndicator;
    BOOL m_bUIRearrangeNeeded;
}

#define ALERT_VIEW_LOGOUT 10001

@synthesize m_tableviewSettings;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   
    self.m_arrSectionTitles = @[@"SUPPORT", @"ABOUT US"];
    self.m_arrSection1 = @[@"FAQ", @"Contact us", @"Your details", @"Log out"];
    self.m_arrSection2 = @[@"One Scream tour", @"Founders", @"Terms and Conditions", @"Privacy Policy", @"How it works"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    m_bUIRearrangeNeeded = YES;
    
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Setting Screen"];

}

- (void)viewDidLayoutSubviews {
    if (m_bUIRearrangeNeeded) {
        m_bUIRearrangeNeeded = NO;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        m_tableviewSettings.contentInset = contentInsets;
        m_tableviewSettings.scrollIndicatorInsets = contentInsets;
        [m_tableviewSettings setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    [super viewDidLayoutSubviews];
}

#pragma mark -Event Listener

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.m_arrSectionTitles.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section{
    if (section == 0) {
        return [self.m_arrSection1 count];
    } else if (section == 1) {
        return [self.m_arrSection2 count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

- (CGFloat)tableView: (UITableView *)tableView heightForHeaderInSection: (NSInteger)section{
    return 60.0f;
}

- (UIView *)tableView: (UITableView *)tableView viewForHeaderInSection: (NSInteger)section{
    static NSString *szCellIdentifier = @"TABLECELL_SETTINGS_HEADER";
    SettingsHeaderTVC *cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
    if (cell == nil) {
        cell = [[SettingsHeaderTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifier];
    }
    
    cell.m_lblName.text = [self.m_arrSectionTitles objectAtIndex:section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    while (cell.contentView.gestureRecognizers.count) {
        [cell.contentView removeGestureRecognizer:[cell.contentView.gestureRecognizers objectAtIndex:0]];
    }
    
    return cell.contentView;
}


- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{
    static NSString *szCellIdentifierSubMenu = @"TABLECELL_SETTINGS_SUBMENU";
    
    SettingsSubmenuTVC * cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifierSubMenu];
    if (cell == nil) {
        cell = [[SettingsSubmenuTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifierSubMenu];
    }
    if (indexPath.section == 0) {
        // SUPPORT menu items
        cell.m_lblName.text = [self.m_arrSection1 objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        // ABOUT US menu items
        cell.m_lblName.text = [self.m_arrSection2 objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    
    if (section == 0) {
        // SUPPORT menu items
        switch (row) {
            case 0: // FAQ
            {
                FaqController *nextScr = (FaqController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FaqController"];
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
            case 1: // Contact us
            {
                ContactUsController *nextScr = (ContactUsController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ContactUsController"];
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
            case 2: // Your details
            {
                PersonalInfoController *nextScr = (PersonalInfoController *) [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalInfoController"];
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
            case 3: // Log out
            {
                [self showLogoutAlert];
            }
                break;
                
            default:
                break;
        }
    } else if (section == 1) {
        // ABOUT US menu items
        switch (row) {
            case 0: // One Scream Tour
            {
                HowToController *nextScr = (HowToController *) [self.storyboard instantiateViewControllerWithIdentifier:@"HowToController"];
                nextScr.m_bOnTour = YES;
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
            case 1: // Founders
            {
                FoundersController *nextScr = (FoundersController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FoundersController"];
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
            case 2: // Terms and Conditions
            {
                TermsController *nextScr = (TermsController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TermsController"];
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
            case 3: // Privacy Policy
            {
                PrivacyController *nextScr = (PrivacyController *) [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyController"];
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
            case 4: // How it works
            {
                HowItWorksController *nextScr = (HowItWorksController *) [self.storyboard instantiateViewControllerWithIdentifier:@"HowItWorksController"];
                [self.navigationController pushViewController:nextScr animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    
    [m_tableviewSettings deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) logout {
    [self addIndicator];
    [backendless.userService logout:^(id response) {
        [self stopIndicator];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"" forKey:@"userObjectId"];
        [userDefaults setObject:@"" forKey:@"email"];
        [userDefaults setObject:@"" forKey:@"password"];
        [userDefaults setObject:@"" forKey:@"first_name"];
        [userDefaults setObject:@"" forKey:@"last_name"];
        [userDefaults setObject:@"" forKey:@"postcode"];
        [userDefaults setObject:@"" forKey:@"phone"];
        [userDefaults setObject:@"" forKey:@"user_type"];
        [userDefaults synchronize];
        
        [self gotoFirstPageController];
    } error:^(Fault *error) {
        [self stopIndicator];
        [self showAlert:error.message alertTag:0] ;
    }];
}

- (void)showAlert:(NSString *)message alertTag:(NSInteger *)tag
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    myalert.tag = (NSInteger)tag;
    [myalert show];
}

- (void) gotoFirstPageController {
    FirstPageController *nextScr = (FirstPageController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPageController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}


- (void)showLogoutAlert
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:@"Are you sure you want to turn off One Scream?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    myalert.tag = (NSInteger)ALERT_VIEW_LOGOUT;
    [myalert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_VIEW_LOGOUT)
    {
        if(buttonIndex == 1)
        {
            [self logout];
        }
    }
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
