//
//  WiFisController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing frequented addresses (WIFI addresses)
//

#import "WiFisController.h"
#import "WiFiDetailController.h"
#import "WiFiSubmenuTVC.h"
#import "ThankyouController.h"
#import "EngineMgr.h"
#import "EMGAddressSuggestionTVC.h"
#import "AFNetworking.h"
#import "AddressSearchTableViewCell.h"


@interface WiFisController ()
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@end

@implementation WiFisController {
    BOOL m_bUIRearrangeNeeded;
    
    BOOL reloaded;
    
    
    int m_nWiFiItemCnt;
    CGFloat screenHeight;
    CGFloat originalHeight;
    NSIndexPath* indx;
}

NSInteger selectField = -9;
BOOL isshown = NO;
NSString* selectedText = @"";

#define ALERTVIEW_TAG_REMOVE_ITEM 10003
#define GOOGLEMAPS_API_PLACE_KEY            @"AIzaSyCJZP2ZEhknm0xU8BW_ipDG7tg1gyAA660"

@synthesize m_btnBack;
@synthesize m_tableviewWiFis;

- (void)viewDidLoad {
    [super viewDidLoad];
    reloaded = NO;
    originalHeight = [self.bottom constant];
    self.m_arrSuggestion = [[NSMutableArray alloc] init];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
    [self registerForKeyboardNotifications];
    if (self.fromMenu) {
        self.h_pageControl.hidden = YES;
        self.h_view.hidden = YES;
//        self.h_tittle.text = @"FREQUENT ADDRESSES";
        [self.m_btnBack setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [self.h_finish setTitle:@"Finished" forState:UIControlStateNormal];
//        self.h_tittle.textColor = [UIColor blackColor];
//        self.h_tableUp.constant = -100;
        self.h_tableup.constant = 8;
        self.h_discription.hidden = NO;
    }else {
        self.h_tableup.priority = 240;
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (void)registerForKeyboardNotifications
{
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:activeField];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGSize keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    CGFloat height = keyboardSize.height;
    
    CGFloat y = 100;
    self.topMargin.constant = -y;
    self.bottom.constant = y;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.topMargin.constant = 0;
    self.bottom.constant = originalHeight;
//    if (self.fromMenu) {
//        
//    }else {
//        self.m_btnBack.hidden = NO;
//        self.h_tittle.hidden = NO;
//    }
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.m_bFromSignup) {
        //[m_btnBack setHidden:YES];
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        self.m_nHeaderPosY.constant = -316;
    }
    
    m_bUIRearrangeNeeded = YES;
    
    [self refreshTable];
}

- (void)viewDidLayoutSubviews {
    if (m_bUIRearrangeNeeded) {
        m_bUIRearrangeNeeded = NO;

        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        m_tableviewWiFis.contentInset = contentInsets;
        m_tableviewWiFis.scrollIndicatorInsets = contentInsets;
        [m_tableviewWiFis setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    [super viewDidLayoutSubviews];
}

- (void) refreshTable {
    m_nWiFiItemCnt = 0;
    int idx = 0;
    while (TRUE) {
        NSString *strWiFiTitle = [[EngineMgr sharedInstance] getWiFiTitleOfIndex:idx++];
        if (strWiFiTitle == nil || [strWiFiTitle length] == 0)
            break;
        m_nWiFiItemCnt++;
    }
    
    [m_tableviewWiFis reloadData];
}

- (void) goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Event Listener
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *szCellIdentifierSubMenu = @"TABLECELL_WIFI_SUBMENU";
//    
//    WiFiSubmenuTVC * cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifierSubMenu];
//    if (cell == nil) {
//        cell = [[WiFiSubmenuTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifierSubMenu];
//    }
//    
//    NSString *strWiFiId = [[EngineMgr sharedInstance] getWiFiIDOfIndex:(int)section];
//    cell.m_lblTitle.text = [[EngineMgr sharedInstance] getWiFiTitleOfIndex:(int)section];
//    if (strWiFiId != nil && [strWiFiId length] > 0) {
//        cell.m_lblTitle.text = [cell.m_lblTitle.text stringByAppendingString:@" (Connected)"];
//    }
//    
//    if (reloaded) {
//        
//    } else {
//        cell.m_lblAddress.text = [[EngineMgr sharedInstance] getWiFiAddressOfIndex:(int)section];
//    }
//    
//    
//    if (self.m_bSelectAddress) {
//        [cell.m_btnDelete setHidden:YES];
//        cell.m_nDeleteBtnWidth.constant = 0;
//    }
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 87;
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section{
     //[self.m_arrSuggestion count];//m_nWiFiItemCnt+1;
    if (section == selectField) {
        return [self.m_arrSuggestion count]+1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >0) {
        return 44;
    }else {
        return 87;
    }
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{
    static NSString *szCellIdentifierSubMenu = @"TABLECELL_WIFI_SUBMENU";
    
    if (isshown && indexPath.row >= 1) {
    
        NSString *szCellIdentifier = @"BasicCell";
        
        AddressSearchTableViewCell *cell = (AddressSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
        if (cell == nil) {
            cell = [[AddressSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifier];
        }
        cell.cell_address.text = [self.m_arrSuggestion objectAtIndex:indexPath.row-1];
        return cell;
        
        
    }else {
        WiFiSubmenuTVC * cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifierSubMenu];
        if (cell == nil) {
            cell = [[WiFiSubmenuTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifierSubMenu];
        }
        
        NSString *strWiFiId = [[EngineMgr sharedInstance] getWiFiIDOfIndex:(int)indexPath.row];
        
        
        NSString *title =[[EngineMgr sharedInstance] getWiFiTitleOfIndex:(int)indexPath.section];
        if (title != nil && [title length] > 0) {
            cell.m_lblTitle.text = title;
        }else if (indexPath.section == 0){
            cell.m_lblTitle.text = @"Home";
        }
        cell.m_lblTitle.tag = indexPath.section;
        if (strWiFiId != nil && [strWiFiId length] > 0) {
            cell.m_lblTitle.text = [cell.m_lblTitle.text stringByAppendingString:@" (Connected)"];
        }
        
        if (selectField == - indexPath.section) {
            cell.m_lblAddress.text = selectedText;
//            activeHome = cell.m_lblTitle;
//            activeField = cell.m_lblAddress;
        }else {
            cell.m_lblAddress.text = [[EngineMgr sharedInstance] getWiFiAddressOfIndex:(int)indexPath.section];

        }
        if (indexPath.section == 0) {
            cell.m_lblTitle.userInteractionEnabled = NO;
        }
        cell.m_lblAddress.tag = indexPath.section;
        
        if (self.m_bSelectAddress) {
            [cell.m_btnDelete setHidden:YES];
            cell.m_nDeleteBtnWidth.constant = 0;
        }
        return cell;

    }
    // Presets first, followed by suggestions
//    int index = (int) indexPath.row;
    
//    NSString *szDescription = [self.m_arrSuggestion objectAtIndex:(index)];
////    [cell.m_btnAddress setTitle:szDescription forState:UIControlStateNormal];
//    cell.textLabel.text = szDescription;
    
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    int row = (int) indexPath.row;
//    
//    if (self.m_bSelectAddress) {
//        NSString* strCurWiFiID = [EngineMgr currentWifiSSID];
//        NSString* strTitle = [[EngineMgr sharedInstance] getWiFiTitleOfIndex:row];
//        NSString* strAddress = [[EngineMgr sharedInstance] getWiFiAddressOfIndex:row];
//        [[EngineMgr sharedInstance] setWifiItem:row title:strTitle address:strAddress id:strCurWiFiID];
//        
//        [[EngineMgr sharedInstance] saveWiFiItemToStorage:row];
//        [self goBack];
//        
//    } else {
//        [self gotoWiFiDetailController:row SSID:nil isAnimation:YES];
//    }
    
    if ([self.m_arrSuggestion count] > 0) {
        [self onSelectAddressSuggestion:(int) indexPath.row];
    }
    
    
    [m_tableviewWiFis deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)editingDidBegin:(id)sender {
    activeField = (UITextField *)sender;
    activeField.text = @"";
    
}

- (IBAction)didChange:(id)sender {
   /* activeField = (UITextField *)sender;
    NSString *sz = activeField.text;
    selectField = activeField.tag;
    indx = [NSIndexPath indexPathForRow:0 inSection:activeField.tag];
    
    if (sz.length == 0){
        [self.m_arrSuggestion removeAllObjects];
//        [self.m_tableviewWiFis reloadData];
        //        [self.m_tableviewSuggestionList setHidden:YES];
        
    }else {
        
        NSString *szToken = [WiFisController generateRandomString:16];
        [self requestGoogleMapsApiPlaceAutoCompleteWithInput:sz token:szToken callback:^(NSString *token, NSArray *results) {
            NSLog(@"%@",results);
//            reloaded = YES;
            isshown = YES;
            
            if ([szToken caseInsensitiveCompare:token] != NSOrderedSame) return;
            [self.m_arrSuggestion removeAllObjects];
            [self.m_arrSuggestion addObjectsFromArray:results];
            NSRange range = NSMakeRange(0, 1);
            NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:activeField.tag];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:2 inSection:activeField.tag];
            [self.m_tableviewWiFis reloadData];
//            [self.m_tableviewWiFis reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.m_tableviewWiFis beginUpdates];
            [self.m_tableviewWiFis reloadRowsAtIndexPaths:@[indexPath1,indexPath2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.m_tableviewWiFis endUpdates];
            //        dispatch_async(dispatch_get_main_queue(), ^{
            //            CGRect frame = self.m_tableviewSuggestionList.frame;
            //            frame.size.height = self.m_tableviewSuggestionList.contentSize.height;
            //            self.m_tableviewSuggestionList.frame = frame;
            //
            //            [self.m_tableviewSuggestionList setHidden:NO];
            //        });
            
        }];
    }*/
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    activeField = nil;
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}



- (IBAction)onAddWiFiItem:(id)sender {
    [self addWiFiItem:YES];
}

- (void) addWiFiItem:(BOOL)isAnimation {
    // Consider if WIFI is connected
//    NSString* strCurWiFiID = [EngineMgr currentWifiSSID];
//    if (strCurWiFiID == nil || [strCurWiFiID length] == 0) {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"One Scream" message:@"WIFI is not connected." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [message show];
//        return;
//    }
    
    // Check if current WIFI was already registered
//    int idx = [[EngineMgr sharedInstance] getWiFiItemIdx:strCurWiFiID];
//    if (idx >= 0) {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"One Scream" message:[NSString stringWithFormat:@"This WiFi device has already been added as \"%@\"", [[EngineMgr sharedInstance] getWiFiTitleOfIndex:idx]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [message show];
//        return;
//    }
    
    // Check if the count of WIFI items is maximum
    if (m_nWiFiItemCnt >= [[EngineMgr sharedInstance] getMaxWIFICount]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"One Scream" message:[NSString stringWithFormat:@"One Scream can't register more than %d items.", [[EngineMgr sharedInstance] getMaxWIFICount]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        return;
    }
    WiFiSubmenuTVC * cell =[m_tableviewWiFis cellForRowAtIndexPath:indx];
    NSString *strTitle = cell.m_lblTitle.text;
    NSString *strAddress = cell.m_lblAddress.text;
    
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
    
    [[EngineMgr sharedInstance] setWifiItem:m_nWiFiItemCnt title:strTitle address:strAddress id:@""];
    
    [[EngineMgr sharedInstance] saveWiFiItemToStorage:m_nWiFiItemCnt];
    
    activeHome = nil;
    activeField = nil;
    selectedText = @"";
    selectField = -9;
    if (self.m_bFromSignup) {
        
        [self gotoThankyouController];
    } else {
        [self goBack];
    }
    
//    [self gotoWiFiDetailController:m_nWiFiItemCnt SSID:@"" isAnimation:isAnimation];
}

- (IBAction)onDeleteItem:(id)sender {
    UIButton *button = sender;
    int index = [self getCellIndexFromSubview:button];
    if (index == -1) return;
    m_tableviewWiFis.tag = index;
    
    [self showAlertViewWithTitle:@"Are you sure you want to remove?" CancelButtonTitle:@"No" OtherButtonTitle:@"Yes" Tag:ALERTVIEW_TAG_REMOVE_ITEM];
}

- (IBAction)onFinished:(id)sender {
    if (self.m_bFromSignup) {
        if (m_nWiFiItemCnt >= [[EngineMgr sharedInstance] getMaxWIFICount]) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"One Scream" message:[NSString stringWithFormat:@"One Scream can't register more than %d items.", [[EngineMgr sharedInstance] getMaxWIFICount]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [message show];
            return;
        }
        WiFiSubmenuTVC * cell =[m_tableviewWiFis cellForRowAtIndexPath:indx];
        NSString *strTitle = cell.m_lblTitle.text;
        NSString *strAddress = cell.m_lblAddress.text;
        
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
        
        [[EngineMgr sharedInstance] setWifiItem:m_nWiFiItemCnt title:strTitle address:strAddress id:@""];
        
        [[EngineMgr sharedInstance] saveWiFiItemToStorage:m_nWiFiItemCnt];
        
        activeHome = nil;
        activeField = nil;
        selectedText = @"";
        selectField = -9;
        [self gotoThankyouController];
    } else {
        [self goBack];
    }
}


- (void) gotoThankyouController {
    ThankyouController *nextScr = (ThankyouController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ThankyouController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (void) gotoWiFiDetailController:(int) p_idx SSID:(NSString*) p_ssid isAnimation:(BOOL)p_bAnimation{
    WiFiDetailController *nextScr = (WiFiDetailController *) [self.storyboard instantiateViewControllerWithIdentifier:@"WiFiDetailController"];
    nextScr.m_nWiFiItemIdx = p_idx;
    nextScr.m_strCurrentWiFiID = p_ssid;
    [self.navigationController pushViewController:nextScr animated:p_bAnimation];
}

- (int) getCellIndexFromSubview: (UIView *) subview{
    UIView *superview = subview.superview;
    while (superview != nil && [superview isKindOfClass:[UITableViewCell class]] == NO && [superview isKindOfClass:[UIViewController class]] == NO){
        superview = superview.superview;
    }
    if ([superview isKindOfClass:[UITableViewCell class]] == NO){
        return -1;
    }
    NSIndexPath *path = [m_tableviewWiFis indexPathForCell:(UITableViewCell *)superview];
    return (int) path.row;
}

- (void) showAlertViewWithTitle: (NSString *) title CancelButtonTitle: (NSString *) cancelButtonTitle OtherButtonTitle: (NSString *) otherButtonTitle Tag: (int) tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    alertView.tag = tag;
    
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == ALERTVIEW_TAG_REMOVE_ITEM){
        if (buttonIndex == 1){
            int index = (int) m_tableviewWiFis.tag;
            
            [self deleteWiFiItem:index];
            
            [self refreshTable];
        }
    }
}

- (void) deleteWiFiItem:(int) p_idx {
    for (int i = p_idx; i < m_nWiFiItemCnt - 1; i++)
    {
        NSString* strTitle = [[EngineMgr sharedInstance] getWiFiTitleOfIndex:i];
        NSString* strAddress = [[EngineMgr sharedInstance] getWiFiAddressOfIndex:i];
        NSString* strSSID = [[EngineMgr sharedInstance] getWiFiIDOfIndex:i];
        [[EngineMgr sharedInstance] setWifiItem:i title:strTitle address:strAddress id:strSSID];
        [[EngineMgr sharedInstance] saveWiFiItemToStorage:i];
    }
    
    [[EngineMgr sharedInstance] setWifiItem:m_nWiFiItemCnt-1 title:@"" address:@"" id:@""];
    [[EngineMgr sharedInstance] saveWiFiItemToStorage:m_nWiFiItemCnt-1];

    m_nWiFiItemCnt = m_nWiFiItemCnt - 1;
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

- (void) onSelectAddressSuggestion: (int) index{
    NSString *szReference = [self.m_arrSuggestion objectAtIndex:index-1];
//    self.m_etAddress.text = szReference;
    WiFiSubmenuTVC * cell =[m_tableviewWiFis cellForRowAtIndexPath:indx];
    cell.m_lblTitle.text = szReference;
    //activeField.text = szReference;
    selectedText = szReference;
    selectField = -indx.section;
    [self.m_arrSuggestion removeAllObjects];
    [self.m_tableviewWiFis reloadData];
//    [self.m_tableviewSuggestionList setHidden:YES];
}

@end
