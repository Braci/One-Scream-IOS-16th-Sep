//
//  WiFiSubmenuTVC.h
//  OneScream
//
//  Customized UITableViewCell class for showing the table in Frequented addresses Screen
//

#import <UIKit/UIKit.h>

@interface WiFiSubmenuTVC : UITableViewCell 

@property (weak, nonatomic) IBOutlet UIButton *m_btnDelete;
@property (weak, nonatomic) IBOutlet UITextField *m_lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *m_lblAddress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *m_nDeleteBtnWidth;

@end
