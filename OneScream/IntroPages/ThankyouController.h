//
//  ThankyouController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for last Screen of first tour
//

#import <UIKit/UIKit.h>
#import "CustomDarkButton.h"
#import "CustomButton.h"

@interface ThankyouController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet CustomDarkButton *trail;
@property (weak, nonatomic) IBOutlet CustomButton *subscribe;
@property (nonatomic) BOOL fromMenu;
@property (nonatomic) BOOL hidebtn;
@property (weak, nonatomic) IBOutlet UIPageControl *control;

- (IBAction)onFreeTrial:(id)sender;
- (IBAction)onSubscribe:(id)sender;

@end

