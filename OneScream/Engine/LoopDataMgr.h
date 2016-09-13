#pragma once

/*
 * The class for saving recent data of specialized size from continuoulsy inputted audio-data
 */

#include <vector>

class CLoopDataMgr
{
public:
	CLoopDataMgr(int p_nSampleFreq);
	~CLoopDataMgr(void);

    void Reset();
    void PutData(float* p_buf, int p_nLen);
    void SaveToWaveFile(const char* p_strUTF8Path);
    
    int GetCurBufSize() { return m_nBufSize; }
    
public:
    float *m_buf;
    
    int m_nCursor;
    int m_nBufSize;
    
    int m_nSampleFreq;
};

