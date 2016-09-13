//
//  FaqDetailController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing Faq in detail
//

#import "FaqDetailController.h"
#import "HowToController.h"

@interface FaqDetailController ()

@end

@implementation FaqDetailController {
    BOOL m_bUIRearrangeNeeded;
}

@synthesize m_strTitle;
@synthesize m_strContent;

@synthesize m_scrollView;
@synthesize m_contentView;
@synthesize m_lblTitle;
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
    [self.navigationController setNavigationBarHidden:NO];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"FAQ Detail Screen"];

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

- (IBAction)onAccept:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initContents {
    // Sets the contents of Terms and Conditions to label.
    
    [m_lblTitle setText:m_strTitle];
    
    m_lblToC.text = m_strContent;
    [m_lblToC sizeToFit];
    
    CGRect frameContents = m_lblToC.frame;
    
    CGRect frameContentView = m_contentView.frame;
    frameContentView.size.width = 100;
    frameContentView.size.height = frameContents.size.height + 250;
    
    self.cheight.constant = frameContentView.size.height;

    [m_scrollView setShowsVerticalScrollIndicator:NO];

}


@end
