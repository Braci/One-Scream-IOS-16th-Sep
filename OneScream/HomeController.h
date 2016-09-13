//
//  HomeController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//  View Controller Class for Home Screen
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeController : UIViewController {
    // past frame count since the scream is detected
    int m_nPastTimes;
    
    // audio opened status before making Police siren
    bool m_bOpenedAudio;
    
    // First Date time to check WIFI
    long m_lFirstDateTime;
    
    // Ignored WIFI items
    NSMutableArray* m_ignoredWIFIs;
    
    NSString *m_strCurWiFiID;
    
    bool m_bNewScreenLoaded;
    
}

/** Image for detecting status */
@property (weak, nonatomic) IBOutlet UIImageView *m_imgDetectingStatus;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgDetectingStatus1;
/** Label for detecting status */
@property (weak, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDetectingStatus;
/** Play/Stop Detecting Button */
@property (weak, nonatomic) IBOutlet CustomButton *m_btnDetect;

- (IBAction)btLeftMenuClick:(id)sender;

- (IBAction)onSettings:(id)sender;
- (IBAction)onBtnDetect:(id)sender;
- (void)switchDetecting;
@end

