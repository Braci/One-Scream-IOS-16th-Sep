//
//  MenuHeaderTVC.h
//  OneScream
//
//
//  Customized UITableViewCell class for showing the header item of table in Menu Screen
//

#import <UIKit/UIKit.h>

@interface MenuHeaderTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *m_lblName;
@property (weak, nonatomic) IBOutlet UILabel *m_image;

@end
