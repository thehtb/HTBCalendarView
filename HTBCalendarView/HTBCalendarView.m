//
//  HTBCalendarView.m
//  HTBCalendarViewTest
//
//  Created by Mark Aufflick on 26/07/13.
//  Copyright (c) 2013 The High Technology Bureau. All rights reserved.
//

#import "HTBCalendarView.h"

#define OneDay (24 * 60 * 60)

#define dateCellID @"dateCellID"

@interface HTBCalendarView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSInteger _currentYear;
    NSInteger daysPaddingAtStartOfYear;
    NSDateFormatter * monthExtractionDateFormatter;
    NSDateFormatter * dayExtractionDateFormatter;
    NSDateFormatter * ymdFormatter;
    NSCache * lastDayOfMonthCache;
    NSMutableArray * dateForIndexPathCache;
    NSDate * dateForFirstCell;
    NSString * currentMonthString; // TODO: need to clear this at midnight in case the month rolls over....
}

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;

- (void)setupViewHierarchy;

- (NSDate *)dateForFirstCell;
- (NSDate *)dateForLastCell;
- (NSInteger)numberOfDaysInWeek;
- (void)reloadCollectionView;
- (NSInteger)itemIndexForDate:(NSDate *)date;
- (NSDate *)firstDayOfMonth:(NSDate *)date;
- (NSDate *)lastDayOfMonth:(NSDate *)date;
- (BOOL)dateIsInCurrentMonth:(NSDate *)date;
- (BOOL)dateIsToday:(NSDate *)date;

@end

@implementation HTBCalendarView
{
    BOOL haveSetSize;
}

- (instancetype)initWithDelegate:(id<HTBCalendarViewDelegate>)delegate frame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) == nil)
        return nil;

    _delegate = delegate;
    [self setupViewHierarchy];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupViewHierarchy];
}

- (void)initDateCache
{
    for (int i=0; i<=400; i++)
        dateForIndexPathCache[i] = [NSNull null];
}

- (void)setupViewHierarchy
{
    _firstDayOfWeek = 1;
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.scrollEnabled = NO;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
    [self.collectionView registerClass:[self.delegate calendarViewCellClass:self] forCellWithReuseIdentifier:dateCellID];
    [self addSubview:self.collectionView];
    
    lastDayOfMonthCache = [[NSCache alloc] init];
    dateForIndexPathCache = [[NSMutableArray alloc] initWithCapacity:401];
    [self initDateCache];
    
    monthExtractionDateFormatter = [[NSDateFormatter alloc] init];
    monthExtractionDateFormatter.dateFormat = @"YYYY-MM";
    dayExtractionDateFormatter = [[NSDateFormatter alloc] init];
    dayExtractionDateFormatter.dateFormat = @"d";
    currentMonthString = [self monthForDate:[NSDate date]];
    ymdFormatter = [[NSDateFormatter alloc] init];
    ymdFormatter.dateFormat = @"YYY-MM-dd";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;

    CGSize cellSize = (CGSize){ floor(self.collectionView.bounds.size.width / [self numberOfDaysInWeek]),
        floor(self.collectionView.bounds.size.height / 6) }; // ever need > 6 rows for other calendars??

    if (!CGSizeEqualToSize(cellSize, self.flowLayout.itemSize))
    {
        if (haveSetSize) // don't want animation the first time
        {
            // this is all a little hacky, but resizing cells is very slow if you do it during a rotation change animation.
            double delayInSeconds = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.flowLayout.itemSize = cellSize;
                [self performSelector:@selector(scrollToCurrentMonthAnimated:) withObject:nil afterDelay:0.2];
            });
        }
        else
        {
            haveSetSize = 1;
            self.flowLayout.itemSize = cellSize;
        }
    }
}

- (void)setCollectionViewDelegate:(id<UICollectionViewDelegate>)collectionViewDelegate
{
    self.collectionView.delegate = collectionViewDelegate;
}

- (id<UICollectionViewDelegate>)collectionViewDelegate
{
    return self.collectionView.delegate;
}

- (void)reloadCollectionView
{
    dateForFirstCell = nil;
    [self initDateCache];
    [self.collectionView reloadData];
    [self performSelector:@selector(scrollToCurrentMonthAnimated:) withObject:nil afterDelay:0.2];
}

- (void)scrollToCurrentMonthAnimated:(BOOL)animated
{
    if (self.calendar != nil && self.monthYearShowing != nil)
    {
        NSInteger index = [self itemIndexForDate:self.monthYearShowing];
        
        dispatch_block_t updateCells = ^{
            [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(HTBCalendarViewCell * cell, NSUInteger idx, BOOL *stop) {
                [self updateCell:cell forDate:cell.date];
            }];
        };
        
        if (animated)
        {
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:updateCells
                             completion:nil];
        }
        else
        {
            updateCells();
        }
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}

- (void)setMonthYearShowing:(NSDate *)monthYearShowing
{
    _monthYearShowing = monthYearShowing;
    
    NSDateComponents * c = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:monthYearShowing];
    
    if ([c year] != _currentYear)
    {
        if (_currentYear == 0)
        {
            _currentYear = [c year];
            [self.collectionView reloadData];
        }
        else
        {
            _currentYear = [c year];
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.alpha = 0;
                             } completion:^(BOOL finished) {
                                 [self reloadCollectionView];
                                 [UIView animateWithDuration:0.25
                                                  animations:^{
                                                      self.alpha = 1;
                                                  }];
                             }];
        }
    }
    else
    {
        [self scrollToCurrentMonthAnimated:YES];
    }
    
    self.headerView.monthYearToDisplay = monthYearShowing;
}

- (void)setCalendar:(NSCalendar *)calendar
{
    _calendar = calendar;
    monthExtractionDateFormatter.calendar = calendar;
    dayExtractionDateFormatter.calendar = calendar;
    ymdFormatter.calendar = calendar;
    [lastDayOfMonthCache removeAllObjects];
    [self reloadCollectionView];
}

- (void)setFirstDayOfWeek:(NSInteger)firstDayOfWeek
{
    NSParameterAssert(firstDayOfWeek > 0);
    _firstDayOfWeek = firstDayOfWeek;
    [self reloadCollectionView];
}

- (NSInteger)numberOfDaysInWeek
{
    return [self.calendar rangeOfUnit:NSWeekdayCalendarUnit inUnit:NSYearCalendarUnit forDate:self.monthYearShowing].length;
}

- (NSDate *)firstDayOfMonth:(NSDate *)date
{
    if (self.calendar == nil || self.monthYearShowing == nil)
        return nil;
    
    NSString * dateString = [[self monthForDate:date] stringByAppendingString:@"-01"];
    NSDate * ret = [ymdFormatter dateFromString:dateString];

    return ret;
}

- (NSDate *)lastDayOfMonth:(NSDate *)date
{
    if (self.calendar == nil || self.monthYearShowing == nil)
        return nil;
    
    NSDate * ret;
    if ((ret = [lastDayOfMonthCache objectForKey:[self monthForDate:date]]) != nil)
        return ret;
    
    NSDateComponents * c = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    c.day = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
    c.calendar = self.calendar;
    
    [lastDayOfMonthCache setObject:c.date forKey:[self monthForDate:date]];
    
    return c.date;
}

- (NSDate *)dateForFirstCell
{
    if (dateForFirstCell)
        return dateForFirstCell;

    if (self.calendar == nil || self.monthYearShowing == nil)
        return nil;
    
    NSDateComponents * firstComponents = [[NSDateComponents alloc] init];
    firstComponents.day = 1;
    firstComponents.month = 1;
    firstComponents.year = [[self.calendar components:NSYearCalendarUnit fromDate:self.monthYearShowing] year];
    firstComponents.calendar = self.calendar;
    
    daysPaddingAtStartOfYear = 0;

    NSDate * date = firstComponents.date;
    
    while (date != nil && [[self.calendar components:NSWeekdayCalendarUnit fromDate:date] weekday] != self.firstDayOfWeek)
    {
        date = [date dateByAddingTimeInterval:-OneDay];
        daysPaddingAtStartOfYear++;
    }
    
    dateForFirstCell = date;
    
    return date;
}

- (NSDate *)dateForLastCell
{
    if (self.calendar == nil || self.monthYearShowing == nil)
        return nil;
    
    NSDateComponents * firstComponents = [[NSDateComponents alloc] init];
    firstComponents.day = 1;
    firstComponents.month = 1;
    firstComponents.year = 1 + [[self.calendar components:NSYearCalendarUnit fromDate:self.monthYearShowing] year];
    firstComponents.calendar = self.calendar;

    NSDate * date = [firstComponents.date dateByAddingTimeInterval:-OneDay]; // last day of year
    
    NSInteger lastDayOfWeek = self.firstDayOfWeek - 1;
    if (lastDayOfWeek < 1)
        lastDayOfWeek = [self numberOfDaysInWeek]; // no -1 since days of week is not zero indexed
    
    while ([[self.calendar components:NSWeekdayCalendarUnit fromDate:date] weekday] != lastDayOfWeek)
        date = [date dateByAddingTimeInterval:OneDay];
    
    return date;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // the +10 is a bit of a fudge - we want up to an extra week to deal with scrolling the last month to the top
    return floor([[self dateForLastCell] timeIntervalSinceDate:[self dateForFirstCell]] / OneDay) + 10;
}

- (NSInteger)itemIndexForDate:(NSDate *)date
{
    NSInteger firstDayOfMonthAsDayOfYear = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[self firstDayOfMonth:self.monthYearShowing]];

    return firstDayOfMonthAsDayOfYear + daysPaddingAtStartOfYear - 1;
}

- (NSDate *)dateForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate * date = dateForIndexPathCache[indexPath.item];
    
    if (date == (id)[NSNull null])
    {
        NSDateComponents * c = [[NSDateComponents alloc] init];
        c.day = indexPath.item;
        date = [self.calendar dateByAddingComponents:c toDate:[self dateForFirstCell] options:0];
        dateForIndexPathCache[indexPath.item] = date;
    }
    
    return date;
}

- (NSString *)monthForDate:(NSDate *)date
{
    return [monthExtractionDateFormatter stringFromDate:date];
}

- (NSString *)dayForDate:(NSDate *)date
{
    return [dayExtractionDateFormatter stringFromDate:date];
}

- (BOOL)dateIsInCurrentMonth:(NSDate *)date
{
    return [currentMonthString isEqualToString:[self monthForDate:date]];
}

- (BOOL)dateIsToday:(NSDate *)date
{
    if (![self dateIsInCurrentMonth:date])
        return NO;
    
    return [[self dayForDate:date] isEqualToString:[self dayForDate:[NSDate date]]];
}

- (void)updateCell:(HTBCalendarViewCell *)cell forDate:(NSDate *)date
{
    // perhaps delegate should be able to override this so the cell doesn't need to be a known class
    cell.calendar = self.calendar;
    if (![cell.date isEqualToDate:date])
    {
        cell.date = date;
        cell.isCurrentMonth = [self dateIsInCurrentMonth:date];
        cell.isToday = [self dateIsToday:date];
    
        //TODO: once performance is improved, perhaps push this back into the cell
        cell.dateLabel.text = [self dayForDate:date];
    }
    
    [self.delegate calendarView:self updateCell:cell forDate:date];
}

- (IBAction)gotoNextMonth:(id)sender
{
    NSDate * date = self.monthYearShowing;
    NSDateComponents * c = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    c.calendar = self.calendar;
    c.month += 1;
    self.monthYearShowing = c.date;
}

- (IBAction)gotoPreviousMonth:(id)sender
{
    NSDate * date = self.monthYearShowing;
    NSDateComponents * c = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    c.calendar = self.calendar;
    c.month -= 1;
    self.monthYearShowing = c.date;
}

- (void)reloadData
{
    [self reloadCollectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate * date = [self dateForItemAtIndexPath:indexPath];
    
    HTBCalendarViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:dateCellID forIndexPath:indexPath];
    [self updateCell:cell forDate:date];
    
    return cell;
}

@end
