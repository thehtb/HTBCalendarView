//
//  HTBCalendarHeaderView.m
//  HTBCalendarViewTest
//
//  Created by Mark Aufflick on 30/07/13.
//  Copyright (c) 2013 The High Technology Bureau. All rights reserved.
//

#import "HTBCalendarHeaderView.h"

#import "HTBCalendarView.h"

@interface HTBCalendarHeaderView ()

@property (nonatomic, strong) UILabel * monthLabel;
@property (nonatomic, strong) UILabel * yearLabel;
@property (nonatomic, strong) UIView * monthHolder;
@property (nonatomic, strong) UIView * yearHolder;

- (void)setupViewHierarchy;
- (NSArray *)dayNames;

@end

@implementation HTBCalendarHeaderView

- (instancetype)initWithCalendarView:(HTBCalendarView *)calendarView
{
    if ((self = [self initWithFrame:CGRectZero]) == nil)
        return nil;
    
    self.calendarView = calendarView;
    [self setupViewHierarchy];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupViewHierarchy];
}

- (void)setupViewHierarchy
{
    self.backgroundColor = [UIColor clearColor];
    self.yearHolder = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.yearHolder];
    self.monthHolder = [[UIView alloc] initWithFrame:self.bounds];
    [self.yearHolder addSubview:self.monthHolder];
    
    UITapGestureRecognizer * monthGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMonth:)];
    [self.monthHolder addGestureRecognizer:monthGesture];
    
    UITapGestureRecognizer * yearGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapYear:)];
    [self.yearHolder addGestureRecognizer:yearGesture];
    
    self.nextMonthButton = [[HTBCalendarTriangleButton alloc] initWithFrame:(CGRect){ CGPointZero, { 25, 25 }}];
    [self addSubview:self.nextMonthButton];
    
    self.prevMonthButton = [[HTBCalendarTriangleButton alloc] initWithFrame:(CGRect){ CGPointZero, { 25, 25 }}];
    self.prevMonthButton.transform = CGAffineTransformMakeScale(-1, 1);
    [self addSubview:self.prevMonthButton];
    
    [self updateDayNameLabels];
}

- (void)updateDayNameLabels
{
    NSArray * dayNames = [self dayNames];
    NSMutableArray * dayNameLabels = [NSMutableArray arrayWithCapacity:[dayNames count]];
    for (NSString * name in dayNames)
    {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        label.backgroundColor = [UIColor clearColor];
        label.text = name;
        [label sizeToFit];
        [dayNameLabels addObject:label];
        [self addSubview:label];
    }
    
    self.dayNameLabels = dayNameLabels;
}

- (void)setCalendarView:(HTBCalendarView *)calendarView
{
    if (self.calendarView != nil)
    {
        [self.nextMonthButton removeTarget:self.calendarView action:@selector(gotoNextMonth:) forControlEvents:UIControlEventTouchUpInside];
        [self.prevMonthButton removeTarget:self.calendarView action:@selector(gotoPreviousMonth:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _calendarView = calendarView;
    
    [self.nextMonthButton addTarget:self.calendarView action:@selector(gotoNextMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self.prevMonthButton addTarget:self.calendarView action:@selector(gotoPreviousMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self updateDayNameLabels];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect flipviewSize = bounds;
    flipviewSize.size.height *= 1.5; // to get a better flip transition
    self.yearHolder.frame = flipviewSize;
    self.monthHolder.frame = self.yearHolder.bounds;
    
    [self layoutMonthLabel:self.monthLabel];
    [self layoutYearLabel:self.yearLabel];
    
    self.nextMonthButton.center = (CGPoint){ bounds.size.width - self.nextMonthButton.bounds.size.width, floor(bounds.size.height / 3) };
    self.prevMonthButton.center = (CGPoint){ self.prevMonthButton.bounds.size.width, floor(bounds.size.height / 3) };
    
    CGFloat dayCenterSpacing = bounds.size.width / [self.dayNameLabels count];
    CGFloat x = dayCenterSpacing / 2;
    for (UILabel * label in self.dayNameLabels)
    {
        label.center = (CGPoint){ x, bounds.size.height - 10 };
        x += dayCenterSpacing;
    }
}

- (void)layoutMonthLabel:(UILabel *)label
{
    CGSize boundsSize = self.bounds.size;
    CGSize size = [label sizeThatFits:boundsSize];
    size.width = (boundsSize.width / 2) - 3;
    label.frame = (CGRect){ { 0, floor((boundsSize.height / 3) - (size.height / 2)) }, size };
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentRight;
}

- (void)layoutYearLabel:(UILabel *)label
{
    CGSize boundsSize = self.bounds.size;
    CGSize size = [label sizeThatFits:boundsSize];
    size.width = (boundsSize.width / 2) - 3;
    label.frame = (CGRect){ { floor(boundsSize.width / 2) + 3, floor((boundsSize.height / 3) - (size.height / 2)) }, size };
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
}

- (void (^)(void))updateMonthLabel
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM" options:0 locale:[NSLocale currentLocale]];
    
    NSString * monthString = [dateFormatter stringFromDate:self.monthYearToDisplay];
    if ([monthString isEqualToString:self.monthLabel.text])
        return nil;
    
    UILabel * newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    newLabel.text = monthString;
    if ([self.delegate respondsToSelector:@selector(calendarViewHeaderView:styleNewMonthLabel:)])
        [self.delegate calendarViewHeaderView:self styleNewMonthLabel:newLabel];
    
    [self layoutMonthLabel:newLabel];
    
    if (self.monthLabel == nil)
    {
        self.monthLabel = newLabel;
        [self.monthHolder addSubview:newLabel];
        return nil;
    }

    UILabel * oldLabel = self.monthLabel;
    self.monthLabel = newLabel;
    
    return ^{
        [oldLabel removeFromSuperview];
        [self.monthHolder addSubview:newLabel];
    };
}

- (void (^)(void))updateYearLabel
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"YYYY" options:0 locale:[NSLocale currentLocale]];
    
    NSString * yearString = [dateFormatter stringFromDate:self.monthYearToDisplay];
    if ([yearString isEqualToString:self.yearLabel.text])
        return nil;
    
    UILabel * newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    newLabel.text = yearString;
    if ([self.delegate respondsToSelector:@selector(calendarViewHeaderView:styleNewYearLabel:)])
        [self.delegate calendarViewHeaderView:self styleNewYearLabel:newLabel];
    
    [self layoutYearLabel:newLabel];
    
    if (self.yearLabel == nil)
    {
        self.yearLabel = newLabel;
        [self.yearHolder addSubview:newLabel];
        
        return nil;
    }
    
    UIView * oldLabel = self.yearLabel;
    self.yearLabel = newLabel;

    return ^{
        [oldLabel removeFromSuperview];
        [self.yearHolder addSubview:newLabel];
    };
}

- (void)setMonthYearToDisplay:(NSDate *)monthYearToDisplay
{
    NSDate * prevDate = _monthYearToDisplay;
    _monthYearToDisplay = monthYearToDisplay;
    
    void (^monthAnimations)(void) = [self updateMonthLabel];
    void (^yearAnimations)(void) = [self updateYearLabel];
    
    if (monthAnimations != nil)
    {
        [UIView transitionWithView:yearAnimations == nil ? self.monthHolder : self.yearHolder
                          duration:0.5
                           options:[prevDate compare:self.monthYearToDisplay] == NSOrderedDescending ? UIViewAnimationOptionTransitionFlipFromBottom : UIViewAnimationOptionTransitionFlipFromTop
                        animations:^{
                            monthAnimations();
                            if (yearAnimations != nil)
                                yearAnimations();
                        } completion:nil];
    }
}

- (NSArray *)dayNames
{
    NSInteger numDaysInWeek = [self.calendarView.calendar rangeOfUnit:NSWeekdayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]].length;

    NSMutableArray * array = [NSMutableArray arrayWithCapacity:numDaysInWeek];
    
    NSString * format = [NSDateFormatter dateFormatFromTemplate:@"EEE" options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    
    NSDateComponents * c = [[NSDateComponents alloc] init];
    c.weekdayOrdinal = 1;
    c.month = 1;
    c.year = 2000;
    
    for (int i=0; i < numDaysInWeek; i++)
    {
        c.weekday = self.calendarView.firstDayOfWeek + i; // this wraps ok if first day of week is not 0
        NSDate * d = [self.calendarView.calendar dateFromComponents:c];
        NSString * dayName = [formatter stringFromDate:d];
        [array addObject:dayName];
    }
    
    return array;
}

- (void)didTapMonth:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(calendarViewHeaderViewDidTapMonth:)])
        [self.delegate calendarViewHeaderViewDidTapMonth:self];
}

- (void)didTapYear:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(calendarViewHeaderViewDidTapYear:)])
        [self.delegate calendarViewHeaderViewDidTapYear:self];
}

@end
