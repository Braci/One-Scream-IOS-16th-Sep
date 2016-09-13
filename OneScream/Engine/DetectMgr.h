//
//  Class to analyize and detect screams from the inputted audio data
//

#pragma once

#include "FftMgr.h"
#include <vector>
#import "AppConstants.h"
typedef void (*LPFUNC_RECORDING)(void*, int, int);

class CDetectMgr
{
public:
	CDetectMgr(int p_nSamplingFreq);
	~CDetectMgr(void);
    
    /*
     * Process the input data from microphone to detect
     */
	ScreamDetectedStatus Process(float* p_fData, int p_nFrameLen, int &p_nAlarmType, int &p_nAlarmIdx);
    
    /*
     * Clear fft variables cleanly.
     */
	void ClearFftValues();
    /*
     * Check with escalation time
     */
    bool CheckWithEscalationTime();
    
    // Save Logs
//    void saveLog(NSAttributedString *logString);
    void saveLog(NSString *logString);
private:

    /*
     * Reset universal engine's variables
     */
    void ResetFrameInfo();
    
private:
    // Engine variables for FFT
	FftMgr* fft;

	int minIdx;
	int maxIdx;

	int m_nDetectedFrames;
    
    /** Universal Engine Varaibles */
    int m_screaming_timeframe;
    int m_breathing_timeframe;
    int m_repeating_scream_cnt;
    
    /** Noising environment deciding varaibles */
    int m_nNoiseSeqFrameCnt;
    int m_nNormalSeqFrameCnt;
    bool m_bInNoiseEnvironment;
    
    /** Instability check */
    float *m_maxFreqs;
    bool m_bInstability;
    
    /** Max Volumes per frame */
    float *m_maxVolumesPerFrame;
    int m_nMaxVolPos;
};

