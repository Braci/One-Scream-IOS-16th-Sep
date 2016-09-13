//
//  HowToController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing first 4 pages when the user downloaded
//

#import "HowToController.h"
#import "SignupController.h"
#import "IntroPage1Controller.h"
#import "IntroPage2Controller.h"
#import "IntroPage3Controller.h"

@interface HowToController ()

@end

@implementation HowToController

@synthesize  scrContentSizeView;
@synthesize  scrollView;

- (id) init{
    if (self = [super init]) {
    }
    self.m_bOnTour = NO;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_bUIInitialized = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}

- (void) viewDidLayoutSubviews
{
    [self initLayout];
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)PagescrollView
{

}

- (IBAction)onContinue:(id)sender {
    if (self.m_bOnTour) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    SignupController *nextScr = (SignupController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignupController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (void) goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initLayout {
    if (m_bUIInitialized) // initialize layout only once.
        return;
    
    int button_height = 40;
    
    m_bUIInitialized = true;
    // Make pages for how to work
    CGRect rect = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    int x_pos = 0;
    int page_width = scrollView.frame.size.width;
    int page_height = scrollView.frame.size.height + 8;
    
    // Page 1
    IntroPage1Controller *page1Controller = [[IntroPage1Controller alloc] initWithNibName:@"IntroPage1Controller" bundle:nil];
    page1Controller.m_parentController = self;
    [page1Controller.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addChildViewController:page1Controller];
    [scrContentSizeView addSubview:page1Controller.view];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page1Controller.view
                                                                   attribute:NSLayoutAttributeLeadingMargin
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:scrContentSizeView
                                                                   attribute:NSLayoutAttributeLeadingMargin
                                                                  multiplier:1.0
                                                                    constant:x_pos]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page1Controller.view
                                                                   attribute:NSLayoutAttributeTopMargin
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:scrContentSizeView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page1Controller.view
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:page_width]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page1Controller.view
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:page_height]];
    
    

    // Page 2
    x_pos += page_width;
    IntroPage2Controller *page2Controller = [[IntroPage2Controller alloc] initWithNibName:@"IntroPage2Controller" bundle:nil];
    page2Controller.m_parentController = self;
    [page2Controller.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addChildViewController:page2Controller];
    [scrContentSizeView addSubview:page2Controller.view];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page2Controller.view
                                                                   attribute:NSLayoutAttributeLeadingMargin
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:scrContentSizeView
                                                                   attribute:NSLayoutAttributeLeadingMargin
                                                                  multiplier:1.0
                                                                    constant:x_pos]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page2Controller.view
                                                                   attribute:NSLayoutAttributeTopMargin
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:scrContentSizeView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page2Controller.view
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:page_width]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page2Controller.view
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:page_height]];
    
    // Page 3
    x_pos += page_width;
    IntroPage3Controller *page3Controller = [[IntroPage3Controller alloc] initWithNibName:@"IntroPage3Controller" bundle:nil];
    page3Controller.m_parentController = self;
    [page3Controller.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addChildViewController:page3Controller];
    [scrContentSizeView addSubview:page3Controller.view];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page3Controller.view
                                                                   attribute:NSLayoutAttributeLeadingMargin
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:scrContentSizeView
                                                                   attribute:NSLayoutAttributeLeadingMargin
                                                                  multiplier:1.0
                                                                    constant:x_pos]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page3Controller.view
                                                                   attribute:NSLayoutAttributeTopMargin
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:scrContentSizeView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page3Controller.view
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:page_width]];
    [scrContentSizeView addConstraint:[NSLayoutConstraint constraintWithItem:page3Controller.view
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:page_height]];
    
    
    ///> make Continue buttons in last page
    CustomButton* btnContinue = [[CustomButton alloc] initWithFrame:CGRectMake(x_pos - 16 + page_width / 2 - 70, page_height - 10 - button_height, 140, button_height)];
    [btnContinue setTitle:@"That's It!" forState:UIControlStateNormal];
    [btnContinue setBackgroundColor:[UIColor colorWithRed:52/255.0f green:66/255.0f blue:81/255.0f alpha:1.0f]];

    btnContinue.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnContinue addTarget:self action:@selector(onContinue:) forControlEvents:UIControlEventTouchUpInside];
    [scrContentSizeView addSubview:btnContinue];

    int whole_width = x_pos + page_width - 8;
    self.view_width.constant = whole_width;
    self.view_height.constant = scrollView.frame.size.height ;
    [scrContentSizeView setFrame:CGRectMake(0, 0, whole_width, rect.size.height)];
    
    
    // set UI settings for page scroll view
    scrollView.clipsToBounds = YES;
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}
@end
