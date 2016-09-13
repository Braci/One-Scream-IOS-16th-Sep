//
//  HomeController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//  View Controller Class for Home Screen
//

#import "HomeController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "FirstPageController.h"
#import "HowToController.h"
#import "SettingsController.h"
#import "DetectedScreamController.h"
#import "EMGLocationManager.h"
#import "UpgradeController.h"
#import "WiFisController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>
#import "AskToJoinController.h"
//#import <Parse/Parse.h>
#import <BackendlessUser.h>
#import <Backendless.h>
#include "EngineMgr.h"
#import "FrequentAddressViewController.h"
#import "detection_history.h"
#import "userNotification.h"
#import "NSDate+Utilities.h"
#import "detection_logs.h"
#import "DBHandler.h"
#import "DetectionHelper.h"
@interface HomeController () {
    int m_nShineRequestCnt;
    BOOL shouldRestartOnIntrupption;
}

@property AVAudioPlayer *myAudioPlayer;
//@property NSString* soundObjectId;
@property BOOL isFirst;
@property BOOL isOpenedAudio;

@end

@implementation HomeController

#define ALERT_VIEW_ASK_TO_JOIN 10002
#define ALERT_VIEW_ASK_TO_REG_WIFI 10003

/** WIFI Checking period */
#define WIFI_CHECKING_PERIOD 1

@synthesize m_lblTitle;
@synthesize m_imgDetectingStatus;
@synthesize m_imgDetectingStatus1;
@synthesize m_lblDetectingStatus;
@synthesize m_btnDetect;


- (void) gotoFrequentedAddressController {
    

    [self.navigationController setNavigationBarHidden:true animated:false];
        FrequentAddressViewController *nextScr = (FrequentAddressViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FrequentAddressViewController"];
        [self.navigationController pushViewController:nextScr animated:NO];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_nShineRequestCnt = 0;
    shouldRestartOnIntrupption = false;
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    self.slidingViewController.anchorRightPeekAmount  = 100.0;
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btLeftMenuClick:)];
    swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecognizerRight];

    // Do any additional setup after loading the view, typically from a nib.
    m_nPastTimes = 0;
    m_bOpenedAudio = false;
    m_lFirstDateTime = 0;
    
    self.myAudioPlayer = nil;
    
    //self.soundObjectId = nil;
    
    self.isFirst=NO;
    
    m_bNewScreenLoaded = false;
    
    [self loadFirstDateTime];
    m_ignoredWIFIs = [[NSMutableArray alloc] init];
    
    [EngineMgr sharedInstance].isNeedToSubscribe = NO;

    
    
    // Login Checking With Parse User Information
    BackendlessUser *currentUser = backendless.userService.currentUser;
    if (currentUser) {
        NSLog(@"in current user");
        
//        [currentUser fetchInBackground];
        
//        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//        currentInstallation.channels = @[[EngineMgr convertEmailToChannelStr:[currentUser email]]];
//        [currentInstallation saveInBackground];
        BOOL show = [[NSUserDefaults standardUserDefaults]  boolForKey:@"subscribeORTrail"];
        if ([currentUser getProperty:HOME_ADDRESS_PARSE_COLOUMN] == nil || show ==  false){
        
            [self gotoFrequentedAddressController];
        }
//        
//        [self initEngine];
    } else {
        // if this is first launch after the app was downloaded, then open first page
        self.isFirst = YES;
        m_bNewScreenLoaded = true;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
            [self gotoFirstPageController:YES];
        } else {
            [self gotoFirstPageController:NO];
        }
    }
    

}

- (IBAction)btLeftMenuClick:(id)sender {
    
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if([[EngineMgr sharedInstance] isDetecting] == false)
        [AppEventTracker trackScreenWithName:@"Standing By"];
    else
        [AppEventTracker trackScreenWithName:@"Listening"];
    // Handle launching from a notification
    /*  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }*/
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    //[[UIApplication sharedApplication] registerForRemoteNotifications];
    [backendless.messaging registerForRemoteNotifications];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];


}


- (void) onAudioSessionEvent: (NSNotification *) notification
{
    
    if ([[EngineMgr sharedInstance] isDetecting] == false) {
        return;
    }
    
    //Check the type of notification, especially if you are sending multiple AVAudioSession events here
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification received!");
        
        //Check to see if it was a Begin interruption
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            NSLog(@"Interruption began!");
            [self terminateAudioSession];
            
        } else {
            NSLog(@"Interruption ended!");
            //Resume your audio
            [self initAudioSession];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide navigation bar of Home screen
    [self.navigationController setNavigationBarHidden:YES];
    
    [EngineMgr sharedInstance].isDetecting = [[NSUserDefaults standardUserDefaults]boolForKey:@"isScreamListening"];
    
    // Updating UI elements for detecting
    [self updateUIForDetectingStatus];
    
    if(self.isFirst){
        self.isFirst = NO;
    }
    
    if ([EngineMgr sharedInstance].isNeedToSubscribe) {
        [EngineMgr sharedInstance].isNeedToSubscribe = NO;
        [self gotoUpgradeController];
        
        m_bNewScreenLoaded = true;
    } else if ([EngineMgr sharedInstance].isAutoStartProtecting) {
        [EngineMgr sharedInstance].isAutoStartProtecting = NO;
        [self switchDetecting];
        
        m_bNewScreenLoaded = true;
    }
    
   if (!m_bNewScreenLoaded) {
       if ([self checkCurrentWIFIAskable]) {
           [self showAlertForWIFI];
       }
    }

 }


#pragma mark - Event Listener

- (IBAction)onSettings:(id)sender {
    [self gotoSettingsController];
}

- (BOOL) isUserExpired {
    // Check if the user is expired
    BackendlessUser *user = backendless.userService.currentUser;
    NSDate *date_expiry = [user getProperty:@"expiry_date"];
    NSDate *now = [NSDate date];
    if (date_expiry == nil)
        date_expiry = now;

    int seconds = [date_expiry timeIntervalSinceDate:now];
    if (seconds >= 0) {
        return NO;
    }
    return YES;
}

- (IBAction)onBtnDetect:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"display_home_screen_alert"]==nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"display_home_screen_alert"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"One Scream" message:@"You can now return to your home screen, Apple’s red bar at the top of your phone lets you know One Scream is working." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self switchDetecting];
}

- (void)switchDetecting {
    [EngineMgr sharedInstance].isDetecting = ![EngineMgr sharedInstance].isDetecting;
    
    [self updateUIForDetectingStatus];
    if([[EngineMgr sharedInstance] isDetecting] == false)
        [AppEventTracker trackScreenWithName:@"Standing By"];
    else
        [AppEventTracker trackScreenWithName:@"Listening"];
    if ([[EngineMgr sharedInstance] isDetecting])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDetectedProcess) name:@"scream_detected" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startOutsideParamsProcess) name:@"outside_params_detected" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDetectedProcess) name:@"detection_confirmed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadedFromBackground) name:@"from_background" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDetectedProcessWithFalse) name:@"detection_false" object:nil];
        
        [EngineMgr sharedInstance].shouldBackgroundRunning = YES;
        
        [[EMGLocationManager sharedInstance] stopLocationUpdate];
        [[EMGLocationManager sharedInstance] startLocationUpdate];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isScreamListening"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self initEngine];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:backendless.userService.currentUser.email forKey:@"User Email"];
        [AppEventTracker trackEvnetWithName:@"Start Detecting" withData:dic];
        [AppEventTracker trackEvnetWithName:@"Listening" withData:dic];
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scream_detected" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"outside_params_detected" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"detection_confirmed" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"detection_false" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"from_background" object:nil];
        
        [EngineMgr sharedInstance].shouldBackgroundRunning = NO;
        
        [[EMGLocationManager sharedInstance] stopLocationUpdate];
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isScreamListening"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
//        [self showAlert:@"You are not protected. Don't forget to turn one scream back on!" alertTag:0];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        if (backendless.userService.currentUser != nil){
            [dic setObject:backendless.userService.currentUser.email forKey:@"User Email"];
            [AppEventTracker trackEvnetWithName:@"Stop Detecting" withData:dic];
            [AppEventTracker trackEvnetWithName:@"Standing By" withData:dic];
        }

        [self terminateEngine];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_VIEW_ASK_TO_JOIN)
    {
        if(buttonIndex == 0) {
            [self gotoUpgradeController];
        } else {
            [self switchDetecting];
        }
    } else if (alertView.tag == ALERT_VIEW_ASK_TO_REG_WIFI) {
        
        if (buttonIndex == 0) {
            [m_ignoredWIFIs addObject:m_strCurWiFiID];
            
            [self gotoWiFisController];
        } else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *strKey = [NSString stringWithFormat:@"ignore_%@", m_strCurWiFiID];
            
            NSDate *now = [NSDate date];
            NSTimeInterval timeStampNow = [now timeIntervalSince1970];
            [userDefaults setInteger:(long)timeStampNow forKey:strKey];
            [userDefaults synchronize];
        }
    }
}

#pragma mark - self UI functions

- (void) updateUIForDetectingStatus {
    if ([[EngineMgr sharedInstance] isDetecting]) {
        // now protecting
        [m_imgDetectingStatus setHidden:NO];
        [self stopViewShine:m_imgDetectingStatus];
        [m_imgDetectingStatus setImage:[UIImage imageNamed:@"ic_moon_home"]];

        [self makeViewSmall];
        [m_lblTitle setText:@"Not to Worry"];
        [m_lblDetectingStatus setText:@"You are being protected by One Scream"];
        [m_btnDetect setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
    } else {
        // now not protecting
        [m_imgDetectingStatus setHidden:YES];
        [self stopViewShine:m_imgDetectingStatus];
        //[m_imgDetectingStatus setImage:[UIImage imageNamed:@"ic_planet"]];
        [m_imgDetectingStatus1 setImage:[UIImage imageNamed:@"ic_planet"]];
        [m_imgDetectingStatus1 setHidden:NO];
        [m_lblTitle setText:@"Standing By"];
        [m_lblDetectingStatus setText:@"Press play and we will listen"];
        [m_btnDetect setImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
    }
}

- (void) gotoHowToController {
    HowToController *nextScr = (HowToController *) [self.storyboard instantiateViewControllerWithIdentifier:@"HowToController"];
    [self.navigationController pushViewController:nextScr animated:NO];
}

- (void) gotoFirstPageController:(BOOL)bFirstStart {
    FirstPageController *nextScr = (FirstPageController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPageController"];
    nextScr.m_bFirst = bFirstStart;
    [self.navigationController pushViewController:nextScr animated:NO];
}

- (void) gotoSettingsController {
    SettingsController *nextScr = (SettingsController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (void) gotoUpgradeController {
    UpgradeController *nextScr = (UpgradeController *) [self.storyboard instantiateViewControllerWithIdentifier:@"UpgradeController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (void) gotoAskToJoinController {
    AskToJoinController *nextScr = (AskToJoinController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AskToJoinController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (void) gotoDetectedController {
    DetectedScreamController *nextScr = (DetectedScreamController *) [self.storyboard instantiateViewControllerWithIdentifier:@"DetectedScreamController"];
    [self.navigationController pushViewController:nextScr animated:YES];
}

- (void) gotoWiFisController {
    WiFisController *nextScr = (WiFisController *) [self.storyboard instantiateViewControllerWithIdentifier:@"WiFisController"];
    nextScr.m_bSelectAddress = true;
    [self.navigationController pushViewController:nextScr animated:YES];
}


#pragma mark - Audio Processing
- (void) initAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    BOOL  success =[session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    if (!success) {
        
        // Exit early
        return ;
    }

    NSError* error;
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    if (![[EngineMgr sharedInstance] isSessionObserverAdded]) {
    
        [center addObserverForName:AVAudioSessionRouteChangeNotification
                            object:session
                             queue:nil
                        usingBlock:^(NSNotification *notification)
         {
             // NSLog(@"notiname=%@", notification.name);
             UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
             NSLog(@"%d",reasonValue);
             
             //AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
             
             NSDictionary *dict = notification.userInfo;
             AVAudioSessionRouteDescription *routeDesc = dict[AVAudioSessionRouteChangePreviousRouteKey];
             AVAudioSessionPortDescription *prevPort = [routeDesc.outputs objectAtIndex:0];
             if ([prevPort.portType isEqualToString:AVAudioSessionPortHeadphones]) {
                 //Head phone removed
             }
             
             // printf("Route change:\n");
             switch (reasonValue) {
                     
                case AVAudioSessionRouteChangeReasonUnknown:
                     NSLog(@"     UNKnown");

                     break;
                 case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
                     NSLog(@"     NewDeviceAvailable");

                     break;
                 case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
                     NSLog(@"     OldDeviceUnavailable");

                     break;
                 case AVAudioSessionRouteChangeReasonCategoryChange:

                         
                     NSLog(@"     CategoryChange");
                        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
                         //Head phone removed
//                         if ([EngineMgr sharedInstance].isEngineRunning && [AVAudioSession sharedInstance] && shouldRestartOnIntrupption == true){
//                             [[NSNotificationCenter defaultCenter] postNotificationName:@"restartEngine" object:nil];
//                             //shouldRestartOnIntrupption =  false;
//                         }
                     
                     break;
                 case AVAudioSessionRouteChangeReasonOverride:
                     NSLog(@"     Override");
//                     if ([EngineMgr sharedInstance].isEngineRunning && [AVAudioSession sharedInstance] && shouldRestartOnIntrupption == true){
//                         [[NSNotificationCenter defaultCenter] postNotificationName:@"restartEngine" object:nil];
//                         //shouldRestartOnIntrupption =  false;
//                         NSLog(@"override restart");
//                     }
                     break;
                 case AVAudioSessionRouteChangeReasonWakeFromSleep:
                     NSLog(@"     WakeFromSleep");
                     break;
                 case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
                     NSLog(@"     NoSuitableRouteForCategory");
                     break;
                 case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
                     
                     NSLog(@"     route Config change ");
                     if ([EngineMgr sharedInstance].isEngineRunning && [AVAudioSession sharedInstance] && shouldRestartOnIntrupption == true){
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"restartEngine" object:nil];
                         //shouldRestartOnIntrupption =  false;
                     }

                     
                     break;
                 default:
                     NSLog(@"     ReasonUnknown %d", reasonValue);
             }
             
             // NSLog(@"Previous route disc= %@", routeDescription);
             [[EngineMgr sharedInstance] propListener:&reasonValue inDataSize:sizeof(reasonValue)];
         }];
        
        [center addObserverForName:AVAudioSessionInterruptionNotification
                            object:session
                             queue:nil
                        usingBlock:^(NSNotification *notification)
         {
             NSLog(@"interrupt notiname=%@", notification.name);
             UInt8 interuptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
             
             switch (interuptionType) {
                 case AVAudioSessionInterruptionTypeBegan:
                     NSLog(@"Audio Session Interruption case started.");
                     shouldRestartOnIntrupption = true;

                     break;
                 case AVAudioSessionInterruptionTypeEnded:
                 {
                     NSLog(@"Audio Session Interruption case ended.");
                     //                    pController->open(g_audioInfo, audioCallback);
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"restartEngine" object:nil];
                     shouldRestartOnIntrupption =  false;


                 }
                     break;
                 default:
                     NSLog(@"Audio Session Interruption Notification case default %d", interuptionType);
                     break;
             }
         }];
        
        [EngineMgr sharedInstance].isSessionObserverAdded = YES;
    }

    //[[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];

    AVAudioSessionPortDescription *port = [AVAudioSession sharedInstance].availableInputs[0];
    
    // Using Back Microphone of iPhone if it is exist [Sergei added 2015.12.12]
//    for (AVAudioSessionDataSourceDescription *source in port.dataSources) {
//        if ([source.dataSourceName isEqualToString:@"Back"]) {
//            [port setPreferredDataSource:source error:nil];
//        }
//    }
    
    Float64 sampleRate = [[EngineMgr sharedInstance] getSampleRate];
    float bufLen = [[EngineMgr sharedInstance] getBufDuration];
    [session setPreferredSampleRate:sampleRate error:nil];
    [session setPreferredIOBufferDuration:bufLen error:nil];
    Float64 sampleRateCur =[session sampleRate];

    
    float bufLenCur = [session IOBufferDuration];
    
    if (bufLen != bufLenCur || sampleRate != sampleRateCur) {
        fprintf(stderr, "ERROR is mismatch [%f:%f][%f:%f]\n", bufLen, bufLenCur, sampleRate, sampleRateCur);
    }
    
}

- (void) terminateAudioSession {
   
    [[AVAudioSession sharedInstance] setActive:NO error: nil];
}

#pragma mark - Engine functions and notification receivers

/**
 * Init engine functions and register notification receivers
 */

-(void)initEngine {
    if ([[EngineMgr sharedInstance] isEngineRunning])
        return;
    
    self.isOpenedAudio = NO;
    
    // Init Engine
    
    [self initAudioSession];
    [[EngineMgr sharedInstance] initEngine];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self detectingSounds];
    });
    
    self.isFirst=YES;
    
    // Register notification receivers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartEngine) name:@"restartEngine" object:nil];
}

-(void)terminateEngine {
    if (![[EngineMgr sharedInstance] isEngineRunning]) {
        return;
    }
    
    [EngineMgr sharedInstance].isDetecting = NO;
    
    [[EngineMgr sharedInstance] terminateEngine];
    
    [self terminateAudioSession];
}

- (void)restartEngine {
    [[EngineMgr sharedInstance] closeAudio];
    
    [self initAudioSession];
    
    [[EngineMgr sharedInstance] restartEngine];
}

- (void) detectingSounds
{
    static int times = 0;
    
    while(YES)
    {
        if (times % 120000 == 50) {
            // Check every 5 hours
            [self checkCurrentWIFIAndRecord];
        }
        
        times++;
        if (times > 240000) {
            times = 0;
        }

        
        if(![[EngineMgr sharedInstance] isEngineRunning])
            break;
        
        NSLog(@"Reading %d %@", times, [[AVAudioSession sharedInstance] secondaryAudioShouldBeSilencedHint] ? @"other" : @"me");
        
        while ([[EngineMgr sharedInstance] readData])
        {
            if(![[EngineMgr sharedInstance] isEngineRunning])
                break;
            
            ScreamDetectedStatus bDetected = [[EngineMgr sharedInstance] detectScream];
            if (bDetected==SCREAM_DETECTED)
            {
                int nSoundDetectedType = [[EngineMgr sharedInstance] getDetectedSoundType];
                
                if (![[EngineMgr sharedInstance] isBackground]) {
                    [self updateScreamDetected:nSoundDetectedType];
                } else {
                    NSString *szNotifcation = @"Scream Detected\nYou have 12 seconds to cancel\nSwipe left to cancel";
                    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                    localNotification.alertBody = szNotifcation;
                    localNotification.alertTitle = @"OneScream";
                    localNotification.alertAction = @"cancel";
                    localNotification.category = @"ACTIONABLE";
                    localNotification.repeatInterval=0;
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    NSLog(@"Background Mode");
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"scream_detected" object:nil];
                }
                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSString *strFilePath = [self saveHistory];
//                    [self saveHistoryOnParse:strFilePath];
//                    strFilePath = [self prepareAndSaveLogFile];
//                    if(strFilePath)
//                        [self saveLogOnBackendless:strFilePath];
//                });
            }else if (bDetected == SCREAM_HAS_OUTSIDE_PARAMETERS){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"outside_params_detected" object:nil];
            }
        }
        usleep(150000);
    }
}

- (void) updateScreamDetected:(int)soundType
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendPushMessage:NO];
        
        [self gotoDetectedController];
    });
}

-(void)doProcess:(BOOL)isOutsideParam
{
    //Make .wav file save locally, save status in local db: wav_file_saved_locally
    NSString *wavFilePath = [self saveHistory];
    NSInteger screamDetectionID = [DBHandler soundDetectedWavLocalFilePath:wavFilePath isOutsideParam:isOutsideParam];
    if(screamDetectionID>0){
        //make .rtf file save locally, save status in local db: rtf_file_save_locally
        NSString *rtfFilePath = [self prepareAndSaveLogFile];
        if(rtfFilePath){
            BOOL success = [DBHandler soundDetectedRTFLocalFilePath:rtfFilePath screamDetectionID:screamDetectionID];
            if(success){
                DetectionHelper *dh = [[DetectionHelper alloc]initWithWavFileLocalPath:wavFilePath RTFFileLocalPath:rtfFilePath screamLocalDBID:screamDetectionID isOutSideParameter:isOutsideParam];
                [dh doProcess:RTF_FILE_SAVED_LOCALLY Param1:nil Param2:nil];
                
            }
        }
    }

}

//-(void)saveWavFileLocallyOnComplition:(void (^)(BOOL succeeded,NSInteger screamDetectionID,NSString *wavFilePath))completionBlock
//{
//    NSString *strFilePath = [self saveHistory];
//    [DBHandler soundDetectedWavLocalFilePath:strFilePath onComplition:^(BOOL succeeded, NSInteger screamDetectionID) {
//        return completionBlock(succeeded,screamDetectionID,strFilePath);
//    }];
//}
//-(void)saveRTFFileLocallyWithScreamDetectionID:(NSInteger)screamID onCompletion:(void (^)(BOOL succeeded,NSInteger screamDetectionID,NSString *rtfFilePath))completionBlock
//{
//
//    NSString *strFilePath = [self prepareAndSaveLogFile];
//    [DBHandler soundDetectedRTFLocalFilePath:strFilePath screamDetectionID:screamID onComplition:^(BOOL succeeded) {
//        completionBlock(succeeded,screamID,strFilePath);
//    }];
//}
-(BOOL)deleteLocalFile:(NSString *)filePath
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if(!success) NSLog(@"%@ couldn't deleted",filePath);
    return success;
}
-(void)sendPushNotificationOnComplition:(void (^)(BOOL succeeded))completionBlock
{
    NSDateFormatter *formatter,*TimeFormatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MMM/yyyy"];
    TimeFormatter = [[NSDateFormatter alloc] init];
    [TimeFormatter setDateFormat:@"HH:mm"];
    
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    NSString* timeString = [TimeFormatter stringFromDate:[NSDate date]];
    
    userNotification *notification = [userNotification new];
    notification.userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userObjectId"];
    notification.userName = backendless.userService.currentUser.email;
    notification.userType = @"2";
    notification.soundType = @"ONE_SCREAM";
    notification.eventDescription = @"One Scream";
    notification.scream_date = dateString;
    notification.time = timeString;
    notification.os = @"iOS";
    notification.status = @"Not Yet";
    //self.soundObjectId = @"";
    id <IDataStore>dateStore =  [backendless.persistenceService of:[userNotification class]];
    [dateStore save:notification response:^(id response) {
        if (response) {
            //[self.view setUserInteractionEnabled:true];
            
            //self.soundObjectId = ((userNotification *)response).objectId;
            completionBlock(YES);
            // The object has been saved.
        }   else {
            // [self.view setUserInteractionEnabled:true];
            // There was a problem, check error.description
            //self.soundObjectId = @"";
            completionBlock(YES);
        }
        [[EngineMgr sharedInstance] setSoundObjectId:((userNotification *)response).objectId];
    } error:^(Fault *error) {
        completionBlock(NO);
    }];
    
//    NSString *strFilePath = [self saveHistory];
//    [self saveHistoryOnParse:strFilePath];
}
- (void) saveWavFileToBackendlessFilePath:(NSString*)p_strFilePath OnComplition:(void (^)(BOOL succeeded,NSString *wavFileURL))completionBlock {
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:p_strFilePath];
    NSString *fileName = [NSString stringWithFormat:@"screams/%0.0f.wav",[[NSDate date] timeIntervalSince1970] ];
    [backendless.fileService upload:fileName content:data response:^(BackendlessFile *fileReturned) {
        if(fileReturned)
            completionBlock(YES,fileReturned.fileURL);
        else
            completionBlock(NO,nil);
    } error:^(Fault *error) {
        NSLog(@"File couldn't be uploaded: %@",[error detail]);
        completionBlock(NO,nil);
    }];
}
- (void) saveRTFFileToBackendlessFilePath:(NSString*)p_strFilePath OnComplition:(void (^)(BOOL succeeded,NSString *RTFFileURL))completionBlock{
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:p_strFilePath];
    NSString *fileName = [NSString stringWithFormat:@"detection_logs/%0.0f.rtf",[[NSDate date] timeIntervalSince1970] ];
    [backendless.fileService upload:fileName content:data response:^(BackendlessFile *fileReturned) {
        if(fileReturned)
            completionBlock(YES,fileReturned.fileURL);
        else
            completionBlock(NO,nil);
    } error:^(Fault *error) {
        completionBlock(NO,nil);
        NSLog(@"Error: %@",[error description]);
    }];
}
-(void)SaveDetectionHistoryToBackendlessWAVFileURL:(NSString *)fileURL RTFFileURL:(NSString *)rtfURL OnComplition:(void (^)(BOOL succeeded))completionBlock {

    BackendlessUser *user = backendless.userService.currentUser;
    detection_history *history = [detection_history new];
    history.scream_file = fileURL;
    history.log_file = rtfURL;
    history.userObjectId = user.objectId;
    history.userEmail = user.email;
    history.device_type = @"iOS";
    if([user getProperty:@"phone"]!=nil){
        history.phone = [user getProperty:@"phone"];
    }
    if([user getProperty:@"postcode"]!=nil){
        history.postcode = [user getProperty:@"postcode"];
    }
    NSString *strFullName = [NSString stringWithFormat:@"%@ %@", [user getProperty:@"first_name"], [user getProperty:@"last_name"]];
    history.fullname = strFullName;
    
    double dLatitude = 0;
    double dLongitude = 0;
    CLLocation* location = [[EMGLocationManager sharedInstance] m_location_gps];
    if (location != nil) {
        dLatitude = location.coordinate.latitude;
        dLongitude = location.coordinate.longitude;
    }
    NSString *strLocation = [NSString stringWithFormat:@"(%.4f, %.4f)", dLatitude, dLongitude];
    history.location = strLocation;
    id<IDataStore> dataStore = [backendless.persistenceService of:[detection_history class]];
    [dataStore save:history response:^(id response) {
        completionBlock(YES);
        //Update Address at backendless
        NSString *strAddress = nil;
        // Set Address with WiFI
        NSString* strWiFiSSID = [EngineMgr currentWifiSSID];
        if (strWiFiSSID != nil) {
            int idx = [[EngineMgr sharedInstance] getWiFiItemIdx:strWiFiSSID];
            if (idx >= 0) {
                strAddress = [[EngineMgr sharedInstance] getWiFiAddressOfIndex:idx];
            }
        }
        
        // Set Address of GPS when there is no WIFI
        
        if (strAddress != nil) {
            history.address = strAddress;
            [dataStore save:history response:^(id response) {
                
            } error:^(Fault * error) {
                
            }];
        } else {
            if (location != nil) {
                [[EMGLocationManager sharedInstance] requestAddressWithLocation:location callback:^(NSString *szAddress) {
                    if (szAddress != nil && [szAddress length] > 0) {
                        history.address = szAddress;
                        [dataStore save:history response:^(id response) {
                            
                        } error:^(Fault * error) {
                            
                        }];
                    }
                }];
            } else {
            }
        }
    
     
//        NSLog(@".wav file and its history saved, now saving detection log file and its relevant entery");
//        NSString *strFilePath = [self prepareAndSaveLogFile];
//        if(strFilePath)
//            [self saveLogOnBackendless:strFilePath];
    } error:^(Fault * error) {
        completionBlock(NO);
        NSLog(@"detection history couldn't be saved: %@",[error message]);
    }];
}
/**
 * Send Push message using Parse Framework
 */
- (void)sendPushMessage:(BOOL)isOutsideParam {
    [self doProcess:isOutsideParam];
    //PFUser *currentUser = [PFUser currentUser];
//    BackendlessUser *currentUser = backendless.userService.currentUser;
//    [backendless.messagingService
//     publish:@"default"
//     message:_textField.text
//     publishOptions:p
//     deliveryOptions:[DeliveryOptions deliveryOptionsForNotification:PUSH_ONLY]
//     response:^(MessageStatus *res) {
//         [_netActivity stopAnimating];
//         NSLog(@"sendMessage: res = %@", res);
//         [(UILabel *)[self.view viewWithTag:100] setText:[NSString stringWithFormat:@"messageId: %@\n\nstatus:%@\n\nerrorMessage:%@", res.messageId, res.status, res.errorMessage]];
//         _textField.text = @"";
//     }
//     error:^(Fault *fault) {
//         [_netActivity stopAnimating];
//         [self showAlert:fault.message];
//         NSLog(@"sendMessage: fault = %@", fault.detail);
//         _textField.text = @"";
//     }];
//    
//    
//    
//    
//    
//    
//    
//
//    if (false)
//    {
        // Find devices associated with these users
//        NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
//        NSString *channel = [EngineMgr convertEmailToChannelStr:currentUser.email];
//        PFQuery *pushQuery = [PFInstallation query];
//        [pushQuery whereKey:@"channels" equalTo:channel];
//        [pushQuery whereKey:@"deviceToken" notEqualTo:deviceToken];
//        
//        NSString *senderEmail  = [[NSUserDefaults standardUserDefaults]objectForKey:@"email"];
//        
//        UIDevice *device = [UIDevice currentDevice];
//        NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
//        NSString* strNotifyType = @"One Scream";
//        
//        // Send push notification to query
//        PFPush *push = [[PFPush alloc] init];
//        [push setQuery:pushQuery]; // Set our Installation query
//        NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@,%d,0",currentDeviceId,0],[NSString stringWithFormat:@"%@- From %@",strNotifyType,senderEmail], @"android.intent.action.PUSH_STATE", nil]
//                                                                    forKeys:[NSArray arrayWithObjects:@"message", @"alert",@"action", nil]];
//        
//        [push setData:postDictionary];
//        [push sendPushInBackground];
//    }
    
//    NSDateFormatter *formatter,*TimeFormatter;
//    formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"dd/MMM/yyyy"];
//    
//    TimeFormatter = [[NSDateFormatter alloc] init];
//    [TimeFormatter setDateFormat:@"HH:mm"];
//    
//    NSString* dateString = [formatter stringFromDate:[NSDate date]];
//    NSString* timeString = [TimeFormatter stringFromDate:[NSDate date]];
//    
//    userNotification *notification = [userNotification new];
//    notification.userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userObjectId"];
//    notification.userName = backendless.userService.currentUser.email;
//    notification.userType = @"2";
//    notification.soundType = @"ONE_SCREAM";
//    notification.eventDescription = @"One Scream";
//    notification.scream_date = dateString;
//    notification.time = timeString;
//    notification.os = @"iOS";
//    notification.status = @"Not Yet";
//    self.soundObjectId = @"";
//    id <IDataStore>dateStore =  [backendless.persistenceService of:[userNotification class]];
//    [dateStore save:notification response:^(id response) {
//        if (response) {
//            //[self.view setUserInteractionEnabled:true];
//            
//            self.soundObjectId = ((userNotification *)response).objectId;
//            // The object has been saved.
//        }   else {
//            // [self.view setUserInteractionEnabled:true];
//            // There was a problem, check error.description
//            self.soundObjectId = @"";
//        }
//        [[EngineMgr sharedInstance] setSoundObjectId:self.soundObjectId];
//    } error:^(Fault *error) {
//        
//    }];
//
//    NSString *strFilePath = [self saveHistory];
//    [self saveHistoryOnParse:strFilePath];
    
    
//    strFilePath = [self prepareAndSaveLogFile];
//    if(strFilePath)
//        [self saveLogOnBackendless:strFilePath];
}

- (void)setTorch:(BOOL)status {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
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
    while(m_nPastTimes <= (POLICE_SIREN_PERIODS / 100)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([[NSUserDefaults standardUserDefaults]boolForKey:@"flashLightAlert"])
            {
                // flash
                if (m_nPastTimes % 8 == 4)
                    [self setTorch:NO];
                else if (m_nPastTimes % 8 == 0)
                    [self setTorch:YES];
            }

            if (m_nPastTimes % 10 == 0)
            {
                // vibrate
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        });
        
        m_nPastTimes++;
        usleep(100000);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.myAudioPlayer != nil) {
            if ([self.myAudioPlayer isPlaying]) {
                [self.myAudioPlayer stop];
            }
            self.myAudioPlayer = nil;
        }
        
        if (m_bOpenedAudio) {
            [[EngineMgr sharedInstance] playAudio];
            
            m_bOpenedAudio = false;
        }
        
        [self setTorch:NO];

        [[EngineMgr sharedInstance] setEnginePause:NO];
    });
}

- (void)startDetectedProcess
{
    [[EngineMgr sharedInstance] setEnginePause:YES];

    if (self.myAudioPlayer != nil) {
        if ([self.myAudioPlayer isPlaying]) {
            [self.myAudioPlayer stop];
        }
        self.myAudioPlayer = nil;
    }
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"policesiren" ofType:@"mp3"];
    NSURL* fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    self.myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.myAudioPlayer.numberOfLoops = -1;
    [self.myAudioPlayer play];
    

    m_bOpenedAudio = [[EngineMgr sharedInstance] pauseAudio] == YES ? true : false;
    
    m_nPastTimes = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self timerFiredForFlash:nil];
    });
    
    [self sendPushMessage:NO];
}
-(void) startOutsideParamsProcess{
    [self doProcess:YES];
}
- (void)onLoadedFromBackground {
    
    if (m_nShineRequestCnt == 0 && [[EngineMgr sharedInstance] isDetecting]) {
        [self makeViewShine:m_imgDetectingStatus];
    }
    
    [self stopDetectedProcess];
}

- (void)stopDetectedProcess
{
    m_nPastTimes = (POLICE_SIREN_PERIODS / 100) + 1;
    
    [self updateHistory:@"Alarm Activated"];
}

- (void)stopDetectedProcessWithFalse {
    m_nPastTimes = (POLICE_SIREN_PERIODS / 100) + 1;
    
    [[EngineMgr sharedInstance] processFalseDetect];
    
    [self updateHistory:@"False"];
}


- (void)updateHistory:(NSString *)status
{
    NSString *soundObjId = [[EngineMgr sharedInstance]getSoundObjectId];
    if (soundObjId == nil || soundObjId.length == 0)
        return;
    id <IDataStore>dataStore =  [backendless.persistenceService of:[userNotification class]];
    [dataStore findID:soundObjId response:^(userNotification *response) {
        response.status = status;
        [dataStore save:response response:^(id response) {
            if (response) {
                
            }   else {
               
            }
           
        } error:^(Fault *error) {
            
        }];
    } error:^(Fault *error) {
        
    }];
    

}

- (void)showAlert:(NSString *)message alertTag:(NSInteger *)tag
{
    UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    myalert.tag = (NSInteger)tag;
    [myalert show];
}

- (void)showAlertForWIFI
{
 // NSString *message = @"Current connected WIFI has been regularly connected every day. Please register this.";
 // UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"One Scream" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Not now", nil];
 //  myalert.tag = (NSInteger)ALERT_VIEW_ASK_TO_REG_WIFI;
 //  [myalert show];
}


#pragma mark - Checking WIFI

- (void) loadFirstDateTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    m_lFirstDateTime = [userDefaults integerForKey:@"first_date_time"];
    if (m_lFirstDateTime == 0) {
        NSDate* date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        comps.hour = 0;
        comps.minute = 0;
        comps.second = 0;
        NSDate *newDate = [calendar dateFromComponents:comps];
        
        NSTimeInterval secs = [newDate timeIntervalSince1970];
        m_lFirstDateTime = (long) secs;
        [userDefaults setInteger:m_lFirstDateTime forKey:@"first_date_time"];
        [userDefaults synchronize];
    }
}

- (bool) checkCurrentWIFIAskable {
    NSString *strWiFiID = [EngineMgr currentWifiSSID];
    

    if (strWiFiID == nil || [strWiFiID length] == 0) {
        // Nothing connected
        return false;
    }
    
    int idx = [[EngineMgr sharedInstance] getWiFiItemIdx:strWiFiID];
    if (idx >= 0) {
        // already registered
        return false;
    }
    
    // Check if this is ignored WIFI
    for (int i = 0; i < [m_ignoredWIFIs count]; i++) {
        if ([strWiFiID isEqualToString:[m_ignoredWIFIs objectAtIndex:i]]) {
            return false;
        }
    }
    
    NSDate *now = [NSDate date];
    NSTimeInterval timeStampNow = [now timeIntervalSince1970];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strKey = [NSString stringWithFormat:@"ignore_%@", strWiFiID];
    long ignoreTimestamp = [userDefaults integerForKey:strKey];
    if (((long)timeStampNow - ignoreTimestamp) < 3600 * 24 )
        return false;

    if (m_lFirstDateTime == 0) {
        m_lFirstDateTime = [userDefaults integerForKey:@"first_date_time"];
    }

    long daysFromStart = ((long)timeStampNow - m_lFirstDateTime) / (3600 * 24);
    
    int nCount = 0;
    for (int i = (int)daysFromStart; i > daysFromStart - WIFI_CHECKING_PERIOD; i--) {
        if (i < 0)
            break;
        NSString *strKey = [NSString stringWithFormat:@"%d_%@", i, strWiFiID];
        if ([userDefaults boolForKey:strKey]) {
            nCount++;
        }
    }
    
    if (nCount == WIFI_CHECKING_PERIOD) {
        m_strCurWiFiID = strWiFiID;
        return true;
    }
    
    return false;
}

- (void) checkCurrentWIFIAndRecord {
    NSString *strWiFiID = [EngineMgr currentWifiSSID];
    
    
    if (strWiFiID == nil || [strWiFiID length] == 0) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (m_lFirstDateTime == 0) {
        m_lFirstDateTime = [userDefaults integerForKey:@"first_date_time"];
    }
    
    NSDate *now = [NSDate date];
    NSTimeInterval timeStampNow = [now timeIntervalSince1970];
    long daysFromStart = ((long)timeStampNow - m_lFirstDateTime) / (3600 * 24);
    NSString *strKey = [NSString stringWithFormat:@"%d_%@", (int)daysFromStart, strWiFiID];
    
    if (![userDefaults boolForKey:strKey]) {
        [userDefaults setBool:true forKey:strKey];
        [userDefaults synchronize];
    }
    
}


- (NSString*) saveHistory {
    
    NSDateFormatter *formatter,*TimeFormatter;
    NSString        *dateString;
    NSString        *timeString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    TimeFormatter = [[NSDateFormatter alloc] init];
    [TimeFormatter setDateFormat:@"HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    timeString = [TimeFormatter stringFromDate:[NSDate date]];
    
    NSString* strFilePath = [EngineMgr getHistoryWavePath:dateString time:timeString];
    
    [[EngineMgr sharedInstance] saveDetectedScream:strFilePath];
    
    return strFilePath;
}
//-(NSString *)prepareAndSaveLogFile
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateFormat = @"MM-dd-yyyy";
//    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
//    NSString *fileName = [NSString stringWithFormat:@"%@.rtf",dateStr];
//    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];//NSASCIIStringEncoding
//    NSError *error;
//    //NSURL *stringURL = [[NSBundle mainBundle] URLForResource:@"Text" withExtension:@".rtf"];
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithFileURL:[NSURL fileURLWithPath:path] options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} documentAttributes:nil error:&error];
//    NSString *TodayLogs = [attString string];
//    //NSData *unicodedStringData =
//    //[TodayLogs dataUsingEncoding:NSUTF8StringEncoding];
//    //TodayLogs =
//    //[[NSString alloc] initWithData:unicodedStringData encoding:NSNonLossyASCIIStringEncoding];
//    NSString *logString = @"";
//    NSDate *todayDate=[NSDate date];
//    if(TodayLogs){
//        NSArray *components = [TodayLogs componentsSeparatedByString:@"!\n"];
//        NSArray *linesArray;
//        NSDate *dt,*dateTemp;
//        NSString *timeRow;
//        for (NSString *logInstance in components){
//            if(logInstance.length==0)continue;
//            linesArray = [logInstance componentsSeparatedByString:@"\n"];
//            if(linesArray.count>0){
//                timeRow = linesArray[0];
//                timeRow = [[timeRow componentsSeparatedByString:@"Time:"][1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
//                dt = [dateFormatter dateFromString:timeRow];
//                dateTemp = todayDate;
//                for(int i=0;i<7;i++){
//                    dateTemp = [dateTemp dateBySubtractingSeconds:1];
//                    if([[dateFormatter stringFromDate:dt] isEqualToString:timeRow]){
//                        logString= [NSString stringWithFormat:@"%@\n%@",logString,logInstance];
//                    }
//                }
//                
//            }
//        }
//    }
//    
//    if(logString.length>0){
////        return [self saveLog:logString];
//        dateFormatter.dateFormat = @"MM-dd-yyyy";
//        fileName = [NSString stringWithFormat:@"%@.rtf",[dateFormatter stringFromDate:todayDate]];
//        NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:fileName];
//        return documentTXTPath;
//    }
//    else
//        return nil;
//    
//    
//}
-(NSString *)prepareAndSaveLogFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",dateStr];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSString *TodayLogs = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *logString = @"";
    NSMutableAttributedString *attributedLogString = [[NSMutableAttributedString alloc]initWithString:@""];
    if(TodayLogs){
        NSArray *components = [TodayLogs componentsSeparatedByString:@"!\n"];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *dateNow;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *screamDate = [userDefaults objectForKey:@"ScreamDate"];
       // NSLog(@"Actual Scream Date: %@",screamDate);
        if(screamDate)
            dateNow = [dateFormatter dateFromString:screamDate];
        else
            dateNow = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
        NSDate *dateBefore7Seconds = [dateNow dateBySubtractingSeconds:7];
        //NSLog(@"Date Now: %@ Date Before 7 Seconds: %@",[dateFormatter stringFromDate:dateNow],[dateFormatter stringFromDate:dateBefore7Seconds]);
        NSMutableArray *breathingRoughnessArray = [NSMutableArray new];
        for (NSString *logInstance in components){
            if(logInstance.length==0)continue;
            NSArray *linesArray = [logInstance componentsSeparatedByString:@"\n"];
            if(linesArray.count>0){
                NSString *timeRow = linesArray[0];
                BOOL isScreamLog=FALSE;//Check for letting know whether the particular log triggered scream or not
                if([timeRow characterAtIndex:0]=='<'){
                    isScreamLog=YES;
                    timeRow = [timeRow stringByReplacingOccurrencesOfString:@"<" withString:@""];
                }
                timeRow = [[timeRow componentsSeparatedByString:@"Time:"][1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                //NSLog(@"dt: %@",timeRow);
                NSDate *dt = [dateFormatter dateFromString:timeRow];
                
                //Breathing Roughness Line
                
                for(NSString *line in linesArray){
                    if([line containsString:@"Breathing Roughness: "]){
                        NSNumber *breathRoughness = [NSNumber numberWithFloat:[[line componentsSeparatedByString:@"Breathing Roughness: "][1]floatValue]];
                        [breathingRoughnessArray addObject:breathRoughness];
                    }
                }
                //Breathing roughness line ends
                if(([dt isEqualToDate:dateNow]||[dt isEarlierThanDate:dateNow])&&([dt isEqualToDate:dateBefore7Seconds]||[dt isLaterThanDate:dateBefore7Seconds])){
                    logString= [NSString stringWithFormat:@"%@\n\n",logInstance];
                    if(isScreamLog){
                        NSDictionary *attrs = @{ NSBackgroundColorAttributeName :  [UIColor yellowColor]};
                        NSAttributedString *tmpString = [[NSAttributedString alloc]initWithString:logString attributes:attrs];
                        [attributedLogString appendAttributedString:tmpString];
                        
                    }else{
                        NSAttributedString *tmpString = [[NSAttributedString alloc]initWithString:logString attributes:nil];
                        [attributedLogString appendAttributedString:tmpString];
                    }
                    
                    
                }
                
//                for(int i=0;i<7;i++){
//                    tempDate = [tempDate dateBySubtractingSeconds:1];
//                    NSLog(@"Today Date: %@ dt: %@",[dateFormatter stringFromDate:tempDate],[dateFormatter stringFromDate:dt]);
//                    if([[dateFormatter stringFromDate:dt] isEqualToString:timeRow]){
//                        logString= [NSString stringWithFormat:@"%@\n%@",logString,logInstance];
//                        if(isScreamLog){
//                            NSDictionary *attrs = @{ NSBackgroundColorAttributeName :  [UIColor yellowColor]};
//                            NSAttributedString *tmpString = [[NSAttributedString alloc]initWithString:logInstance attributes:attrs];
//                            [attributedLogString appendAttributedString:tmpString];
//                            
//                        }else{
//                            NSAttributedString *tmpString = [[NSAttributedString alloc]initWithString:logInstance attributes:nil];
//                            [attributedLogString appendAttributedString:tmpString];
//                        }
//                    }
//                }
                
            }
        }
        if(breathingRoughnessArray.count>0){
            CGFloat totalRoughness = 0;
            for(NSNumber *breathRough in breathingRoughnessArray){
                totalRoughness = totalRoughness + [breathRough floatValue];
            }
            CGFloat averageBreathingRoughness = totalRoughness/breathingRoughnessArray.count;
            NSDictionary *attrs = @{ NSForegroundColorAttributeName :  [UIColor redColor]};
            NSAttributedString *tmpString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"Average Breathing Roughness = %f\n",averageBreathingRoughness] attributes:attrs];
            [attributedLogString appendAttributedString:tmpString];
        }
    }
    
    if(attributedLogString.length>0){
          return [self saveRTFFileLocally:attributedLogString];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
//        NSDateFormatter *dateFormatter = [NSDateFormatter new];
//        dateFormatter.dateFormat = @"MM-dd-yyyy";
//        NSString *fileName = [NSString stringWithFormat:@"%@.txt",[dateFormatter stringFromDate:[NSDate date]]];
//        NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:fileName];
//        return documentTXTPath;
    }
    else
        return nil;
    
    
}
-(NSString *)saveRTFFileLocally:(NSAttributedString *)logString{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%f.rtf", today];
    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [logString dataFromRange:(NSRange){0, [logString length]} documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:NULL];
    if(![fileManager fileExistsAtPath:documentTXTPath])
    {
        NSError *error;
        BOOL succeed = [data writeToFile:documentTXTPath options:NSDataWritingAtomic error:&error];
        if(!succeed)
            NSLog(@"Couldn't save/update rtf log file: %@\nError: %@",documentTXTPath,[error description]);
    }
    else
    {
        NSError *error;
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:documentTXTPath] error:&error];
        // [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:data];
        if(error){
            NSLog(@"error writing to rtf log file: %@",[error description]);
        }
    }
    return documentTXTPath;
}
//-(NSString *)saveLog:(NSString *)logString{
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateFormat = @"MM-dd-yyyy";
//    NSString *fileName = [NSString stringWithFormat:@"%@.txt",[dateFormatter stringFromDate:[NSDate date]]];
//    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:fileName];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if(![fileManager fileExistsAtPath:documentTXTPath])
//    {
//        NSError *error;
//        [logString writeToFile:documentTXTPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    }
//    else
//    {
//        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
//        [myHandle seekToEndOfFile];
//        [myHandle writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
//    }
//    return documentTXTPath;
//    
//}
- (void) saveHistoryOnParse:(NSString*)p_strFilePath {
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:p_strFilePath];
    NSString *fileName = [NSString stringWithFormat:@"screams/%0.0f.wav",[[NSDate date] timeIntervalSince1970] ];
    [backendless.fileService upload:fileName content:data response:^(BackendlessFile *fileReturned) {
        BackendlessUser *user = backendless.userService.currentUser;
        detection_history *history = [detection_history new];
        history.scream_file = fileReturned.fileURL;
        history.userObjectId = user.objectId;
        history.userEmail = user.email;
        history.device_type = @"iOS";
        if([user getProperty:@"phone"]!=nil){
            history.phone = [user getProperty:@"phone"];
        }
        if([user getProperty:@"postcode"]!=nil){
            history.postcode = [user getProperty:@"postcode"];
        }
        NSString *strFullName = [NSString stringWithFormat:@"%@ %@", [user getProperty:@"first_name"], [user getProperty:@"last_name"]];
        history.fullname = strFullName;
        
        double dLatitude = 0;
        double dLongitude = 0;
        CLLocation* location = [[EMGLocationManager sharedInstance] m_location_gps];
        if (location != nil) {
            dLatitude = location.coordinate.latitude;
            dLongitude = location.coordinate.longitude;
        }
        NSString *strLocation = [NSString stringWithFormat:@"(%.4f, %.4f)", dLatitude, dLongitude];
        history.location = strLocation;
        id<IDataStore> dataStore = [backendless.persistenceService of:[detection_history class]];
        [dataStore save:history response:^(id response) {
            NSString *logID;
            if (response) {
                //[self.view setUserInteractionEnabled:true];
                
                logID = ((detection_history *)response).objectId;
                // The object has been saved.
            }   else {
                // [self.view setUserInteractionEnabled:true];
                // There was a problem, check error.description
                logID = @"";
            }
            [[EngineMgr sharedInstance] setDetectionLogObjectId:logID];
        
            NSLog(@".wav file and its history saved, now saving detection log file and its relevant entery");
            NSString *strFilePath = [self prepareAndSaveLogFile];
            if(strFilePath)
                [self saveLogOnBackendless:strFilePath];
        } error:^(Fault * error) {
            NSLog(@"detection history couldn't be saved: %@",[error message]);
        }];
        
        NSString *strAddress = nil;
        // Set Address with WiFI
        NSString* strWiFiSSID = [EngineMgr currentWifiSSID];
        if (strWiFiSSID != nil) {
            int idx = [[EngineMgr sharedInstance] getWiFiItemIdx:strWiFiSSID];
            if (idx >= 0) {
                strAddress = [[EngineMgr sharedInstance] getWiFiAddressOfIndex:idx];
            }
        }
        
        // Set Address of GPS when there is no WIFI
        
        if (strAddress != nil) {
            history.address = strAddress;
            [dataStore save:history response:^(id response) {
                
            } error:^(Fault * error) {
                
            }];
        } else {
            if (location != nil) {
                [[EMGLocationManager sharedInstance] requestAddressWithLocation:location callback:^(NSString *szAddress) {
                    if (szAddress != nil && [szAddress length] > 0) {
                        history.address = szAddress;
                        [dataStore save:history response:^(id response) {
                            
                        } error:^(Fault * error) {
                            
                        }];
                    }
                }];
            } else {
            }
        }
    } error:^(Fault *error) {
        NSLog(@"File couldn't be uploaded: %@",[error detail]);
    }];
    

}
- (void) saveLogOnBackendless:(NSString*)p_strFilePath {
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:p_strFilePath];
     NSString *fileName = [NSString stringWithFormat:@"detection_logs/%0.0f.rtf",[[NSDate date] timeIntervalSince1970] ];
    [backendless.fileService upload:fileName content:data response:^(BackendlessFile *fileReturned) {
        BackendlessUser *user = backendless.userService.currentUser;
        detection_logs *log = [detection_logs new];
        log.log_file = fileReturned.fileURL;
        log.userObjectId = user.objectId;
        log.userEmail = user.email;
        log.device_type = @"iOS";
        
        NSString *strFullName = [NSString stringWithFormat:@"%@ %@", [user getProperty:@"first_name"], [user getProperty:@"last_name"]];
        log.fullname = strFullName;
        
        id<IDataStore> dataStore = [backendless.persistenceService of:[detection_logs class]];
        [dataStore save:log response:^(id response) {
            NSString *logID;
            if (response) {
                //[self.view setUserInteractionEnabled:true];
                
                logID = ((detection_logs *)response).objectId;
                // The object has been saved.
            }   else {
                // [self.view setUserInteractionEnabled:true];
                // There was a problem, check error.description
                logID = @"";
            }
            [[EngineMgr sharedInstance] setDetectionLogObjectId:logID];
        } error:^(Fault * error) {
            NSLog(@"Could't save log file to server: %@",[error description]);
        }];
        
    } error:^(Fault *error) {
        NSLog(@"Error: %@",[error description]);
    }];
}

#pragma mark - Glowing Effect

-(void)makeViewSmall {
    
    CGRect rect = m_imgDetectingStatus1.frame;
    rect.size.width -= 6;
    rect.size.height -= 6;
    rect.origin.x += 3;
    rect.origin.y += 3;
    m_imgDetectingStatus1.frame = rect;
    
    if (rect.size.width < m_imgDetectingStatus.frame.size.width) {
        if ([[EngineMgr sharedInstance] isDetecting]){
            [m_imgDetectingStatus1 setHidden:YES];
        }
        rect.origin.x -= (260 - rect.size.width) / 2;
        rect.origin.y -= (260 - rect.size.height) / 2;
        rect.size.width = 260;
        rect.size.height = 260;
        m_imgDetectingStatus1.frame = rect;
        [self makeViewShine:m_imgDetectingStatus];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self makeViewSmall];
        });
    }
}

-(void)makeViewShine:(UIView*) view {
    view.layer.shadowColor = [UIColor whiteColor].CGColor;
    view.layer.shadowRadius = 10.0f;
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowOffset = CGSizeZero;
    
    m_nShineRequestCnt++;
    
    [UIView animateWithDuration:0.7f delay:0 options:(UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        [UIView setAnimationRepeatCount:HUGE_VAL];
        
        view.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        
    } completion:^(BOOL finished) {
        m_nShineRequestCnt--;
        
        view.layer.shadowRadius = 0.0f;
        view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);

        if (m_nShineRequestCnt == 0 && [[EngineMgr sharedInstance] isDetecting] && (![[EngineMgr sharedInstance] isBackground])) {
            [self makeViewShine:view];
        }
    }];
}


-(void) stopViewShine:(UIView*) view {
    view.layer.shadowColor = [UIColor yellowColor].CGColor;
    view.layer.shadowRadius = 0.0f;
    view.layer.shadowOpacity = 0.0f;
    view.layer.shadowOffset = CGSizeZero;
    [view.layer removeAllAnimations];
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue
{
}

@end
