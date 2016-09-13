//
//  FaqController.h
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for FAQ Screen
//

#import <UIKit/UIKit.h>

@interface FaqController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *m_tableviewFaqs;

@end

