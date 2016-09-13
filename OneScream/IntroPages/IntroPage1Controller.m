//
//  IntroPage1Controller.m
//  OneScream
//
//  Created by  Anwar Almojakresh on 11/5/15.
//  Copyright (c) 2015 One Scream Ltd. All rights reserved.
//

#import "IntroPage1Controller.h"
#import "HowToController.h"

@interface IntroPage1Controller ()

@end

@implementation IntroPage1Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    if (((HowToController*) self.m_parentController).m_bOnTour) {
//        [self.m_btnBack setHidden:NO];
//    } else {
//        [self.m_btnBack setHidden:YES];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnBack:(id)sender {
    [(HowToController*)self.m_parentController goBack];
}
@end
