//
//  FrequentAddressViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 20/03/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "FrequentAddressViewController.h"
#import "SaveFrequentedAddressesViewController.h"
//#import "Parse/Parse.h"
#import "UserAddress.h"
#import "ThankyouController.h"
#import <BackendlessUser.h>
#import <Backendless.h>
@interface FrequentAddressViewController ()<UIGestureRecognizerDelegate>
{

    __weak IBOutlet UIPageControl *pageControl;
    __weak IBOutlet UIView *addressViewContainer;
    
    __weak IBOutlet UIButton *homeAddressButton;
    __weak IBOutlet UIView *homeAddressViewContainer;
    __weak IBOutlet UIView *homeAddressView;

    
    __weak IBOutlet UIButton *workAddressButton;
    __weak IBOutlet UIView *workAddressViewContainer;
    __weak IBOutlet UIView *workAddressView;

    
    __weak IBOutlet UIButton *frequentedAddressButton;
    __weak IBOutlet UIView *frequentedAddressViewContainer;
    __weak IBOutlet UIView *frequentedAddressView;

    
    
    __weak IBOutlet UIButton *saveAddressButton;
    
    __weak IBOutlet UIImageView *homeAddressImageView;
    __weak IBOutlet NSLayoutConstraint *homeAddressContainerViewHeight;

    __weak IBOutlet NSLayoutConstraint *workAddressContainerViewYPostion;
    __weak IBOutlet NSLayoutConstraint *frequentedAddressContainerViewYPosition;
    
    __weak IBOutlet UILabel *homeAddressLabel;
    __weak IBOutlet UILabel *workAddressLabel;
    __weak IBOutlet UILabel *frequentedAddressLabel;
    
    __weak IBOutlet UILabel *headerAddressLabel;

    __weak IBOutlet NSLayoutConstraint *addressLabelYPosition;
    
    
    
    
    
}

@end

@implementation FrequentAddressViewController


#pragma mark - View


-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    BackendlessUser *user = backendless.userService.currentUser;
    
    if ([user getProperty:HOME_ADDRESS_PARSE_COLOUMN] == nil){
        homeAddressButton.hidden = false;
        homeAddressView.hidden = true;
        workAddressContainerViewYPostion.constant = - (homeAddressView.bounds.size.height - homeAddressButton.frame.size.height) - 1;
    }else{
        
        UserAddress *homeAddress = [user getProperty:HOME_ADDRESS_PARSE_COLOUMN];
        homeAddressView.hidden = false;
        homeAddressButton.hidden = true;
        saveAddressButton.hidden = false;
        headerAddressLabel.hidden = true;
        
        workAddressContainerViewYPostion.constant =  - 1;
        
        [self setUIWithAddress:homeAddress forLabel:homeAddressLabel];
       // homeAddressLabel.text = [NSString stringWithFormat:@"%@,\n%@,\n%@,%@,%@",homeAddress.streetAddress1,homeAddress.streetAddress2,homeAddress.city,homeAddress.state,homeAddress.postal];
        
        
        
    }
    if ([user getProperty:WORK_ADDRESS_PARSE_COLOUMN] == nil){
        workAddressButton.hidden = false;
        workAddressView.hidden = true;
        
        frequentedAddressContainerViewYPosition.constant = - (workAddressView.bounds.size.height - workAddressButton.bounds.size.height) - 1;
        
    }else{
        workAddressView.hidden = false;
        workAddressButton.hidden = true;
        headerAddressLabel.hidden = true;
        
        frequentedAddressContainerViewYPosition.constant = - 1;
        
        
        UserAddress *workAddress = [user getProperty:WORK_ADDRESS_PARSE_COLOUMN];
        [self setUIWithAddress:workAddress forLabel:workAddressLabel];

        
        //workAddressLabel.text = [NSString stringWithFormat:@"%@,\n%@,\n%@,%@,%@",workAddress.streetAddress1,workAddress.streetAddress2,workAddress.city,workAddress.state,workAddress.postal];
        
        
        
        
    }
    
    if ([user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN] == nil){
        frequentedAddressButton.hidden = false;
        frequentedAddressView.hidden = true;
        
    }else{
        frequentedAddressView.hidden = false;
        frequentedAddressButton.hidden = true;
        headerAddressLabel.hidden = true;
        
        
        UserAddress *userAddress = [user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
        [self setUIWithAddress:userAddress forLabel:frequentedAddressLabel];
    
        
        
    }
    
    
    if (headerAddressLabel.hidden == true){
        addressLabelYPosition.constant = 0;
        
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
        addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@"%@",userAddress.streetAddress2]];

        
    }
    if (userAddress.apt_flat != nil && ![userAddress.apt_flat isEqualToString:@""]){
        addressString = [addressString stringByAppendingString:[NSString stringWithFormat:@", %@\n",userAddress.apt_flat]];
        
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
    
    
    homeAddressViewContainer.clipsToBounds = YES;
    workAddressViewContainer.clipsToBounds = YES;

    
    UIColor *borderColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    homeAddressButton.layer.cornerRadius = 3.0;
    homeAddressButton.layer.borderColor = borderColor.CGColor;
    homeAddressButton.layer.borderWidth = 1;
    
    
    workAddressButton.layer.cornerRadius = 3.0;
    workAddressButton.layer.borderColor = borderColor.CGColor;
    workAddressButton.layer.borderWidth = 1;
    
    frequentedAddressButton.layer.cornerRadius = 3.0;
    frequentedAddressButton.layer.borderColor = borderColor.CGColor;
    frequentedAddressButton.layer.borderWidth = 1;
    
    
    /*PFUser *user = [PFUser currentUser];
    [user removeObjectForKey:HOME_ADDRESS_PARSE_COLOUMN];
    [user removeObjectForKey:WORK_ADDRESS_PARSE_COLOUMN];
    [user removeObjectForKey:FREQUENTED_ADDRESS_PARSE_COLOUMN];*/
    
    
    UITapGestureRecognizer *homeReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLabel:)];
    homeReco.numberOfTapsRequired = 1;
    [homeAddressLabel addGestureRecognizer:homeReco];
    homeAddressLabel.userInteractionEnabled = YES;

    
    
    UITapGestureRecognizer *workReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLabel:)];
    workReco.numberOfTapsRequired = 1;
    workReco.delegate = self;
    [workAddressLabel addGestureRecognizer:workReco];
    workAddressLabel.userInteractionEnabled = YES;


    
    
    
    UITapGestureRecognizer *otherReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLabel:)];
    otherReco.numberOfTapsRequired = 1;
    otherReco.delegate = self;
    [frequentedAddressLabel addGestureRecognizer:otherReco];
    frequentedAddressLabel.userInteractionEnabled = YES;

}

-(void)tapOnLabel:(UITapGestureRecognizer *)reco{
    SaveFrequentedAddressesViewController *nextScr = (SaveFrequentedAddressesViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SaveFrequentedAddressesViewController"];
    nextScr.isForUpdateAddress = true;
    
    if (reco.view == homeAddressLabel){
        nextScr.address_type = HOME;

    }else if (reco.view == workAddressLabel){
        nextScr.address_type = WORK ;

    }else if (reco.view == frequentedAddressLabel){
        nextScr.address_type = FREQUENT;
    }
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"%@",NSStringFromClass([gestureRecognizer class]));
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [addressViewContainer setNeedsLayout];
    [addressViewContainer layoutIfNeeded];
    [AppEventTracker trackScreenWithName:@"Your Addresses screen"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions
- (IBAction)addHomeAddressButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"SaveFrequentedAddressesViewController" sender:sender];
}

- (IBAction)addWorkaddressButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"SaveFrequentedAddressesViewController" sender:sender];

}

- (IBAction)addFrequentedAddressButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"SaveFrequentedAddressesViewController" sender:sender];

}
- (IBAction)saveAddressButtonPressed:(id)sender {
    //[self.navigationController popToRootViewControllerAnimated:NO];
    ThankyouController *nextScr = (ThankyouController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ThankyouController"];
    nextScr.fromMenu = NO;
    nextScr.hidebtn = YES;
    [self.navigationController pushViewController:nextScr animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    SaveFrequentedAddressesViewController *dVC = (SaveFrequentedAddressesViewController*) segue.destinationViewController  ;
    if (sender == homeAddressButton){
        dVC.address_type = HOME;
    }else if (sender == workAddressButton){
        dVC.address_type = WORK;
    }else if (sender == frequentedAddressButton) {
        dVC.address_type = FREQUENT;
    }
}


@end
