#pragma once


class FftMgr
{
public:
	FftMgr(int p_buflen, float sampleRate);
	virtual ~FftMgr(void);

    float getBand(int i);
    
    int freqToIndex(float freq);
    
    float indexToFreq(int i);
    
    void forward(float* buffer, int buffer_len);
    

private:
    void fillSpectrum();

private:
    int buf_len;
    int sampleRate;
    float bandWidth;
    double* real;
    double* imag;
    double* spectrum;
    int spectrum_len;
};

