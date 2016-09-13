//
//  UICardCVCTextField.m
//  OneScream
//
//  Customized UITextField class to input CVC in Upgrade Membership Screen  
//


#import "UICardCVCTextField.h"

@implementation UICardCVCTextField

- (id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        self.delegate = self;
        self.m_delegate = nil;
        [self addTarget:self action:@selector(onEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void) setDelegate:(id<UITextFieldDelegate>)delegate{
    if (delegate == self){
        [super setDelegate:delegate];
    }
    else{
        self.m_delegate = delegate;
    }
}


#pragma mark -IBAction Listener

- (IBAction)onEditingChanged:(id)sender {
    
}

// Delegate methods
#pragma mark -Editing the Text Field's Text (from Apple Document)

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString:@"\n"].location != NSNotFound;
    
    return newLength <= 3 || returnKey;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldClear:)]){
        [self.m_delegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldReturn:)]){
        [self.m_delegate textFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark -Managing Editing (from Apple Document)

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]){
        [self.m_delegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]){
        [self.m_delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]){
        [self.m_delegate textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]){
        [self.m_delegate textFieldDidEndEditing:textField];
    }
}

@end
