//
// The class to read the data from files and to make the wave files from wave data
//

#include "WaveFileWritter.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "globals.h"


using namespace std;

#define SCALE_SHORT_INV	(0.000030517578125f)

#define MAX_24Bit	(0xFFFFFF / 2 - 1)
#define MIN_24Bit	(-0xFFFFFF / 2)
#define SCALE_24Bit	(0xFFFFFF / 2)

#define MAX_INT32	(2147483647)
#define MIN_INT32	(-2147483648)
#define SCALE_INT32	(2147483648.0)
#define SCALE_INT32_INV	(0.0000000004656612873077392578125)




inline void Bit24ToFloat(const unsigned char* pSrc, float* pDst)
{
    int x = pSrc[0] | pSrc[1] << 8 | pSrc[2] << 16;
    int y = x & 0x800000 ? x - 0x1000000 : x;
    pDst[0] = y / float(SCALE_24Bit);
}

inline void FloatToBit24(float* pSrc, unsigned char* pDst)
{
    int x = int(pSrc[0] * SCALE_24Bit);
    if (x < MIN_24Bit)
    {
        x = MIN_24Bit;
    }
    else if(x > MAX_24Bit)
    {
        x = MAX_24Bit;
    }
    x += SCALE_24Bit;
    
    memcpy(pDst, &x, 3);
}


WaveFileWriter::WaveFileWriter( void )
{
    m_fp = NULL;
    m_strPath[0] = 0;
}

WaveFileWriter::~WaveFileWriter( void )
{
    Finish();
    if(m_fp) fclose(m_fp);
}

bool WaveFileWriter::_Create(FILE* fp, int p_nSamplingFreq, int p_nBits, int p_nChannels)
{
    if (fp == nullptr) return false;
    
    WaveHead wavHead(0, p_nSamplingFreq, p_nBits, p_nChannels);
    fwrite(&wavHead, sizeof(WaveHead), 1, fp);
    
    m_wavHead = wavHead;
    m_nDataSize = 0;
    
    return true;
}

bool WaveFileWriter::Create(const char* p_szFileName, int p_nSamplingFreq, int p_nBits, int p_nChannels)
{
    if(m_fp) fclose(m_fp);
    
    m_ErrorCode = WF_ERR_NOERROR;
    
    m_fp = fopen(p_szFileName, "wb");
    if(m_fp == NULL)
    {
        m_ErrorCode = WF_ERR_FILE_OPEN;
        return false;
    }
    
    strcpy(m_strPath, p_szFileName);
    
    return _Create(m_fp, p_nSamplingFreq, p_nBits, p_nChannels);
}

bool WaveFileWriter::AppendData( void* p_pData, int p_nBytes )
{
    m_ErrorCode = WF_ERR_NOERROR;
    if(!m_fp)
    {
        m_ErrorCode = WF_ERR_FILE_OPEN;
        return false;
    }
    
    size_t nWritten = fwrite(p_pData, 1, p_nBytes, m_fp);
    m_nDataSize += nWritten;
    if(nWritten != p_nBytes)
    {
        m_ErrorCode = WF_ERR_WRITE;
        return false;
    }
    return true;
}

bool WaveFileWriter::Finish()
{
    m_ErrorCode = WF_ERR_NOERROR;
    if(m_fp == NULL)
    {
        m_ErrorCode = WF_ERR_FILE_OPEN;
        return false;
    }
    
    m_wavHead.nRIFF = 36 + m_nDataSize;
    m_wavHead.size = m_nDataSize;
    
    fseek(m_fp, 0, SEEK_SET);
    fwrite(&m_wavHead, sizeof(WaveHead), 1, m_fp);
    fclose(m_fp);
    m_fp = NULL;
    
    return true;
}

