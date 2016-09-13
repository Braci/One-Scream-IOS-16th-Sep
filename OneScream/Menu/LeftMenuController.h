//
//  LeftMenuController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Settings Screen
//

#import <UIKit/UIKit.h>

@interface LeftMenuController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *m_tableviewSettings;
@property (weak, nonatomic) IBOutlet UIButton *privacy;
@property (weak, nonatomic) IBOutlet UIButton *terms;

- (IBAction)onPrivacyPolicy:(id)sender;
- (IBAction)onTermsServices:(id)sender;

@end

