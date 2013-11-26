//
//  HTBCalendarView.h
//  HTBCalendarViewTest
//
//  Created by Mark Aufflick on 26/07/13.
//  Copyright (c) 2013 The High Technology Bureau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTBCalendarViewCell.h"
#import "HTBCalendarHeaderView.h"

@protocol HTBCalendarViewDelegate;

@interface HTBCalendarView : UIView

@property (nonatomic, weak) IBOutlet HTBCalendarHeaderView * headerView;
@property (nonatomic, strong) NSDate * monthYearShowing;
@property (nonatomic, strong) NSCalendar * calendar;
@property (nonatomic) NSInteger firstDayOfWeek;
@property (nonatomic, weak) IBOutlet id<UICollectionViewDelegate> collectionViewDelegate;
@property (nonatomic, weak) IBOutlet id<HTBCalendarViewDelegate> delegate;

/** The designated initialiser. The delegate must be provided so the cell class can be determined.
 
 This is the designated initialiser. The delegate must be provided so the cell class can be determined.
 If instead you choose to use a nib, the delegate IBOutlet must be bound.
 */
- (instancetype)initWithDelegate:(id<HTBCalendarViewDelegate>)delegate frame:(CGRect)frame;

- (NSDate *)dateForItemAtIndexPath:(NSIndexPath *)indexPath;
- (IBAction)gotoNextMonth:(id)sender;
- (IBAction)gotoPreviousMonth:(id)sender;
- (void)reloadData;
- (void)scrollToCurrentMonthAnimated:(BOOL)animated;

@end

@protocol HTBCalendarViewDelegate <NSObject>

/** the class to be used for all the collectionview cells. This must be a subclass of HTBCalendarViewCell unless you
 subclass HTBCalendarView and override `updateCell:forDate:`
 */
- (Class)calendarViewCellClass:(HTBCalendarView *)calendarView;
- (void)calendarView:(HTBCalendarView *)calendarView updateCell:(HTBCalendarViewCell *)cell forDate:(NSDate *)date;


@end