//
//  detection_Logs.h
//  OneScream
//
//  Created by Laptop World on 06/08/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BackendlessFile.h>
@interface detection_logs : NSObject
//@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, assign, getter = getObjectId, setter = setObjectId:) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic,strong)NSString *log_file;
@property (nonatomic,strong)NSString *userObjectId;
@property (nonatomic,strong)NSString *userEmail;
@property (nonatomic,strong)NSString *device_type;
@property (nonatomic,strong)NSString *fullname;
@property (nonatomic,strong)NSString *log_type; //Confirmed screams, False alert scream , Detected outside scream paratmeres
@end
