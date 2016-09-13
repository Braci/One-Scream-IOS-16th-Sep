//
//  EngineMgr.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/17/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//  The interface class for communicating between UI viewers and Engine codes
//

#import "EngineMgr.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#import "globals.h"
#import "DetectMgr.h"
#import "LoopDataMgr.h"
#import "IosAudioController.h"

#define EMGTIMER_MAX_VALUE                  99999

@implementation EngineMgr

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]) {
        
    }
    
    m_nDetectedSoundType = 0;
    m_nDetectedSoundType = 0;
    
    [self initializeManager];
    
    self.shouldBackgroundRunning = NO;
    self.isDetecting = NO;
    self.isNeedToSubscribe = NO;
    self.isAutoStartProtecting = NO;
    
    self.isSessionObserverAdded = NO;
    
    return self;
}

- (void) initializeManager{

    // load UNIVERSAL_THRSHOLD_DELTA from storage
    SCREAM_ROUGHNESS_DELTA = [[[NSUserDefaults standardUserDefaults] valueForKey:@"univ_threshold_delta"] intValue];

    // load WIFI informations from storage
    [self loadWiFiItemsFromStorage];

}

#pragma mark - Variable methods

- (void) setIsBackground:(BOOL) isBackground {
    IS_BACKGROUND = isBackground == YES ? true : false;
}

- (BOOL) isBackground {
    return IS_BACKGROUND ? YES : NO;
}

- (void) setIsEngineRunning:(BOOL) isEngineRunning {
    g_isEngineRunning = isEngineRunning == YES ? true : false;
}

- (BOOL) isEngineRunning {
    return g_isEngineRunning ? YES : NO;
}

- (void) setSoundObjectId:(NSString*) soundObjectId {
    if (soundObjectId == nil)
        soundObjectId = @"";
    
    strcpy(g_strSoundObjectID, [soundObjectId UTF8String]);
}
- (NSString*) getSoundObjectId {
    return [NSString stringWithUTF8String:g_strSoundObjectID];
}

- (void) setDetectionLogObjectId:(NSString*) logObjectId {
    if (logObjectId == nil)
        logObjectId = @"";
    
    strcpy(g_strDetectionLogObjectID, [logObjectId UTF8String]);
}
- (NSString*) getDetectionLogObjectId {
    return [NSString stringWithUTF8String:g_strDetectionLogObjectID];
}

- (void) setEnginePause:(BOOL) isPause {
    g_bPaused = isPause == YES ? true : false;
}

- (BOOL) isEnginePaused {
    return g_bPaused ? YES : NO;
}

#pragma mark - Engine methods

- (float) getSampleRate {
    return SAMPLE_FREQ;
}

- (float) getBufDuration {
    return  512 / (float)SAMPLE_FREQ * 1;
}

- (void) propListener:(const void*) inData inDataSize:(UInt32) inDataSize {
    propListenerFromExternal(inDataSize, inData);
}

- (BOOL) initEngine {
    int nRecordChannels = 1;
    
    g_pDetectMgr = new CDetectMgr(SAMPLE_FREQ);
    g_pLoopDataMgr = new CLoopDataMgr(SAMPLE_FREQ);
    
    g_RecOutBuffer.Init(1 * SAMPLE_FREQ * nRecordChannels * sizeof(float));
    
    g_fBufData = new float[FRAME_LEN];
    
    IosAudioController* pController = IosAudioController::getInstance();
    g_audioInfo = new AudioParameterInfo();
    g_audioInfo->channel = 1;
    g_audioInfo->micOn = true;
    g_audioInfo->sampleRate = SAMPLE_FREQ;
    g_audioInfo->numPacket = 1;
    g_audioInfo->samplesPerFrame = 512;
    g_audioInfo->listner = nullptr;
    
    pController->open(g_audioInfo, audioCallback);
    
    self.isEngineRunning = YES;
    
    return TRUE;
}

- (BOOL) restartEngine {
    int nRecordChannels = 1;
    g_RecOutBuffer.Init(1 * SAMPLE_FREQ * nRecordChannels * sizeof(float));
    
    IosAudioController* pController = IosAudioController::getInstance();
    pController->open(g_audioInfo, audioCallback);
    
    // trying 4 times more because the app is down sometimes.
    m_nTryingCnt = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkAndStartEngine];
    });
    
    return TRUE;
}

- (void)checkAndStartEngine {
    m_nTryingCnt++;
    if (m_nTryingCnt > 4)
        return;
    
    IosAudioController* pController = IosAudioController::getInstance();
    if (!pController->isOpened()) {
        int nRecordChannels = 1;
        g_RecOutBuffer.Init(1 * SAMPLE_FREQ * nRecordChannels * sizeof(float));
        
        pController->open(g_audioInfo, audioCallback);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkAndStartEngine];
    });
}

- (BOOL) openAudio {
    IosAudioController* pController = IosAudioController::getInstance();
    if (pController->isOpened())
        return FALSE;
    
    pController->open(g_audioInfo, audioCallback);
    return TRUE;
}

- (BOOL) closeAudio {
    IosAudioController* pController = IosAudioController::getInstance();
    if (pController != nullptr && pController->isOpened())
    {
        pController->close();
        return TRUE;
    }
    return FALSE;
}

- (BOOL) playAudio {
    IosAudioController* pController = IosAudioController::getInstance();
    if (pController->isOpened())
        return FALSE;
    
    pController->play();
    return TRUE;
}

- (BOOL) pauseAudio {
    IosAudioController* pController = IosAudioController::getInstance();
    if (!pController->isOpened())
        return FALSE;
    
    pController->pause();
    return TRUE;
}


- (BOOL) terminateEngine {
    IosAudioController* pController = IosAudioController::getInstance();
    if (pController != nullptr && pController->isOpened())
    {
        pController->close();
        pController = nullptr;
    }
    
    if (g_pDetectMgr != nullptr)
    {
        delete g_pDetectMgr;
        g_pDetectMgr = nullptr;
    }
    
    if (g_fBufData != nullptr)
    {
        delete[] g_fBufData;
        g_fBufData = nullptr;
    }
    
    if (g_audioInfo != nullptr)
    {
        delete g_audioInfo;
        g_audioInfo = nullptr;
    }
    
    self.isEngineRunning = NO;
    
    return TRUE;
}

- (BOOL) readData {
    bool bRet = g_RecOutBuffer.ReadData(g_fBufData, FRAME_LEN * sizeof(float));
    return bRet ? YES : NO;
}

- (ScreamDetectedStatus) detectScream {
    ScreamDetectedStatus bDetect = SCREAM_NOT_DETECTED;
    
    if (g_pDetectMgr != nil)
    {
        if (self.isDetecting)
        {
            // Recording last 4 seconds
            if (g_pLoopDataMgr != nullptr) {
                g_pLoopDataMgr->PutData(g_fBufData, FRAME_LEN);
            }
            
            int nSoundType = 0;
            int nSoundIdx = 0;
            
            bDetect = g_pDetectMgr->Process(g_fBufData, FRAME_LEN, nSoundType, nSoundIdx);
            if (bDetect==SCREAM_DETECTED) {
                m_nDetectedSoundType = nSoundType;
                m_nDetectedSoundIdx = nSoundIdx;
            }
        } else {
            if (g_pLoopDataMgr != nullptr && g_pLoopDataMgr->GetCurBufSize() > 0) {
                g_pLoopDataMgr->Reset();
            }
        }
    }
    
    return bDetect;
}

- (int) getDetectedSoundType {
    return m_nDetectedSoundType;
}

- (int) getDetectedSoundIdx {
    return m_nDetectedSoundIdx;
}

- (void) processFalseDetect {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    SCREAM_ROUGHNESS_DELTA += FALSE_DETECTION_CORRECTION;
    [userDefaults setValue:[NSNumber numberWithInt:SCREAM_ROUGHNESS_DELTA] forKey:@"univ_threshold_delta"];
    [userDefaults synchronize];
}


#pragma mark - WIFI functions

- (int)getMaxWIFICount {
    return MAX_WIFI_ITEM_CNT;
}

- (void)loadWiFiItemsFromStorage {
    NSString* strKey;
    NSString* strValue;
    for (int i = 0; i < MAX_WIFI_ITEM_CNT; i++) {
        // Title
        strKey = [NSString stringWithFormat:@"WIFI_TITLE_%d", i];
        strValue = [[NSUserDefaults standardUserDefaults] stringForKey:strKey];
        if(strValue != nil) {
            strcpy(g_WiFiItems[i].szTitle, [strValue UTF8String]);
        } else {
            strcpy(g_WiFiItems[i].szTitle, "");
        }
        
        // WIFI ID
        strKey = [NSString stringWithFormat:@"WIFI_ID_%d", i];
        strValue = [[NSUserDefaults standardUserDefaults] stringForKey:strKey];
        if(strValue != nil) {
            strcpy(g_WiFiItems[i].szWiFiID, [strValue UTF8String]);
        } else {
            strcpy(g_WiFiItems[i].szWiFiID, "");
        }
        
        // Address
        strKey = [NSString stringWithFormat:@"WIFI_ADDRESS_%d", i];
        strValue = [[NSUserDefaults standardUserDefaults] stringForKey:strKey];
        if(strValue != nil) {
            strcpy(g_WiFiItems[i].szAddress, [strValue UTF8String]);
        } else {
            strcpy(g_WiFiItems[i].szAddress, "");
        }
    }
}

- (void)saveWiFiItemToStorage:(int)p_idx {
    NSString* strKey;
    NSString* strValue;
    
    // Title
    strKey = [NSString stringWithFormat:@"WIFI_TITLE_%d", p_idx];
    strValue = [NSString stringWithUTF8String:g_WiFiItems[p_idx].szTitle];
    [[NSUserDefaults standardUserDefaults] setObject:strValue forKey:strKey];
    
    // WIFI ID
    strKey = [NSString stringWithFormat:@"WIFI_ID_%d", p_idx];
    strValue = [NSString stringWithUTF8String:g_WiFiItems[p_idx].szWiFiID];
    [[NSUserDefaults standardUserDefaults] setObject:strValue forKey:strKey];
    
    // Address
    strKey = [NSString stringWithFormat:@"WIFI_ADDRESS_%d", p_idx];
    strValue = [NSString stringWithUTF8String:g_WiFiItems[p_idx].szAddress];
    [[NSUserDefaults standardUserDefaults] setObject:strValue forKey:strKey];
}


- (int)getWiFiItemIdx:(NSString*)p_ssid {
    if (p_ssid == nil || [p_ssid length] == 0)
        return -1;
    
    const char* ssid = [p_ssid UTF8String];
    int idx = -1;
    
    for (int i = 0; i < MAX_WIFI_ITEM_CNT; i++) {
        if (strlen(g_WiFiItems[i].szWiFiID) == 0)
            break;
        
        if (strcmp(g_WiFiItems[i].szWiFiID, ssid) == 0) {
            idx = i;
            break;
        }
    }
    return idx;
}

- (NSString*) getWiFiTitleOfIndex:(int)p_idx {
    if (p_idx < 0 || p_idx >= MAX_WIFI_ITEM_CNT)
        return nil;
    
    return [NSString stringWithUTF8String:g_WiFiItems[p_idx].szTitle];
}

- (NSString*) getWiFiAddressOfIndex:(int)p_idx {
    if (p_idx < 0 || p_idx >= MAX_WIFI_ITEM_CNT)
        return nil;
    
    return [NSString stringWithUTF8String:g_WiFiItems[p_idx].szAddress];
}

- (NSString*) getWiFiIDOfIndex:(int)p_idx {
    if (p_idx < 0 || p_idx >= MAX_WIFI_ITEM_CNT)
        return nil;
    
    return [NSString stringWithUTF8String:g_WiFiItems[p_idx].szWiFiID];
}

- (BOOL) setWifiItem:(int) p_idx title:(NSString*) p_strTitle address:(NSString*) p_strAddress id:(NSString*) p_strWiFiId {
    if (p_idx < 0 || p_idx >= MAX_WIFI_ITEM_CNT)
        return FALSE;
    
    strcpy(g_WiFiItems[p_idx].szTitle, [p_strTitle UTF8String]);
    strcpy(g_WiFiItems[p_idx].szAddress, [p_strAddress UTF8String]);
    strcpy(g_WiFiItems[p_idx].szWiFiID, [p_strWiFiId UTF8String]);
    
    return TRUE;
}

- (BOOL) saveDetectedScream:(NSString*) p_strFilePath {
    
    if (g_pLoopDataMgr == nullptr)
        return NO;
    
    g_pLoopDataMgr->SaveToWaveFile([p_strFilePath UTF8String]);
    return YES;
}

#pragma mark - General Functions

+ (NSString*) convertEmailToChannelStr:(NSString*)strEmail {
    if (strEmail == nil)
        return nil;
    NSString *str = [strEmail stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@"@" withString:@"-"];
    return str;
}


+ (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"BSSID"]) {
            ssid = info[@"BSSID"];
        }
    }
    return ssid;
}

+ (BOOL)validateEmailWithString:(NSString*)strEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

+ (NSString*)getHistoryWavePath:(NSString*) dateString time:(NSString*) timeString
{
    NSArray* w_pArrDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* w_pStrSoundDetectDir = [(NSString*)[w_pArrDirs objectAtIndex:0] stringByAppendingPathComponent:@"OneScream_history"];
    
    NSError* error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:w_pStrSoundDetectDir])
        [[NSFileManager defaultManager] createDirectoryAtPath:w_pStrSoundDetectDir withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    NSString* strHistoryFileName = [NSString stringWithFormat:@"%@_%@.wav", dateString, [timeString stringByReplacingOccurrencesOfString:@":" withString:@"_"]];
    
    NSString* strFilePath = [NSString stringWithFormat:@"%@/%@", w_pStrSoundDetectDir, strHistoryFileName];
    
    return strFilePath;
}

@end
