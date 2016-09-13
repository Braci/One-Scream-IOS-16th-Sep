//
//  FaqViewController.m
//  OneScream
//
//  Created by Anwar Almojakresh on 02/02/2016.
//  Copyright © 2016 One Scream Ltd. All rights reserved.
//

#import "FaqViewController.h"
#import "FaqTableViewCell.h"
#import "FaqDetailViewController.h"

@interface FaqViewController ()



@end

NSArray* catagories;
// Question
NSArray* Your_Details;
NSArray* Payment;
NSArray* Troubleshooting;
NSArray* Your_Privacy;
NSArray* Screaming;
NSArray* About;
NSArray* One_Scream;

//Answer
NSArray* Your_DetailsA;
NSArray* PaymentA;
NSArray* TroubleshootingA;
NSArray* Your_PrivacyA;
NSArray* ScreamingA;
NSArray* AboutA;
NSArray* One_ScreamA;

NSInteger rowSelected = -1;

@implementation FaqViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    catagories = [[NSArray alloc] initWithObjects:@"Your Details",@"Payment",@"Troubleshooting ",@"Screaming",@"About the app",@"One Scream on your device",@"Your Privacy", nil];
    
    Your_Details = [[NSArray alloc] initWithObjects:@"How can I change my account information?",@"How can I manage my subscription?",@"Can I cancel my yearly subscription before the end of the year?", nil];
    
    Your_DetailsA = [[NSArray alloc] initWithObjects:@"To change your account information, go to the Account page and click on Your Details to amend.",@"You can change or cancel your subscription in the Account section of the app. Go to Your Details then click the Manage Subscription button.",@"Click on Account, then Your Details to find the Manage Subscriptions button. You can cancel your renewal within 8 hours of that next date in the Apple store.", nil];
    
    Payment = [[NSArray alloc] initWithObjects:@"How much does One Scream cost?",@"I am having trouble paying!",@"Are there any hidden extra fees, for example when I have created an alert?", nil];
    
    PaymentA = [[NSArray alloc] initWithObjects:@"One Scream costs 1.49 a month, or save almost 20% by signing up for a 14.49 yearly subscription.",@"Please click on this link for simple instructions from Apple on how to change or update your payment method https://support.apple.com/en-us/HT201266",@"There are no hidden fees, what you see is what you get.", nil];
    
    Troubleshooting = [[NSArray alloc] initWithObjects:@"How do I close or exit the One Scream app?",@"My app is not working.", nil];
    
    TroubleshootingA = [[NSArray alloc] initWithObjects:@"To close or exit the One Scream app, click on the menu bar in the top left of the screen. Click Log Out.",@"You may need to change or update your payment method in Apple to reactivate the app. Go to the Account section of the app. In Your Details, click the Manage Subscription button. If you have been blocked for misusing the app, you will not be able to activate One Scream again.", nil];
    
    Your_Privacy = [[NSArray alloc] initWithObjects:@"Is One Scream listening to what I say?",@"Who can see my location?",@"What do you do with my information?", nil];
    
    Your_PrivacyA = [[NSArray alloc] initWithObjects:@"No! One Scream does not hear spoken words, only sounds. We aim to protect your privacy. We only ever listen for or record screams to become smarter, and our app learns with every user.",@"No one will ever monitor your location, including us. Your location will be sent to Police only if a panic scream is detected.",@"We only use your details in the event of an emergency, to provide Police with your identity and location.", nil];
    
    Screaming = [[NSArray alloc] initWithObjects:@"What is a panic scream?",@"In my nightmares I cannot scream. What if I cannot scream in real life?",@"What happens if I scream at my phone when I am not in danger?",@"Do I need to scream for the app?", nil];
    
    ScreamingA = [[NSArray alloc] initWithObjects:@"A panic scream is a woman’s natural response to danger. A scream is a universally recognised primal sound that humans make when in distress to call for help. All panic screams have very similar qualities. ",@"Many people who cannot scream in nightmares or have never screamed in their lives will often still scream if they are in danger and need help. It is an innate response for females in danger to scream for help. If you do not scream, the app will not be able to help you. ",@"Do not try to scream a panic scream for the app unless you are in distress. If you misuse the app, Police can ask us to block you as a user; false alarms distract Police from doing their job, protecting those in real danger.",@"You should not scream unless you are in real distress.", nil];
    
    About = [[NSArray alloc] initWithObjects:@"I am worried my alarm will activate when it shouldn’t!",@"What should I expect if the alarm is activated?",@"How can I stop the alert if I am not able to cancel within the 12 seconds?",@"What are Frequented Addresses?", @"What is the red bar on the top of my iPhone screen?", @"How do I know One Scream is listening?", @"In which countries is One Scream available? ", @"When should I use One Scream?", nil];
    
    AboutA = [[NSArray alloc] initWithObjects:@"We have carefully measured the qualities that define a true panic scream. Just as your own ear hears real distress, our app can also distinguish a true panic scream from other screams and sounds. However if the alarm does mistakenly activate, you have 12 seconds to cancel the alarm. A push notification with the option to cancel the alarm will appear on your phone.",@"The phone will vibrate, you will hear a loud siren, and the lights of your phone will flash. You have 12 seconds to cancel the alarm before the police are notified.",@"If an alert has been sent to Police, it is crucial to stay on the line and confirm your false alarm before an emergency vehicle has been dispatched",@"Frequented Addresses are places where you spend the most time, such as home and work. We only access those addresses if the app hears your panic scream. Your phone connects to your home or work WiFi which confirms your location. Using WiFi is helpful as GPS is not always entirely accurate. It is mandatory to connect to your home address and important to connect to WiFi at work.", @"Apple requires the red bar to show when an app is using your microphone while continuously running in the background.", @"If you are using an iPhone you will see a red bar at the top of your screen, this red bar signifies that One Scream is listening. If you are an Android user, you will see the app icon of One Scream at the top of the screen when the app is listening.", @"Currently One Scream is only available in the UK. We hope to launch in other countries soon! ", @"While it is up to your discretion, we hope you will leave One Scream running in the background at all times. There will be instances when you would always remember to turn One Scream on, such as when walking home late or on a long run alone. We also want to be listening in the unlikely event of a sudden or unexpected attack. If One Scream is not listening, it cannot help.", nil];
    
    One_Scream = [[NSArray alloc] initWithObjects:@"Do I need a phone plan? ",@"Can I use One Scream on my tablet or computer?",@"What happens if I have no signal/connection?",@"Is One Scream running down my battery?", @"I want to switch One Scream off in places like the cinema or the theatre.", nil];
    
    One_ScreamA = [[NSArray alloc] initWithObjects:@"YYou do not need a monthly phone plan for One Scream to operate. One Scream requires a data connection in order to report your location to Police in an emergency, this connection can be provided by a pay as you go plan carrier.",@"One Scream is only designed for mobile phones.",@"One Scream is working within the phone, if you have no signal the app will detect your scream but will not have a way to communicate to Police.",@"One Scream operates incredibly efficiently but if it runs in the background all the time, it will have an impact on battery life.", @"Please feel free to use One Scream at your discretion. If you turn off your app at the cinema or theatre, remember to turn it back on after the show. We have designed the app to run in the background all the time because attacks are often sudden and unexpected.", nil];
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppEventTracker trackScreenWithName:@"FAQ Screen"];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [catagories count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{

    NSString *szCellIdentifier = @"FAQCELL";
    
    FaqTableViewCell *cell = (FaqTableViewCell*) [tableView dequeueReusableCellWithIdentifier:szCellIdentifier];
    if (cell == nil) {
        cell = [[FaqTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:szCellIdentifier];
    }
    cell.cell_discription.text = [catagories objectAtIndex:indexPath.row];
    return cell;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    rowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"Details" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"Details"]) {
        FaqDetailViewController* vc = (FaqDetailViewController*)segue.destinationViewController;
        if (rowSelected == 0) {
            vc.dataModelArray = (NSMutableArray*)Your_Details;
            vc.answers = Your_DetailsA;
            vc.header = [catagories objectAtIndex:rowSelected];
        } else if (rowSelected == 1) {
            vc.dataModelArray = (NSMutableArray*)Payment;
            vc.answers = PaymentA;
            vc.header = [catagories objectAtIndex:rowSelected];
        }else if (rowSelected == 2) {
            vc.dataModelArray = (NSMutableArray*)Troubleshooting;
            vc.answers = TroubleshootingA;
            vc.header = [catagories objectAtIndex:rowSelected];
        }else if (rowSelected == 3) {
            vc.dataModelArray = (NSMutableArray*)Screaming;
            vc.answers = ScreamingA;
            vc.header = [catagories objectAtIndex:rowSelected];
        }else if (rowSelected == 4) {
            vc.dataModelArray = (NSMutableArray*)About;
            vc.answers = AboutA;
            vc.header = [catagories objectAtIndex:rowSelected];
        }else if (rowSelected == 5) {
            vc.dataModelArray = (NSMutableArray*)One_Scream;
            vc.answers = One_ScreamA;
            vc.header = [catagories objectAtIndex:rowSelected];
        }else if (rowSelected == 6) {
            vc.dataModelArray = (NSMutableArray*)Your_Privacy;
            vc.answers = Your_PrivacyA;
            vc.header = [catagories objectAtIndex:rowSelected];
        }
        
    }
}


@end
