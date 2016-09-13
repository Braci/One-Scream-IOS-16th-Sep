//
//  EMGLocationManager.m
//  OneScream
//
//
//  Location Manager class to get real-time location and get address from its location
//

#import "EMGLocationManager.h"
#import "UIView+Toast.h"
#import "AFNetworking.h"
#import "EMGGMPlaceAutoCompleteDataModel.h"
#import "EngineMgr.h"

@implementation EMGLocationManager

#define LOCATIONMANAGER_DEFAULT_LOCATION_LATITUDE           40.7141667
#define LOCATIONMANAGER_DEFAULT_LOCATION_LONGITUDE          -74.0063889

#define GOOGLEMAPS_API_KEY                  @"AIzaSyCNaLIcxvAIwid2XVNEbl2mzZn8uCmjlSg"
#define GOOGLEMAPS_API_PLACE_KEY            @"AIzaSyCJZP2ZEhknm0xU8BW_ipDG7tg1gyAA660"


+ (EMGLocationManager *) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) dealloc{
    [self.m_locationManager stopUpdatingLocation];
}

- (void) initializeManager{
    if (self.m_locationManager != nil){
        [self.m_locationManager stopUpdatingLocation];
    }
    
    self.m_isLocationPermissionGranted = YES;
    
    self.m_locationManager = [[CLLocationManager alloc] init];
    self.m_locationManager.delegate = self;
    self.m_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.m_locationManager.distanceFilter = 5;
    self.m_isTrackingLocation = YES;
    self.m_shouldShowAlertForLocationError = YES;
    
    self.m_location_gps = [[CLLocation alloc]initWithLatitude:LOCATIONMANAGER_DEFAULT_LOCATION_LATITUDE longitude:LOCATIONMANAGER_DEFAULT_LOCATION_LONGITUDE];
    
    self.m_szAddress_gps = @"";
    
    self.m_isLocationFailed = YES;
    
    [self requestCurrentLocation];
}

- (void) startLocationUpdate{
    NSLog(@"startLocationUpdate called");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        [self.m_locationManager requestAlwaysAuthorization];
        //[self.m_locationManager requestWhenInUseAuthorization];

    } else {
        if ([[EngineMgr sharedInstance] isBackground]){
            [self.m_locationManager startUpdatingLocation];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.m_locationManager startUpdatingLocation];
            });
        }
    }
}

- (void) stopLocationUpdate{
    if ([[EngineMgr sharedInstance] isBackground]){
        [self.m_locationManager stopUpdatingLocation];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.m_locationManager stopUpdatingLocation];
        });
    }
}

- (void) requestCurrentLocation{
    [self stopLocationUpdate];
    [self startLocationUpdate];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {

        case kCLAuthorizationStatusDenied:
        {
            self.m_isLocationPermissionGranted = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithMessage:@"Location service is off, Please switch it ON from the settings in your iPhone."];
            });
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            self.m_isLocationPermissionGranted = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.m_locationManager startUpdatingLocation];
            });
            break;
        }
        default:
            break;
    }
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:EMGLOCALNOTIFICATION_LOCATION_PERMISSION_UPDATED object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if ([locations count] == 0) return;
    CLLocation *newLocation = [locations lastObject];
    // NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    // if (locationAge < 0.01) return;
    
    self.m_location_gps = newLocation;
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationChange" object:nil];
    // [self requestAddressWithLocation:nil LocationType:EMGENUM_LOCATIONTYPE_GPS callback:nil];

    self.m_isLocationFailed = NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (self.m_isTrackingLocation == NO) return;
    
    NSString *sz = @"";
    BOOL shouldRetry = YES;
    switch([error code])
    {
        case kCLErrorNetwork:{ // general, network-related error
            sz = @"Location service failed!\nPlease check your network connection or that you are not in airplane mode.";
            shouldRetry = YES;
            break;
        }
        case kCLErrorDenied:{
            sz = @"User denied to use location service.";
            shouldRetry = NO;
            break;
        }
        case kCLErrorLocationUnknown:{
            sz = @"One Scream is unable to obtain geo-location information right now.";
            shouldRetry = NO;
            break;
        }
        default:{
            sz = [NSString stringWithFormat:@"Location service failed due to unknown error.\n%@", error.description];
            shouldRetry = YES;
            break;
        }
    }
    NSLog(@"locationManager didFailWithError: %@", error.description);
    // [EMGGenericFunctionManager showAlertWithMessage:@"Location service is not enabled on your device!"];
    
    if (self.m_shouldShowAlertForLocationError == YES){
        [self showAlertWithMessage:sz];
    }
    else{
        [self showToastToViewController:[EMGLocationManager getTopMostViewController] Message:sz];
    }
    
    [self.m_locationManager stopUpdatingLocation];
    if (shouldRetry){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.m_locationManager startUpdatingLocation];
        });
    }
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [EMGGenericFunctionManager showToastToViewController:[EMGGenericFunctionManager getTopMostViewController] Message:@"Default location (New York) will be used while trying again."];
    });
    */ 
    
    self.m_shouldShowAlertForLocationError = NO;
    self.m_isLocationFailed = YES;
}

- (void) requestAddressWithLocation: (CLLocation *) location callback: (void (^)(NSString *szAddress)) callback{
    NSString *szUrl = @"http://maps.googleapis.com/maps/api/geocode/json";
    CLLocation *loc = location;
    if (loc == nil) {
        loc = self.m_location_gps;
    }
    
    NSString *latlng = [NSString stringWithFormat:@"%f,%f", loc.coordinate.latitude, loc.coordinate.longitude];
    NSDictionary *params = @{@"latlng" : latlng};
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestManager GET:szUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            NSDictionary *dictResponse = responseObject;
            NSString *status = [self refineNSString:[dictResponse objectForKey:@"status"]];
            if ([status caseInsensitiveCompare:@"OK"] == NSOrderedSame){
                NSArray *results = [dictResponse objectForKey:@"results"];
                if ([results count] > 0){
                    NSDictionary *dict = [results objectAtIndex:0];
                    NSString *address = [self refineNSString: [dict objectForKey:@"formatted_address"]];
                    
                    self.m_szAddress_gps = address;
                    
                    if (callback){
                        callback(address);
                    }
                }
            } else {
                NSLog(@"Got bad status code from google maps geocode: %@", status);
                [self doFallbackGeocodeWithType:callback];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Google maps geocode exception!");
            if (callback){
                callback(@"");
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callback){
            NSLog(@"%@", error);
            callback(@"");
        }
    }];
}

- (void) doFallbackGeocodeWithType : (void (^)(NSString *szAddress)) callback {
    NSLog(@"Doing fallback geocoder");
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:self.m_location_gps completionHandler:^(NSArray *placemarks, NSError *error){
        if (!(error)) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"Geocoded with CLGeocoder");
            self.m_szAddress_gps = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            
            if (callback) {
                callback(self.m_szAddress_gps);
            }
        } else {
            NSLog(@"Failover geocode failed with error %@", error);
            NSLog(@"\nCurrent Location Not Detected\n");
            if (callback) {
                callback(@"");
            }
        }
    }];

}


- (void) requestGoogleMapsApiPlaceAutoCompleteWithInput: (NSString *) input token: (NSString *) token callback: (void (^)(NSString *token, NSArray *results)) callback{
    
    NSString *szUrl = @"https://maps.googleapis.com/maps/api/place/autocomplete/json";
    NSDictionary *params = @{@"input" : input,
                             @"sensor": @"true",
                             @"key": GOOGLEMAPS_API_PLACE_KEY
                             };
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestManager GET:szUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            NSDictionary *dictResponse = responseObject;
            NSString *status = [self refineNSString:[dictResponse objectForKey:@"status"]];
            NSMutableArray *arrResult = [[NSMutableArray alloc] init];
            if ([status caseInsensitiveCompare:@"OK"] == NSOrderedSame){
                NSArray *arr = [dictResponse objectForKey:@"predictions"];
                if ([arr count] > 0){
                    for (int i = 0; i < (int)[arr count]; i++){
                        NSDictionary *dict = [arr objectAtIndex:i];
                        EMGGMPlaceAutoCompleteDataModel *place = [[EMGGMPlaceAutoCompleteDataModel alloc] init];
                        [place setWithDictionary:dict];
                        [arrResult addObject:place];
                    }
                }
            }
            if (callback){
                callback(token, arrResult);
            }
        }
        @catch (NSException *exception) {
            if (callback){
                callback(token, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callback){
            callback(token, nil);
        }
    }];
}

- (void) requestGoogleMapsApiPlaceDetailsWithReference: (NSString *) reference callback: (void (^)(CLLocation *location)) callback{
    NSString *szUrl = @"https://maps.googleapis.com/maps/api/place/details/json";
    NSDictionary *params = @{@"reference" : reference,
                             @"sensor": @"true",
                             @"key": GOOGLEMAPS_API_PLACE_KEY
                             };
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestManager GET:szUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            NSDictionary *dictResponse = responseObject;
            NSString *status = [self refineNSString:[dictResponse objectForKey:@"status"]];
            if ([status caseInsensitiveCompare:@"OK"] == NSOrderedSame){
                NSDictionary *dictResult = [dictResponse objectForKey:@"result"];
                NSDictionary *dictGeometry = [dictResult objectForKey:@"geometry"];
                NSDictionary *dictLocation = [dictGeometry objectForKey:@"location"];
                float fLat = [((NSNumber *) [dictLocation objectForKey:@"lat"]) floatValue];
                float fLng = [((NSNumber *) [dictLocation objectForKey:@"lng"]) floatValue];
                
                CLLocation *location = [[CLLocation alloc]initWithLatitude: fLat longitude:fLng];
                
                self.m_location_gps = location;
                
                if (callback){
                    callback(location);
                }
            }
        }
        @catch (NSException *exception) {
            if (callback){
                callback([[CLLocation alloc]initWithLatitude: 0 longitude:0]);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callback){
            callback([[CLLocation alloc]initWithLatitude: 0 longitude:0]);
        }
    }];
}

- (void) showAlertWithMessage: (NSString *) szMessage{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"One Scream" message:szMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void) showToastToViewController: (UIViewController *) vc Message: (NSString *) szMessage{
    [vc.view makeToast:szMessage];
}

+ (UIViewController *) findBestViewControllerFromViewController: (UIViewController *)vc{
    if (vc.presentedViewController && [vc.presentedViewController isKindOfClass:[UIAlertController class]] == NO){
        return [EMGLocationManager findBestViewControllerFromViewController:vc.presentedViewController];
    }
    else if([vc isKindOfClass:[UISplitViewController class]]){
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [EMGLocationManager findBestViewControllerFromViewController:svc.viewControllers.lastObject];
        }
        else{
            return vc;
        }
    }
    else if ([vc isKindOfClass:[UINavigationController class]]){
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [EMGLocationManager findBestViewControllerFromViewController:svc.topViewController];
        }
        else {
            return vc;
        }
    }
    else if ([vc isKindOfClass:[UITabBarController class]]){
        // Return visible view
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0){
            return [EMGLocationManager findBestViewControllerFromViewController:svc.selectedViewController];
        }
        else{
            return vc;
        }
    }
    
    // Unknown view controller type
    return vc;
}

+ (UIViewController *) getTopMostViewController{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [EMGLocationManager findBestViewControllerFromViewController:viewController];
}

- (NSString *) refineNSString: (id)sz{
    NSString *szResult = @"";
    if ((sz == nil) || ([sz isKindOfClass:[NSNull class]] == YES)) szResult = @"";
    else szResult = [NSString stringWithFormat:@"%@", sz];
    return szResult;
}
@end
