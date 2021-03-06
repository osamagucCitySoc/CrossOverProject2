//
//  ViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/15/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Constants.h"
#import "ManageTransactionsViewController.h"
#import "Transaction.h"
#import "MonthReportViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController
{
    NSUserDefaults* userDefaults; /** @param Instance of the NSUserDefaults.*/
    __weak IBOutlet UILabel *currentBankAccountAmountLabel /** @param outlet for the label that shows the currently stored amount in the bank account.*/;
    __weak IBOutlet UITableView *tableVieww /** @param outlet for the table view that will be showing the different options the user can choose from.*/;
    NSArray* optionsDataSource /** @param array that contains all options a user can choose from.*/;
    __weak IBOutlet UIView *datePickerView /** @param UIView to be used when a user wants to see a report for a certain month.*/;
    __weak IBOutlet UIDatePicker *datePicker/** @param date picker to be used when a user wants to see a report for a certain month.*/;
    /** The coming outlets all of them are there to make the associated animations. They are composing the View that asks the user to enter which month he wants to get a report about */
    __weak IBOutlet UIView *theWalletView;
    __weak IBOutlet UIButton *wSubBtn;
    __weak IBOutlet UIButton *wCancelBtn;
    __weak IBOutlet UILabel *dateBackLabel;
    __weak IBOutlet UILabel *genRepLabel;
    NSMutableDictionary* monthSummary/** @param Dictionary contains the whole summary for a certain month the user wants to see the reports about it.*/;
    NSTimeInterval startTime;
    NSNumber *fromVal1,*toVal1;/** @param thos values are used to make the first animation when the app starts to animate the value of the bank Account*/
    BOOL doneFirstAnm;/** @param this bool value tells whether the animation had already been displayed or yet*/
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"expensesSeg"])
    {
        ManageTransactionsViewController* dst = (ManageTransactionsViewController*)[segue destinationViewController];
        [dst setTransactionType:@"Expenses"];
        
    }else if([[segue identifier]isEqualToString:@"incomeSeg"])
    {
        ManageTransactionsViewController* dst = (ManageTransactionsViewController*)[segue destinationViewController];
        [dst setTransactionType:@"Incomes"];
        
    }else if([[segue identifier]isEqualToString:@"monthReportSeg"])
    {
        MonthReportViewController* dst = (MonthReportViewController*)[segue destinationViewController];
        if(tableVieww.indexPathForSelectedRow.row == 1)
        {
            [dst setReportType:@"Expenses"];
        }else
        {
            [dst setReportType:@"Incomes"];
        }
        [dst setMonthData:monthSummary];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
    
    NSString* currentAmount = [userDefaults objectForKey:consBankAccountUserDefaultsKey];
    NSString* currentCurrencySymbol = [userDefaults objectForKey:consCurrencyUserDefaultsKey];
    
    if(!currentAmount)
    {
        currentAmount = @"0.000";
        [theWalletView setHidden:YES];
        [NSTimer scheduledTimerWithTimeInterval: 1.0
                                         target: self
                                       selector:@selector(walletHiddenOff:)
                                       userInfo: nil repeats:NO];
    }else
    {
    
    if (!doneFirstAnm)
    {
        doneFirstAnm = YES;
        [self animate1From:@(0) toNumber:[NSNumber numberWithInteger:currentAmount.integerValue] withSymbol:currentCurrencySymbol];
    }
    else
    {
        currentBankAccountAmountLabel.text = [@"" stringByAppendingFormat:@"%@ %@",currentCurrencySymbol,currentAmount];
    }
    }
}

- (void)animate1From:(NSNumber *)aFrom toNumber:(NSNumber *)aTo withSymbol:(NSString *)theSymbol{
    fromVal1 = aFrom;
    toVal1 = aTo;
    
    currentBankAccountAmountLabel.text = [@"" stringByAppendingFormat:@"%@ %@",theSymbol,[fromVal1 stringValue]];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(animate1Number:)];
    
    startTime = CACurrentMediaTime();
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)animate1Number:(CADisplayLink *)link {
    NSString* currentCurrencySymbol = [userDefaults objectForKey:consCurrencyUserDefaultsKey];

    static float DURATION = 1.0;
    float dt = ([link timestamp] - startTime) / DURATION;
    if (dt >= 1.0) {
        NSString* currentAmount = [userDefaults objectForKey:consBankAccountUserDefaultsKey];
        
        currentBankAccountAmountLabel.text = [@"" stringByAppendingFormat:@"%@ %@",currentCurrencySymbol,currentAmount];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    
    float current = ([toVal1 floatValue] - [fromVal1 floatValue]) * dt + [fromVal1 floatValue];
    
    currentBankAccountAmountLabel.text = [@"" stringByAppendingFormat:@"%@ %.3f",currentCurrencySymbol, current];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [datePickerView setAlpha:0.0];
    [self initVariables];
    [self initialiseTheBankAccount];
    
    NSString* currentAmount = [userDefaults objectForKey:consBankAccountUserDefaultsKey];
    NSString* currentCurrencySymbol = [userDefaults objectForKey:consCurrencyUserDefaultsKey];
    
    if(!currentAmount)
    {
        [theWalletView setHidden:YES];
    }
    if(!currentCurrencySymbol)
    {
        [theWalletView setHidden:YES];
    }
}

-(void)walletHiddenOff:(NSTimer *)timer {
    [theWalletView setHidden:NO];
}


/**
 This method is used to initialise the inner variables and views used by this controller.
 */

-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setMinimumDate:[NSDate date]];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:1];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [datePicker setMaximumDate:maxDate];
    
    // Those are the list of different options that the user can play with.
    NSDictionary* manageOptions = [[NSDictionary alloc]initWithObjects:@[@"Manage your wallet",@[@"Manage your account amount",@"Manage your currency symbol",@"Manage your expenses",@"Manage your income"]] forKeys:@[@"title",@"options"]];
    NSDictionary* reportOptions = [[NSDictionary alloc]initWithObjects:@[@"Analyse your wallet",@[@"Wallet per month report",@"Expenses per month",@"Income per month"]] forKeys:@[@"title",@"options"]];
    optionsDataSource = [[NSArray alloc]initWithObjects:manageOptions,reportOptions, nil];
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
}

/**
 This method is used whenever the user wants to change the current balance in his bank account, or to tell him to do so on the first launch of the app
 */

-(void)initialiseTheBankAccount
{
    // First, check if this is the first launch for the app, hence show the popup controller for adjusting the initial amount in the bank account.
    // The value of the bank account amount entered by the user will be simply stored inside the NSUserDefaults
    if(![userDefaults objectForKey:consBankAccountUserDefaultsKey])
    {
        // This means that the user never setteled the bank account amount, hence he needs to initially put the amount he has at the moment.
        [self performSegueWithIdentifier:@"enterBankAccountAmountSeg" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [optionsDataSource count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[optionsDataSource objectAtIndex:section] objectForKey:@"options"] count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[optionsDataSource objectAtIndex:section] objectForKey:@"title"];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"optionsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    UIView *backView = [[UIView alloc] init];
    
    backView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:168.0/255.0 blue:194.0/255.0 alpha:1.0];
    
    cell.selectedBackgroundView = backView;
    
    [[cell textLabel]setText:[[[optionsDataSource objectAtIndex:indexPath.section] objectForKey:@"options"] objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The user selected a certain option, and we need to deal accordingly.
    if(indexPath.section == 0)
    {
        // The user chose a managing option
        if(indexPath.row == 0)
        {
            // The user wants to change his bank account amount.
            [self performSegueWithIdentifier:@"enterBankAccountAmountSeg" sender:self];
        }else if(indexPath.row == 1)
        {
            // The user wants to change his preferred currency symbol.
            [self performSegueWithIdentifier:@"enterCurrencySeg" sender:self];
        }else if(indexPath.row == 2)
        {
            // The user wants to manage his expenses.
            [self performSegueWithIdentifier:@"expensesSeg" sender:self];
        }else if(indexPath.row == 3)
        {
            // The user wants to manage his expenses.
            [self performSegueWithIdentifier:@"incomeSeg" sender:self];
        }
        
    }else if(indexPath.section == 1)
    {
        // The user chose a reporting option
        if(indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"walletReportSeg" sender:self];
        }else
        {
            [genRepLabel setFrame:CGRectMake(genRepLabel.frame.origin.x, genRepLabel.frame.origin.y-[[UIScreen mainScreen] bounds].size.height, genRepLabel.frame.size.width, genRepLabel.frame.size.height)];
            
            [datePicker setFrame:CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y+[[UIScreen mainScreen] bounds].size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
            
            [dateBackLabel setFrame:CGRectMake(dateBackLabel.frame.origin.x, dateBackLabel.frame.origin.y+[[UIScreen mainScreen] bounds].size.height, dateBackLabel.frame.size.width, dateBackLabel.frame.size.height)];
            
            [wSubBtn setFrame:CGRectMake(wSubBtn.frame.origin.x, wSubBtn.frame.origin.y+[[UIScreen mainScreen] bounds].size.height/2, wSubBtn.frame.size.width, wSubBtn.frame.size.height)];
            
            [wCancelBtn setFrame:CGRectMake(wCancelBtn.frame.origin.x, wCancelBtn.frame.origin.y+[[UIScreen mainScreen] bounds].size.height/2, wCancelBtn.frame.size.width, wCancelBtn.frame.size.height)];
            
            [UIView animateWithDuration:0.3f animations:^{
                [datePickerView setAlpha:1.0f];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f animations:^{
                    [genRepLabel setFrame:CGRectMake(genRepLabel.frame.origin.x, genRepLabel.frame.origin.y+[[UIScreen mainScreen] bounds].size.height, genRepLabel.frame.size.width, genRepLabel.frame.size.height)];
                    
                    [datePicker setFrame:CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y-[[UIScreen mainScreen] bounds].size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
                    
                    [dateBackLabel setFrame:CGRectMake(dateBackLabel.frame.origin.x, dateBackLabel.frame.origin.y-[[UIScreen mainScreen] bounds].size.height, dateBackLabel.frame.size.width, dateBackLabel.frame.size.height)];
                    
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2f animations:^{
                        
                        [wSubBtn setFrame:CGRectMake(wSubBtn.frame.origin.x, wSubBtn.frame.origin.y-[[UIScreen mainScreen] bounds].size.height/2, wSubBtn.frame.size.width, wSubBtn.frame.size.height)];
                        
                        [wCancelBtn setFrame:CGRectMake(wCancelBtn.frame.origin.x, wCancelBtn.frame.origin.y-[[UIScreen mainScreen] bounds].size.height/2, wCancelBtn.frame.size.width, wCancelBtn.frame.size.height)];
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                    [UIView commitAnimations];
                }];
            }];
            
        }
    }
}


/**
 This method is used to hide the month/year date picker. This picker is shown whenever the user wants to see the reports (expenses or incomes) for a certain month.
 */
- (IBAction)cancelButtonClicked:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        
        [datePicker setFrame:CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y+[[UIScreen mainScreen] bounds].size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
        
        [dateBackLabel setFrame:CGRectMake(dateBackLabel.frame.origin.x, dateBackLabel.frame.origin.y+[[UIScreen mainScreen] bounds].size.height, dateBackLabel.frame.size.width, dateBackLabel.frame.size.height)];
        
        [wSubBtn setFrame:CGRectMake(wSubBtn.frame.origin.x, wSubBtn.frame.origin.y+[[UIScreen mainScreen] bounds].size.height/2, wSubBtn.frame.size.width, wSubBtn.frame.size.height)];
        
        [wCancelBtn setFrame:CGRectMake(wCancelBtn.frame.origin.x, wCancelBtn.frame.origin.y+[[UIScreen mainScreen] bounds].size.height/2, wCancelBtn.frame.size.width, wCancelBtn.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 delay:0.0 options:0
                         animations:^{
                             [datePickerView setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             [datePicker setFrame:CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y-[[UIScreen mainScreen] bounds].size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
                             
                             [dateBackLabel setFrame:CGRectMake(dateBackLabel.frame.origin.x, dateBackLabel.frame.origin.y-[[UIScreen mainScreen] bounds].size.height, dateBackLabel.frame.size.width, dateBackLabel.frame.size.height)];
                             
                             [wSubBtn setFrame:CGRectMake(wSubBtn.frame.origin.x, wSubBtn.frame.origin.y-[[UIScreen mainScreen] bounds].size.height/2, wSubBtn.frame.size.width, wSubBtn.frame.size.height)];
                             
                             [wCancelBtn setFrame:CGRectMake(wCancelBtn.frame.origin.x, wCancelBtn.frame.origin.y-[[UIScreen mainScreen] bounds].size.height/2, wCancelBtn.frame.size.width, wCancelBtn.frame.size.height)];
                             
                             [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
                         }];
        [UIView commitAnimations];
    }];
    
}

/**
 This method is used to generate the report (expenses or incomes) for a certain month selected by the user.
 */
- (IBAction)generateMonthReportClicked:(id)sender
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar1 = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    unsigned unitFlags1 = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components1 = [calendar1 components: unitFlags1 fromDate: currentDate];
    int minMonth = [[NSNumber numberWithInteger:[components1 month]] intValue];
    int minYear  = [[NSNumber numberWithInteger:[components1 year]] intValue];
    
    
    
    NSDate *dateFromPicker = [datePicker date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [calendar components: unitFlags fromDate: dateFromPicker];
    
    int maxMonth = [[NSNumber numberWithInteger:[components month]] intValue];
    int maxYear = [[NSNumber numberWithInteger:[components year]] intValue];
    
    NSMutableArray* monthsSummary = [Transaction loadTransactions:minMonth minYear:minYear maxMonth:maxMonth maxYear:maxYear];
    monthSummary = [monthsSummary lastObject];
    [UIView animateWithDuration:0.3f animations:^{
        
        [datePicker setFrame:CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y+[[UIScreen mainScreen] bounds].size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
        
        [dateBackLabel setFrame:CGRectMake(dateBackLabel.frame.origin.x, dateBackLabel.frame.origin.y+[[UIScreen mainScreen] bounds].size.height, dateBackLabel.frame.size.width, dateBackLabel.frame.size.height)];
        
        [wSubBtn setFrame:CGRectMake(wSubBtn.frame.origin.x, wSubBtn.frame.origin.y+[[UIScreen mainScreen] bounds].size.height/2, wSubBtn.frame.size.width, wSubBtn.frame.size.height)];
        
        [wCancelBtn setFrame:CGRectMake(wCancelBtn.frame.origin.x, wCancelBtn.frame.origin.y+[[UIScreen mainScreen] bounds].size.height/2, wCancelBtn.frame.size.width, wCancelBtn.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 delay:0.0 options:0
                         animations:^{
                             [datePickerView setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             [datePicker setFrame:CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y-[[UIScreen mainScreen] bounds].size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
                             
                             [dateBackLabel setFrame:CGRectMake(dateBackLabel.frame.origin.x, dateBackLabel.frame.origin.y-[[UIScreen mainScreen] bounds].size.height, dateBackLabel.frame.size.width, dateBackLabel.frame.size.height)];
                             
                             [wSubBtn setFrame:CGRectMake(wSubBtn.frame.origin.x, wSubBtn.frame.origin.y-[[UIScreen mainScreen] bounds].size.height/2, wSubBtn.frame.size.width, wSubBtn.frame.size.height)];
                             
                             [wCancelBtn setFrame:CGRectMake(wCancelBtn.frame.origin.x, wCancelBtn.frame.origin.y-[[UIScreen mainScreen] bounds].size.height/2, wCancelBtn.frame.size.width, wCancelBtn.frame.size.height)];
                             [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
                         }];
        [UIView commitAnimations];
        
        [self performSegueWithIdentifier:@"monthReportSeg" sender:self];
    }];
}


@end
