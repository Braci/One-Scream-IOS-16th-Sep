//
//  AppConstants.h
//  OneScream
//
//  Created by Laptop World on 05/07/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConstants : NSObject

//Backendless Constants
extern NSString * BK_APP_ID;
extern NSString * BK_SECRET_KEY;
extern NSString * BK_VERSION_NUM;

typedef enum{
   WAV_FILE_SAVED_LOCALLY = 1,
   RTF_FILE_SAVED_LOCALLY = 2,
   PUSH_NOTIFICATION_SENT = 3,
   WAV_FILE_UPLOADED      = 4,
   RTF_FILE_UPLOADED      = 5,
   SCREAM_LOG_HISTORY_ENTRY_BACKENDLESS_LOCAL_DELETED = 6,//It means, detection_history table on backendless is updated and local wav and rtf files are deleted
   SCREAM_PROCESS_DONE    = 6,
    
}detectionHistoryStatus;
typedef enum{
    SCREAM_DETECTED = 1,
    SCREAM_NOT_DETECTED = 2,
    SCREAM_HAS_OUTSIDE_PARAMETERS = 3,
}ScreamDetectedStatus;
@end

