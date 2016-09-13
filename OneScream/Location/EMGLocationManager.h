//
//  EMGLocationManager.h
//  OneScream
//
//
//  Location Manager class to get real-time location and get address from its location
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EMGLocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *m_locationManager;

@property (strong, nonatomic) CLLocation *m_location_gps;               // LOCATION for GPS spot

@property (strong, nonatomic) NSString *m_szAddress_gps;

@property BOOL m_isLocationPermissionGranted;

@property BOOL m_isTrackingLocation;
@property BOOL m_isLocationFailed;
@property BOOL m_shouldShowAlertForLocationError;

+ (EMGLocationManager *) sharedInstance;
- (void) initializeManager;
- (void) startLocationUpdate;
- (void) stopLocationUpdate;
- (void) requestCurrentLocation;

- (void) requestAddressWithLocation: (CLLocation *) location callback: (void (^)(NSString *szAddress)) callback;
- (void) requestGoogleMapsApiPlaceAutoCompleteWithInput: (NSString *) input token: (NSString *) token callback: (void (^)(NSString *token, NSArray *results)) callback;
- (void) requestGoogleMapsApiPlaceDetailsWithReference: (NSString *) reference callback: (void (^)(CLLocation *location)) callback;

@end
