//
//  CalendarCell.m
//  Tabula2
//
//  Created by Mark Aufflick on 31/07/13.
//
//

#import "CalendarCell.h"

@interface CalendarCell ()

@property (nonatomic, strong) UILabel * bigTick;

@end

@implementation CalendarCell

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) == nil)
        return nil;
    
    self.bigTick = [[UILabel alloc] initWithFrame:CGRectZero];
    self.bigTick.textAlignment = NSTextAlignmentCenter;
    self.bigTick.font = [UIFont fontWithName:@"Helvetica" size:36];
    self.bigTick.textColor = [UIColor greenColor];
    [self.contentView addSubview:self.bigTick];
    
    self.dateLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = CGRectInset(self.bounds, 0.5, 0.5);
    self.contentView.frame = bounds;
    
    CGRect dateFrame;
    CGRect tickFrame;
    CGRectDivide(bounds, &dateFrame, &tickFrame, self.bounds.size.height / 2, CGRectMinYEdge);
    
    dateFrame.origin.x += 4;
    self.dateLabel.frame = dateFrame;
    tickFrame.size.height = 20;
    self.bigTick.frame = tickFrame;
}

- (void)setTicked:(BOOL)ticked
{
    self.bigTick.text = ticked ? @"✔︎" : @"";
}

-(void)updateStyle
{
    NSDateComponents * components = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:self.date];

    if (self.isToday)
    {
        self.dateLabel.textColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor darkGrayColor];
    }
    else if ([self.date compare:[NSDate date]] == NSOrderedAscending)
    {
        self.dateLabel.textColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        self.dateLabel.textColor = [UIColor blackColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    if (components.weekday == 1 || components.weekday == 7)
        self.dateLabel.textColor = [UIColor redColor];
}

@end
