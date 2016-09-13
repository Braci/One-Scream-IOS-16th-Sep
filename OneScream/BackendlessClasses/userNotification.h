//
//  userNotification.h
//  OneScream
//
//  Created by Laptop World on 18/07/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userNotification : NSObject
//@property (nonatomic, strong)NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong)NSString *userName;
@property (nonatomic, strong)NSString *userType;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, strong)NSString *time;
@property (nonatomic, strong)NSString *status;
@property (nonatomic, strong)NSString *soundType;
@property (nonatomic, strong)NSString *scream_date;
@property (nonatomic, strong)NSString *os;
@property (nonatomic, strong)NSString *eventDescription;
@property (nonatomic, assign, getter = getObjectId, setter = setObjectId:) NSString *objectId;
@end
