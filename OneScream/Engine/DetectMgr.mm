//
//  Class to analyize and detect screams from the inputted audio data
//

#include "DetectMgr.h"
#include "globals.h"
#import <math.h>
#import <stdio.h>
#import <UIKit/UIKit.h>

using namespace std;

// min frequency to represent graphically
const float minFreqToDraw = 400;
// max frequency to represent
const float maxFreqToDraw = 5000;

const int MAX_GROUP_CNT = 2000;

const int MAX_FREQ_CNT = 10;
const float fDeltaThreshold = 0.1f;

const int MAX_VOLUME_CNT = 30;

const bool isTesting = true;
static NSString *logDate;
CDetectMgr::CDetectMgr(int p_nSamplingFreq)
{
    if (MAX_FREQS_CNT_TO_CHECK <= 0) {
        MAX_FREQS_CNT_TO_CHECK = 1;
    }
    
	fft = new FftMgr(FRAME_LEN, (float)p_nSamplingFreq); //m_wavReader.m_Info.SamplingFreq

	minIdx = fft->freqToIndex(minFreqToDraw);
	maxIdx = fft->freqToIndex(maxFreqToDraw);

	m_nDetectedFrames = 0;
    
    m_maxFreqs = new float[MAX_FREQS_CNT_TO_CHECK];
    
    m_maxVolumesPerFrame = new float[MAX_VOLUME_CNT];
    
    ResetFrameInfo();
    
    m_nNoiseSeqFrameCnt = 0;
    m_nNoiseSeqFrameCnt = 0;
    m_bInNoiseEnvironment = false;
    
    
    // test
    if (isTesting) {
        SCREAM_ROUGHNESS = 375;
        MAX_FREQS_CNT_TO_CHECK = 1;
        COUNTING_SCREAMS = 2;
        SCREAM_INSTABILITY_BANDWIDTH = -1;
    }

}

CDetectMgr::~CDetectMgr(void)
{
	ClearFftValues();
	delete fft;
    
    delete m_maxVolumesPerFrame;
    
    delete m_maxFreqs;
}

void CDetectMgr::ResetFrameInfo()
{
    m_screaming_timeframe = 0;
    m_breathing_timeframe = 0;
    m_repeating_scream_cnt = 0;
    
    for (int i = 0; i < MAX_FREQS_CNT_TO_CHECK; i++) {
        m_maxFreqs[i] = 0;
    }
    
    for (int i = 0; i < MAX_VOLUME_CNT; i++) {
        m_maxVolumesPerFrame[i] = 0;
    }
    m_nMaxVolPos = 0;
}

void CDetectMgr::ClearFftValues()
{

	m_nDetectedFrames = 0;
}

ScreamDetectedStatus CDetectMgr::Process(float* p_fData, int p_nFrameLen, int &p_nAlarmType, int &p_nAlarmIdx)
{
    float fMaxVals[MAX_FREQ_CNT] = {0.0f};
    float fMaxFreqs[MAX_FREQ_CNT] = {0.0f};
    
    float val = 0.0f;
    float prevVal = 0.0f;
    float dist = 0.0f;
    float preDist = 0.0f;

    int idx = 0;
    
    if (g_bPaused)
        return SCREAM_NOT_DETECTED;
    
    //Finding out Maximum volume value 'fMaxVolume' among the members of array: p_fData
    float fMaxVolume = p_fData[0];
    for (int i = 1; i < FRAME_LEN; i++) {
        if (fMaxVolume < p_fData[i]) {
            fMaxVolume = p_fData[i];
        }
    }
    
    m_maxVolumesPerFrame[m_nMaxVolPos] = fMaxVolume;
    m_nMaxVolPos = (m_nMaxVolPos + 1) % MAX_VOLUME_CNT;
    
    // convert inputted data form mic to FFT values
    p_fData[0] = 0;
	fft->forward(p_fData, FRAME_LEN);
    
    // format engine variables to process
    for (int i = 0; i < MAX_FREQ_CNT; i++)
    {
        fMaxVals[i] = 0.0f;
        fMaxFreqs[i] = 0.0f;
    }
    
    // get 10 maximum amplitudes and their frequencies
    for (int i = minIdx; i <= maxIdx; i++)
    {
        val = fft->getBand(i);
        
        dist = val - prevVal;
        if (preDist > 0 && dist < 0)
        {
            if (prevVal > fDeltaThreshold)
            {
                idx = 0;
                for (; idx < MAX_FREQ_CNT; idx++)
                {
                    if (fMaxVals[idx]==0 || prevVal > fMaxVals[idx])
                        break;
                }
                
                float fFreq = fft->indexToFreq(i - 1);
                if (idx < MAX_FREQ_CNT)
                {
                    for (int j = MAX_FREQ_CNT - 1; j > idx; j--)
                    {
                        if (fMaxVals[j-1] == 0)
                            continue;
                        fMaxVals[j] = fMaxVals[j-1];
                        fMaxFreqs[j] = fMaxFreqs[j-1];
                    }
                    fMaxVals[idx] = prevVal;
                    fMaxFreqs[idx] = fFreq;
                }
            }
        }
        
        preDist = dist;
        prevVal = val;
    }
    
    val = log10f(fMaxVals[0]);
    
	ScreamDetectedStatus bDetected = SCREAM_NOT_DETECTED;

	if (m_nDetectedFrames > 0) 
	{
		m_nDetectedFrames--;
		return bDetected;
	}

    // Checking Noise Environment
    float evalutation_val = fMaxVals[0];
    if (evalutation_val > BACKGROUND_NOISE_ROUGHNESS) {
        m_nNoiseSeqFrameCnt++;
        m_nNormalSeqFrameCnt = 0;
    } else {
        m_nNormalSeqFrameCnt++;
        m_nNoiseSeqFrameCnt = 0;
    }
    
    if (!m_bInNoiseEnvironment) {
        if (m_nNoiseSeqFrameCnt >= CONTINUES_BACKGROUND_NOISE_TIME) {
            // noise environment is checked
            m_bInNoiseEnvironment = true;
        }
    } else {
        if (m_nNormalSeqFrameCnt >= CONTINUES_BACKGROUND_NOISE_TIME) {
            // current environment becomes ok
            m_bInNoiseEnvironment = false;
        }
    }
    
    if (m_bInNoiseEnvironment) {
        return SCREAM_NOT_DETECTED;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormmater = [NSDateFormatter new];
    dateFormmater.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *dateString = [dateFormmater stringFromDate:[NSDate date]];
    
    
//    NSAttributedString *attributedLogString;
//    if(fMaxFreqs[0]>minFreqToDraw || fMaxFreqs[0]<maxFreqToDraw){
//        NSDictionary *attrs = @{ NSBackgroundColorAttributeName :  [UIColor yellowColor]};
//        attributedLogString = [[NSAttributedString alloc]initWithString:logString attributes:attrs];
//    }else
//    {
//        attributedLogString = [[NSAttributedString alloc]initWithString:logString attributes:nil];
//    }
//    saveLog(attributedLogString);

    //    saveLog(logString);
    if(![dateString isEqualToString:logDate]){
        logDate = dateString;
    }
    
    NSString *logString;
    // Universal Engine to detect one scream
    int nThreshold = SCREAM_ROUGHNESS + SCREAM_ROUGHNESS_DELTA;
    if(bDetected==SCREAM_NOT_DETECTED){
        bool bCandidate = true;
        
        
        for (int i = 0; i < MAX_FREQS_CNT_TO_CHECK; i++) {
            //Check if the scream comes in outside parameters
            if (nThreshold==300) {
                if(fMaxFreqs[i] >= SCREAM_FREQ_MIN && fMaxFreqs[i] <= SCREAM_FREQ_MAX)
                    bCandidate = true;
                else
                    bCandidate = false;
                bDetected=SCREAM_HAS_OUTSIDE_PARAMETERS;
                break;
            }else{
                if (!(fMaxFreqs[i] >= SCREAM_FREQ_MIN && fMaxFreqs[i] <= SCREAM_FREQ_MAX
                      && fMaxVals[i] >= nThreshold)) {
                    bCandidate = false;
                    
                    break;
                }
            }
            
        }
        
        if (bCandidate)
        {
            m_breathing_timeframe = 0;
            float tmpMaxFreq[MAX_FREQS_CNT_TO_CHECK];
            for (int i = 0; i < MAX_FREQS_CNT_TO_CHECK; i++) {
                tmpMaxFreq[i] = fMaxFreqs[i];
            }
            //********* Note about following code ***********
            /* MAX_FREQS_CNT_TO_CHECK is 1, so following loops won't run, otherwise the function of the following
             code is to reverse tmpMaxFreq array members */
            for (int i = 0; i < MAX_FREQS_CNT_TO_CHECK - 1; i++) {
                for (int j = i+1; j < MAX_FREQS_CNT_TO_CHECK; j++) {
                    float fTemp = tmpMaxFreq[i];
                    tmpMaxFreq[i] = tmpMaxFreq[j];
                    tmpMaxFreq[j] = fTemp;
                }
            }
            //***********************************************
            // check instability of Top Frequencies
            if (m_screaming_timeframe > 0) {
                bool bInstable = true;
                for (int i = 0; i < MAX_FREQS_CNT_TO_CHECK; i++) {
                    if (fabs(tmpMaxFreq[i] - m_maxFreqs[i]) < SCREAM_INSTABILITY_BANDWIDTH) { bInstable = false;}
                    m_maxFreqs[i] = tmpMaxFreq[i];}
                if (bInstable) {
                    m_bInstability = true;
                }
            } else {
                m_bInstability = false;
            }
            m_screaming_timeframe++;
            
            //check if scream_timeframe comes in outside params range 4-20, scream roughness (300 for outside params) is already checked above.
            if(m_screaming_timeframe>=4 && m_screaming_timeframe<=20 && bDetected==SCREAM_HAS_OUTSIDE_PARAMETERS && m_repeating_scream_cnt==2){
                m_repeating_scream_cnt = 0;
            }else
            { //means this scream doesn't come in outside params
                
                if (m_screaming_timeframe == SCREAM_SOUND_TIME_MIN)
                {
                    m_repeating_scream_cnt++;
                    if (m_repeating_scream_cnt >= COUNTING_SCREAMS)
                    {
                        if (m_bInstability || SCREAM_INSTABILITY_BANDWIDTH <= 0) {
                            bDetected = SCREAM_DETECTED;
                            p_nAlarmType = -1;
                            p_nAlarmIdx = 0;
                        }
                    }
                }
                else if (m_screaming_timeframe >= SCREAM_SOUND_TIME_MAX) {
                    m_repeating_scream_cnt = 0;
                }
                /*            else if (m_screaming_timeframe == UNIVERSAL_DETECT_PERIOD_FRAMES)
                 {
                 bDetected = true;
                 p_nAlarmType = -1;
                 p_nAlarmIdx = 0;
                 }
                 */
            }
            
        } else {
            m_breathing_timeframe++;
            //check if breathing time frame comes in normal breathing range
            //or Check if breathing time frame comes in outside params range, other outside params like scream roughness is already checked above
            if ((m_breathing_timeframe >= SCREAM_BREATH_TIME_MIN && m_screaming_timeframe > 0)||(m_breathing_timeframe>=4 && m_screaming_timeframe<=20 && bDetected==SCREAM_HAS_OUTSIDE_PARAMETERS && m_repeating_scream_cnt==2))
                {
                    m_screaming_timeframe = 0;
                    
                    if (!m_bInstability || !CheckWithEscalationTime()) {
                        m_repeating_scream_cnt = 0;
                    }
                    
                    m_bInstability = false;
                }
            
            //Check if it has been too long that scream is not heard (i.e. only breathing frequencies are being detected)
            //if so, make repeating scream count 0, because for letting  repeating scream remain greater than 0, breathing time range/frame
            //shouldn't be too long
            
            if (m_breathing_timeframe > SCREAM_BREATH_TIME_MAX && m_repeating_scream_cnt > 0)
            {
                m_repeating_scream_cnt = 0;
            }
        }
            
        if(!bCandidate && m_repeating_scream_cnt==1){
            printf("bDetected=%d       maxFreq=%f         maxVal=%f\n\n                  maxFreq2=%f        maxVal2=%f\n\n                  m_screaming_timeframe=%d  m_repeating_scream_cnt=%d   m_breathing_timeframe=%d  breathing_level_roughness=%f \n\n\n",
                   bDetected ? 1 : 0, fMaxFreqs[0], fMaxVals[0], fMaxFreqs[1], fMaxVals[2], m_screaming_timeframe, m_repeating_scream_cnt, m_breathing_timeframe,fMaxVals[1]);
            logString = [NSString stringWithFormat:@"Time: %@\nMax Freq 1: %f\nMax Freq 2:%f\nMax Val 1:%f\nMax Val 2:%f\nScream Time Frame: %d\nBreathing Time: %d\nRepeating Screams: %d\nBreathing Roughness: %f\n!\n",dateString,fMaxFreqs[0],fMaxFreqs[1],fMaxVals[0],fMaxVals[2],m_screaming_timeframe,m_breathing_timeframe,m_repeating_scream_cnt,fMaxVals[1]];
        }
        else{
            printf("bDetected=%d       maxFreq=%f         maxVal=%f\n\n                  maxFreq2=%f        maxVal2=%f\n\n                  m_screaming_timeframe=%d  m_repeating_scream_cnt=%d   m_breathing_timeframe=%d\n\n\n",
                   bDetected ? 1 : 0, fMaxFreqs[0], fMaxVals[0], fMaxFreqs[1], fMaxVals[2], m_screaming_timeframe, m_repeating_scream_cnt, m_breathing_timeframe);
            logString = [NSString stringWithFormat:@"Time: %@\nMax Freq 1: %f\nMax Freq 2:%f\nMax Val 1:%f\nMax Val 2:%f\nScream Time Frame: %d\nBreathing Time: %d\nRepeating Screams: %d\n!\n",dateString,fMaxFreqs[0],fMaxFreqs[1],fMaxVals[0],fMaxVals[2],m_screaming_timeframe,m_breathing_timeframe,m_repeating_scream_cnt];
        }
        
        
        
    }
    
    
    
	if (bDetected==SCREAM_DETECTED)
	{
        // when scream is detected
        [userDefaults setObject:dateString forKey:@"ScreamDate"];
        [userDefaults synchronize];
        ResetFrameInfo();
		m_nDetectedFrames = 15;
        logString = [NSString stringWithFormat:@"<%@",logString];
	}
    
    saveLog(logString);
	return bDetected;
}
//void CDetectMgr::saveLog(NSAttributedString *logString){
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateFormat = @"MM-dd-yyyy";
//    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
//    NSString *fileName = [NSString stringWithFormat:@"%@.rtf",dateStr];
//    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:fileName];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSData *data = [logString dataFromRange:(NSRange){0, [logString length]} documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:NULL];
//    if(![fileManager fileExistsAtPath:documentTXTPath])
//    {
//        NSError *error;
//        BOOL succeed = [data writeToFile:documentTXTPath options:NSDataWritingAtomic error:&error];
//        if(!succeed)
//            NSLog(@"Couldn't save/update log file: %@\nError: %@",documentTXTPath,[error description]);
//    }
//    else
//    {
//        NSError *error;
//        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:documentTXTPath] error:&error];
//        // [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
//        [myHandle seekToEndOfFile];
//        [myHandle writeData:data];
//        if(error){
//            NSLog(@"error writing to file: %@",[error description]);
//        }
//    }
//
//   
//}
void CDetectMgr::saveLog(NSString *logString){
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",dateStr];
    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:documentTXTPath])
    {
        NSError *error;
        BOOL succeed = [logString writeToFile:documentTXTPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if(!succeed)
            NSLog(@"Couldn't save/update log file: %@\nError: %@",documentTXTPath,[error description]);
    }
    else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    }
}


bool CDetectMgr::CheckWithEscalationTime() {
    if (isTesting)
        return true;
    
    int thresholdIndex = 0;
    float minPosArray[MAX_VOLUME_CNT] = {0};
    int minPosArrayCnt = 0;
    float maxPosArray[MAX_VOLUME_CNT] = {0};
    int maxPosArrayCnt = 0;
    
    int nStartPos = m_nMaxVolPos;
    bool bPrevIsInc = m_maxVolumesPerFrame[(nStartPos + 1) % MAX_VOLUME_CNT] > m_maxVolumesPerFrame[nStartPos];
    
    for (int i = 1; i < MAX_VOLUME_CNT; i++) {
        bool bInc = m_maxVolumesPerFrame[(nStartPos + i + 1) % MAX_VOLUME_CNT] > m_maxVolumesPerFrame[(nStartPos + i) % MAX_VOLUME_CNT];
        if (bPrevIsInc && !bInc) {
            maxPosArray[maxPosArrayCnt++] = i;
        } else if (!bPrevIsInc && bInc) {
            minPosArray[minPosArrayCnt++] = i;
        }
        bPrevIsInc = bInc;
    }
    
    int nMinPos = 0;
    int nMaxPos = 0;
    
    int nScreamStartPos = ((m_nMaxVolPos - 1 - m_screaming_timeframe) + MAX_VOLUME_CNT) % MAX_VOLUME_CNT;
    
    for (int i = 0; i < minPosArrayCnt; i++) {
        nMinPos = minPosArray[i];
        if (nMinPos >= nScreamStartPos) {
            break;
        }
    }
    
    for (int i = 0; i < maxPosArrayCnt; i++) {
        nMaxPos = maxPosArray[i];
        if (nMaxPos >= nScreamStartPos && nMaxPos > nMinPos) {
            break;
        }
    }
    
    if ((nMaxPos - nMinPos) >= 2 && (nMaxPos - nMinPos) <= 5) {
        return true;
    }
    
    return false;
}
