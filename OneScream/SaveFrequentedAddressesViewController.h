//
//  SaveFrequentedAddressesViewController.h
//  OneScream
//
//  Created by Anwar Almojakresh on 20/03/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum AddressType
{
    HOME,
    WORK,
    FREQUENT
} AddressType;
@interface SaveFrequentedAddressesViewController : UIViewController
@property (nonatomic,assign)AddressType address_type;
@property (nonatomic,assign)BOOL isForUpdateAddress;
@end
