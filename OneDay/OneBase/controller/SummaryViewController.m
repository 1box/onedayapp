//
//  SummaryViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-13.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "SummaryViewController.h"
#import "AddonData.h"
#import "PCLineChartView.h"
#import "KMTableView.h"
#import "DailyDoManager.h"
#import "SummaryCellView.h"
#import "KMDateUtils.h"

#define LineChartHeight 220.f


@interface SummaryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) IBOutlet KMTableView *summaryList;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) PCLineChartView *lineChart;

@property (nonatomic) NSArray *lineComponents;
@property (nonatomic) NSArray *summaryDos;
@end


@implementation SummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lineChart = [[PCLineChartView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self.view), LineChartHeight)];
    [self prepareDataSource];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateTitle];
    [_summaryList reloadData];
}

- (void)pullBack
{
    [self renderPullBack:self.summaryList];
}

#pragma mark - private

- (void)updateTitle
{
    NSString *title = @"";
    switch (_type) {
        case SummaryViewTypeMonth:
            title = NSLocalizedString(@"CashMonthSummaryTitle", nil);
            break;
            case SummaryViewTypeYear:
            title = NSLocalizedString(@"CashYearSummaryTitle", nil);
            break;
        default:
            break;
    }
    self.navigationItem.title = title;
}

- (void)prepareDataSource
{
    NSMutableArray *mutLineComponents = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *summaryCashes = [NSMutableArray arrayWithCapacity:12];
    
    __block CGFloat minSummary = -40.f;
    __block CGFloat maxSummary = 100.f;
    
    switch (_type) {
        case SummaryViewTypeMonth:
        {
            self.summaryDos = [[DailyDoManager sharedManager] monthlyDosForAddon:_addon year:[NSDate date]];
            NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:12];
            for (int i=0; i<12; i++) {
                [xLabels addObject:[NSNumber numberWithInt:i+1]];
            }
            [_lineChart setXLabels:xLabels];
            
            __block int lastMonth = 1;
            [_summaryDos enumerateObjectsUsingBlock:^(MonthlyDo *monthlyDo, NSUInteger idx, BOOL *stop) {
                for (int i=lastMonth; i < (monthlyDo.currentMonth.month - idx); i ++) {
                    [summaryCashes addObject:@0];
                }
                [summaryCashes addObject:[NSNumber numberWithFloat:monthlyDo.summary]];
                lastMonth = monthlyDo.currentMonth.month;
                minSummary = MIN(minSummary, monthlyDo.summary);
                maxSummary = MAX(maxSummary, monthlyDo.summary);
            }];
            
            if ([summaryCashes count] < 12) {
                for (int i=[summaryCashes count]; i<12; i++) {
                    [summaryCashes addObject:@0];
                }
            }
            
        }
            break;
        case SummaryViewTypeYear:
        {
            self.summaryDos = [[DailyDoManager sharedManager] yearlyDosForAddon:_addon];
            
            NSMutableArray *mutXLabels = [NSMutableArray arrayWithCapacity:[_summaryDos count]];
            
            int ealiestYear = ((YearlyDo *)[_summaryDos lastObject]).currentYear.year;
            int latestYear = ((YearlyDo *)[_summaryDos objectAtIndex:0]).currentYear.year;
            for (int i=ealiestYear; i < latestYear; i++) {
                [mutXLabels addObject:[NSString stringWithFormat:@"%d", i]];
            }
            [_lineChart setXLabels:mutXLabels];
            
            __block int lastYear = ealiestYear;
            [_summaryDos enumerateObjectsUsingBlock:^(YearlyDo *yearlyDo, NSUInteger idx, BOOL *stop) {
                for (int i=lastYear; i < (yearlyDo.currentYear.year - idx); i ++) {
                    [summaryCashes addObject:@0];
                }
                [summaryCashes addObject:[NSNumber numberWithFloat:yearlyDo.summary]];
                lastYear = yearlyDo.currentYear.year;
                minSummary = MIN(minSummary, yearlyDo.summary);
                maxSummary = MAX(maxSummary, yearlyDo.summary);
            }];
            
//            if ([summaryCashes count] < [mutXLabels count]) {
//                for (int i=[summaryCashes count]; i<[mutXLabels count]; i++) {
//                    [summaryCashes addObject:@0];
//                }
//            }
        }
            break;
            
        default:
            break;
    }
    
    PCLineChartViewComponent *component = [[PCLineChartViewComponent alloc] init];
    component.shouldLabelValues = NO;
    [component setTitle:@""];
    [component setPoints:[summaryCashes copy]];
    [component setColour:PCColorDefault];
    [mutLineComponents addObject:component];
    
    self.lineComponents = [mutLineComponents copy];
    [_lineChart setComponents:[_lineComponents mutableCopy]];
    
    int range = MAX(abs(roundNumberFloor(minSummary)), abs(roundNumberCeil(maxSummary)));
    _lineChart.minValue = -1*range;
    _lineChart.maxValue = range;
    _lineChart.interval = (range*2)/4;
    _lineChart.yLabelFont = [UIFont boldSystemFontOfSize:10.f];
    
    NSMutableDictionary *mapping = [NSMutableDictionary dictionaryWithCapacity:5];
    for (int i=_lineChart.minValue; i<=_lineChart.maxValue; i+=_lineChart.interval) {
        NSString *mappingValue = @"";
        if (abs(i/1000000000) > 1) {
            mappingValue = [NSString stringWithFormat:@"%db", i/1000000000];
        }
        else if (abs(i/1000000) > 1) {
            mappingValue = [NSString stringWithFormat:@"%dm", i/1000000];
        }
        else if (abs(i/1000) > 1) {
            mappingValue = [NSString stringWithFormat:@"%dk", i/1000];
        }
        else {
            mappingValue = [NSString stringWithFormat:@"%d", i];
        }
        [mapping setObject:mappingValue forKey:[NSNumber numberWithInteger:i]];
    }
    _lineChart.mappedYLabels = [mapping copy];
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_summaryDos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *summaryCellID = @"SummaryCellID";
    
    SummaryCellView *cell = [tableView dequeueReusableCellWithIdentifier:summaryCellID];
    if (indexPath.row < [_summaryDos count]) {
        switch (_type) {
            case SummaryViewTypeMonth:
            {
                MonthlyDo *summaryDo = [_summaryDos objectAtIndex:indexPath.row];
                cell.dateLabel.text = [[YearToDayFormatter() shortMonthSymbols] objectAtIndex:summaryDo.currentMonth.month - 1];
                cell.summaryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CashMonthSummaryText", nil), summaryDo.summary];
            }
                break;
            case SummaryViewTypeYear:
            {
                YearlyDo *summaryDo = [_summaryDos objectAtIndex:indexPath.row];
                cell.dateLabel.text = [NSString stringWithFormat:@"%d", summaryDo.currentYear.year];
                cell.summaryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CashYearSummaryText", nil), summaryDo.summary];
            }
                break;
                
            default:
                break;
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _lineChart;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return LineChartHeight;
    }
    else {
        return 0.f;
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *ret = @"";
//    switch (_type) {
//        case SummaryViewTypeMonth:
//            ret = NSLocalizedString(@"CashMonthSummaryTitle", nil);
//            break;
//        case SummaryViewTypeYear:
//            ret = NSLocalizedString(@"CashYearSummaryTitle", nil);
//            break;
//            
//        default:
//            break;
//    }
//    return ret;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_summaryList updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_summaryDos count]) {
        KMCheckboxTableCell *cell = (KMCheckboxTableCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.checked = !cell.isChecked;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_summaryList updateBackgroundViewForCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeSelected];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in tableView.visibleCells) {
        [_summaryList updateBackgroundViewForCell:tCell atIndexPath:[tableView indexPathForCell:tCell] backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
    }
}

@end
