#pragma once

//
// The class to read the data from files and to make the wave files from wave data
//


#include <vector>
#include "basedef.h"

enum WF_ErrorCode
{
    WF_ERR_NOERROR = 0,
    WF_ERR_FILE_OPEN,
    WF_ERR_FORMAT,
    WF_ERR_DATA_CHUNK,
    WF_ERR_UNSUPPORT_FORMAT,
    WF_ERR_MAPPING,
    WF_ERR_WRITE,
    WF_ERR_UNKNOWN = -1
};

#pragma pack(1)

typedef struct
{
    int FormatTag;
    int SamplingFreq;
    int Bits;
    int Channels;
    int DataOffset;
    int DataBytes;
    int BytesOneSample;
}WAVE_FILE_INFO, *PWAVE_FILE_INFO;


struct WaveHead
{
    WaveHead()
    {
        memset(this, 0, sizeof(WaveHead));
    }
    
    WaveHead(unsigned int p_nBytes,  int p_nSamplingFreq, int p_nBits, int p_nChannels)
    {
        memset(this, 0, sizeof(WaveHead));
        memcpy(RIFF, "RIFF", 4);
        nRIFF = p_nBytes + 36;
        memcpy(WAVE, "WAVE", 4);
        memcpy(fmt, "fmt ", 4);
        nfmt = 16;
        wFormatTag = 1;
        channels = (WORD)p_nChannels;
        nSamplesPerSec = p_nSamplingFreq;
        nAvgBytesPerSec = p_nSamplingFreq * p_nBits / 8 * p_nChannels;
        wBlockAlign = p_nBits / 8 * p_nChannels;
        wBitsPerSample = p_nBits;
        memcpy(data, "data", 4);
        size = p_nBytes;
    }
    
    char	RIFF[4];		//'RIFF'
    int		nRIFF;			//RIFF chunk
    char	WAVE[4];		//'WAVE'
    char	fmt[4];			//'fmt '
    int		nfmt;			//size fmt chunk
    WORD	wFormatTag;		//Wave format tag
    WORD	channels;		//channels
    int		nSamplesPerSec;	//nSamplesPerSec
    int		nAvgBytesPerSec;//nAvgBytesPerSec
    WORD	wBlockAlign;	//wBlockAlign (channel*bitspersample/8)
    WORD	wBitsPerSample;	//wBitsPerSample
    char	data[4];		//'data'chunk
    UINT	size;			//bytes of wave data
};

class WaveFileWriter
{
    
public:
    WaveFileWriter(void);
    ~WaveFileWriter(void);
    
    // Create wave file for indicated format
    bool Create(const char* p_szFileName, int p_nSamplingFreq, int p_nBits, int p_nChannels);
    
    // Append wave data
    bool AppendData(void* p_pData, int p_nBytes);
    
    // Finish the writting wave file
    bool Finish();
    
    bool IsOpened(){return m_fp != NULL;}
    
    const char* GetWaveFileName() {return m_strPath;}
    
    int GetChannels()	{return (int)m_wavHead.channels;}
    int GetSamplingFreq()	{return m_wavHead.nSamplesPerSec;}
    int GetBits()	{return (int)m_wavHead.wBitsPerSample;}
    
private:
    bool _Create(FILE* fp, int p_nSamplingFreq, int p_nBits, int p_nChannels);
    
    FILE		*m_fp;
    unsigned int m_nDataSize;
    WaveHead     m_wavHead;
    WF_ErrorCode m_ErrorCode;
    char		 m_strPath[MAX_PATH];
};