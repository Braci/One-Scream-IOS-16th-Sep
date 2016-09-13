//
//  UserAddress.h
//  OneScream
//
//  Created by Anwar Almojakresh on 22/03/2016.
//  Copyright © 2016 One Scream Ltd.All rights reserved.
//

//#import <Parse/Parse.h>

@interface UserAddress : NSObject
@property (nonatomic, strong) NSString *businessName;
@property (nonatomic, strong) NSString *streetAddress1;
@property (nonatomic, strong) NSString *streetAddress2;
@property (nonatomic, strong) NSString *apt_flat;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *postal;
@property (nonatomic, strong) NSString *addressType;

@property (nonatomic, assign, getter = getObjectId, setter = setObjectId:) NSString *objectId;
@end
