//
//  UICardNumberTextField.h
//  OneScream
//
//
//  Customized UITextField class to input Card Number in Upgrade Membership Screen
//

#import <UIKit/UIKit.h>

@interface UICardNumberTextField : UITextField <UITextFieldDelegate>

#define UICardNumberTextField_KEYPRESSED_BACKSPACE        1000

@property (weak, nonatomic) id<UITextFieldDelegate> m_delegate;

@end
