//
//  IntroPage1Controller.h
//  OneScream
//
//  Created by  Anwar Almojakresh on 11/5/15.
//  Copyright (c) 2015 One Scream Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroPage1Controller : UIViewController

@property (weak, nonatomic) UIViewController *m_parentController;

@property (weak, nonatomic) IBOutlet UIButton *m_btnBack;

- (IBAction)onBtnBack:(id)sender;
@end
