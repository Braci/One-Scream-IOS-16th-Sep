//
//  PrivacyController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for showing privacy policy
//

#import <UIKit/UIKit.h>

@interface PrivacyController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cheight;
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;
@property (weak, nonatomic) IBOutlet UIView *m_contentView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblToC;

- (IBAction)onAccept:(id)sender;
@end

