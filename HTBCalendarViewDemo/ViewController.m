//
//  ViewController.m
//  HTBCalendarViewDemo
//
//  Created by Mark Aufflick on 26/11/2013.
//  Copyright (c) 2013 The High Technology Group. All rights reserved.
//

#import "ViewController.h"
#import "HTBCalendarView.h"
#import "CalendarCell.h"

@interface ViewController () <UICollectionViewDelegate, HTBCalendarViewDelegate, HTBCalendarHeaderViewDelegate>
{
    NSCalendar * calendar;
}

@property (weak, nonatomic) IBOutlet HTBCalendarView * calendarView;
@property (weak, nonatomic) IBOutlet HTBCalendarHeaderView *calendarHeaderView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // if you're creating the calendar view in a nib/storyboard (as this demo does)
    // you need to assign the delegate in the nib/storyboard or it won't be done early enough.
    // if you're creating it in code, use initWithDelegate.
    
    //self.calendarView.delegate = self;
    self.calendarView.collectionViewDelegate = self;
    self.calendarHeaderView.delegate = self;

    calendar = [NSCalendar currentCalendar];
    self.calendarView.calendar = calendar;
    self.calendarView.firstDayOfWeek = 1;
    self.calendarView.backgroundColor = [UIColor whiteColor];
    
    self.calendarView.headerView = self.calendarHeaderView;
    self.calendarHeaderView.calendarView = self.calendarView;
    
    // do this after connecting header view, or the inital month/year headers won't show
    self.calendarView.monthYearShowing = [NSDate date];
}

#pragma mark - HTBCalendarView/UICollectionViewDelegate

- (Class)calendarViewCellClass:(HTBCalendarView *)calendarView
{
    return [CalendarCell class];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell * cell = (CalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];

    NSLog(@"did tap cell at indexpath: %@ (%@)", indexPath, cell);
}

- (void)calendarView:(HTBCalendarView *)calendarView updateCell:(HTBCalendarViewCell *)cell forDate:(NSDate *)date
{
    // this is where you would update content based on some external data
    NSDateComponents * components = [calendar components:NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    ((CalendarCell *)cell).ticked = components.day % 2 == 0;
    
    // date intrinsic formatting (eg. colouring weekends) can go in the calendar cell subclass    
}

#pragma mark - HTBCalendarHeaderViewDelegate

- (void)calendarViewHeaderView:(HTBCalendarHeaderView *)headerView styleNewMonthLabel:(UILabel *)label
{
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
}

- (void)calendarViewHeaderView:(HTBCalendarHeaderView *)headerView styleNewYearLabel:(UILabel *)label
{
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
}

- (void)calendarViewHeaderViewDidTapMonth:(HTBCalendarHeaderView *)headerView
{
    self.calendarView.monthYearShowing = [NSDate date];
}

- (void)calendarViewHeaderViewDidTapYear:(HTBCalendarHeaderView *)headerView
{
    self.calendarView.monthYearShowing = [NSDate date];
}


@end
