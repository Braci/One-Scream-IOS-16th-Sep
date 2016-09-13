//
//  FaqDetailViewController.h
//  OneScream
//
//  Created by Anwar Almojakresh on 02/02/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKExpandTableView.h"
#import "HVTableView.h"
@interface FaqDetailViewController : UIViewController <HVTableViewDelegate, HVTableViewDataSource>
@property (weak, nonatomic) IBOutlet HVTableView *table_view;
@property (weak, nonatomic) IBOutlet UILabel *tittle;


@property(nonatomic,strong) NSArray* answers;
@property(nonatomic,strong) NSString* header;
@property(nonatomic,strong) NSMutableArray * dataModelArray;
@end
