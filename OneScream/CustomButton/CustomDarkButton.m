//
//  CustomDarkButton.m
//  OneScream
//
//
//  The Customized Button class for showing general button in this app
//

#import "CustomDarkButton.h"

@implementation CustomDarkButton


- (void)awakeFromNib
{
    self.layer.backgroundColor = [UIColor colorWithRed:52/255.0f green:66/255.0f blue:81/255.0f alpha:1.0f].CGColor;

    [super awakeFromNib];
}




@end
