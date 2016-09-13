//
//  HowToController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing first 4 pages when the user downloaded
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface HowToController : UIViewController {
    bool m_bUIInitialized;
}

@property BOOL m_bOnTour;

@property (nonatomic, weak) IBOutlet UIView *scrContentSizeView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_height;

- (IBAction)onContinue:(id)sender;

- (void)goBack;
@end

