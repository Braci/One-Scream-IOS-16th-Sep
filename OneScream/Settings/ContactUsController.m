//
//  ContactUsController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for Contact us Screen
//

#import "ContactUsController.h"
#import "MZSelectableLabel.h"
#import <MessageUI/MessageUI.h>
@interface ContactUsController ()<MFMailComposeViewControllerDelegate>


@property (nonatomic,weak) IBOutlet MZSelectableLabel *emailLabel;
@end

@implementation ContactUsController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController navigationBar].hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
    [self setLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [AppEventTracker trackScreenWithName:@"Contact us screen"];

}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setLabel{
    
    
    
    NSString *statementString = @"Reach out to our help team at help@onescream.com";
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:statementString];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSRange fullRange = NSMakeRange(0, [stringText length]);
    [stringText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:fullRange];
    
    CGFloat fSize = 13;
    /*if (self.view.frame.size.width == 320){
        fSize = 7.5;
    }*/
    
    UIFont * font = [UIFont fontWithName:@"SFUIText-Regular" size:fSize];
    [stringText addAttribute: NSFontAttributeName value:font range: fullRange];
    [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:52/255.0 green:66/255.0 blue:81/255.0 alpha:1.0] range: fullRange];

    UIFont * semiBoldFont = [UIFont fontWithName:@"SFUIText-Semibold" size:fSize];
    
    
    NSRange privacyRange = [statementString rangeOfString:@"help@onescream.com"];
    [stringText addAttribute: NSFontAttributeName value:semiBoldFont range: privacyRange];
    [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:109/255.0 green:130/255.0 blue:152/255.0 alpha:1.0] range: privacyRange];

    //[stringText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:privacyRange];


    
    
    
    
    self.emailLabel.attributedText = stringText;
    self.emailLabel.numberOfLines = 2;
    self.emailLabel.minimumScaleFactor = 0.5;
    self.emailLabel.adjustsFontSizeToFitWidth = YES;
    self.emailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.emailLabel setSelectableRange:privacyRange];
    
    
    // to respond to links being touched by the user.
    
    self.emailLabel.selectionHandler = ^(NSRange range, NSString *string) {
        if ([string isEqualToString:@"help@onescream.com"]){
            [self showEmail:@"help@onescream.com"];
        }
    };
}

- (void)showEmail:(NSString*)sender {

    if ([MFMailComposeViewController canSendMail]){
        NSArray *toRecipents = [NSArray arrayWithObject:sender];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }

    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
