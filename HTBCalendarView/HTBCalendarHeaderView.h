//
//  HTBCalendarHeaderView.h
//  HTBCalendarViewTest
//
//  Created by Mark Aufflick on 30/07/13.
//  Copyright (c) 2013 The High Technology Bureau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTBCalendarTriangleButton.h"

@protocol HTBCalendarHeaderViewDelegate;
@class HTBCalendarView;

@interface HTBCalendarHeaderView : UIView

@property (nonatomic, strong) NSDate * monthYearToDisplay;
@property (nonatomic, strong) IBOutlet HTBCalendarView * calendarView;
@property (nonatomic, weak) IBOutlet id<HTBCalendarHeaderViewDelegate> delegate;

// move these styling options to optional delegate methods
@property (nonatomic, strong) NSArray * dayNameLabels;
@property (nonatomic, strong) HTBCalendarTriangleButton * nextMonthButton;
@property (nonatomic, strong) HTBCalendarTriangleButton * prevMonthButton;

/** The designated initializer.
 
 This is the designated initializer. `calendarView` must be specified because it is used during the view setup.
 If you choose to use this class in a nib file then you need to instead make sure that the `calendarView`
 IBOutlet is bound.
 
 @param calendarView your instance of HTBCalendarView
 */
- (instancetype)initWithCalendarView:(HTBCalendarView *)calendarView;

@end

@protocol HTBCalendarHeaderViewDelegate <NSObject>

@optional
- (void)calendarViewHeaderView:(HTBCalendarHeaderView *)headerView styleNewMonthLabel:(UILabel *)label;
- (void)calendarViewHeaderView:(HTBCalendarHeaderView *)headerView styleNewYearLabel:(UILabel *)label;
- (void)calendarViewHeaderViewDidTapMonth:(HTBCalendarHeaderView *)headerView;
- (void)calendarViewHeaderViewDidTapYear:(HTBCalendarHeaderView *)headerView;

@end
