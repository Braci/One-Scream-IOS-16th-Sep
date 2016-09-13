//
//  DetectedScreamController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  View Controller Class for Scream Detected screen
//

#import <UIKit/UIKit.h>

@interface DetectedScreamController : UIViewController
{
    // GPS Location
    double m_dLatitude;
    double m_dLongitude;
    double m_dAccuracy;
}

@property (weak, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblAddress;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgDetected;
@property (weak, nonatomic) IBOutlet UIButton *m_lblCountDown;
@property (weak, nonatomic) IBOutlet UIButton *doNOtMakeCall;

@property (weak, nonatomic) IBOutlet UILabel *note;
@property (weak, nonatomic) IBOutlet UIButton *cancel;

- (IBAction)onConfirm:(id)sender;
- (IBAction)onFalse:(id)sender;


@end

