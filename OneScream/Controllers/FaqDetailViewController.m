//
//  FaqDetailViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 02/02/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "FaqDetailViewController.h"
#import "FaqQTableViewCell.h"
#import "FaqATableViewCell.h"

@interface FaqDetailViewController ()

@end

NSInteger selected = -1;
BOOL isOpen = NO;

@implementation FaqDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table_view.HVTableViewDataSource = self;
    self.table_view.HVTableViewDelegate = self;
    self.tittle.text = self.header;
    // Do any additional setup after loading the view.
    
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"FAQ detail screen"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.dataModelArray count];
   /* if (section == selected) {
        return 2;
    } else {
        return 1;
    }*/
}

/*-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *szCellIdentifier = @"QUESTION";
    NSString *szCellIdentifierOpen = @"ANSWER";
    
    if (isOpen && indexPath.row == 1) {
        FaqATableViewCell *cell = (FaqATableViewCell*) [tableView dequeueReusableCellWithIdentifier:szCellIdentifierOpen];
        if (cell == nil) {
            cell = [[FaqATableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifierOpen];
        }
        cell.cell_answer.text = [self.answers objectAtIndex:indexPath.section];
//        isOpen = NO;
        return cell;
    } else {
        FaqQTableViewCell *cell = (FaqQTableViewCell*) [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
        if (cell == nil) {
            cell = [[FaqQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifier];
        }
        cell.cell_question.text = [self.dataModelArray objectAtIndex:indexPath.section];
        return cell;
    }
    
    
}*/


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isExpanded
{
    NSString *szCellIdentifier = @"QUESTION";
    

        FaqQTableViewCell *cell = (FaqQTableViewCell*) [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
        if (cell == nil) {
            cell = [[FaqQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifier];
        }
        cell.cell_question.text = [self.dataModelArray objectAtIndex:indexPath.row];
        cell.answerLabel.text = [self.answers objectAtIndex:indexPath.row];
    
    
    NSString * answer = [self.answers objectAtIndex:indexPath.row];
    NSString *substring = @"https:";
    NSRange textRange = [[answer lowercaseString] rangeOfString:[substring lowercaseString]];
    
    if(textRange.location != NSNotFound){
        //Does contain the substring
        
        
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSRange urlRange  =  [expression rangeOfFirstMatchInString:answer options:NSMatchingCompleted range:NSMakeRange(0, [answer length])];
        NSString *match = [answer substringWithRange:urlRange];
        
        NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:answer];
        
        
        //NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        //[paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        NSRange fullRange = NSMakeRange(0, [stringText length]);
        //[stringText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:fullRange];
        
        CGFloat fSize = 13;
        /*if (self.view.frame.size.width == 320){
         fSize = 7.5;
         }*/
        
        [stringText addAttribute: NSFontAttributeName value:cell.answerLabel.font range: fullRange];
        [stringText addAttribute: NSForegroundColorAttributeName value: cell.answerLabel.textColor range: fullRange];
        
        
        
        //NSRange urlRange = [answer rangeOfString:match];
        [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:109/255.0 green:130/255.0 blue:152/255.0 alpha:1.0] range: urlRange];
        
        
        
        cell.answerLabel.attributedText = stringText;
        cell.answerLabel.adjustsFontSizeToFitWidth = true;
        
        
        
        [cell.answerLabel setSelectableRange:urlRange];
        
        
        // to respond to links being touched by the user.
        
        cell.answerLabel.selectionHandler = ^(NSRange range, NSString *string) {
            if ([string isEqualToString:match]){
                NSURL *url = [NSURL URLWithString:string];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        };
        NSLog(@"%@", match); 
    }else{
        //Does not contain the substring
    }
    
        cell.answerLabel.hidden = true;

    
        return cell;
}





//perform your expand stuff (may include animation) for cell here. It will be called when the user touches a cell
-(void)tableView:(UITableView *)tableView expandCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    
    FaqQTableViewCell *fCell = (FaqQTableViewCell*) cell;
    [UIView animateWithDuration:.5 animations:^{
        fCell.answerLabel.hidden = false;
        [fCell.contentView viewWithTag:7].transform = CGAffineTransformMakeRotation(3.14);
    }];
}

//perform your collapse stuff (may include animation) for cell here. It will be called when the user touches an expanded cell so it gets collapsed or the table is in the expandOnlyOneCell satate and the user touches another item, So the last expanded item has to collapse
-(void)tableView:(UITableView *)tableView collapseCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    FaqQTableViewCell *fCell = (FaqQTableViewCell*) cell;
    [UIView animateWithDuration:.5 animations:^{
        fCell.answerLabel.hidden = true;
        [fCell.contentView viewWithTag:7].transform = CGAffineTransformMakeRotation(3.14);
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isexpanded
{
    //you can define different heights for each cell. (then you probably have to calculate the height or e.g. read pre-calculated heights from an array
    
    CGFloat labelWidth = self.view.frame.size.width -  65 ;//@"SFUIText-Regular"
    
    NSDictionary *attributesDictionaryForAnswers = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"ProximaNovaAlt-Regular" size:12.176], NSFontAttributeName,
                                          nil];
    NSDictionary *attributesDictionaryQuestions = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"ProximaNova-Bold" size:14.39], NSFontAttributeName,
                                          nil];
    if (isexpanded) {
        
        NSString *question = [self.dataModelArray objectAtIndex:indexPath.row];
        NSString *answer = [self.answers objectAtIndex:indexPath.row];

        CGRect qSize = [question boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionaryQuestions context:nil];
        CGRect aSize = [answer boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionaryForAnswers context:nil];
        return qSize.size.height +aSize.size.height+60;

        
        
    }else {

        NSString *question = [self.dataModelArray objectAtIndex:indexPath.row];
        CGRect qSize = [question boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionaryQuestions context:nil];
        return qSize.size.height+40;



    }

}




- (CGSize)sizeForLabel:(UILabel *)label {
    CGSize constrain = CGSizeMake(label.bounds.size.width, FLT_MAX);
    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:constrain lineBreakMode:UILineBreakModeWordWrap];
    
    //size.height += 100;
    
    return size;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
