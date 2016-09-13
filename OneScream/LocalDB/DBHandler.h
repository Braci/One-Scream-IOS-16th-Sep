//
//  DBHandler.h
//  OneScream
//
//  Created by Laptop World on 22/08/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHandler : NSObject
+(void)creatAndCheckDatabase;
+(NSInteger)soundDetectedWavLocalFilePath:(NSString *)wavLocalFilePath isOutsideParam:(BOOL)isOutSideParam;
+(BOOL)soundDetectedRTFLocalFilePath:(NSString *)rtfLocalFilePath screamDetectionID:(NSInteger)screamDetectionID;
+(BOOL)soundDetectedPushNotificationSentScreamDetectionID:(NSInteger)screamDetectionID;
+(BOOL)soundDetectedWavBackendlessFilePath:(NSString *)wavBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID;
+(BOOL)soundDetectedRTFBackendlessFilePath:(NSString *)RTFBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID;
+(BOOL)soundDetectedAllthingsDoneScreamDetectionID:(NSInteger)screamDetectionID;
+(void)ProcessTheInProcessScreams;


//+(void)soundDetectedWavLocalFilePath:(NSString *)wavLocalFilePath onComplition:(void (^)(BOOL succeeded,NSInteger screamDetectionID))completionBlock;
//+(void)soundDetectedRTFLocalFilePath:(NSString *)rtfLocalFilePath screamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock;
//+(void)soundDetectedPushNotificationSentScreamDetectionID:(NSInteger)screamDetectionID OnComplition:(void (^)(BOOL succeeded))completionBlock;
//+(void)soundDetectedWavBackendlessFilePath:(NSString *)wavBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock;
//+(void)soundDetectedRTFBackendlessFilePath:(NSString *)RTFBackenlessFilePath screamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock;
//+(void)soundDetectedAllthingsDoneScreamDetectionID:(NSInteger)screamDetectionID onComplition:(void (^)(BOOL succeeded))completionBlock;
@end
