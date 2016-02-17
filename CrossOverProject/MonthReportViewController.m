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
    __weak IBOutlet UILabel *noViewLabel;;/** @param this is a no UIView will appear if there are no added expenses and incomes, hence no reports can be shown*/
    __weak IBOutlet UIView *noView;
    __weak IBOutlet UIView *chartViewContainer; /** @param an outlet for the view that holds the pie chart inside it. It is used to know the Frame where to add the pie chart*/
    __weak IBOutlet UILabel *backLabel;
    PNPieChart *_chartView;/** @param the pie chart that will be used to display the percentage of contributions for each category in the current months expenses/incomes.*/
}

@synthesize reportType,monthData;

- (void)viewDidLoad {
    [super viewDidLoad];
    [noView setHidden:YES];

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
    NSMutableDictionary* categories; // This will hold an array of dictionaries, where each dictionary will contain the name of the category and the total amount this category is putting (whether as an expense or income).
    float totalValue; // This is the total value of the (expenses or incomes) in this month. This data will be used to calculate the percentage of each category from the above. Also, it will be used to know the percentage of one time events (ones without categories) are putting.
    BOOL isExpenses = NO;
    if([reportType isEqualToString:@"Expenses"])
    {
        isExpenses = YES;
        categories = [[monthData objectForKey:@"tags"] objectForKey:@"expensesCategories"];
        totalValue = (-[[monthData objectForKey:@"expenses"] floatValue]);
    }else
    {
        categories = [[monthData objectForKey:@"tags"] objectForKey:@"incomesCategories"];
        totalValue = [[monthData objectForKey:@"incomes"] floatValue];
    }
    
    if (totalValue == 0)
    {
        [noView setHidden:NO];
        [noViewLabel setText:[NSString stringWithFormat:@"No %@ recorded for this month",reportType]];
    }
    else
    {
        [noView setHidden:YES];
        for (int i = 0; i < [categories allKeys].count; i++)
        {
            // Generate a random color for each slice in the pie chart
            CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
            UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
            
            [yVals addObject:[PNPieChartDataItem dataItemWithValue:[[categories objectForKey:[categories.allKeys objectAtIndex:i]] floatValue] color:color description:categories.allKeys[i]]];
            totalValue -= [[categories objectForKey:[categories.allKeys objectAtIndex:i]] floatValue];
        }
        
        UIColor *color;
        if (isExpenses)
        {
            color = [UIColor colorWithRed:199.0/255.0 green:38.0/255.0 blue:32.0/255.0 alpha:1.0];
        }
        else
        {
            color = [UIColor colorWithRed:54.0/255.0 green:169.0/255.0 blue:53.0/255.0 alpha:1.0];
        }
        
        [yVals addObject:[PNPieChartDataItem dataItemWithValue:totalValue color:color description:@"One Time"]];
        
        _chartView = [[PNPieChart alloc] initWithFrame:backLabel.frame items:yVals];
        _chartView.descriptionTextColor = [UIColor whiteColor];
        _chartView.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
        _chartView.descriptionTextShadowColor = [UIColor clearColor];
        _chartView.showAbsoluteValues = NO;
        _chartView.showOnlyValues = NO;
        [_chartView strokeChart];
        
        [chartViewContainer addSubview:_chartView];
        chartViewContainer.frame = backLabel.frame;
        _chartView.frame = CGRectMake(_chartView.frame.origin.x-28, _chartView.frame.origin.y-60, _chartView.frame.size.width, _chartView.frame.size.height);
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 This method is called when the back button is clicked to dismiss the current view and get back to the caller.
 */
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
