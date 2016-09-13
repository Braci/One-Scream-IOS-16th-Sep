//
//  EMGGMPlaceAutoCompleteDataModel.h
//  OneScream
//
//  The Information class for getting address from short keyword
//

#import <Foundation/Foundation.h>

@interface EMGGMPlaceAutoCompleteDataModel : NSObject

@property (strong, nonatomic) NSString *m_szId;
@property (strong, nonatomic) NSString *m_szPlaceId;
@property (strong, nonatomic) NSString *m_szReference;
@property (strong, nonatomic) NSString *m_szDescription;

- (id) init;
- (void) setWithDictionary: (NSDictionary *) dict;

@end
