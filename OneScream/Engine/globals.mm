#include "globals.h"
#include "DetectMgr.h"
#include "IAudioDriver.h"
#include "LoopDataMgr.h"

/*
 * detected sound object id used for parse.com
 */
char g_strSoundObjectID[1024] = {0};

/*
 * detected sound object id used for parse.com
 */

/*
 * detected sound object id used for backendless.com
 */
char g_strDetectionLogObjectID[1024] = {0};

/*
 * detected sound object id used for backendless.com
 */
WIFI_ITEM g_WiFiItems[MAX_WIFI_ITEM_CNT];

/*
 * Main instance of detecting engine
 */
CDetectMgr* g_pDetectMgr;

/*
 * to save the audio data for last 4 seconds to save it when scream is detected
 */
CLoopDataMgr* g_pLoopDataMgr;

/*
 * These variables are for getting audio data from microphone of device
 */
AudioParameterInfo* g_audioInfo = nullptr;
RWBuffer	g_RecOutBuffer;
float*	g_fBufData;

/*
 * These variables are used to running engine for detecting
 */
bool IS_BACKGROUND = false;
bool g_isEngineRunning = false;	
bool g_bPaused = false;

/*
 * One Scream Universal Engine's detecting parameters
 */
int SCREAM_ROUGHNESS = 375;
int SCREAM_ROUGHNESS_DELTA = 0;

int MAX_FREQS_CNT_TO_CHECK = 1;
float SCREAM_INSTABILITY_BANDWIDTH = -1; // 8 hz

int UNIVERSAL_DETECT_PERIOD_FRAMES = 50;
int SCREAM_FREQ_MIN = 500;
int SCREAM_FREQ_MAX = 5000;
int SCREAM_SOUND_TIME_MIN = 6;
int SCREAM_SOUND_TIME_MAX = 30;
int SCREAM_BREATH_TIME_MIN = 5;
int SCREAM_BREATH_TIME_MAX = 25;
int COUNTING_SCREAMS = 2;

/*
 * Background Noise detecting values
 */
int CONTINUES_BACKGROUND_NOISE_TIME = 10 * 4;
int BACKGROUND_NOISE_ROUGHNESS = 150;
int FALSE_DETECTION_CORRECTION = 25;

/*
 * String split function
 */
std::vector<std::string> split(std::string str, std::string sep)
{
    char* cstr=const_cast<char*>(str.c_str());
    char* current;
    std::vector<std::string> arr;
    current=strtok(cstr, sep.c_str());
    while(current!=NULL){
        arr.push_back(current);
        current=strtok(NULL,sep.c_str());
    }
    
    return arr;
}


/*
 * Audio Callback function which is called every frame by OS.
 */
int audioCallback(const void* inData, void* outData, unsigned long numSamples) {
    
    //long samples = numSamples;
   
    
    float **in = (float **)inData;
    
    if (g_RecOutBuffer.GetWriteSpace() < (int)(numSamples * sizeof(float)))
    {
        //... can't output recorded audio data
    }
    else
    {
        
        g_RecOutBuffer.WriteData(in[0], (int)numSamples*sizeof(float));
    }
    
    return 0;
}


