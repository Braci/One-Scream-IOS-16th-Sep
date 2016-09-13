//
//  UICardNumberTextField.m
//  OneScream
//
//
//  Customized UITextField class to input Card Number in Upgrade Membership Screen
//

#import "UICardNumberTextField.h"

@implementation UICardNumberTextField

- (id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        self.delegate = self;
        self.m_delegate = nil;
        [self addTarget:self action:@selector(onEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setDelegate:(id<UITextFieldDelegate>)delegate{
    if (delegate == self){
        [super setDelegate:delegate];
    }
    else{
        self.m_delegate = delegate;
    }
}

#pragma mark -Utility

- (NSString *) beautifyPhoneNumber :(NSString *)szOriginalPhoneNumber isBackspace:(BOOL) isBackspace{
    NSString *szPhoneNumber = szOriginalPhoneNumber;
    szPhoneNumber = [[szPhoneNumber componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if (szPhoneNumber.length == 0) return @"";
    
    NSString *szResult = @"";
    szResult = [szResult stringByAppendingString: [szPhoneNumber substringWithRange:NSMakeRange(0, MIN(4, szPhoneNumber.length))]];
    if (szPhoneNumber.length <= 4 && isBackspace == YES) return szResult;
    if (szPhoneNumber.length < 4 && isBackspace == NO) return szResult;
    
    szResult = [NSString stringWithFormat:@"%@ %@", szResult, [szPhoneNumber substringWithRange:NSMakeRange(4, MIN(4, szPhoneNumber.length - 4))]];
    if (szPhoneNumber.length <= 8 && isBackspace == YES) return szResult;
    if (szPhoneNumber.length < 8 && isBackspace == NO) return szResult;
    
    szResult = [NSString stringWithFormat:@"%@ %@", szResult, [szPhoneNumber substringWithRange:NSMakeRange(8, MIN(4, szPhoneNumber.length - 8))]];
    if (szPhoneNumber.length <= 12 && isBackspace == YES) return szResult;
    if (szPhoneNumber.length < 12 && isBackspace == NO) return szResult;
    
    szResult = [NSString stringWithFormat:@"%@ %@", szResult, [szPhoneNumber substringWithRange:NSMakeRange(12, MIN(4, szPhoneNumber.length - 12))]];
    return szResult;
}

#pragma mark -IBAction Listener

- (IBAction)onEditingChanged:(id)sender {
    NSString *szPhone = self.text;
    NSInteger tag = self.tag;
    BOOL isBackspace = NO;
    
    if (tag == UICardNumberTextField_KEYPRESSED_BACKSPACE) isBackspace = YES;
    [self setText:[self beautifyPhoneNumber:szPhone isBackspace:isBackspace]];
}

// Delegate methods
#pragma mark -Editing the Text Field's Text (from Apple Document)

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (string.length == 0){
        [self setTag:UICardNumberTextField_KEYPRESSED_BACKSPACE];
    }
    else{
        [self setTag:0];
    }
    
    if (self.m_delegate && [self.m_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]){
        [self.m_delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
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
