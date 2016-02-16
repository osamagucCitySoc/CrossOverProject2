//
//  MonthReportViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "MonthReportViewController.h"
@import Charts;

@interface MonthReportViewController ()<ChartViewDelegate>

@end

@implementation MonthReportViewController
{
    __weak IBOutlet PieChartView *_chartView;
}

@synthesize reportType,monthData;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chartView.usePercentValuesEnabled = YES;
    _chartView.holeTransparent = YES;
    _chartView.holeRadiusPercent = 0.58;
    _chartView.transparentCircleRadiusPercent = 0.61;
    _chartView.descriptionText = @"";
    [_chartView setExtraOffsetsWithLeft:5.f top:10.f right:5.f bottom:5.f];
    
    _chartView.drawCenterTextEnabled = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@ Report",[monthData objectForKey:@"title"],reportType]];
    _chartView.centerAttributedText = centerText;
    
    _chartView.drawHoleEnabled = YES;
    _chartView.rotationAngle = 0.0;
    _chartView.rotationEnabled = YES;
    _chartView.highlightPerTapEnabled = YES;
    
    ChartLegend *l =_chartView.legend;
    l.position = ChartLegendPositionRightOfChart;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;
    
    
    _chartView.delegate = self;
    
    [self generateData];
    
    [_chartView animateWithYAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
}


- (void)generateData
{
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    NSMutableDictionary* categories;
    float totalValue;
    if([reportType isEqualToString:@"Expenses"])
    {
        categories = [[monthData objectForKey:@"tags"] objectForKey:@"expensesCategories"];
        totalValue = (-[[monthData objectForKey:@"expenses"] floatValue]);
    }else
    {
        categories = [[monthData objectForKey:@"tags"] objectForKey:@"incomesCategories"];
        totalValue = [[monthData objectForKey:@"incomes"] floatValue];
    }
    
    
    for (int i = 0; i < [categories allKeys].count; i++)
    {
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:[[categories objectForKey:[categories.allKeys objectAtIndex:i]] floatValue] xIndex:i]];
        [xVals addObject:categories.allKeys[i]];
        totalValue -= [[categories objectForKey:[categories.allKeys objectAtIndex:i]] floatValue];
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        [colors addObject:color];
    }
    
    
    [yVals addObject:[[BarChartDataEntry alloc] initWithValue:totalValue xIndex:categories.count]];
    [xVals addObject:@"One time"];
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    [colors addObject:color];

    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals label:[reportType stringByAppendingString:@" Decomposition"]];
    dataSet.sliceSpace = 2.0;
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:pFormatter];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:UIColor.whiteColor];
    
    _chartView.data = data;
    [_chartView highlightValues:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
