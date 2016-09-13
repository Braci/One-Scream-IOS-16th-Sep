//
//  UpdateFrequentedAddressesViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 25/03/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "UpdateFrequentedAddressesViewController.h"
//#import "Parse/Parse.h"
#import "UserAddress.h"
#import "SaveFrequentedAddressesViewController.h"
#import "MBProgressHUD.h"
#import <Backendless.h>
#import <BackendlessUser.h>
@interface UpdateFrequentedAddressesViewController ()
{

    __weak IBOutlet UIButton *backButton;

    __weak IBOutlet UIView *homeAddressView;
    __weak IBOutlet UIView *homeAddressContainerView;
    
    __weak IBOutlet UILabel *homeAddressLabel;
    
    
    
    __weak IBOutlet UIView *workAddressContainerView;
    __weak IBOutlet UIButton *addWorkAddressButton;
    __weak IBOutlet UIView *workAddressView;
    
    __weak IBOutlet UILabel *workAddressLabel;
    
    
    
    __weak IBOutlet UIView *frequentedAddressContainerView;
    __weak IBOutlet UIButton *addFrequentedAddressButton;
    __weak IBOutlet UIView *frequentedAddressView;
    
    __weak IBOutlet UILabel *frequentedAddressLabel;
    
    
    __weak IBOutlet NSLayoutConstraint *workAddressContainerViewYPostion;
    __weak IBOutlet NSLayoutConstraint *frequentedAddressContainerViewYPosition;
    
    
    
}
@end

@implementation UpdateFrequentedAddressesViewController

#pragma mark - View


-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    BackendlessUser *user = backendless.userService.currentUser;
    UserAddress *homeAddress = [user getProperty:HOME_ADDRESS_PARSE_COLOUMN];
    if (homeAddress != nil || ![homeAddress isKindOfClass:[NSNull class]]){
        homeAddressView.hidden = false;
        [self setUIWithAddress:homeAddress forLabel:homeAddressLabel];

        //homeAddressLabel.text = [NSString stringWithFormat:@"%@,\n%@,\n%@,%@,%@",homeAddress.streetAddress1,homeAddress.streetAddress2,homeAddress.city,homeAddress.state,homeAddress.postal];
    }
    
    //addWorkAddressButton.hidden = false;
    //workAddressView.hidden = true;
    UserAddress *workAddress = [user getProperty:WORK_ADDRESS_PARSE_COLOUMN];

    if (workAddress == nil || [workAddress isKindOfClass:[NSNull class]]){
        addWorkAddressButton.hidden = false;
        workAddressView.hidden = true;
        
        frequentedAddressContainerViewYPosition.constant = - (workAddressView.bounds.size.height - addWorkAddressButton.bounds.size.height) - 1;
        
    }else{
        workAddressView.hidden = false;
        addWorkAddressButton.hidden = true;
        
        frequentedAddressContainerViewYPosition.constant = - 1;
        UserAddress *workAddress = [user getProperty:WORK_ADDRESS_PARSE_COLOUMN];
        [self setUIWithAddress:workAddress forLabel:workAddressLabel];
        //workAddressLabel.text = [NSString stringWithFormat:@"%@,\n%@,\n%@,%@,%@",workAddress.streetAddress1,workAddress.streetAddress2,workAddress.city,workAddress.state,workAddress.postal];
        
    }
    UserAddress *frequentedAddress = [user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
    if (frequentedAddress == nil || [frequentedAddress isKindOfClass:[NSNull class]]){
        addFrequentedAddressButton.hidden = false;
        frequentedAddressView.hidden = true;
        
    }else{
        frequentedAddressView.hidden = false;
        addFrequentedAddressButton.hidden = true;
        UserAddress *frequentedAddress = [user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
        [self setUIWithAddress:frequentedAddress forLabel:frequentedAddressLabel];
        //frequentedAddressLabel.text = [NSString stringWithFormat:@"%@,\n%@,\n%@,%@,%@",frequentedAddress.streetAddress1,frequentedAddress.streetAddress2,frequentedAddress.city,frequentedAddress.state,frequentedAddress.postal];
    }
    
}
-(void)setUIWithAddress:(UserAddress *)userAddress forLabel:(UILabel*)label{
    if(!userAddress || [userAddress isKindOfClass:[NSNull class]])
    {
        label.text = @"";
        return;
    }
    
    //UserAddress *userAddress = user[FREQUENTED_ADDRESS_PARSE_COLOUMN];
    NSString *addressString = @"";
    addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@\n",userAddress.streetAddress1]];
    if (userAddress.streetAddress2 != nil && ![userAddress.streetAddress2 isEqualToString:@""]){
        addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@, ",userAddress.streetAddress2]];
        
        
    }
    if (userAddress.apt_flat != nil && ![userAddress.apt_flat isEqualToString:@""]){
        addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@,\n",userAddress.apt_flat]];
        
    }else{
        if (![[addressString substringFromIndex:[addressString length] - 1] isEqualToString:@"\n"]){
            addressString = [addressString stringByAppendingString:@"\n"];
        }
    }
    addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@, ",userAddress.city]];
    if (userAddress.state != nil && ![userAddress.state isEqualToString:@""]){
        addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@, ",userAddress.state]];
    }
    addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@",userAddress.postal]];
    label.text = addressString;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    homeAddressContainerView.clipsToBounds = YES;
    workAddressContainerView.clipsToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    UIColor *borderColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];

    
    
    addWorkAddressButton.layer.cornerRadius = 3.0;
    addWorkAddressButton.layer.borderColor = borderColor.CGColor;
    addWorkAddressButton.layer.borderWidth = 1;
    
    addFrequentedAddressButton.layer.cornerRadius = 3.0;
    addFrequentedAddressButton.layer.borderColor = borderColor.CGColor;
    addFrequentedAddressButton.layer.borderWidth = 1;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)editHomeAddressButtonPressed:(id)sender {
    SaveFrequentedAddressesViewController *nextScr = (SaveFrequentedAddressesViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SaveFrequentedAddressesViewController"];
    nextScr.isForUpdateAddress = true;
    nextScr.address_type = HOME;
    [self.navigationController pushViewController:nextScr animated:YES];
}
- (IBAction)addWorkAddressButtonPressed:(id)sender {
    
    SaveFrequentedAddressesViewController *nextScr = (SaveFrequentedAddressesViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SaveFrequentedAddressesViewController"];
    nextScr.isForUpdateAddress = false;
    nextScr.address_type = WORK;
    [self.navigationController pushViewController:nextScr animated:YES];
}
- (IBAction)editWorkAddressButtonPressed:(id)sender {
    
    SaveFrequentedAddressesViewController *nextScr = (SaveFrequentedAddressesViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SaveFrequentedAddressesViewController"];
    nextScr.isForUpdateAddress = true;
    nextScr.address_type = WORK;
    [self.navigationController pushViewController:nextScr animated:YES];
}
- (IBAction)deleteWorkAddressButtonPressed:(id)sender {
    
    UpdateFrequentedAddressesViewController *wSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    BackendlessUser *user = [backendless.userService currentUser];
    UserAddress *address = [user getProperty:WORK_ADDRESS_PARSE_COLOUMN];
    id<IDataStore>dataStore = [backendless.persistenceService of:[UserAddress class]];
    [dataStore removeID:address.objectId];
    [user setProperty:WORK_ADDRESS_PARSE_COLOUMN object:nil];
    [backendless.userService update:user response:^(BackendlessUser *bkUser) {
        [MBProgressHUD hideHUDForView:wSelf.view animated:true];
    } error:^(Fault *error) {
        [MBProgressHUD hideHUDForView:wSelf.view animated:true];
    }];

}
- (IBAction)editFrequentedAddressButtonPressed:(id)sender {
    SaveFrequentedAddressesViewController *nextScr = (SaveFrequentedAddressesViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SaveFrequentedAddressesViewController"];
    nextScr.isForUpdateAddress = true;
    nextScr.address_type = FREQUENT;
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (IBAction)deleteFrequentedAddressButtonPressed:(id)sender {
    
    UpdateFrequentedAddressesViewController *wSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    BackendlessUser *user = [backendless.userService currentUser];
    UserAddress *address = [user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
    id<IDataStore>dataStore = [backendless.persistenceService of:[UserAddress class]];
    [dataStore removeID:address.objectId];
    [user setProperty:WORK_ADDRESS_PARSE_COLOUMN object:nil];
    [backendless.userService update:user response:^(BackendlessUser *bkUser) {
        [MBProgressHUD hideHUDForView:wSelf.view animated:true];
    } error:^(Fault *error) {
        [MBProgressHUD hideHUDForView:wSelf.view animated:true];
    }];
}

- (IBAction)addFrequentedAddressesButtonPressed:(id)sender {
    
    SaveFrequentedAddressesViewController *nextScr = (SaveFrequentedAddressesViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SaveFrequentedAddressesViewController"];
    nextScr.isForUpdateAddress = false;
    nextScr.address_type = FREQUENT;
    [self.navigationController pushViewController:nextScr animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
