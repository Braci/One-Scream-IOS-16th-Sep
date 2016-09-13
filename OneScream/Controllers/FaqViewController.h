//
//  FaqViewController.h
//  OneScream
//
//  Created by Anwar Almojakresh on 02/02/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaqViewController : UIViewController <UITabBarDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table_view;

@end
