//
//  WiFiDetailController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for editing WiFi address
//

#import "WiFiDetailController.h"
#import "EngineMgr.h"
#import "EMGAddressSuggestionTVC.h"
#import "AFNetworking.h"

@interface WiFiDetailController ()

@end

@implementation WiFiDetailController

#define GOOGLEMAPS_API_PLACE_KEY            @"AIzaSyCJZP2ZEhknm0xU8BW_ipDG7tg1gyAA660"

@synthesize scrollView;

@synthesize m_lblWiFiID;
@synthesize m_etTitle;
@synthesize m_etAddress;
@synthesize m_btnRegister;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.m_bNew = true;
    if (self.m_nWiFiItemIdx >= 0 && [[EngineMgr sharedInstance] getWiFiTitleOfIndex:self.m_nWiFiItemIdx].length > 0)
        self.m_bNew = false;

    self.m_arrSuggestion = [[NSMutableArray alloc] init];
    self.m_tableviewSuggestionList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.m_tableviewSuggestionList.layer.borderWidth = 1;
    self.m_tableviewSuggestionList.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.m_tableviewSuggestionList setHidden:YES];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self registerForKeyboardNotifications];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    
    [self refreshUIFromEngine];
}

- (IBAction)onRegister:(id)sender {
    NSString *strTitle = [m_etTitle text];
    NSString *strAddress = [m_etAddress text];
    
    if ([strTitle length] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"One Scream" message:@"Please input a Name place." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        return;
    }
    
    if ([strAddress length] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"One Scream" message:@"Please input an address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        return;
    }
    
    [[EngineMgr sharedInstance] setWifiItem:self.m_nWiFiItemIdx title:strTitle address:strAddress id:(self.m_bNew ? self.m_strCurrentWiFiID : nil)];
    
    [[EngineMgr sharedInstance] saveWiFiItemToStorage:self.m_nWiFiItemIdx];
    
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)onBtnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)refreshUIFromEngine
{
    if (self.m_bNew) {
        [m_lblWiFiID setText:[NSString stringWithFormat:@"Please input new frequented address"]];
        [m_btnRegister setTitle:@"Register" forState:UIControlStateNormal];
    } else {
        [m_lblWiFiID setText:[NSString stringWithFormat:@"Linked WIFI ID is %@", self.m_strCurrentWiFiID]];
        [m_etTitle setText:[[EngineMgr sharedInstance] getWiFiTitleOfIndex:self.m_nWiFiItemIdx]];
        [m_etAddress setText:[[EngineMgr sharedInstance] getWiFiAddressOfIndex:self.m_nWiFiItemIdx]];
        [m_btnRegister setTitle:@"Save" forState:UIControlStateNormal];
    }
}


#pragma mark -Biz Logic

- (void) onSelectAddressSuggestion: (int) index{
    NSString *szReference = [self.m_arrSuggestion objectAtIndex:index];
    self.m_etAddress.text = szReference;
    
    [self.m_arrSuggestion removeAllObjects];
    [self.m_tableviewSuggestionList reloadData];
    [self.m_tableviewSuggestionList setHidden:YES];
}


#pragma mark -Event Listener

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self onSelectAddressSuggestion:(int) indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (int)[self.m_arrSuggestion count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *szCellIdentifier = @"TVC_ADDRESS_SUGGESTION";
    
    EMGAddressSuggestionTVC *cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
    if (cell == nil) {
        cell = [[EMGAddressSuggestionTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifier];
    }
    
    // Presets first, followed by suggestions
    int index = (int) indexPath.row;

    NSString *szDescription = [self.m_arrSuggestion objectAtIndex:(index)];
    [cell.m_btnAddress setTitle:szDescription forState:UIControlStateNormal];
    
    cell.m_btnAddress.tag = indexPath.row;
    
    return cell;
}

- (IBAction)onBtnAddressSuggestionClick:(id)sender {
    [self.view endEditing:YES];
    
    UIButton *button = sender;
    int index = (int) button.tag;
    
    [self onSelectAddressSuggestion:index];
}


- (IBAction)onTxtAddressDidBeginEditing:(id)sender {
    self.m_etAddress.text = @"";
}

- (IBAction)onTxtAddressChanged:(id)sender {
    NSString *sz = self.m_etAddress.text;
    if (sz.length == 0){
        [self.m_arrSuggestion removeAllObjects];
        [self.m_tableviewSuggestionList reloadData];
        [self.m_tableviewSuggestionList setHidden:YES];
        return;
    }
    
    NSString *szToken = [WiFiDetailController generateRandomString:16];
    [self requestGoogleMapsApiPlaceAutoCompleteWithInput:sz token:szToken callback:^(NSString *token, NSArray *results) {
        if ([szToken caseInsensitiveCompare:token] != NSOrderedSame) return;
        [self.m_arrSuggestion removeAllObjects];
        [self.m_arrSuggestion addObjectsFromArray:results];
        [self.m_tableviewSuggestionList reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect frame = self.m_tableviewSuggestionList.frame;
            frame.size.height = self.m_tableviewSuggestionList.contentSize.height;
            self.m_tableviewSuggestionList.frame = frame;
            
            [self.m_tableviewSuggestionList setHidden:NO];
        });
        
    }];
}

+ (NSString *)generateRandomString:(int)length {
    NSString *szPattern = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [szPattern characterAtIndex:
                                            arc4random_uniform((int)[szPattern length])]];
    }
    return randomString;
}

- (void)requestGoogleMapsApiPlaceAutoCompleteWithInput:(NSString *)input token:(NSString *)token
                                              callback:(void (^)(NSString *token, NSArray *results))callback {
    
    NSString *szUrl = @"https://maps.googleapis.com/maps/api/place/autocomplete/json";
    NSDictionary *params = @{@"input" : input,
                             @"sensor": @"true",
                             @"key": GOOGLEMAPS_API_PLACE_KEY
                             };
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestManager GET:szUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            NSDictionary *dictResponse = responseObject;
            NSString *status = [self refineNSString:[dictResponse objectForKey:@"status"]];
            NSMutableArray *arrResult = [[NSMutableArray alloc] init];
            if ([status caseInsensitiveCompare:@"OK"] == NSOrderedSame) {
                NSArray *arr = [dictResponse objectForKey:@"predictions"];
                if ([arr count] > 0) {
                    for (int i = 0; i < (int)[arr count]; i++) {
                        NSDictionary *dict = [arr objectAtIndex:i];
                        NSString *szReference = [self refineNSString:[dict objectForKey:@"description"]];
                        [arrResult addObject:szReference];
                    }
                }
            }
            if (callback) {
                callback(token, arrResult);
            }
        }
        @catch (NSException *exception) {
            if (callback) {
                callback(token, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callback) {
            callback(token, nil);
        }
    }];
}

- (NSString *)refineNSString:(id)sz {
    NSString *szResult = @"";
    if ((sz == nil) || ([sz isKindOfClass:[NSNull class]] == YES))
        szResult = @"";
    else
        szResult = [NSString stringWithFormat:@"%@", sz];
    
    return szResult;
}


@end
