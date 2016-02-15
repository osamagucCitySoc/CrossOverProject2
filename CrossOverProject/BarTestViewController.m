//
//  BarTestViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "BarTestViewController.h"

@interface BarTestViewController ()<ChartViewDelegate>

@end

@implementation BarTestViewController
{

    __weak IBOutlet HorizontalBarChartView *_chartView;
       
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Stacked Bar Chart Negative";
    
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
    
    NSArray *xVals = @[ @"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December" ];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSet:set];
    _chartView.data = data;
    [_chartView animateWithYAxisDuration:3.0];
}


- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i + 1990) stringValue]];
    }
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals3 = [[NSMutableArray alloc] init];
    
    double mult = range * 1000.f;
    
    for (int i = 0; i < count; i++)
    {
        double val = (double) (arc4random_uniform(mult) + 3.0);
        [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        val = (double) (arc4random_uniform(mult) + 3.0);
        [yVals2 addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        val = (double) (arc4random_uniform(mult) + 3.0);
        [yVals3 addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals1 label:@"Company A"];
    [set1 setColor:[UIColor colorWithRed:104/255.f green:241/255.f blue:175/255.f alpha:1.f]];
    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithYVals:yVals2 label:@"Company B"];
    [set2 setColor:[UIColor colorWithRed:164/255.f green:228/255.f blue:251/255.f alpha:1.f]];
    BarChartDataSet *set3 = [[BarChartDataSet alloc] initWithYVals:yVals3 label:@"Company C"];
    [set3 setColor:[UIColor colorWithRed:242/255.f green:247/255.f blue:158/255.f alpha:1.f]];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    [dataSets addObject:set3];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    data.groupSpace = 0.8;
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _chartView.data = data;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
