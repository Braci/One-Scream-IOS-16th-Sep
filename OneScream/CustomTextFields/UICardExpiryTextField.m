//
//  UICardExpiryTextField.m
//  OneScream
//
//
//  Customized UITextField class to input Expiry date in Upgrade Membership Screen
//

#import "UICardExpiryTextField.h"

@implementation UICardExpiryTextField

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
    NSString *szExpiryDate = szOriginalPhoneNumber;
    szExpiryDate = [[szExpiryDate componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if (szExpiryDate.length == 0) return @"";
    
    NSString *szResult = szExpiryDate;
    if (szExpiryDate.length <= 2 && isBackspace == YES) return szResult;
    if (szExpiryDate.length < 2 && isBackspace == NO) return szResult;
    
    szResult = [NSString stringWithFormat:@"%@", [szExpiryDate substringWithRange:NSMakeRange(0, MIN(2, szExpiryDate.length))]];
    
    return szResult;
}

#pragma mark -IBAction Listener

- (IBAction)onEditingChanged:(id)sender {
    NSString *szPhone = self.text;
    NSInteger tag = self.tag;
    BOOL isBackspace = NO;
    
    if (tag == UICardExpiryTextField_KEYPRESSED_BACKSPACE) isBackspace = YES;
    [self setText:[self beautifyPhoneNumber:szPhone isBackspace:isBackspace]];
}

// Delegate methods
#pragma mark -Editing the Text Field's Text (from Apple Document)

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (string.length == 0){
        [self setTag:UICardExpiryTextField_KEYPRESSED_BACKSPACE];
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
