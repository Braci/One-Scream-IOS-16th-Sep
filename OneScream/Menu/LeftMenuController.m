//
//  LeftMenuController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Left Menu
//

#import "LeftMenuController.h"
#import "UIViewController+ECSlidingViewController.h"

#import "MenuHeaderTVC.h"
#import "MenuSubmenuTVC.h"
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
#import "Tour1UIVViewController.h"
#import "FaqViewController.h"
#import "AboutViewController.h"
#import "HomeController.h"
#include "EngineMgr.h"
#import "backendless.h"
@interface LeftMenuController ()

@property (nonatomic, strong) UINavigationController *transitionsNavigationController;

@property (strong, nonatomic) NSArray *m_arrSectionTitles;
@property (strong, nonatomic) NSArray *m_arrSection1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *termAndConditionCenterAlignContraint;

@end

@implementation LeftMenuController {
    UIActivityIndicatorView *activityIndicator;
    BOOL m_bUIRearrangeNeeded;
    NSIndexPath *previous;
}

#define ALERT_VIEW_LOGOUT 10001

@synthesize m_tableviewSettings;

- (void)viewDidLoad {
    [super viewDidLoad];
    previous = [NSIndexPath indexPathForRow:0 inSection:0];
    self.transitionsNavigationController = (UINavigationController *)self.slidingViewController.topViewController;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   
    self.m_arrSectionTitles = @[@"One Scream"];
    self.m_arrSection1 = @[@"One Scream", @"Account", @"Contact", @"Tour",@"About",@"FAQ", @"Log out"];
    NSMutableAttributedString* privacy = [[NSMutableAttributedString alloc] initWithString: @"PRIVACY POLICY"];
    NSMutableAttributedString* term = [[NSMutableAttributedString alloc] initWithString: @"TERMS & SERVICES"];
    UIColor *color = [UIColor colorWithRed:107/255.0f green:128/255.0f blue:125/255.0f alpha:1.0f]; // select needed color
    NSDictionary *attributes = @{NSKernAttributeName: [NSNumber numberWithFloat:2.0], NSForegroundColorAttributeName : color};
    
    [privacy addAttributes:attributes range:NSMakeRange(0, privacy.length)];
    [self.privacy setAttributedTitle:privacy forState:UIControlStateNormal];
    
    [term addAttributes:attributes range:NSMakeRange(0, term.length)];
    [self.terms setAttributedTitle:term forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    m_bUIRearrangeNeeded = YES;
    [m_tableviewSettings reloadData];
    [self.navigationController setNavigationBarHidden:YES];
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
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

//- (CGFloat)tableView: (UITableView *)tableView heightForHeaderInSection: (NSInteger)section{
//    return 120.0f;
//}
//
//- (UIView *)tableView: (UITableView *)tableView viewForHeaderInSection: (NSInteger)section{
//    static NSString *szCellIdentifier = @"TABLECELL_MENU_HEADER";
//    MenuHeaderTVC *cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
//    if (cell == nil) {
//        cell = [[MenuHeaderTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifier];
//    }
//    
//    cell.m_lblName.text = [self.m_arrSectionTitles objectAtIndex:section];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    while (cell.contentView.gestureRecognizers.count) {
//        [cell.contentView removeGestureRecognizer:[cell.contentView.gestureRecognizers objectAtIndex:0]];
//    }
//    
//    return cell.contentView;
//}


- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{
    static NSString *szCellIdentifierSubMenu = @"TABLECELL_MENU_SUBMENU";
    
    MenuSubmenuTVC * cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifierSubMenu];
    if (cell == nil) {
        cell = [[MenuSubmenuTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifierSubMenu];
    }
    if (indexPath.section == 0) {
        // SUPPORT menu items
        cell.m_lblName.text = [self.m_arrSection1 objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            cell.m_lblName.textColor = [UIColor whiteColor];
            cell.m_image.hidden = NO;
            previous = indexPath;

        }else{
            cell.m_lblName.textColor = [UIColor colorWithRed:52.0f/255.0f green:66.0f/255.0f blue:81.0f/255.0f alpha:1.0f];
            cell.m_image.hidden = YES;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
//        self.slidingViewController.topViewController = self.transitionsNavigationController;
//        [self.slidingViewController resetTopViewAnimated:YES];
//    });
    
    MenuSubmenuTVC * Pcell =[self.m_tableviewSettings cellForRowAtIndexPath:previous];
        Pcell.m_lblName.textColor = [UIColor colorWithRed:52.0f/255.0f green:66.0f/255.0f blue:81.0f/255.0f alpha:1.0f];
    Pcell.m_image.hidden = YES;
    previous = indexPath;
    
    MenuSubmenuTVC * cell =[self.m_tableviewSettings cellForRowAtIndexPath:indexPath];
    cell.m_lblName.textColor = [UIColor whiteColor];
    cell.m_image.hidden = NO;
    
    if (section == 0) {
        // SUPPORT menu items
        switch (row) {
                
            case 0: // One Scream
            {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
                    self.slidingViewController.topViewController = self.transitionsNavigationController;

                });
            }
                break;
            case 1: // Your details
            {
                PersonalInfoController *nextScr = (PersonalInfoController *) [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalInfoController"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:nextScr animated:YES];
                    [self.slidingViewController resetTopViewAnimated:NO];

                });
                
            }
                break;
            case 2: // Contact us
            {
                ContactUsController *nextScr = (ContactUsController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ContactUsController"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:nextScr animated:YES];
                    [self.slidingViewController resetTopViewAnimated:NO];

                });
            }
                break;
            case 3: // One Scream Tour
            {
//                HowToController *nextScr = (HowToController *) [self.storyboard instantiateViewControllerWithIdentifier:@"HowToController"];
//                nextScr.m_bOnTour = YES;
                Tour1UIVViewController *nextScr = (Tour1UIVViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TOUR1"];
                nextScr.fromMenu = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.slidingViewController resetTopViewAnimated:NO];
                    [self.navigationController pushViewController:nextScr animated:YES];
                    [self.slidingViewController resetTopViewAnimated:NO];

                });
            }
                break;
                
            case 4: // about
            {
                AboutViewController *aboutVC = (AboutViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:aboutVC animated:YES];
                    [self.slidingViewController resetTopViewAnimated:NO];

                });
            }
                break;
            case 5: // FAQ
            {
                FaqViewController *nextScr = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FAQCONTROLLER"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:nextScr animated:YES];
                    [self.slidingViewController resetTopViewAnimated:NO];

                });
            }
                break;
            case 6: // Log out
            {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self showLogoutAlert];
                });
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
    NSMutableDictionary *properties = [NSMutableDictionary new];
    BackendlessUser *user = [backendless.userService currentUser];
    [properties setObject:[user getProperty:@"first_name"] forKey:@"User Name"];
    [properties setObject:user.email forKey:@"User Email"];
    [AppEventTracker trackEvnetWithName:@"Log out" withData:properties];
    [AppEventTracker onSignOut];
    [backendless.userService logout:^(id object) {
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if([EngineMgr sharedInstance].isDetecting){
                
                if([self.transitionsNavigationController isMemberOfClass:[HomeController class]]){
                    HomeController *hm = (HomeController*) self.transitionsNavigationController;
                    [hm switchDetecting];
                }
            }
            
        });
    } error:^(Fault *error) {
        [self stopIndicator];
        [self showAlert:[error message] alertTag:0] ;
    }];
    [self.slidingViewController resetTopViewAnimated:NO];

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
   /* UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:@"Are you sure you want to turn off One Scream?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    myalert.tag = (NSInteger)ALERT_VIEW_LOGOUT;
    [myalert show];*/
    
    [self logout];
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
- (IBAction)back:(id)sender {
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    self.slidingViewController.topViewController = self.transitionsNavigationController;
    [self.slidingViewController resetTopViewAnimated:YES];
}

- (IBAction)onPrivacyPolicy:(id)sender {

    PrivacyController *nextScr = (PrivacyController *) [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyController"];
    [self.navigationController pushViewController:nextScr animated:YES];
    [self.slidingViewController resetTopViewAnimated:YES];

}

- (IBAction)onTermsServices:(id)sender {
    TermsController *nextScr = (TermsController *) [self.storyboard instantiateViewControllerWithIdentifier:@"TermsController"];
    [self.navigationController pushViewController:nextScr animated:YES];
    [self.slidingViewController resetTopViewAnimated:YES];

}

+ (instancetype) dvs_attributedStringWithString:(NSString *)string
                                       tracking:(CGFloat)tracking
                                           font:(UIFont *)font
{
    CGFloat fontSize = font.pointSize;
    CGFloat characterSpacing = tracking * fontSize / 1000;
    UIColor *color = [UIColor colorWithRed:52/255.0f green:66/255.0f blue:81/255.0f alpha:1.0f]; // select needed color
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSKernAttributeName: [NSNumber numberWithFloat:characterSpacing], NSForegroundColorAttributeName : color};
    
    return [[NSAttributedString alloc] initWithString:string 
                                           attributes:attributes];
}
@end

