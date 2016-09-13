//
//  DetectionHelper.m
//  OneScream
//
//  Created by Laptop World on 01/09/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "DetectionHelper.h"
#import "EngineMgr.h"
#import "DBHandler.h"
#import "NSDate+Utilities.h"
#import <UIKit/UIKit.h>
#import "userNotification.h"
#import <Backendless.h>
#import "detection_history.h"
#import "EMGLocationManager.h"

@implementation DetectionHelper
{
    NSString *wavFileLocalPath;
    NSString *rtfFileLocalPath;
    NSInteger screamDetectionID;
    BOOL isOutSideParameter;
}
-(DetectionHelper *)initWithWavFileLocalPath:(NSString *)wavFilePath RTFFileLocalPath:(NSString *)rtfFilePath screamLocalDBID:(NSInteger)screamLocalDBID isOutSideParameter:(BOOL)outsideParameter
{
    if(!self)
    {
        self = [DetectionHelper new];
        
    }
    wavFileLocalPath = wavFilePath;
    rtfFileLocalPath = rtfFilePath;
    screamDetectionID = screamLocalDBID;
    isOutSideParameter = outsideParameter;
    return self;
}
-(void)doProcess:(detectionHistoryStatus)detectionStatus Param1:(NSObject *)param1 Param2:(NSObject *)param2
{
    switch (detectionStatus) {
        case RTF_FILE_SAVED_LOCALLY:
        {
            if(isOutSideParameter){
                //Don't send any notification entry into backendless
                //Save status in local db: user_notification_sent
                BOOL done = [DBHandler soundDetectedPushNotificationSentScreamDetectionID:screamDetectionID];
                if(done){
                    [self doProcess:PUSH_NOTIFICATION_SENT Param1:nil Param2:nil];
                }
            }else
            {
                //Make user_notification entry at Backendless
                [self sendPushNotificationOnComplition:^(BOOL succeeded) {
                    if(succeeded){
                        //Save status in local db: user_notification_sent
                        BOOL done = [DBHandler soundDetectedPushNotificationSentScreamDetectionID:screamDetectionID];
                        if(done){
                            [self doProcess:PUSH_NOTIFICATION_SENT Param1:nil Param2:nil];
                        }
                    }
                }];
            }
        }
            break;
        case PUSH_NOTIFICATION_SENT:
        {
            //Upload wav file to backendless
            [self saveWavFileToBackendlessFilePath:wavFileLocalPath OnComplition:^(BOOL succeeded, NSString *wavFileURL) {
                if(succeeded){
                    //Save status in local db: wav_file_uploaded and update wav_file_online_path value to 'wavFileURL
                    BOOL done = [DBHandler soundDetectedWavBackendlessFilePath:wavFileURL screamDetectionID:screamDetectionID];
                    if(done){
                        [self doProcess:WAV_FILE_UPLOADED Param1:wavFileURL Param2:nil];
                    }
                }
            }];
        }
            break;
        case WAV_FILE_UPLOADED:
        {
            //Upload rtf file to backendless
            [self saveRTFFileToBackendlessFilePath:rtfFileLocalPath OnComplition:^(BOOL succeeded, NSString *RTFFileOnlineURL) {
                if(succeeded){
                    //Save status in local db: rtf_file_uploaded and update rtf_file_online_path value to 'RTFFileURL'
                    BOOL done = [DBHandler soundDetectedRTFBackendlessFilePath:RTFFileOnlineURL screamDetectionID:screamDetectionID];
                    if(done){
                        [self doProcess:RTF_FILE_UPLOADED Param1:param1 Param2:RTFFileOnlineURL];
                    }
                }
            }];
        }
            break;
        case RTF_FILE_UPLOADED:{
            //Make scream history entry
            [self SaveDetectionHistoryToBackendlessWAVFileURL:param1 RTFFileURL:param2 OnComplition:^(BOOL succeeded) {
                if(succeeded){
                    //Update local db status: Scream_log_history_entry_backendless_local_deleted
                    BOOL done = [DBHandler soundDetectedAllthingsDoneScreamDetectionID:screamDetectionID];
                    if(done){
                        //delete local files now
                        [self deleteLocalFile:wavFileLocalPath];
                        [self deleteLocalFile:rtfFileLocalPath];
                        [self doProcess:SCREAM_LOG_HISTORY_ENTRY_BACKENDLESS_LOCAL_DELETED Param1:nil Param2:nil];
                    }
                }
            }];
        }
            break;
//        case SCREAM_LOG_HISTORY_ENTRY_BACKENDLESS_LOCAL_DELETED:{
//            
//        }
//            break;
            
        default:
            break;
    }
}
//-(void)doProcess
//{
//    //Make .wav file save locally, save status in local db: wav_file_saved_locally
//    NSString *wavFilePath = [self saveHistory];
//    NSInteger screamDetectionID = [DBHandler soundDetectedWavLocalFilePath:wavFilePath];
//    if(screamDetectionID>0){
//        //make .rtf file save locally, save status in local db: rtf_file_save_locally
//        NSString *rtfFilePath = [self prepareAndSaveLogFile];
//        BOOL success = [DBHandler soundDetectedRTFLocalFilePath:rtfFilePath screamDetectionID:screamDetectionID];
//        if(success){
//            //Make user_notification entry at Backendless
//            [self sendPushNotificationOnComplition:^(BOOL succeeded) {
//                if(succeeded){
//                    //Save status in local db: user_notification_sent
//                    BOOL done = [DBHandler soundDetectedPushNotificationSentScreamDetectionID:screamDetectionID];
//                    if(done){
//                        //Upload wav file to backendless
//                        [self saveWavFileToBackendlessFilePath:wavFilePath OnComplition:^(BOOL succeeded, NSString *wavFileURL) {
//                            if(succeeded){
//                                //Save status in local db: wav_file_uploaded and update wav_file_online_path value to 'wavFileURL
//                                BOOL done = [DBHandler soundDetectedWavBackendlessFilePath:wavFileURL screamDetectionID:screamDetectionID];
//                                if(done){
//                                    //Upload rtf file to backendless
//                                    [self saveRTFFileToBackendlessFilePath:rtfFilePath OnComplition:^(BOOL succeeded, NSString *RTFFileOnlineURL) {
//                                        if(succeeded){
//                                            //Save status in local db: rtf_file_uploaded and update rtf_file_online_path value to 'RTFFileURL'
//                                            BOOL done = [DBHandler soundDetectedRTFBackendlessFilePath:RTFFileOnlineURL screamDetectionID:screamDetectionID];
//                                            if(done){
//                                                //Make scream history entry
//                                                [self SaveDetectionHistoryToBackendlessWAVFileURL:wavFileURL RTFFileURL:RTFFileOnlineURL OnComplition:^(BOOL succeeded) {
//                                                    if(succeeded){
//                                                        //Update local db status: Scream_log_history_entry_backendless_local_deleted
//                                                        BOOL done = [DBHandler soundDetectedAllthingsDoneScreamDetectionID:screamDetectionID];
//                                                        if(done){
//                                                            //delete local files now
//                                                            [self deleteLocalFile:wavFilePath];
//                                                            [self deleteLocalFile:rtfFilePath];
//                                                        }
//                                                    }
//                                                }];
//                                                
//                                            }
//                                        }
//                                    }];
//                                }
//                            }
//                        }];
//                    }
//                }
//            }];
//        }
//    }
//}
- (NSString*) saveHistory {
    
    NSDateFormatter *formatter,*TimeFormatter;
    NSString        *dateString;
    NSString        *timeString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    TimeFormatter = [[NSDateFormatter alloc] init];
    [TimeFormatter setDateFormat:@"HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    timeString = [TimeFormatter stringFromDate:[NSDate date]];
    
    NSString* strFilePath = [EngineMgr getHistoryWavePath:dateString time:timeString];
    
    [[EngineMgr sharedInstance] saveDetectedScream:strFilePath];
    
    return strFilePath;
}
-(NSString *)prepareAndSaveLogFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",dateStr];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSString *TodayLogs = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *logString = @"";
    NSMutableAttributedString *attributedLogString = [[NSMutableAttributedString alloc]initWithString:@""];
    if(TodayLogs){
        NSArray *components = [TodayLogs componentsSeparatedByString:@"!\n"];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *dateNow;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *screamDate = [userDefaults objectForKey:@"ScreamDate"];
        NSLog(@"Actual Scream Date: %@",screamDate);
        if(screamDate)
           dateNow = [dateFormatter dateFromString:screamDate];
        else
           dateNow = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
        NSDate *dateBefore7Seconds = [dateNow dateBySubtractingSeconds:7];
        NSLog(@"Date Now: %@ Date Before 7 Seconds: %@",[dateFormatter stringFromDate:dateNow],[dateFormatter stringFromDate:dateBefore7Seconds]);
        for (NSString *logInstance in components){
            if(logInstance.length==0)continue;
            NSArray *linesArray = [logInstance componentsSeparatedByString:@"\n"];
            if(linesArray.count>0){
                NSString *timeRow = linesArray[0];
                BOOL isScreamLog=FALSE;//Check for letting know whether the particular log triggered scream or not
                if([timeRow characterAtIndex:0]=='<'){
                    isScreamLog=YES;
                    timeRow = [timeRow stringByReplacingOccurrencesOfString:@"<" withString:@""];
                }
                timeRow = [[timeRow componentsSeparatedByString:@"Time:"][1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSLog(@"dt: %@",timeRow);
                NSDate *dt = [dateFormatter dateFromString:timeRow];
                
                if(([dt isEqualToDate:dateNow]||[dt isEarlierThanDate:dateNow])&&([dt isEqualToDate:dateBefore7Seconds]||[dt isLaterThanDate:dateBefore7Seconds])){
                    logString= [NSString stringWithFormat:@"%@\n\n%@",logString,logInstance];
                    if(isScreamLog){
                        NSDictionary *attrs = @{ NSBackgroundColorAttributeName :  [UIColor yellowColor]};
                        NSAttributedString *tmpString = [[NSAttributedString alloc]initWithString:logInstance attributes:attrs];
                        [attributedLogString appendAttributedString:tmpString];
                        
                    }else{
                        NSAttributedString *tmpString = [[NSAttributedString alloc]initWithString:logInstance attributes:nil];
                        [attributedLogString appendAttributedString:tmpString];
                    }
                }
                
            }
        }
    }
    
    if(attributedLogString.length>0){
        return [self saveRTFFileLocally:attributedLogString];
    }
    else
        return nil;
    
    
}
-(NSString *)saveRTFFileLocally:(NSAttributedString *)logString{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];// Get documents directory
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%f.rtf", today];
    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [logString dataFromRange:(NSRange){0, [logString length]} documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:NULL];
    if(![fileManager fileExistsAtPath:documentTXTPath])
    {
        NSError *error;
        BOOL succeed = [data writeToFile:documentTXTPath options:NSDataWritingAtomic error:&error];
        if(!succeed)
            NSLog(@"Couldn't save/update rtf log file: %@\nError: %@",documentTXTPath,[error description]);
    }
    else
    {
        NSError *error;
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:documentTXTPath] error:&error];
        // [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:data];
        if(error){
            NSLog(@"error writing to rtf log file: %@",[error description]);
        }
    }
    return documentTXTPath;
}
-(void)sendPushNotificationOnComplition:(void (^)(BOOL succeeded))completionBlock
{
    NSDateFormatter *formatter,*TimeFormatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MMM/yyyy"];
    TimeFormatter = [[NSDateFormatter alloc] init];
    [TimeFormatter setDateFormat:@"HH:mm"];
    
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    NSString* timeString = [TimeFormatter stringFromDate:[NSDate date]];
    
    userNotification *notification = [userNotification new];
    notification.userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userObjectId"];
    notification.userName = backendless.userService.currentUser.email;
    notification.userType = @"2";
    notification.soundType = @"ONE_SCREAM";
    notification.eventDescription = @"One Scream";
    notification.scream_date = dateString;
    notification.time = timeString;
    notification.os = @"iOS";
    notification.status = @"Not Yet";
    id <IDataStore>dateStore =  [backendless.persistenceService of:[userNotification class]];
    [dateStore save:notification response:^(id response) {
        NSString *soundObjId;
        if (response) {
            //[self.view setUserInteractionEnabled:true];
            
            soundObjId = ((userNotification *)response).objectId;
            completionBlock(YES);
            // The object has been saved.
        }   else {
            // [self.view setUserInteractionEnabled:true];
            // There was a problem, check error.description
            soundObjId = @"";
            completionBlock(YES);
        }
        [[EngineMgr sharedInstance] setSoundObjectId:soundObjId];
    } error:^(Fault *error) {
        completionBlock(NO);
    }];
}

- (void) saveWavFileToBackendlessFilePath:(NSString*)p_strFilePath OnComplition:(void (^)(BOOL succeeded,NSString *wavFileURL))completionBlock {
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:p_strFilePath];
    NSString *fileName = [NSString stringWithFormat:@"screams/%0.0f.wav",[[NSDate date] timeIntervalSince1970] ];
    [backendless.fileService upload:fileName content:data response:^(BackendlessFile *fileReturned) {
        if(fileReturned)
            completionBlock(YES,fileReturned.fileURL);
        else
            completionBlock(NO,nil);
    } error:^(Fault *error) {
        NSLog(@"File couldn't be uploaded: %@",[error detail]);
        completionBlock(NO,nil);
    }];
}
- (void) saveRTFFileToBackendlessFilePath:(NSString*)p_strFilePath OnComplition:(void (^)(BOOL succeeded,NSString *RTFFileURL))completionBlock{
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:p_strFilePath];
    NSString *fileName = [NSString stringWithFormat:@"detection_logs/%0.0f.rtf",[[NSDate date] timeIntervalSince1970] ];
    [backendless.fileService upload:fileName content:data response:^(BackendlessFile *fileReturned) {
        if(fileReturned)
            completionBlock(YES,fileReturned.fileURL);
        else
            completionBlock(NO,nil);
    } error:^(Fault *error) {
        completionBlock(NO,nil);
        NSLog(@"Error: %@",[error description]);
    }];
}

-(void)SaveDetectionHistoryToBackendlessWAVFileURL:(NSString *)fileURL RTFFileURL:(NSString *)rtfURL OnComplition:(void (^)(BOOL succeeded))completionBlock {
    
    BackendlessUser *user = backendless.userService.currentUser;
    detection_history *history = [detection_history new];
    history.scream_file = fileURL;
    history.log_file = rtfURL;
    history.userObjectId = user.objectId;
    history.userEmail = user.email;
    history.device_type = @"iOS";
    if([user getProperty:@"phone"]!=nil){
        history.phone = [user getProperty:@"phone"];
    }
    if([user getProperty:@"postcode"]!=nil){
        history.postcode = [user getProperty:@"postcode"];
    }
    history.log_type = isOutSideParameter?@"Outside parameters":@"Not Yet";
    NSString *strFullName = [NSString stringWithFormat:@"%@ %@", [user getProperty:@"first_name"], [user getProperty:@"last_name"]];
    history.fullname = strFullName;
    
    double dLatitude = 0;
    double dLongitude = 0;
    CLLocation* location = [[EMGLocationManager sharedInstance] m_location_gps];
    if (location != nil) {
        dLatitude = location.coordinate.latitude;
        dLongitude = location.coordinate.longitude;
    }
    NSString *strLocation = [NSString stringWithFormat:@"(%.4f, %.4f)", dLatitude, dLongitude];
    history.location = strLocation;
    id<IDataStore> dataStore = [backendless.persistenceService of:[detection_history class]];
    [dataStore save:history response:^(id response) {
        completionBlock(YES);
        //Save Detection History Object id
        
        NSString *logID;
        if (response) {
            //[self.view setUserInteractionEnabled:true];
            
            logID = ((detection_history *)response).objectId;
            // The object has been saved.
        }   else {
            // [self.view setUserInteractionEnabled:true];
            // There was a problem, check error.description
            logID = @"";
        }
        [[EngineMgr sharedInstance] setDetectionLogObjectId:logID];
        
        //Update Address at backendless
        NSString *strAddress = nil;
        // Set Address with WiFI
        NSString* strWiFiSSID = [EngineMgr currentWifiSSID];
        if (strWiFiSSID != nil) {
            int idx = [[EngineMgr sharedInstance] getWiFiItemIdx:strWiFiSSID];
            if (idx >= 0) {
                strAddress = [[EngineMgr sharedInstance] getWiFiAddressOfIndex:idx];
            }
        }
        
        // Set Address of GPS when there is no WIFI
        
        if (strAddress != nil) {
            history.address = strAddress;
            [dataStore save:history response:^(id response) {
                
            } error:^(Fault * error) {
                
            }];
        } else {
            if (location != nil) {
                [[EMGLocationManager sharedInstance] requestAddressWithLocation:location callback:^(NSString *szAddress) {
                    if (szAddress != nil && [szAddress length] > 0) {
                        history.address = szAddress;
                        [dataStore save:history response:^(id response) {
                            
                        } error:^(Fault * error) {
                            
                        }];
                    }
                }];
            } else {
            }
        }
        
        
        //        NSLog(@".wav file and its history saved, now saving detection log file and its relevant entery");
        //        NSString *strFilePath = [self prepareAndSaveLogFile];
        //        if(strFilePath)
        //            [self saveLogOnBackendless:strFilePath];
    } error:^(Fault * error) {
        completionBlock(NO);
        NSLog(@"detection history couldn't be saved: %@",[error message]);
    }];
}
-(BOOL)deleteLocalFile:(NSString *)filePath
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if(!success) NSLog(@"%@ couldn't deleted",filePath);
    return success;
}
@end
