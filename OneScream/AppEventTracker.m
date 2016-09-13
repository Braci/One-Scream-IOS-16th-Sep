//
//  AppEventTracker.m
//  OneScream
//
//  Created by Anwar Almojakresh on 24/02/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "AppEventTracker.h"
#import "GoSquared/GoSquared.h"
//#import <Parse/Parse.h>
#import "UserAddress.h"
#import "backendless.h"
#import "User.h"
@implementation AppEventTracker


+(void) initializeSDKKeys{
    //[[GoSquared sharedTracker] setSiteToken:@"GSN-683503-P"];
    //[[GoSquared sharedTracker] setApiKey:@"1DF4WPHQHN1R26BK"];
    
    [GoSquared sharedTracker].token = @"GSN-683503-P";
    [GoSquared sharedTracker].key = @"1DF4WPHQHN1R26BK";
    [GoSquared sharedTracker].logLevel = GSLogLevelDebug;
    [GoSquared sharedTracker].shouldTrackInBackground = YES;
}

+(void) onLogin{

    //[[GoSquared sharedTracker] identify:[NSString stringWithFormat:@"email:%@",[PFUser currentUser].email]];
    //[[GoSquared sharedTracker] identify:[PFUser currentUser].email];
    [self saveAndUpdateUserData:NO];
}
+(void) onSignOut{
    [[GoSquared sharedTracker] unidentify];
}
+(void) trackEvnetWithName:(NSString*)name withData:(NSDictionary *)dataDic{
    [[GoSquared sharedTracker] trackEvent:name properties:dataDic];
    
}
+(void)trackScreenWithName: (NSString *)name{
    [[GoSquared sharedTracker] trackScreen:name];
}

+(void)saveAndUpdateUserData:(BOOL)shoulIncludeCreationDate{
    
    //20JC26CDOMMCDT9G
    
    
//    NSMutableDictionary *postDic = [[NSMutableDictionary alloc]init];
    //PFUser * user = [PFUser currentUser];
    User *user = (User *)[backendless.userService currentUser];
    
//    [postDic setValue:user.email forKey:@"person_id"];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user getProperty:@"first_name"],[user getProperty:@"last_name"]];
    [properties setValue:fullName forKey:@"name"];
    [properties setValue:[user getProperty:@"first_name"] forKey:@"first_name"];
    [properties setValue:[user getProperty:@"last_name"] forKey:@"last_name"];
    [properties setValue:user.email forKey:@"email"];
    [properties setValue:[user getProperty:@"phone"] forKey:@"phone"];
    [properties setValue:user.email forKey:@"id"];
    if (shoulIncludeCreationDate){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        
//        NSDate *now = [NSDate date];
        NSDate *date = [user getProperty:@"created"];
        NSString *iso8601String = [dateFormatter stringFromDate:date];
        [properties setValue:iso8601String forKey:@"created_at"];
    }
    NSString *appVersionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSNumber *appVersion = [NSNumber numberWithDouble:[appVersionStr doubleValue]];
    NSDictionary *customDic = [[NSDictionary alloc]initWithObjectsAndKeys:appVersion ,@"App_Version", nil];
    [properties setValue:customDic forKey:@"custom"];//    [postDic setValue:properties forKey:@"properties"];
    NSLog(@"Properties: %@",properties);
    [[GoSquared sharedTracker]identifyWithProperties:properties];
    //[[GoSquared sharedTracker] identify:[PFUser currentUser].email properties:properties];
}

+(void)updateCityAndState{

    NSMutableDictionary *postDic = [[NSMutableDictionary alloc]init];
    BackendlessUser *user = backendless.userService.currentUser;
    //PFUser * user = [PFUser currentUser];
    UserAddress *address =  [user getProperty:HOME_ADDRESS_PARSE_COLOUMN];
    if (address == nil){
        return;
    }
    
//    [postDic setValue:[NSString stringWithFormat:@"email:%@",user.email] forKey:@"person_id"];
//    
//    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
//    
//    [properties setValue:address.city forKey:@"city"];
//    [postDic setValue:properties forKey:@"properties"];
//    
//    [[GoSquared sharedTracker] identify:[PFUser currentUser].email properties:postDic];
    


    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user getProperty:@"first_name"],[user getProperty:@"last_name"]];
    [properties setValue:fullName forKey:@"name"];
    [properties setValue:[user getProperty:@"first_name"] forKey:@"first_name"];
    [properties setValue:[user getProperty:@"last_name"] forKey:@"last_name"];
    [properties setValue:user.email forKey:@"email"];
    [properties setValue:[user getProperty:@"phone"] forKey:@"phone"];
    [properties setValue:user.email forKey:@"id"];
    [properties setValue:address.city forKey:@"city"];
    //    [postDic setValue:properties forKey:@"properties"];
    NSString *appVersionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSNumber *appVersion = [NSNumber numberWithDouble:[appVersionStr doubleValue]];
    NSDictionary *customDic = [[NSDictionary alloc]initWithObjectsAndKeys:appVersion ,@"App_Version", nil];
    [properties setValue:customDic forKey:@"custom"];
    NSLog(@"Properties: %@",properties);
    [[GoSquared sharedTracker]identifyWithProperties:properties];
}

@end
