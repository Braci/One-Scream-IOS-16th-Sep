//
//  Constants.m
//  StripeExample
//
//  Stripe Constants to implement Stripe paying
//

#import "StripeConstants.h"

/**
 *  Replace these with your own values and then remove this warning.
 *  Make sure to replace the values in Example/Parse/config/global.json as well if you want to use Parse.
 */

// This can be found at https://dashboard.stripe.com/account/apikeys
NSString *const StripePublishableKey = @"pk_test_KfuZzdl7NryPQNaLw8hznUCF";

// To set this up, check out https://github.com/stripe/example-ios-backend
// This should be in the format https://my-shiny-backend.herokuapp.com
NSString *const BackendChargeURLString = @"https://polar-river-1687.herokuapp.com";

// To learn how to obtain an Apple Merchant ID, head to https://stripe.com/docs/mobile/apple-pay
NSString *const AppleMerchantId = nil; // TODO: replace nil with your own value

@implementation StripeConstants
@end
