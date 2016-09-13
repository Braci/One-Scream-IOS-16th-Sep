//
//  DetectionHelper.h
//  OneScream
//
//  Created by Laptop World on 01/09/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
@interface DetectionHelper : NSObject
-(DetectionHelper *)initWithWavFileLocalPath:(NSString *)wavFilePath RTFFileLocalPath:(NSString *)rtfFilePath screamLocalDBID:(NSInteger)screamLocalDBID isOutSideParameter:(BOOL)outsideParameter;
-(void)doProcess:(detectionHistoryStatus)detectionStatus Param1:(NSObject *)param1 Param2:(NSObject *)param2;

@end
