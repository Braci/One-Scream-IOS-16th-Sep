//
//  UICardExpiryTextField.h
//  OneScream
//
//
//  Customized UITextField class to input Expiry date in Upgrade Membership Screen
//

#import <UIKit/UIKit.h>

@interface UICardExpiryTextField : UITextField <UITextFieldDelegate>

#define UICardExpiryTextField_KEYPRESSED_BACKSPACE        1000

@property (weak, nonatomic) id<UITextFieldDelegate> m_delegate;

@end
