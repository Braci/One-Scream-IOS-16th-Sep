#pragma once
#include <vector>
#include <string>
#include "RWBuffer.h"

class CDetectMgr;
class CLoopDataMgr;

struct WIFI_ITEM {
    char szTitle[80];
    char szWiFiID[128];
    char szAddress[512];
};

/*
 *Frequency and Frame length of data from Audio Resource (Microphone)
 */
static const int SAMPLE_FREQ = 44100;
static const int FRAME_LEN = 4096;
static const int MAX_WIFI_ITEM_CNT = 5;
/*
 * WiFi informations to help for getting correct address
 */
extern WIFI_ITEM g_WiFiItems[MAX_WIFI_ITEM_CNT];

/*
 * detected sound object id used for parse.com
 */
extern char g_strSoundObjectID[1024];

/*
 * detected log object id used for backendless.com
 */

extern char g_strDetectionLogObjectID[1024];
/*
 * Main instance of detecting engine
 */
extern CDetectMgr* g_pDetectMgr;

/*
 * to save the audio data for last 4 seconds to save it when scream is detected
 */
extern CLoopDataMgr* g_pLoopDataMgr;


/*
 * These variables are for getting audio data from microphone of device
 */
class AudioParameterInfo;
extern AudioParameterInfo* g_audioInfo;

extern RWBuffer	g_RecOutBuffer;
extern float*	g_fBufData;

int audioCallback(const void* inData, void* outData, unsigned long numSamples);

/*
 * These variables are used to running engine for detecting
 */
extern bool IS_BACKGROUND;
extern bool g_isEngineRunning;
extern bool g_bPaused;

/*
 * One Scream Universal Engine's detecting parameters
 */
extern int SCREAM_ROUGHNESS;
extern int SCREAM_ROUGHNESS_DELTA;

extern int MAX_FREQS_CNT_TO_CHECK;
extern float SCREAM_INSTABILITY_BANDWIDTH;

extern int SCREAM_FREQ_MIN;
extern int SCREAM_FREQ_MAX;
extern int SCREAM_SOUND_TIME_MIN;
extern int SCREAM_BREATH_TIME_MAX;
extern int SCREAM_SOUND_TIME_MAX;
extern int SCREAM_BREATH_TIME_MIN;
extern int COUNTING_SCREAMS;

/*
 * Background Noise detecting values
 */
extern int CONTINUES_BACKGROUND_NOISE_TIME;
extern int BACKGROUND_NOISE_ROUGHNESS;
extern int FALSE_DETECTION_CORRECTION;

/*
 * String split function
 */
std::vector<std::string> split(std::string str, std::string sep);
