//
//  MonthReportViewController.m
//  CrossOverProject
//
//  Created by Osama Rabie on 2/16/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "MonthReportViewController.h"
#import "PNChart.h"

@interface MonthReportViewController ()

@end

@implementation MonthReportViewController
{
    __weak IBOutlet UIView *chartViewContainer;
    PNPieChart *_chartView;
}

@synthesize reportType,monthData;

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self generateData];
}

/**
 This method is used to generate the data for the PIE chart using the passed month details and also to setup the UI of the pie chart itself.
 */

- (void)generateData
{
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    // First, we add all the tags and their associated values.
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
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        [yVals addObject:[PNPieChartDataItem dataItemWithValue:[[categories objectForKey:[categories.allKeys objectAtIndex:i]] floatValue] color:color description:categories.allKeys[i]]];
        totalValue -= [[categories objectForKey:[categories.allKeys objectAtIndex:i]] floatValue];
    }
    
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    [yVals addObject:[PNPieChartDataItem dataItemWithValue:totalValue color:color description:@"One Time"]];
    
    _chartView = [[PNPieChart alloc] initWithFrame:chartViewContainer.frame items:yVals];
    _chartView.descriptionTextColor = [UIColor blackColor];
    _chartView.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
    _chartView.descriptionTextShadowColor = [UIColor whiteColor];
    _chartView.showAbsoluteValues = NO;
    _chartView.showOnlyValues = NO;
    [_chartView strokeChart];

    [chartViewContainer addSubview:_chartView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
