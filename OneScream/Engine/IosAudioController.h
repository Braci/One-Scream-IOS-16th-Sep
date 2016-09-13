//
//  IosAudioController.h
//  EasyPlayer
//
//  Contorller class for access and get the data from audio resource (microphone)
//

#ifndef __IosAudioController__
#define __IosAudioController__

#include "IAudioDriver.h"

void propListenerFromExternal (UInt32 inDataSize, const void *inData);

class IosAudioController : public IAudioDriver {
public:
    static IosAudioController* getInstance();
    
    virtual ~IosAudioController()   {   close();    }
    
    virtual int  open(const AudioParameterInfo* paramInfo, AudioCallback callback);
	virtual void close();
    
    void play();
    void pause();
    
	virtual bool isOpened();
    
private:
    IosAudioController()    {}
};

#endif /* defined(__IosAudioController__) */
