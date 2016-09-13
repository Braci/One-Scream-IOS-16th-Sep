#include "FftMgr.h"
#include <math.h>
#include <string.h>
#include <new>

#import "Fft.h"

/**
 * Constructs an FftMgr that will accept sample buffers that are
 * <code>timeSize</code> long and have been recorded with a sample rate of
 * <code>sampleRate</code>. <code>timeSize</code> <em>must</em> be a
 * power of two. This will throw an exception if it is not.
 *
 * @param timeSize
 *          the length of the sample buffers you will be analyzing
 * @param sampleRate
 *          the sample rate of the audio you will be analyzing
 */
FftMgr::FftMgr(int p_nBufLen, float p_sampleRate)
{
    buf_len = p_nBufLen;
    sampleRate = p_sampleRate;
    bandWidth = (2.f / buf_len) * ((float)sampleRate / 2.f);
    
    real = NULL;
    imag = NULL;
    spectrum = NULL;
    
    spectrum_len = 0;

    spectrum_len = buf_len / 2 + 1;
    spectrum = new double[spectrum_len];
    real = new double[buf_len];
    imag = new double[buf_len];

}

FftMgr::~FftMgr(void)
{
    if (real != NULL)
        delete[] real;
    if (imag != NULL)
        delete[] imag;
    if (spectrum != NULL)
        delete[] spectrum;
}


/**
 * Returns the amplitude of the requested frequency band.
 *
 * @param i
 *          the index of a frequency band
 * @return the amplitude of the requested frequency band
 */
float FftMgr::getBand(int i)
{
    if (i < 0) i = 0;
    if (i > spectrum_len - 1) i = spectrum_len - 1;
    return spectrum[i];
}

/**
 * Returns the index of the frequency band that contains the requested
 * frequency.
 *
 * @param freq
 *          the frequency you want the index for (in Hz)
 * @return the index of the frequency band that contains freq
 */
int FftMgr::freqToIndex(float freq)
{
    // special case: freq is lower than the bandwidth of spectrum[0]
    if (freq < bandWidth / 2) return 0;
    // special case: freq is within the bandwidth of spectrum[spectrum_len - 1]
    if (freq > sampleRate / 2 - bandWidth / 2) return spectrum_len - 1;
    // all other cases
    float fraction = freq / (float) sampleRate;
    int i = (int)(buf_len * fraction + 0.5);
    return i;
}

/**
 * Returns the middle frequency of the i<sup>th</sup> band.
 * @param i
 *        the index of the band you want to middle frequency of
 */
float FftMgr::indexToFreq(int i)
{
    float bw = bandWidth;
    // special case: the width of the first bin is half that of the others.
    //               so the center frequency is a quarter of the way.
    if ( i == 0 ) return bw * 0.25f;
    // special case: the width of the last bin is half that of the others.
    if ( i == spectrum_len - 1 )
    {
        float lastBinBeginFreq = (sampleRate / 2) - (bw / 2);
        float binHalfWidth = bw * 0.25f;
        return lastBinBeginFreq + binHalfWidth;
    }
    // the center frequency of the ith band is simply i*bw
    // because the first band is half the width of all others.
    // treating it as if it wasn't offsets us to the middle
    // of the band.
    return i*bw;
}

// fill the spectrum array with the amps of the data in real and imag
// used so that this class can handle creating the average array
// and also do spectrum shaping if necessary
void FftMgr::fillSpectrum()
{
    for (int i = 0; i < spectrum_len; i++)
    {
        spectrum[i] = (float) sqrt(real[i] * real[i] + imag[i] * imag[i]);
    }
}

void FftMgr::forward(float* buffer, int buffer_len)
{
    if (buffer_len != buf_len)
    {
        //    Minim.error("FFT.forward: The length of the passed sample buffer must be equal to timeSize().");
        return;
    }
    
    for (int i = 0; i < buf_len; i++) {
        real[i] = buffer[i];
        imag[i] = 0;
    }
    
    transform(real, imag, buf_len);
    
    // fill the spectrum buffer with amplitudes
    fillSpectrum();
}

