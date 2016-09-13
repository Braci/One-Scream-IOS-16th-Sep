//
//  EngineMgr.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/17/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//  The interface class for communicating between UI viewers and Engine codes
//

#ifndef OneScream_EngineMgr_h
#define OneScream_EngineMgr_h

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#define USER_TYPE_FREE @"Trial"
#define USER_TYPE_PREMIUM_MONTH @"Paid_Month"
#define USER_TYPE_PREMIUM_YEAR @"Paid_Year"
#define USE_DEFAULT_PASSWORD 1
#define POLICE_SIREN_PERIODS 12000 //12000 ms

@interface EngineMgr : NSObject {
    
    // Detecting
    int m_nTryingCnt;
    
    // Detected Sound Info (current only -1 for only one scream)
    int m_nDetectedSoundType;
    int m_nDetectedSoundIdx;
}

/*
 * Variables
 */
@property BOOL shouldBackgroundRunning;
@property BOOL isDetecting;
@property BOOL isNeedToSubscribe;
@property BOOL isAutoStartProtecting;
@property BOOL isSessionObserverAdded;

/*
 * Initial self methods
 */
+ (instancetype) sharedInstance;
- (void) initializeManager;

/*
 * Methods for variable
 */
- (void) setIsBackground:(BOOL) isBackground;
- (BOOL) isBackground;

- (void) setIsEngineRunning:(BOOL) isEngineRunning;
- (BOOL) isEngineRunning;

- (void) setSoundObjectId:(NSString*) soundObjectId;
- (NSString*) getSoundObjectId;

- (void) setDetectionLogObjectId:(NSString*) logObjectId;
-(NSString *)getDetectionLogObjectId;

- (void) setEnginePause:(BOOL) isPause;
- (BOOL) isEnginePaused;


/*
 * Engine Functions
 */
- (float) getSampleRate;
- (float) getBufDuration;

- (void) propListener:(const void*) inData inDataSize:(UInt32) inDataSize;

- (BOOL) initEngine;
- (BOOL) restartEngine;
- (BOOL) openAudio;
- (BOOL) closeAudio;
- (BOOL) playAudio;
- (BOOL) pauseAudio;
- (BOOL) terminateEngine;
- (BOOL) readData;
- (ScreamDetectedStatus) detectScream;
- (int) getDetectedSoundType;
- (int) getDetectedSoundIdx;

- (void) processFalseDetect;

/*
 * WIFI functions
 */
- (int)getMaxWIFICount;
- (void)loadWiFiItemsFromStorage;
- (void)saveWiFiItemToStorage:(int)p_idx;
- (int)getWiFiItemIdx:(NSString*)p_ssid;

- (NSString*) getWiFiTitleOfIndex:(int)p_idx;
- (NSString*) getWiFiAddressOfIndex:(int)p_idx;
- (NSString*) getWiFiIDOfIndex:(int)p_idx;

- (BOOL) setWifiItem:(int) p_idx title:(NSString*) p_strTitle address:(NSString*) p_strAddress id:(NSString*) p_strWiFiId;

- (BOOL) saveDetectedScream:(NSString*) p_strFilePath;

/*
 * General methods
 */
+ (NSString*) convertEmailToChannelStr:(NSString*)strEmail;
+ (NSString *)currentWifiSSID;
+ (BOOL)validateEmailWithString:(NSString*)strEmail;
+ (NSString*)getHistoryWavePath:(NSString*) dateString time:(NSString*) timeString;


@end

#endif
