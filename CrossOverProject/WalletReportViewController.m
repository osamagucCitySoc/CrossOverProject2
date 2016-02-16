//
//  WalletReportViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "WalletReportViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Transaction.h"
#import "Constants.h"
#import "MonthReportViewController.h"


@interface WalletReportViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@end

@implementation WalletReportViewController
{

    __weak IBOutlet UITableView *tableVieww;
    NSUserDefaults* userDefaults/** @param Instance of the NSUserDefaults.*/;
    NSArray* monthNames;
    NSMutableArray* mainDataSource;
    float maxExpense/** @param used to propoerly and dynamically set the minimum X value on the chart.*/;
    float maxIncome/** @param used to propoerly and dynamically set the maximum X value on the chart.*/;;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"expensesReportSeg"])
    {
        MonthReportViewController* dst = (MonthReportViewController*)[segue destinationViewController];
        [dst setReportType:@"Expenses"];
        [dst setMonthData:[mainDataSource objectAtIndex:tableVieww.indexPathForSelectedRow.section]];
    }else if([[segue identifier]isEqualToString:@"incomesReportSeg"])
    {
        MonthReportViewController* dst = (MonthReportViewController*)[segue destinationViewController];
        [dst setReportType:@"Incomes"];
        [dst setMonthData:[mainDataSource objectAtIndex:tableVieww.indexPathForSelectedRow.section]];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initVariables];
}

/**
 This method is used to initialise the inner variables and views used by this controller.
 */
-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    maxExpense = 0;
    maxIncome = 0;
    // We create a list of the months names
    monthNames = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    
    // We get all the saved transactions (whether exepenses or incomes grouped by the month).
    [self loadTransactions];
}

/**
 This method is used to load the monthly summary for a period of a one year.
 */
-(void)loadTransactions
{
    // We need to display the total expenses and incomes for each month Then the query will get all entries for all months and then they will be grouped.
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [calendar components: unitFlags fromDate: currentDate];
    int minMonth = [[NSNumber numberWithInteger:[components month]] intValue];
    int minYear  = [[NSNumber numberWithInteger:[components year]] intValue];
    int maxYear  = minYear+1;
    
    mainDataSource = [Transaction loadTransactions:minMonth minYear:minYear maxMonth:(minMonth-1) maxYear:maxYear];
    
    for(int i = 0 ;i < mainDataSource.count ; i++)
    {
        if([[[mainDataSource objectAtIndex:i] objectForKey:@"expenses"] floatValue]<maxExpense)
        {
            maxExpense = [[[mainDataSource objectAtIndex:i] objectForKey:@"expenses"] floatValue];
        }
        if([[[mainDataSource objectAtIndex:i] objectForKey:@"incomes"] floatValue]>maxIncome)
        {
            maxIncome = [[[mainDataSource objectAtIndex:i] objectForKey:@"incomes"] floatValue];
        }
    }
    
    [tableVieww setDataSource:self];
    [tableVieww setDelegate:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return mainDataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"walletCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath
                             ];
    NSDictionary* monthSummary = [mainDataSource objectAtIndex:indexPath.section];
    
    [[(UILabel*)cell viewWithTag:1]setText:[NSString stringWithFormat:@"%0.2f %@",[[monthSummary objectForKey:@"expenses"] floatValue],[userDefaults objectForKey:consCurrencyUserDefaultsKey]]];
    
    [[(UILabel*)cell viewWithTag:2]setText:[NSString stringWithFormat:@"+%0.2f %@",[[monthSummary objectForKey:@"incomes"] floatValue],[userDefaults objectForKey:consCurrencyUserDefaultsKey]]];
    
    [[(UILabel*)cell viewWithTag:3]setText:[NSString stringWithFormat:@"End balance : %0.2f %@",[[monthSummary objectForKey:@"endBalance"] floatValue],[userDefaults objectForKey:consCurrencyUserDefaultsKey]]];
    
    return cell;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary* monthSummary = [mainDataSource objectAtIndex:section];
    return [NSString stringWithFormat:@"Summary for : %@",[monthSummary objectForKey:@"title"]];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Expenses report",@"Incomes report", nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}


#pragma mark UIActionSheetDelegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)
    {
        if(buttonIndex == 0)
        {
            // Expenses report
            [self performSegueWithIdentifier:@"expensesReportSeg" sender:self];
        }else if(buttonIndex == 1)
        {
            // Incomes report
            [self performSegueWithIdentifier:@"incomesReportSeg" sender:self];
        }
    }
}


@end
