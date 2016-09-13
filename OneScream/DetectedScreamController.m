//
//  DetectedScreamController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  View Controller Class for Scream Detected screen
//


#import "DetectedScreamController.h"
#import "EMGLocationManager.h"
#import "EngineMgr.h"
#import <AVFoundation/AVFoundation.h>
//#import <Parse/Parse.h>
#import <Backendless.h>
#import "userNotification.h"
#import "detection_history.h"
@interface DetectedScreamController ()<IResponder>

@property int m_nPastTimes;
@property NSTimer* repeatTimer;

@property bool m_bOpenedAudio;

@property AVAudioPlayer *myAudioPlayer;

@end

@implementation DetectedScreamController

@synthesize m_lblTitle;
@synthesize m_lblAddress;
@synthesize m_lblCountDown;
@synthesize m_imgDetected;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self processDetected];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"Scream Detected Screen"];

}

- (IBAction)dontCall:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onConfirm:(id)sender {
    [self updateHistory:@"Alarm Activated"];
    [self updateDetectionLogs:@"Alarm Activated"];
    [self goBack];
}



- (IBAction)onFalse:(id)sender {
    [self updateHistory:@"False"];
    [self updateDetectionLogs:@"False"];
    [[EngineMgr sharedInstance] setEnginePause:NO];
    // process UNIVERSAL_ENGINE_THRESHOLD_DELTA
    [[EngineMgr sharedInstance] processFalseDetect];
    if ([self.myAudioPlayer isPlaying])
        [self.myAudioPlayer stop];
    
    if (self.m_bOpenedAudio)
    {
        [[EngineMgr sharedInstance] playAudio];
    }
    
    [self setTorch:NO];
    [self.repeatTimer invalidate];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) processDetected {
    [[EngineMgr sharedInstance] setEnginePause:YES];
    
    self.m_nPastTimes = 0;
    
    self.m_bOpenedAudio = [[EngineMgr sharedInstance] pauseAudio];
    
    self.repeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFiredForFlash:) userInfo:nil repeats:YES];
    
    
    [m_lblTitle setText:@"Scream Detected"];
    [m_imgDetected setImage:[UIImage imageNamed:@"Splash.png"]];
    
    // Set Address with WiFI
    bool bAddressSet = false;
    [m_lblAddress setText:@""];
    NSString* strWiFiSSID = [EngineMgr currentWifiSSID];
    if (strWiFiSSID != nil) {
        int idx = [[EngineMgr sharedInstance] getWiFiItemIdx:strWiFiSSID];
        if (idx >= 0) {
            [m_lblAddress setText:[[EngineMgr sharedInstance] getWiFiAddressOfIndex:idx]];
            bAddressSet = true;
        }
    }
    
    // Set Address of GPS when there is no WIFI
    if (!bAddressSet) {
        CLLocation* location = [[EMGLocationManager sharedInstance] m_location_gps];
        if (location != nil) {
            m_dLatitude = location.coordinate.latitude;
            m_dLongitude = location.coordinate.longitude;
            m_dAccuracy = location.horizontalAccuracy;
            [[EMGLocationManager sharedInstance] requestAddressWithLocation:location callback:^(NSString *szAddress) {
                NSString *strText = @"";
                if (szAddress == nil || [szAddress length] == 0) {
                    [m_lblAddress setText:@"can not get gps location."];
                    strText = [NSString stringWithFormat:@"(%.4f, %.4f) [%.4f] \n can not get gps location", m_dLongitude,
                               m_dLatitude, m_dAccuracy];
                } else {
                    strText = [NSString stringWithFormat:@"(%.4f, %.4f) [%.4f] \n%@", m_dLongitude,
                               m_dLatitude, m_dAccuracy, szAddress];
                }
                [m_lblAddress setText:strText];
            }];
        } else {
            [m_lblAddress setText:@"can not get gps location."];
        }
    }
    
    // playing police siren
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"policesiren" ofType:@"mp3"];
    NSURL* fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    self.myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.myAudioPlayer.numberOfLoops = -1;
    [self.myAudioPlayer setVolume:1.0f];
    [self.myAudioPlayer play];
}

- (void) goBack
{
    [[EngineMgr sharedInstance] setEnginePause:NO];
    
    self.cancel.hidden = YES;
    self.m_lblCountDown.userInteractionEnabled = NO;
//    [self.m_lblCountDown setText:@"DO NOT\nMAKE A CALL"];

    //[self.m_lblCountDown setTitle:@"Do not\nmake a call" forState:UIControlStateNormal];
    //[self.m_lblCountDown.titleLabel setTextAlignment: NSTextAlignmentCenter];
    //self.m_lblCountDown.titleLabel.font = [UIFont fontWithName:@"SanFranciscoDisplay-Thin" size:48]; //[UIFont systemFontOfSize:40];
    self.doNOtMakeCall.hidden = false;
    self.doNOtMakeCall.titleLabel.numberOfLines = 2;
    [self.doNOtMakeCall.titleLabel setTextAlignment: NSTextAlignmentCenter];

    self.m_lblCountDown.hidden = true;
    if ([self.myAudioPlayer isPlaying])
        [self.myAudioPlayer stop];
    
    if (self.m_bOpenedAudio)
    {
        [[EngineMgr sharedInstance] playAudio];
    }
    
    [self setTorch:NO];
    [self.repeatTimer invalidate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)setTorch:(BOOL)status {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        
        AVCaptureDevice *device = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        [device lockForConfiguration:nil];
        if ( [device hasTorch] ) {
            if ( status ) {
                [device setTorchMode:AVCaptureTorchModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
            }
        }
        [device unlockForConfiguration];
        
    }
}

- (void)timerFiredForFlash:(id)userInfo
{
    
    if (self.m_nPastTimes <= (POLICE_SIREN_PERIODS / 100))
    {
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"flashLightAlert"])
            // flash
        {
            if (self.m_nPastTimes % 8 == 4)
                [self setTorch:NO];
            else if (self.m_nPastTimes % 8 == 0)
                [self setTorch:YES];
        }
        // vibrate
        if (self.m_nPastTimes % 10 == 0)
        {
            NSLog(@"Start Vibrate");
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        
        int count = (120 - self.m_nPastTimes) / 10;
        if (count > 9) {
            NSString *tittle = [NSString stringWithFormat:@"%d", count];
            [self.m_lblCountDown setTitle:tittle forState:UIControlStateNormal];
        }else {
            NSString *tittle = [NSString stringWithFormat:@"0%d", count];
            [self.m_lblCountDown setTitle:tittle forState:UIControlStateNormal];
        }
    }
    
    if (self.m_nPastTimes == (POLICE_SIREN_PERIODS / 100))
    {
        [self setTorch:NO];
        
        if ([self.myAudioPlayer isPlaying])
            [self.myAudioPlayer stop];
        
    }
    
    if (self.m_nPastTimes > (POLICE_SIREN_PERIODS / 100)) {
        [self.note setText:@"We are communicating to the Police"];
        [self onConfirm:nil];
        //[self goBack];
    }
    
    if (self.m_nPastTimes < 500)
        self.m_nPastTimes++;
}

- (void)updateHistory:(NSString *)status
{
    NSString* soundObjectId = [[EngineMgr sharedInstance] getSoundObjectId];
    if (soundObjectId == nil || [soundObjectId length] == 0)
        return;
    id<IDataStore> dataStore = [backendless.persistenceService of:[userNotification class]];
   // userNotification *notification = [dataStore findID:soundObjectId];
    [dataStore findID:soundObjectId response:^(id response) {
        userNotification *notification = response;
        notification.status=status;
        [backendless.persistenceService update:notification response:^(id response) {
            
        } error:^(Fault *error) {
            
        }];
    } error:^(Fault * error) {
        
    }];
    
//    PFQuery *query = [PFQuery queryWithClassName:@"userNotification"];
//    
//    // Retrieve the object by id
//    [query getObjectInBackgroundWithId:soundObjectId
//                                 block:^(PFObject *PFNotify, NSError *error) {
//                                     // Now let's update it with some new data. In this case, only cheatMode and score
//                                     // will get sent to the cloud. playerName hasn't changed.
//                                     PFNotify[@"status"] = status;
//                                     [PFNotify saveInBackground];
//                                 }];
    
}
- (void)updateDetectionLogs:(NSString *)status
{
    NSString* detectionLogObjectId = [[EngineMgr sharedInstance] getDetectionLogObjectId];
    if (detectionLogObjectId == nil || [detectionLogObjectId length] == 0)
        return;
    id<IDataStore> dataStore = [backendless.persistenceService of:[detection_history class]];
    // userNotification *notification = [dataStore findID:soundObjectId];
    [dataStore findID:detectionLogObjectId response:^(id response) {
        detection_history *log = response;
        log.log_type=status;
        [backendless.persistenceService update:log response:^(id response) {
            
        } error:^(Fault *error) {
            NSLog(@"Couldn't update detection_history: %@",[error description]);
        }];
    } error:^(Fault * error) {
        
    }];
}
@end
