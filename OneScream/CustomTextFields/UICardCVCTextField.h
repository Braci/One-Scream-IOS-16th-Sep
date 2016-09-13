//
//  UICardCVCTextField.h
//  OneScream
//
//  Customized UITextField class to input CVC in Upgrade Membership Screen
//


#import <UIKit/UIKit.h>

@interface UICardCVCTextField : UITextField <UITextFieldDelegate>

#define UICardCVCTextField_KEYPRESSED_BACKSPACE        1000

@property (weak, nonatomic) id<UITextFieldDelegate> m_delegate;

@end
