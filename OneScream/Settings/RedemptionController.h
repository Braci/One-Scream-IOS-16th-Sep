//
//  RedemptionController.h
//  OneScream
//
//  Created by  Venus Kye on 9/11/15.
//  Copyright (c) 2015  Venus Kye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedemptionController : UIViewController <UITextFieldDelegate> {
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onBack:(id)sender;
- (IBAction)onRedeem:(id)sender;

@end

