//
//  CustomButton.m
//  OneScream
//
//
//  The Customized Button class for showing general button in this app
//

#import "CustomButton.h"

@implementation CustomButton


- (void)awakeFromNib
{
    self.layer.backgroundColor = [UIColor colorWithRed:107/255.0f green:128/255.0f blue:150/255.0f alpha:1.0f].CGColor;

    [super awakeFromNib];
}




@end
