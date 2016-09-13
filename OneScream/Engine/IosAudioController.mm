//
//  IosAudioController.cpp
//  EasyPlayer
//
//
//  Contorller class for access and get the data from audio resource (microphone)
//

#include <stdio.h>
#include <stdarg.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>
#include "basedef.h"
#include "IosAudioController.h"
#include "globals.h"
#include "EngineMgr.h"



#ifdef IOS
void checkStatus(OSStatus status)
{
    if (status != 0) {
        fprintf(stderr, "ERROR %d [%s:%u]\n", (int)status, __func__, __LINE__);
    }
}

#define kOutputBus 0
#define kInputBus 1

#define kBytesPerSample 4
#define kNumberChannelsIn 1
#define kNumberChannelsOut 2
#define kMaxBufferLen 8192

typedef struct {
    AudioComponentInstance audioUnit;
    AudioBuffer bufIn;
    int frameLen;
	int packetNum;
    int samplingRate;
    int micOn;
    bool isOpen;
    AudioCallback callback;
    AudioListner listner;
} MyContext;

MyContext myCtx = {0};

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData)
{
    MyContext *ctx = (MyContext*)inRefCon;
    
    if (ctx != nullptr) {
        ctx->bufIn.mDataByteSize = inNumberFrames * kBytesPerSample;
        
        AudioBufferList bufferList;
        bufferList.mNumberBuffers = 1;
        bufferList.mBuffers[0] = ctx->bufIn;
        
        OSStatus status = AudioUnitRender(ctx->audioUnit,
                                          ioActionFlags,
                                          inTimeStamp,
                                          inBusNumber,
                                          inNumberFrames,
                                          &bufferList);
        checkStatus(status);
        
        float *in[2];
        in[0] = (float*)ctx->bufIn.mData;
        in[1] = in[0];
        
        for (int j = 0; j < ctx->packetNum; j++) {
            int shift = ctx->frameLen * j;
            float *inbuf[2];
            inbuf[0] = in[0] + shift;
            inbuf[1] = in[1] + shift;
            
            ctx->callback((void*)inbuf, nullptr, ctx->frameLen);
        }
    }
	
	return noErr;
}

static OSStatus playbackCallback(void *inRefCon,
								 AudioUnitRenderActionFlags *ioActionFlags,
								 const AudioTimeStamp *inTimeStamp,
								 UInt32 inBusNumber,
								 UInt32 inNumberFrames,
								 AudioBufferList *ioData)
{
    MyContext *ctx = (MyContext*)inRefCon;
    
    if (ctx != nullptr
        && ctx->callback != nullptr
        && ioData->mNumberBuffers == 2) {
        bool isOk = true;
        float *in[2];
        float *out[2];
        
        for (int i = 0; i < 2; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];
        
            int numSamples = buffer.mDataByteSize / kBytesPerSample;
        
            if (ctx->micOn != 0) {
                int numSamplesIn = ctx->bufIn.mDataByteSize / kBytesPerSample;
                if (numSamplesIn != numSamples) {
                    isOk = false;
                    static bool isDone = false;
                    if (!isDone) {
                        isDone = true;
                        fprintf(stderr, "ERROR in & out buffer size missing. [%d:%d][%s:%u]\n", numSamplesIn, numSamples, __func__, __LINE__);
                    }
                    memset(buffer.mData, 0, buffer.mDataByteSize);
                }
            }
            
            if (numSamples != ctx->frameLen * ctx->packetNum) {
                isOk = false;
                static bool isDone = false;
                if (!isDone) {
                    isDone = true;
                    fprintf(stderr, "ERROR sample size missing. [%d != %d * %d][%s:%u]\n", numSamples, ctx->frameLen, ctx->packetNum, __func__, __LINE__);
                }
                memset(buffer.mData, 0, buffer.mDataByteSize);
            }
            
            out[i] = (float*)buffer.mData;
        }
        
        if (!isOk) {
            goto L_EXIT;
        }
        
        in[0] = (float*)ctx->bufIn.mData;
        in[1] = in[0];

        for (int j = 0; j < ctx->packetNum; j++) {
            int shift = ctx->frameLen * j;
            float *inbuf[2];
            inbuf[0] = in[0] + shift;
            inbuf[1] = in[1] + shift;
            float *outbuf[2];
            outbuf[0] = out[0] + shift;
            outbuf[1] = out[1] + shift;

            ctx->callback((void*)inbuf, (void*)outbuf, ctx->frameLen);
        }
    }
 
L_EXIT:
    return noErr;
}

void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
	MyContext *ctx = (MyContext*)inClientData;
    
    if (ctx == nullptr) {
        return;
    }
	
	if (inInterruption == kAudioSessionEndInterruption) {
		AudioOutputUnitStart(ctx->audioUnit);
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
		AudioOutputUnitStop(ctx->audioUnit);
    }
    
    if (ctx->listner != nullptr) {
        ctx->listner(kAudioListnerTypeInterruption, inInterruption, 0, nullptr);
    }
}


void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
    MyContext *ctx = (MyContext*)inClientData;
    
    if (ctx == nullptr) {
        return;
    }
    
    if (ctx->listner != nullptr) {
        ctx->listner(kAudioListnerTypeProperty, inID, inDataSize, inData);
    }
}

void propListenerFromExternal (UInt32 inDataSize,
                               const void *inData) {
    propListener(&myCtx, kAudioSessionProperty_AudioRouteChange, inDataSize, inData);
}

void SetAudioFormat(AudioStreamBasicDescription& audioFormat, Float64 sampleRate, UInt32 numChannels)
{
    audioFormat.mSampleRate			= sampleRate;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	audioFormat.mBitsPerChannel		= kBytesPerSample * 8;
	audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= numChannels;
    audioFormat.mBytesPerFrame		= kBytesPerSample;
    audioFormat.mBytesPerPacket		= audioFormat.mBytesPerFrame;
}
#pragma mark AVAdudioSessionDelegate methods

void beginInterruption()
{
    rioInterruptionListener(&myCtx, kAudioSessionBeginInterruption);
}

void endInterruption()
{
     rioInterruptionListener(&myCtx, kAudioSessionEndInterruption);
}

void init()
{
    myCtx.bufIn.mNumberChannels = kNumberChannelsIn;
	myCtx.bufIn.mData = malloc( kMaxBufferLen * kBytesPerSample );
    
    OSStatus status;
    
    // Set buffer length
    Float64 sampleRate = (Float64)myCtx.samplingRate;
    
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent comp = AudioComponentFindNext(nullptr, &desc);
    
	// Get audio units
	status = AudioComponentInstanceNew(comp, &myCtx.audioUnit);
	checkStatus(status);
	
	// Enable IO for recording
	UInt32 flag = 1;
    if (myCtx.micOn != 0) {
        status = AudioUnitSetProperty(myCtx.audioUnit,
                                      kAudioOutputUnitProperty_EnableIO,
                                      kAudioUnitScope_Input,
                                      kInputBus,
                                      &flag,
                                      sizeof(flag));
        checkStatus(status);
    }

    
	// Enable IO for playback
    flag = 0;
	status = AudioUnitSetProperty(myCtx.audioUnit,
								  kAudioOutputUnitProperty_EnableIO,
								  kAudioUnitScope_Output,
								  kOutputBus,
								  &flag,
								  sizeof(flag));
	checkStatus(status);
	
	// Apply format
    AudioStreamBasicDescription inFormat;
    SetAudioFormat(inFormat, sampleRate, kNumberChannelsIn);
    status = AudioUnitSetProperty(myCtx.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &inFormat,
                                  sizeof(inFormat));
    checkStatus(status);
    
    AudioStreamBasicDescription outFormat;
    SetAudioFormat(outFormat, sampleRate, kNumberChannelsOut);
	status = AudioUnitSetProperty(myCtx.audioUnit,
								  kAudioUnitProperty_StreamFormat,
								  kAudioUnitScope_Input,
								  kOutputBus,
								  &outFormat,
								  sizeof(outFormat));
	checkStatus(status);
	
	
	// Set input callback
    AURenderCallbackStruct callbackStruct;
    if (myCtx.micOn != 0) {
        callbackStruct.inputProc = recordingCallback;
        callbackStruct.inputProcRefCon = &myCtx;
        status = AudioUnitSetProperty(myCtx.audioUnit,
                                      kAudioOutputUnitProperty_SetInputCallback,
                                      kAudioUnitScope_Input,
                                      kInputBus,
                                      &callbackStruct,
                                      sizeof(callbackStruct));
        checkStatus(status);
    }
	
    flag = 0;
    status = AudioUnitSetProperty(myCtx.audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));

//    AudioUnitAddRenderNotify(myCtx.audioUnit, recordingCallback, &myCtx);
    
	// Initialise
	status = AudioUnitInitialize(myCtx.audioUnit);
	checkStatus(status);
}

void terminate()
{
    
    AudioUnitUninitialize(myCtx.audioUnit);
      [[AVAudioSession sharedInstance] setActive: false error: nil];
   // AudioSessionSetActive(false);
    
    if (myCtx.bufIn.mData != nullptr) {
        free(myCtx.bufIn.mData);
        myCtx.bufIn.mData = nullptr;
    }
}

IosAudioController* IosAudioController::getInstance()
{
    static IosAudioController instance;
    return &instance;
}

int  IosAudioController::open(const AudioParameterInfo* paramInfo, AudioCallback callback)
{
    if (myCtx.isOpen) {
        return -2;
    }
    
    int r = -1;
    
    if (paramInfo != nullptr && callback != nullptr) {
        if (paramInfo->samplesPerFrame <= 0 || paramInfo->sampleRate <= 0) {
            return -1;
        }
        myCtx.frameLen = paramInfo->samplesPerFrame;
		myCtx.packetNum = paramInfo->numPacket;
        myCtx.samplingRate = paramInfo->sampleRate;
        myCtx.micOn = paramInfo->micOn;
        myCtx.listner = paramInfo->listner;
        myCtx.callback = callback;
        
        init();
        OSStatus status = AudioOutputUnitStart(myCtx.audioUnit);
        checkStatus(status);
        
        myCtx.isOpen = true;
        
        r = 0;
    }
    
    return r;
}

void IosAudioController::close()
{
    if (myCtx.isOpen) {
        OSStatus status = AudioOutputUnitStop(myCtx.audioUnit);
        checkStatus(status);
        terminate();
        myCtx.isOpen = false;
    }
}

void IosAudioController::play()
{
    OSStatus status = AudioOutputUnitStart(myCtx.audioUnit);
    checkStatus(status);
    myCtx.isOpen = true;
}

void IosAudioController::pause()
{
    OSStatus status = AudioOutputUnitStop(myCtx.audioUnit);
    checkStatus(status);
    myCtx.isOpen = false;
}



bool IosAudioController::isOpened()
{
    return myCtx.isOpen;
}
#elif MAC
IosAudioController* IosAudioController::getInstance()
{
    static IosAudioController instance;
    return &instance;
}

int  IosAudioController::open(const AudioParameterInfo* paramInfo, AudioCallback callback)
{
    return  0;
}
void IosAudioController::close()
{
    
}
bool IosAudioController::isOpened()
{
    return false;
}
#endif
