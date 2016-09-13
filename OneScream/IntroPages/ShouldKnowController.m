//
//  ShouldKnowController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for "You Should Know" Screen on first tour
//

#import "ShouldKnowController.h"
#import "HowToController.h"
#import "SignupController.h"

@interface ShouldKnowController ()

@end

@implementation ShouldKnowController {
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
    
    if (self.m_bOnTour) {
        [self.navigationController setNavigationBarHidden:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)viewDidLayoutSubviews {
    [self initContents];
    
    if (m_bUIRearrangeNeeded) {
        m_bUIRearrangeNeeded = NO;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        m_scrollView.contentInset = contentInsets;
        m_scrollView.scrollIndicatorInsets = contentInsets;
        [m_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    [super viewDidLayoutSubviews];
}

- (IBAction)onContinue:(id)sender {
    if (self.m_bOnTour) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    SignupController *nextScr = (SignupController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignupController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (void) initContents {
    // Sets the contents of Terms and Conditions to label.
    NSString *strContent = nil;
    
    NSString *str = @"One Scream can not hear you if your phone is powered off or when you are on the phone.\n\n";
    strContent = [NSString stringWithFormat:@"%@", str];
    
    str = @"One Scream can hear you if your phone is in your bag or less than 5 meters away from you.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"We will not record your spoken words, we care about your Privacy. We will record your panic scream, it makes us smarter.\n\n";
    strContent = [NSString stringWithFormat:@"%@%@", strContent, str];
    
    str = @"If our app activates a call to Police on your behalf, the Police will hear the recorded scream and they will have an open line to hear you.\n\n";
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
