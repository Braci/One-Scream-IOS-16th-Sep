//
//  TermsController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Terms and Conditions Screen
//

#import "TermsController.h"
#import "HowToController.h"

@interface TermsController ()

@end

@implementation TermsController {
    BOOL m_bUIRearrangeNeeded;
}

@synthesize m_scrollView;
@synthesize m_contentView;
@synthesize m_lblToC;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    m_bUIRearrangeNeeded = YES;
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLayoutSubviews {
    //[self initContents];
    
    if (m_bUIRearrangeNeeded) {
        m_bUIRearrangeNeeded = NO;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        m_scrollView.contentInset = contentInsets;
        m_scrollView.scrollIndicatorInsets = contentInsets;
        [m_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    [super viewDidLayoutSubviews];
}

- (IBAction)onAccept:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initContents {
    
    // Sets the contents of Terms and Conditions to label.
    NSString *strContent = nil;
    
    NSString *str = @"1. INTRODUCTION: Welcome to our One Scream mobile application. This Application is published by or on behalf of One Scream Ltd.\n\n";
    strContent = [NSString stringWithFormat:@"%@", str];
    
    str = @"By downloading or otherwise accessing the App you agree to be bound by the following terms and conditions. If you have any queries about the App or these Terms, you can contact us by any of the means set out in paragraph 10 of these Terms. If you do not agree with these Terms, you should stop using the App immediately.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"B2. GENERAL RULES RELATING TO CONDUCT: The App is made available for your own, personal use. The App must not be used for any commercial purpose whatsoever or for any illegal or unauthorised purpose. When you use the App you must comply with all applicable UK laws and with any applicable international laws, including the local laws in your country of residence (together referred to as “Applicable Laws”).\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"You agree that when using the App you will comply with all Applicable Laws and these Terms. In particular, but without limitation, you agree not to:\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @" (a) Use the App in any unlawful manner or in a manner which promotes or encourages illegal activity including (without limitation) copyright infringement; or\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @" (b) Attempt to gain unauthorized access to the App or any networks, servers or computer systems connected to the App; or\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @" (c) Modify, adapt, translate or reverse engineer any part of the App or re-format or frame any portion of the pages comprising the App, save to the extent expressly permitted by these Terms or by law.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"3. CONTENT: The copyright in all material contained on, in, or available through the App including all information, data, text, music, sound, photographs, graphics and video messages, the selection and arrangement thereof, and all source code, software compilations and other material is owned by or licensed to One Scream Ltd.or its group companies. All rights are reserved. You can view, print or download extracts of the Material for your own personal use but you cannot otherwise copy, edit, vary, reproduce, publish, display, distribute, store, transmit, commercially exploit, disseminate in any form whatsoever or use the Material without One Scream Ltd.express permission.\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"The trademarks, service marks, and logos contained on or in the App are owned by One Scream Ltd. or its group companies or third party partners of One Scream Ltd. You cannot use, copy, edit, vary, reproduce, publish, display, distribute, store, transmit, commercially exploit or disseminate the Trade Marks without the prior written consent of One Scream Ltd. or the relevant group company or the relevant third party partner of One Scream Ltd..\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"4. LINK TO THIRD PARTIES: The App may contain links to websites operated by third parties. One Scream Ltd. may monetise some of these links through the use of third party affiliate programmes. Notwithstanding such affiliate programmes, One Scream Ltd. does not have any influence or control over any such Third Party Websites and, unless otherwise stated, is not responsible for and does not endorse any Third Party Websites or their availability or contents.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"5. ONE SCREAM LTD. PRIVACY POLICY: We take your privacy very seriously. One Scream Ltd.  will only use your personal information in accordance with the terms of our policies. By using the App you acknowledge and agree that you have read and accept the terms.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"6. DISCLAIMER / LIABILITY: USE OF THE APP IS AT YOUR OWN RISK.\n One Scream Ltd. will not be liable, in contract, tort (including, without limitation, negligence), under statute or otherwise, as a result of or in connection with the App, for any: (i) economic loss (including, without limitation, loss of revenues, profits, contracts, business or anticipated savings); or (ii) loss of goodwill or reputation; or (iii) special or indirect or consequential loss. One Scream Ltd. Will not be liable for any technology fails as the technology can and will fail. It is the responsibility of the user to always be within quick reach of other means within the area.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"7. SERVICE SUSPENSION: One Scream Ltd. reserves the right to suspend or cease providing any services relating to the apps published by it, with or without notice, and shall have no liability or responsibility to you in any manner whatsoever if it chooses to do so.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"8. ADVERTISERS IN THE APP: We accept no responsibility for adverts contained within the App. If you agree to purchase goods and/or services from any third party who advertises in the App, you do so at your own risk. The advertiser, not One Scream Ltd. is responsible for such goods and/or services and if you have any queries or complaints in relation to them, your only recourse is against the advertiser.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"9. COMPETITIONS: If you take part in any competition which is run in or through the App, you agree to be bound by the rules of that competition and any other rules specified by One Scream Ltd. from time to time and by the decisions of One Scream Ltd. which are final in all matters relating to the Competition. One Scream Ltd. reserves the right to disqualify any entrant and/or winner in its absolute discretion without notice in accordance with the Competition Rules.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"10. GENERAL: These Terms (as amended from time to time) constitute the entire agreement between you and One Scream Ltd.  concerning your use of the App.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"One Scream Ltd.  reserves the right to update these Terms from time to time. If it does so, the updated version will be effective immediately, and the current Terms are available through a link in the App to this page.  You are responsible for regularly reviewing these Terms so that you are aware of any changes to them and you will be bound by the new policy upon your continued use of the App.  No other variation to these Terms shall be effective unless in writing and signed by an authorized representative on behalf of One Scream Ltd.’\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"These Terms shall be governed by and construed in accordance with English law and you agree to submit to the exclusive jurisdiction of the English Courts.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"If any provision(s) of these Terms is held by a court of competent jurisdiction to be invalid or unenforceable, then such provision(s) shall be construed, as nearly as possible, to reflect the intentions of the parties (as reflected in the provision(s)) and all other provisions shall remain in full force and effect.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"One Scream Ltd. failure to exercise or enforce any right or provision of these Terms shall not constitute a waiver of such right or provision unless acknowledged and agreed to by One Scream Ltd. in writing.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"Unless otherwise expressly stated, nothing in the Terms shall create any rights or any other benefits whether pursuant to the Contracts (Rights of Third Parties) Act 1999 or otherwise in favor of any person other than you, One Scream Ltd. and its group of companies.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    
    
    m_lblToC.text = strContent;
    [m_lblToC sizeToFit];
    
    CGRect frameContents = m_lblToC.frame;
    
    CGRect frameContentView = m_contentView.frame;
    frameContentView.size.width = 100;
    frameContentView.size.height = frameContents.size.height + 250;
    
    self.cheight.constant = frameContentView.size.height;

    [m_scrollView setShowsVerticalScrollIndicator:NO];

}


@end
