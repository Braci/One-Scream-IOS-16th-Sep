/*
 * The class for saving recent data of specialized size from continuoulsy inputted audio-data
 */


#include "LoopDataMgr.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "globals.h"
#include "WaveFileWritter.h"

using namespace std;

const int LOOP_BUF_FRAME_SIZE = 44100 * 5;

#define MAX_SHORT	(32767)
#define MIN_SHORT	(-32768)
#define SCALE_SHORT	(32768)

inline short float2short(float fValue)
{
    float fVal = fValue * SCALE_SHORT;
    
    short sVal;
    
    if (fVal > MAX_SHORT)
    {
        sVal = MAX_SHORT;
    }
    else if (fVal < MIN_SHORT)
    {
        sVal = MIN_SHORT;
    }
    else
    {
        sVal = (short)fVal;
    }
    
    return sVal;
}

CLoopDataMgr::CLoopDataMgr(int p_nSampleFreq)
{
    m_nSampleFreq = p_nSampleFreq;
    
    m_buf = new float[LOOP_BUF_FRAME_SIZE];
    m_nCursor = 0;
    m_nBufSize = 0;
}

CLoopDataMgr::~CLoopDataMgr(void)
{
    if (m_buf != nullptr) {
        delete m_buf;
        m_buf = nullptr;
    }
}

void CLoopDataMgr::Reset()
{
    if (m_buf != nullptr) {
        memset(m_buf, 0x00, sizeof(float) * LOOP_BUF_FRAME_SIZE);
    }
    
    m_nCursor = 0;
    m_nBufSize = 0;
}

void CLoopDataMgr::PutData(float* p_buf, int p_nLen)
{
    if (m_nCursor + p_nLen > LOOP_BUF_FRAME_SIZE) {
        int nFirstSize = LOOP_BUF_FRAME_SIZE - m_nCursor;
        memcpy(&m_buf[m_nCursor], p_buf, nFirstSize * sizeof(float));
        int nSecondSize = p_nLen - nFirstSize;
        memcpy(&m_buf[0], &p_buf[nFirstSize], nSecondSize * sizeof(float));
        m_nCursor = nSecondSize;
    } else {
        memcpy(&m_buf[m_nCursor], p_buf, p_nLen * sizeof(float));
        m_nCursor = (m_nCursor + p_nLen) % LOOP_BUF_FRAME_SIZE;
    }
    
    m_nBufSize = m_nBufSize + p_nLen;
    if (m_nBufSize > LOOP_BUF_FRAME_SIZE)
        m_nBufSize = LOOP_BUF_FRAME_SIZE;
}

void CLoopDataMgr::SaveToWaveFile(const char* p_strUTF8Path)
{
    if (m_nBufSize == 0 || m_buf == nullptr)
        return;
    
    WaveFileWriter waveFileWritter;
    waveFileWritter.Create(p_strUTF8Path, m_nSampleFreq, 16, 1);
    
    short *buf = new short[m_nBufSize];
    int nStartPos = m_nCursor - m_nBufSize;
    if (nStartPos < 0)
        nStartPos += LOOP_BUF_FRAME_SIZE;
    
    for (int i = 0; i < m_nBufSize; i++) {
        buf[i] = float2short(m_buf[(nStartPos + i) % LOOP_BUF_FRAME_SIZE]);
    }
    waveFileWritter.AppendData(buf, m_nBufSize * sizeof(short));
    waveFileWritter.Finish();
    
    delete buf;
    
    Reset();
    
}