//
//  DBHandler.m
//  OneScream
//
//  Created by Laptop World on 22/08/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "DBHandler.h"
#import <FMDatabaseQueue.h>
#import <FMDatabase.h>
#import <FMResultSet.h>
#import "AppConstants.h"
#import "DetectionHelper.h"

@implementation DBHandler
static FMDatabaseQueue *queue;
static NSString *databasePath;
static dispatch_queue_t serialDBQueue;
+(void)initDatabaseQueue
{
    if(!queue)
    {
        if(!databasePath)
           [self getDBPath];
        queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
//        [queue inDatabase:^(FMDatabase *db) {
//            [db setKey:@"SECRET_KEY"];
//        }];
    }
}
+(void)getDBPath
{
    NSString *dbName = @"OneScreamDB.sqlite";
    NSArray *documentPaths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentPaths objectAtIndex:0];
    databasePath = [documentDirectory stringByAppendingPathComponent:dbName];
}
+(void)ContactNumberExists:(NSString *)number onComplition:(void (^)(BOOL succeeded))completionBlock
{
    [self initDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *querry = [NSString stringWithFormat:@"SELECT * FROM CONTACTS where Mobile='%@'",number];
        FMResultSet *results = [db executeQuery:querry];
        int count=0;
        while([results next])
        {
            count++;
        }
        if (count>0)
            completionBlock(YES);
        else
            completionBlock(NO);
    }];
}
+(NSInteger)soundDetectedWavLocalFilePath:(NSString *)wavLocalFilePath isOutsideParam:(BOOL)isOutSideParam
{
    FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
    if([database open])
    {
        NSDateFormatter *dateFormmater = [[NSDateFormatter alloc]init];
        dateFormmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *todayDate = [dateFormmater stringFromDate:[NSDate date]];
        
        BOOL result;
         NSString *querry = @"INSERT INTO scream_detections (Date_Time,wav_file_local_path,status_value,is_outside_param) VALUES (?,?,?,?)";
        result = [database executeUpdate:querry,todayDate,wavLocalFilePath,@(WAV_FILE_SAVED_LOCALLY),@(isOutSideParam)];
        NSInteger scream_detection_id = result?[database lastInsertRowId]:0;
        [database close];
        return scream_detection_id;
    }else{
        return 0;
    }
}
//+(void)soundDetectedWavLocalFilePath:(NSString *)wavLocalFilePath onComplition:(void (^)(BOOL succeeded,NSInteger screamDetectionID))completionBlock
//{
//    [self initDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        NSString *querry = @"INSERT INTO scream_detections (Date_Time,wav_file_local_path,status_value) VALUES (?,?,?)";
//        BOOL success = [db executeUpdate:querry,[NSDate date],wavLocalFilePath,@(WAV_FILE_SAVED_LOCALLY)];
//        if (success)
//            completionBlock(YES,[db lastInsertRowId]);
//        else
//            completionBlock(NO,0);
//    }];
//}
+(BOOL)soundDetectedRTFLocalFilePath:(NSString *)rtfLocalFilePath screamDetectionID:(NSInteger)screamDetectionID
{
    FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
    if([database open])
    {
        BOOL result;
        NSString *querry = @"UPDATE scream_detections SET rtf_file_local_path = ?, status_value = ? WHERE scream_detections_id = ?";
        result = [database executeUpdate:querry,rtfLocalFilePath,@(RTF_FILE_SAVED_LOCALLY),@(screamDetectionID)];
        
        [database close];
        return result;
        
    }else{
        return NO;
    }
}
//+(void)soundDetectedRTFLocalFilePath:(NSString *)rtfLocalFilePath screamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock
//{
//    [self initDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        NSString *querry = @"UPDATE scream_detections SET rtf_file_local_path = ?, status_value = ? WHERE scream_detections_id = ?";
//        BOOL success = [db executeUpdate:querry,rtfLocalFilePath,screamDetectionID,@(RTF_FILE_SAVED_LOCALLY)];
//        if (success)
//            completionBlock(YES);
//        else
//            completionBlock(NO);
//    }];
//}
+(BOOL)soundDetectedPushNotificationSentScreamDetectionID:(NSInteger)screamDetectionID
{
    FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
    if([database open])
    {
        BOOL result;
        NSString *querry = @"UPDATE scream_detections SET status_value = ? WHERE scream_detections_id = ?";
        result = [database executeUpdate:querry,@(PUSH_NOTIFICATION_SENT),@(screamDetectionID)];
        [database close];
        return result;
        
    }else{
        return NO;
    }
}

//+(void)soundDetectedPushNotificationSentScreamDetectionID:(NSInteger)screamDetectionID OnComplition:(void (^)(BOOL succeeded))completionBlock
//{
//    [self initDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        NSString *querry = @"UPDATE scream_detections SET status_value = ? WHERE scream_detections_id = ?";
//        BOOL success = [db executeUpdate:querry,screamDetectionID,@(PUSH_NOTIFICATION_SENT)];
//        if (success)
//            completionBlock(YES);
//        else
//            completionBlock(NO);
//    }];
//}

+(BOOL)soundDetectedWavBackendlessFilePath:(NSString *)wavBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID
{
    FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
    if([database open])
    {
        BOOL result;
        NSString *querry = @"UPDATE scream_detections SET wav_file_online_path = ?, status_value = ? WHERE scream_detections_id = ?";
        result = [database executeUpdate:querry,wavBackenlessFilePath,@(WAV_FILE_UPLOADED),@(screamDetectionID)];
        [database close];
        return result;
        
    }else{
        return NO;
    }

}
//+(void)soundDetectedWavBackendlessFilePath:(NSString *)wavBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock
//{
//    [self initDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        NSString *querry = @"UPDATE scream_detections SET wav_file_online_path = ?, status_value = ? WHERE scream_detections_id = ?";
//        BOOL success = [db executeUpdate:querry,wavBackenlessFilePath,screamDetectionID,@(WAV_FILE_UPLOADED)];
//        if (success)
//            completionBlock(YES);
//        else
//            completionBlock(NO);
//    }];
//}
+(BOOL)soundDetectedRTFBackendlessFilePath:(NSString *)RTFBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID
{
    FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
    if([database open])
    {
        BOOL result;
        NSString *querry = @"UPDATE scream_detections SET rtf_file_online_path = ?, status_value = ? WHERE scream_detections_id = ?";
        result = [database executeUpdate:querry,RTFBackenlessFilePath,@(RTF_FILE_UPLOADED),@(screamDetectionID)];
        [database close];
        return result;
        
    }else{
        return NO;
    }
}
//+(void)soundDetectedRTFBackendlessFilePath:(NSString *)RTFBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock
//{
//    [self initDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        NSString *querry = @"UPDATE scream_detections SET rtf_file_online_path = ?, status_value = ? WHERE scream_detections_id = ?";
//        BOOL success = [db executeUpdate:querry,RTFBackenlessFilePath,screamDetectionID,@(RTF_FILE_UPLOADED)];
//        if (success)
//            completionBlock(YES);
//        else
//            completionBlock(NO);
//    }];
//}
+(BOOL)soundDetectedAllthingsDoneScreamDetectionID:(NSInteger)screamDetectionID
{
    FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
    if([database open])
    {
        BOOL result;
        NSString *querry = @"UPDATE scream_detections SET status_value = ? WHERE scream_detections_id = ?";
        result = [database executeUpdate:querry,@(SCREAM_LOG_HISTORY_ENTRY_BACKENDLESS_LOCAL_DELETED),@(screamDetectionID)];
        [database close];
        return result;
        
    }else{
        return NO;
    }
}

//+(void)soundDetectedAllthingsDoneScreamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock
//{
//    [self initDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        NSString *querry = @"UPDATE scream_detections SET status_value = ? WHERE scream_detections_id = ?";
//        BOOL success = [db executeUpdate:querry,screamDetectionID,@(SCREAM_LOG_HISTORY_ENTRY_BACKENDLESS_LOCAL_DELETED)];
//        if (success)
//            completionBlock(YES);
//        else
//            completionBlock(NO);
//    }];
//}

+(void)creatAndCheckDatabase
{
    [self getDBPath];
    BOOL success;
    NSError *error;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    success =[fileManager fileExistsAtPath:databasePath];
    if (success)
    {
        //NSLog(@"Path:%@",self.databasePath);
        return;
    }
    NSString *databasePathFromApp = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"OneScreamDB.sqlite"];
    success=[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:&error];
    if (!success)
    {
        
        NSLog(@"error: %@",[error localizedDescription]);
    }
    
}

+(void)ProcessTheInProcessScreams
{
    FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
    serialDBQueue = dispatch_queue_create("OneScreamDBQueue", DISPATCH_QUEUE_SERIAL);
    NSMutableArray *inProcessScreams = [NSMutableArray new];
    if([database open])
    {
        NSString *querry = [NSString stringWithFormat:@"SELECT * FROM scream_detections where (status_value >= %d AND status_value < %d)",RTF_FILE_SAVED_LOCALLY,SCREAM_LOG_HISTORY_ENTRY_BACKENDLESS_LOCAL_DELETED];
        FMResultSet *results = [database executeQuery:querry];
        while([results next])
        {
            [inProcessScreams addObject:[results resultDictionary]];
        }
        [results close];
        [database close];
        
    }
    if(inProcessScreams.count>0){
        for(NSDictionary *screamDic in inProcessScreams){
            [self ProcessScream:screamDic];
        }
    }
}
+(void)ProcessScream:(NSDictionary *)screamInProcess
{
    NSInteger scream_status = [screamInProcess[@"status_value"]integerValue];
    if(scream_status<RTF_FILE_SAVED_LOCALLY)return;
    dispatch_async(serialDBQueue, ^{
        
        DetectionHelper *dh = [[DetectionHelper alloc]initWithWavFileLocalPath:screamInProcess[@"wav_file_local_path"] RTFFileLocalPath:screamInProcess[@"rtf_file_local_path"] screamLocalDBID:scream_status isOutSideParameter:[screamInProcess[@"is_outside_param"]boolValue]];
        if(scream_status==PUSH_NOTIFICATION_SENT){
            [dh doProcess:PUSH_NOTIFICATION_SENT Param1:nil Param2:nil];
        }else if (scream_status==WAV_FILE_UPLOADED){
            [dh doProcess:WAV_FILE_UPLOADED Param1:screamInProcess[@"wav_file_online_path"] Param2:nil];
        }else if (scream_status==RTF_FILE_UPLOADED){
            [dh doProcess:RTF_FILE_UPLOADED Param1:screamInProcess[@"wav_file_online_path"] Param2:screamInProcess[@"rtf_file_online_path"]];
        }
    });
}
@end
