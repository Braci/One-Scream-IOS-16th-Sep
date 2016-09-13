/*
 * IAudioDriver.h
 *
 * Copyright (c) One Scream Ltd. 2015
 *
 * Interface class to obey the standard for access of audio resource (microphone, headphone, speaker)
 *
 */
#pragma once

enum {
    kAudioListnerTypeInterruption = 0
    , kAudioListnerTypeProperty
};

typedef int (*AudioCallback)(const void* inData, void* outData, unsigned long numSamples);
typedef int (*AudioListner)(int type, unsigned long data1, unsigned long data2, const void* data3);

struct AudioParameterInfo {
	int channel;
	int sampleRate;
	int samplesPerFrame;
    int micOn;
    AudioListner listner;
	int numPacket;
};

class IAudioDriver {
public:
	virtual ~IAudioDriver() {}
    
	virtual int  open(const AudioParameterInfo* paramInfo, AudioCallback callback) = 0;
	virtual void close() = 0;
	virtual bool isOpened() = 0;
};
