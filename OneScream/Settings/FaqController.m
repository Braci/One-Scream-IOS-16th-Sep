//
//  FaqController.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//
//
//  The ViewController Class for FAQ Screen
//

#import "FaqController.h"
#import "FaqDetailController.h"
#import "FaqSubmenuTVC.h"


@interface FaqController ()

@property (strong, nonatomic) NSArray *m_arrFaqTitles;

@end

@implementation FaqController {
    BOOL m_bUIRearrangeNeeded;
}

@synthesize m_tableviewFaqs;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.m_arrFaqTitles = @[
                            @[
                                @"How do I change my email preferences?",
                                @"To change your email preferences, go to the accounts page and click on your details to amend."
                              ],
                            @[
                                @"How do I cancel my subscription?",
                                @"To cancel your subscription, go to your protection plan and click \'Cancel One Scream\'"
                                ],
                            @[
                                @"I am having trouble paying.",
                                @"Please contact us at help@onescream.com"
                                ],
                            @[
                                @"I am worried my alarm will activate when it shouldn't!",
                                @"We have carefully measured the qualities that define a true panic scream. Just as your own ear hears real distress, our app can also distinguish a true panic scream from other screams and sounds. However if the alarm does mistakenly activate, you have 12 seconds to cancel the alarm."
                                ],
                            @[
                                @"I want to know what to expect if the alarm is activated.",
                                @"The phone will vibrate, you will hear a loud siren, the lights of your phone will flash."
                                ],
                            @[
                                @"What is the red bar on the top of my screen?",
                                @"App requires the red bar to show when apps which run in the background."
                                ],
                        ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    
    m_bUIRearrangeNeeded = YES;
    [AppEventTracker trackScreenWithName:@"FAQ Screen"];

}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews {
    if (m_bUIRearrangeNeeded) {
        m_bUIRearrangeNeeded = NO;

        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        m_tableviewFaqs.contentInset = contentInsets;
        m_tableviewFaqs.scrollIndicatorInsets = contentInsets;
        [m_tableviewFaqs setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    
    [super viewDidLayoutSubviews];
}

#pragma mark -Event Listener
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section{
    return [self.m_arrFaqTitles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{
    static NSString *szCellIdentifierSubMenu = @"TABLECELL_FAQ_SUBMENU";
    
    FaqSubmenuTVC * cell = [tableView dequeueReusableCellWithIdentifier:szCellIdentifierSubMenu];
    if (cell == nil) {
        cell = [[FaqSubmenuTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifierSubMenu];
    }
    
    cell.m_lblName.text = [[self.m_arrFaqTitles objectAtIndex:indexPath.row] objectAtIndex:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    
    FaqDetailController *nextScr = (FaqDetailController *) [self.storyboard instantiateViewControllerWithIdentifier:@"FaqDetailController"];
    nextScr.m_strTitle = [[self.m_arrFaqTitles objectAtIndex:row] objectAtIndex:0];
    nextScr.m_strContent = [[self.m_arrFaqTitles objectAtIndex:row] objectAtIndex:1];
    [self.navigationController pushViewController:nextScr animated:YES];
    
    [m_tableviewFaqs deselectRowAtIndexPath:indexPath animated:YES];
}



@end
