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

@import Charts;

@interface WalletReportViewController ()<ChartViewDelegate,UIActionSheetDelegate>

@end

@implementation WalletReportViewController
{
    __weak IBOutlet HorizontalBarChartView *_chartView;
    NSUserDefaults* userDefaults;
    NSArray* monthNames;
    NSMutableArray* mainDataSource;
    float maxExpense;
    float maxIncome;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"expensesReportSeg"])
    {
        MonthReportViewController* dst = (MonthReportViewController*)[segue destinationViewController];
        [dst setReportType:@"Expenses"];
        ChartHighlight* highlighted = [[_chartView highlighted] lastObject];
        [dst setMonthData:[mainDataSource objectAtIndex:highlighted.xIndex]];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initVariables];
}


-(void)initVariables
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    maxExpense = 0;
    maxIncome = 0;
    // We create a list of the months names
    monthNames = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    
    // We get all the saved transactions (whether exepenses or incomes grouped by the month).
    [self loadTransactions];
    
    // We adjust the bar chart based on the values we got from above
    [self adjustBarChart];
}

-(void)loadTransactions
{
    mainDataSource = [Transaction loadTransactions];
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
    _chartView.pinchZoomEnabled = YES;
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.startAtZeroEnabled = NO;
    _chartView.rightAxis.customAxisMax = maxIncome+20;
    _chartView.rightAxis.customAxisMin = maxExpense-20;
    _chartView.rightAxis.drawGridLinesEnabled = NO;
    _chartView.rightAxis.drawZeroLineEnabled = YES;
    _chartView.rightAxis.labelCount = 10;
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
    NSMutableArray *xVals = [NSMutableArray array];
    for(int i = 0 ; i < mainDataSource.count ; i++)
    {
        [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ [[mainDataSource objectAtIndex:i] objectForKey:@"expenses"], [[mainDataSource objectAtIndex:i] objectForKey:@"incomes"]] xIndex:i]];
        [xVals addObject:[[[mainDataSource objectAtIndex:i] objectForKey:@"title"] stringByAppendingFormat:@"\n%0.2f",[[[mainDataSource objectAtIndex:i] objectForKey:@"endBalance"] floatValue]]];
    }
    
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
    
    
    
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSet:set];
    _chartView.data = data;
    [_chartView animateWithYAxisDuration:3.0];
    
    //[_chartView zoomIn];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected, dataSetIndex %ld, stack-index %ld",(long)dataSetIndex, (long)highlight.stackIndex);
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Expenses report",@"Incomes report", nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
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
