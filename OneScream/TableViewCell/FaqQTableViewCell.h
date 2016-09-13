//
//  FaqQTableViewCell.h
//  OneScream
//
//  Created by Anwar Almojakresh on 02/02/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZSelectableLabel.h"

@interface FaqQTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cell_question;
@property (weak, nonatomic) IBOutlet MZSelectableLabel *answerLabel;

@end
