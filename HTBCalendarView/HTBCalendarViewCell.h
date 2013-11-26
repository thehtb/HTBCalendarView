//
//  HTBCalendarViewCell.h
//  HTBCalendarViewTest
//
//  Created by Mark Aufflick on 26/07/13.
//  Copyright (c) 2013 The High Technology Bureau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTBCalendarViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) NSCalendar * calendar;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic) BOOL isCurrentMonth;
@property (nonatomic) BOOL isToday;

- (void)updateStyle;

@end
