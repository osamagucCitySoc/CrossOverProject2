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
@import Charts;

@interface WalletReportViewController ()<ChartViewDelegate>

@end

@implementation WalletReportViewController
{
    __weak IBOutlet HorizontalBarChartView *_chartView;
    NSUserDefaults* userDefaults;
    NSArray* monthNames;
    NSMutableArray* mainDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initVariables];
}


-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    // We create a list of the months names
    monthNames = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    
    // We get all the saved transactions (whether exepenses or incomes grouped by the month).
    [self loadTransactions];
    
    // We adjust the bar chart based on the values we got from above
    [self adjustBarChart];
}

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
    
    NSPredicate *transactionFilter = [NSPredicate predicateWithFormat:@"(month >= %i AND year = %i) OR (month <= %i AND year = %i)", minMonth,minYear,minMonth,maxYear];
    
    // Now we get all the saved transactions between a period of one year starting from the current month.
    NSArray* allTransactions = [Transaction MR_findAllSortedBy:@"year,month" ascending:YES withPredicate:transactionFilter inContext:[NSManagedObjectContext MR_defaultContext]];
    
    
    // Assumption is, the current bank account amount is the current amount the user has at this moment. So it will be the initial starting point value.
    float startingAmount = [[userDefaults objectForKey:consBankAccountUserDefaultsKey] floatValue];
    
    // We then need to have a data source that will have the name of each month in the coming year, total expenses in this month, total incomes in this month, the estimated balance by end of this month.
    // First, we initialise this data source
    mainDataSource = [[NSMutableArray alloc]init];
    NSMutableDictionary* mainDataSourceHelper = [[NSMutableDictionary alloc]init];
    // Second, we fill it with dictionaries only having the name of the 12 period months with expenses, incomes and balance are set to 0
    for(int i = minMonth ; i <= 12 ; i++)
    {
        NSMutableDictionary* monthSummary = [[NSMutableDictionary alloc]initWithObjects:@[[NSString stringWithFormat:@"%i-%i",i,minYear],@(0),@(0),@(0),@(mainDataSourceHelper.count)] forKeys:@[@"title",@"expenses",@"incomes",@"endBalance",@"orderingKey"]];
        [mainDataSourceHelper setValue:monthSummary forKey:[NSString stringWithFormat:@"%i-%i",i,minYear]];
    }
    for(int i = 1 ; i < minMonth ; i++)
    {
        NSMutableDictionary* monthSummary = [[NSMutableDictionary alloc]initWithObjects:@[[NSString stringWithFormat:@"%i-%i",i,maxYear],@(0),@(0),@(0),@(mainDataSourceHelper.count)] forKeys:@[@"title",@"expenses",@"incomes",@"endBalance",@"orderingKey"]];
        [mainDataSourceHelper setValue:monthSummary forKey:[NSString stringWithFormat:@"%i-%i",i,maxYear]];
    }

    
    // Now we need to calculate for each month in the coming year what will be the expenses and the incomes and hence, the ending balance by this month. This will use the results fetched from the database above.
    if([allTransactions count]>0)
    {
        // This means, we have at least one transaction and we need to update the values (expenses and the incomes and hence, the ending balance) for each month accordingly.
        
        // First, we fill in the total expenses and incomes for each month based on the transactions stored
        for(Transaction* transaction in allTransactions)
        {
            NSString* transactionMonth = [NSString stringWithFormat:@"%i-%i",transaction.month.intValue,transaction.year.intValue];
            NSMutableDictionary* monthSummary = [mainDataSourceHelper objectForKey:transactionMonth];
            float monthSummaryExpenses = [[monthSummary objectForKey:@"expenses"] floatValue];
            float monthSummaryIncomes = [[monthSummary objectForKey:@"incomes"] floatValue];
            
            
            // Then we need to check if it is a one time event or a recurring event.
            if(transaction.recurring.intValue == 0)
            {
                // Then this is a one time event, hence, only affects its month.
                if(transaction.amount.floatValue < 0)
                {
                    monthSummaryExpenses += transaction.amount.floatValue;
                }else
                {
                    monthSummaryIncomes += transaction.amount.floatValue;
                }
                [monthSummary setValue:@(monthSummaryExpenses) forKey:@"expenses"];
                [monthSummary setValue:@(monthSummaryIncomes) forKey:@"incomes"];
                [mainDataSourceHelper setObject:monthSummary forKey:transactionMonth];
            }else
            {
                // Then this is a recurring event and need to affect this month and all coming ones.
                int orderingKey = [[monthSummary objectForKey:@"orderingKey"] intValue];
                for(NSString* key in [mainDataSourceHelper allKeys])
                {
                    if([[[mainDataSourceHelper objectForKey:key] objectForKey:@"orderingKey"] floatValue] >= orderingKey)
                    {
                        if(transaction.amount.floatValue < 0)
                        {
                            [[mainDataSourceHelper objectForKey:key] setValue:@([[mainDataSourceHelper objectForKey:@"expenses"] floatValue]+transaction.amount.floatValue) forKey:@"expenses"];
                        }else
                        {
                            [[mainDataSourceHelper objectForKey:key] setValue:@([[mainDataSourceHelper objectForKey:@"incomes"] floatValue]+transaction.amount.floatValue) forKey:@"expenses"];
                        }
                    }
                }
            }
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"orderingKey"  ascending:YES];
        mainDataSource = [[NSMutableArray alloc]initWithArray:[[mainDataSourceHelper allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
        
        // Then we need to set the balance by the end of each month.
        for(int i = 0 ;i < mainDataSource.count ; i++)
        {
            startingAmount += [[[mainDataSource objectAtIndex:i] objectForKey:@"expenses"] floatValue];
            startingAmount += [[[mainDataSource objectAtIndex:i] objectForKey:@"incomes"] floatValue];
            [[mainDataSource objectAtIndex:i] setValue:@(startingAmount) forKey:@"endBalance"];
        }
    }else
    {
        // This means, we have no transactions stored and hence, all the values can be filled by default value with expenses = 0, incomes = 0 and total balance for each month is the starting amount.
        for(int i = 0 ;i < mainDataSource.count ; i++)
        {
            [[mainDataSource objectAtIndex:i] setValue:@(startingAmount) forKey:@"endBalance"];
        }
    }
}

-(void)adjustBarChart
{
    NSNumberFormatter *customFormatter = [[NSNumberFormatter alloc] init];
    customFormatter.negativePrefix = @"-";
    customFormatter.positivePrefix = @"+";
    
    customFormatter.minimumSignificantDigits = 1;
    customFormatter.minimumFractionDigits = 1;
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    // scaling can now only be done on x- and y-axis separately
    _chartView.pinchZoomEnabled = NO;
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.startAtZeroEnabled = NO;
    _chartView.rightAxis.customAxisMax = 25.0;
    _chartView.rightAxis.customAxisMin = -25.0;
    _chartView.rightAxis.drawGridLinesEnabled = NO;
    _chartView.rightAxis.drawZeroLineEnabled = YES;
    _chartView.rightAxis.labelCount = 7;
    _chartView.rightAxis.valueFormatter = customFormatter;
    _chartView.rightAxis.labelFont = [UIFont systemFontOfSize:9.f];
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.drawAxisLineEnabled = NO;
    _chartView.rightAxis.labelFont = [UIFont systemFontOfSize:9.f];
    
    ChartLegend *l = _chartView.legend;
    l.position = ChartLegendPositionBelowChartRight;
    l.formSize = 8.f;
    l.formToTextSpace = 4.f;
    l.xEntrySpace = 6.f;
    
    NSMutableArray *yValues = [NSMutableArray array];
    for(int i = 0 ; i < mainDataSource.count ; i++)
    {
        
    }
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-10, @10 ] xIndex: 0]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-12, @13 ] xIndex: 1]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-15, @15 ] xIndex: 2]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-17, @17 ] xIndex: 3]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-19, @20 ] xIndex: 4]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-19, @19 ] xIndex: 5]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-16, @16 ] xIndex: 6]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-13, @14 ] xIndex: 7]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-10, @11 ] xIndex: 8]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-5, @6 ] xIndex: 9]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-1, @2 ] xIndex: 10]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-1, @2 ] xIndex: 11]];
    
    BarChartDataSet *set = [[BarChartDataSet alloc] initWithYVals:yValues label:@"Wallet Distribution"];
    set.valueFormatter = customFormatter;
    set.valueFont = [UIFont systemFontOfSize:7.f];
    set.axisDependency = AxisDependencyRight;
    set.barSpace = 0.4f;
    set.colors = @[
                   [UIColor colorWithRed:67/255.f green:67/255.f blue:72/255.f alpha:1.f],
                   [UIColor colorWithRed:124/255.f green:181/255.f blue:236/255.f alpha:1.f]
                   ];
    set.stackLabels = @[
                        @"Total Exepenses", @"Totla Incomings"
                        ];
    
    NSArray *xVals = @[ @"January\nPSAMA",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December" ];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSet:set];
    _chartView.data = data;
    [_chartView animateWithYAxisDuration:3.0];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected, dataSetIndex %ld, stack-index %ld",(long)dataSetIndex, (long)highlight.stackIndex);
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}


@end
