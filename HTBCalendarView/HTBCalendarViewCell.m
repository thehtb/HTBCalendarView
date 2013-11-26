//
//  HTBCalendarViewCell.m
//  HTBCalendarViewTest
//
//  Created by Mark Aufflick on 26/07/13.
//  Copyright (c) 2013 The High Technology Bureau. All rights reserved.
//

#import "HTBCalendarViewCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation HTBCalendarViewCell

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) == nil)
        return nil;
    
    self.contentView.backgroundColor = [UIColor whiteColor];

    frame.origin = CGPointZero;
    self.dateLabel = [[UILabel alloc] initWithFrame:frame];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.opaque = NO;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.dateLabel];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.dateLabel.frame = self.bounds;
}

- (void)updateStyle
{
    self.contentView.backgroundColor = self.isCurrentMonth ? [UIColor whiteColor] : [UIColor lightGrayColor];
    self.dateLabel.textColor = self.isToday ? [UIColor redColor] : self.isCurrentMonth ? [UIColor blackColor] : [UIColor darkGrayColor];
}

- (void)setIsCurrentMonth:(BOOL)isCurrentMonth
{
    _isCurrentMonth = isCurrentMonth;
    [self updateStyle];
}

- (void)setIsToday:(BOOL)isToday
{
    _isToday = isToday;
    [self updateStyle];
}

@end
