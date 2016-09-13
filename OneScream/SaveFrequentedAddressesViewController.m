//
//  SaveFrequentedAddressesViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 20/03/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "SaveFrequentedAddressesViewController.h"
#import "UserAddress.h"
#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>
#import <Backendless.h>
#import <BackendlessUser.h>
@interface SaveFrequentedAddressesViewController ()

{

    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UILabel *headerLabel;

    __weak IBOutlet UITextField *businessNameTextField;

    __weak IBOutlet UITextField *street1TextField;
    __weak IBOutlet UITextField *street2TextField;
    __weak IBOutlet UITextField *cityTextField;

    __weak IBOutlet UITextField *postalTextField;
    __weak IBOutlet UITextField *stateTextField;
    __weak IBOutlet UIButton *saveButton;
    
    
    
}

@end

@implementation SaveFrequentedAddressesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_address_type == HOME){
        headerLabel.text = @"Home Address";
        [saveButton setTitle:@"Save Home Address" forState:UIControlStateNormal];
    }else if (_address_type == WORK){
        headerLabel.text = @"Work Address";
        [saveButton setTitle:@"Save Work Address" forState:UIControlStateNormal];

    }else if (_address_type == FREQUENT){
        headerLabel.text = @"Other Address";
        [saveButton setTitle:@"Save Other Address" forState:UIControlStateNormal];
    }
    if (_address_type == HOME || _address_type == FREQUENT){
        
        businessNameTextField.placeholder = @"Address 1";
        street1TextField.placeholder = @"Address 2";
        street2TextField.placeholder = @"Apt/Flat/Suite";
    }
    
    UIColor *borderColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    businessNameTextField.layer.cornerRadius = 3.0;
    businessNameTextField.layer.borderColor = borderColor.CGColor;
    businessNameTextField.layer.borderWidth = 1;
    
    
    CGRect rect = CGRectMake(0, 0,10, businessNameTextField.frame.size.height);

    UIView  *paddingView = [[UIView alloc]initWithFrame:rect];
    businessNameTextField.leftView = paddingView;
    businessNameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    
    
    street1TextField.layer.cornerRadius = 3.0;
    street1TextField.layer.borderColor = borderColor.CGColor;
    street1TextField.layer.borderWidth = 1;
    
    
    rect = CGRectMake(0, 0,10, street1TextField.frame.size.height);
    
    paddingView = [[UIView alloc]initWithFrame:rect];
    street1TextField.leftView = paddingView;
    street1TextField.leftViewMode = UITextFieldViewModeAlways;
    
    
    
    street2TextField.layer.cornerRadius = 3.0;
    street2TextField.layer.borderColor = borderColor.CGColor;
    street2TextField.layer.borderWidth = 1;
    
    rect = CGRectMake(0, 0,10, street2TextField.frame.size.height);
    
    paddingView = [[UIView alloc]initWithFrame:rect];
    street2TextField.leftView = paddingView;
    street2TextField.leftViewMode = UITextFieldViewModeAlways;
    
    
    cityTextField.layer.cornerRadius = 3.0;
    cityTextField.layer.borderColor = borderColor.CGColor;
    cityTextField.layer.borderWidth = 1;
    
    rect = CGRectMake(0, 0,10, cityTextField.frame.size.height);
    
    paddingView = [[UIView alloc]initWithFrame:rect];
    cityTextField.leftView = paddingView;
    cityTextField.leftViewMode = UITextFieldViewModeAlways;
    
    
    stateTextField.layer.cornerRadius = 3.0;
    stateTextField.layer.borderColor = borderColor.CGColor;
    stateTextField.layer.borderWidth = 1;
    
    rect = CGRectMake(0, 0,10, cityTextField.frame.size.height);
    
    paddingView = [[UIView alloc]initWithFrame:rect];
    stateTextField.leftView = paddingView;
    stateTextField.leftViewMode = UITextFieldViewModeAlways;
    
    
    postalTextField.layer.cornerRadius = 3.0;
    postalTextField.layer.borderColor = borderColor.CGColor;
    postalTextField.layer.borderWidth = 1;
    
    rect = CGRectMake(0, 0,10, cityTextField.frame.size.height);
    
    paddingView = [[UIView alloc]initWithFrame:rect];
    postalTextField.leftView = paddingView;
    postalTextField.leftViewMode = UITextFieldViewModeAlways;
    
    if (_isForUpdateAddress){
        [self setData];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [AppEventTracker trackScreenWithName:[NSString stringWithFormat:@"%@ screen",headerLabel.text]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helpers

-(void)setData{
    
    BackendlessUser *user = backendless.userService.currentUser;
    UserAddress *address;
    if (self.address_type == HOME){
        address =  [user getProperty:HOME_ADDRESS_PARSE_COLOUMN];
    }else if (self.address_type == WORK){
        address = [user getProperty:WORK_ADDRESS_PARSE_COLOUMN];
    }else {
        address = [user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
    }
    
    if(!address || [address isKindOfClass:[NSNull class]]){
        return;
    }
    if (_address_type == HOME || _address_type == FREQUENT){
        businessNameTextField.text = address.streetAddress1;
        street1TextField.text = address.streetAddress2;
        street2TextField.text =  address.apt_flat;
    }else{
        businessNameTextField.text = address.businessName;
        street1TextField.text = address.streetAddress1;
        street2TextField.text =  address.streetAddress2;
    }
    cityTextField.text =  address.city;
    postalTextField.text =  address.postal;
    stateTextField.text = address.state;
    
    
    
}


#pragma mark - IBACtion

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)saveButtonPressed:(id)sender {
    
    
    
    if (_address_type == HOME || _address_type == FREQUENT){
        
        if ([businessNameTextField.text isEqualToString:@""]){
            [self showAlert:@"Please input your home address " alertTag:1 andDelegate:nil];
            return;
            
        }/*else if ([street1TextField.text isEqualToString:@""]){
            
            [self showAlert:@"Please Enter Street Address 2" alertTag:1 andDelegate:nil];
            return;
            
        }*//*else if ([street2TextField.text isEqualToString:@""] && _address_type != FREQUENT){
            [self showAlert:@"Please Enter APT/FLAT/SUITE" alertTag:1 andDelegate:nil];
            return;
            
        }*/
    
    }else {
    
        if ([businessNameTextField.text isEqualToString:@""]){
            [self showAlert:@"Please input the companies name" alertTag:1 andDelegate:nil];
            return;
            
        }else if ([street1TextField.text isEqualToString:@""]){
            
            [self showAlert:@"Please input your street name and number" alertTag:1 andDelegate:nil];
            return;
            
        }/*else if ([street2TextField.text isEqualToString:@""]){
            [self showAlert:@"Please Enter Street Address 2" alertTag:1 andDelegate:nil];
            return;
            
        }*/
    
    
    }
    
    if ([cityTextField.text isEqualToString:@""]){
        [self showAlert:@"Please input your city" alertTag:1 andDelegate:nil];
        return;
        
    }/*else if ([stateTextField.text isEqualToString:@""] && _address_type != FREQUENT){
        [self showAlert:@"Please Enter State" alertTag:1 andDelegate:nil];
        return;
        
    }*/else if ([postalTextField.text isEqualToString:@""]){
        [self showAlert:@"Please input your postcode" alertTag:1 andDelegate:nil];
        return;
    }else if (([postalTextField.text length]<5) || ([postalTextField.text length] > 8)){
        [self showAlert:@"Please verify your postcode is correct" alertTag:1 andDelegate:nil];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    SaveFrequentedAddressesViewController *wSelf = self;

    if (_isForUpdateAddress){
        BackendlessUser *user = backendless.userService.currentUser;
        
        UserAddress *address;
        if (self.address_type == HOME){
            address =  [user getProperty:HOME_ADDRESS_PARSE_COLOUMN];
        }else if (self.address_type == WORK){
            address = [user getProperty:WORK_ADDRESS_PARSE_COLOUMN];
        }else {
            address = [user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
        }
        if(!address || [address isKindOfClass:[NSNull class]])
            address = [UserAddress new];
        if (_address_type == HOME || _address_type == FREQUENT){
            address.streetAddress1 = businessNameTextField.text;
            address.streetAddress2 = street1TextField.text;
            address.apt_flat = street2TextField.text;
        }else{
            address.businessName = businessNameTextField.text;
            address.streetAddress1 = street1TextField.text;
            address.streetAddress2 = street2TextField.text;
        
        }
        
        address.city = cityTextField.text;
        address.state = stateTextField.text;
        address.postal = postalTextField.text;
        
        id <IDataStore>dateStore =  [backendless.persistenceService of:[UserAddress class]];
        [dateStore save:address response:^(id response) {
            [MBProgressHUD hideHUDForView:wSelf.view animated:true];
            [wSelf backButtonPressed:nil];
        } error:^(Fault *error) {
            [wSelf showAlert:[error description] alertTag:1 andDelegate:nil];
            [MBProgressHUD hideHUDForView:wSelf.view animated:true];
        }];
        
//        [address saveInBackgroundWithBlock:^(BOOL success, NSError * error){
//            
//            if (success == true){
//                [MBProgressHUD hideHUDForView:wSelf.view animated:true];
//                [wSelf backButtonPressed:nil];
//            }else {
//                [wSelf showAlert:[error description] alertTag:1 andDelegate:nil];
//                [MBProgressHUD hideHUDForView:wSelf.view animated:true];
//            }
//            
//            
//        }];
        
        
        
        
    }else{
    
//        UserAddress *address = [[UserAddress alloc] initWithClassName:@"UserAddress"];
        UserAddress *address = [UserAddress new];
        if (_address_type == HOME || _address_type == FREQUENT){
            address.streetAddress1 = businessNameTextField.text;
            address.streetAddress2 = street1TextField.text;
            address.apt_flat = street2TextField.text;
        }else{
            address.businessName = businessNameTextField.text;
            address.streetAddress1 = street1TextField.text;
            address.streetAddress2 = street2TextField.text;
        }
        address.city = cityTextField.text;
        address.state = stateTextField.text;
        address.postal = postalTextField.text;
        
        if (self.address_type == HOME){
            address.addressType = @"HOME";
        }else if (self.address_type == WORK){
            address.addressType = @"WORK";
            
        }else {
            address.addressType = @"Other";
        }
        id <IDataStore>dateStore =  [backendless.persistenceService of:[UserAddress class]];
        [dateStore save:address response:^(id response) {
           BackendlessUser *user = backendless.userService.currentUser;
            if (self.address_type == HOME){
                [user setProperty:HOME_ADDRESS_PARSE_COLOUMN object:address];
            }else if (self.address_type == WORK){
                [user setProperty:WORK_ADDRESS_PARSE_COLOUMN object:address];
            }else {
                [user setProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN object:address];
            }
            [backendless.userService update:user response:^(BackendlessUser *bkUser) {
                [MBProgressHUD hideHUDForView:wSelf.view animated:true];
                [wSelf backButtonPressed:nil];
                
            } error:^(Fault *error) {
                [MBProgressHUD hideHUDForView:wSelf.view animated:true];
                [wSelf backButtonPressed:nil];
            }];

        } error:^(Fault *error) {
            
        }];
    
    }
}

#pragma mark - Alert

- (void)showAlert:(NSString *)message alertTag:(NSInteger)tag andDelegate:(id)delegate
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles: nil];
    myalert.tag = (NSInteger)tag;
    [myalert show];
}


#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if (textField == postalTextField){
        [self saveButtonPressed:saveButton];
    }
    
    return true;

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
