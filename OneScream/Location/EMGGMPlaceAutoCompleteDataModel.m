//
//  EMGGMPlaceAutoCompleteDataModel.m
//  OneScream
//
//  The Information class for getting address from short keyword
//

#import "EMGGMPlaceAutoCompleteDataModel.h"

@implementation EMGGMPlaceAutoCompleteDataModel

- (id) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.m_szId = @"";
    self.m_szDescription = @"";
    self.m_szPlaceId = @"";
    self.m_szReference = @"";
}

- (void) setWithDictionary: (NSDictionary *) dict{
    [self initialize];
    
    @try {
        NSString *szId = [self refineNSString:[dict objectForKey:@"id"]];
        NSString *szDescription = [self refineNSString:[dict objectForKey:@"description"]];
        NSString *szPlaceId = [self refineNSString:[dict objectForKey:@"place_id"]];
        NSString *szReference = [self refineNSString:[dict objectForKey:@"reference"]];
        
        self.m_szId = szId;
        self.m_szDescription = szDescription;
        self.m_szPlaceId = szPlaceId;
        self.m_szReference = szReference;
    }
    @catch (NSException *exception) {
        [self initialize];
        @throw exception;
    }
}

- (NSString *) refineNSString: (id)sz{
    NSString *szResult = @"";
    if ((sz == nil) || ([sz isKindOfClass:[NSNull class]] == YES)) szResult = @"";
    else szResult = [NSString stringWithFormat:@"%@", sz];
    return szResult;
}

@end
