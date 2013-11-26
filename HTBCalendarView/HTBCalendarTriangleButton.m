//
//  HTBCalendarTriangleButton.m
//  HTBCalendarViewTest
//
//  Created by Mark Aufflick on 30/07/13.
//  Copyright (c) 2013 The High Technology Bureau. All rights reserved.
//

#import "HTBCalendarTriangleButton.h"

@interface HTBCalendarTriangleButton ()

- (void)setupViewProperties;

@end

@implementation HTBCalendarTriangleButton

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) == nil)
        return nil;
    
    [self setupViewProperties];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupViewProperties];
}

- (void)setupViewProperties
{
    self.triangleFillColor = [UIColor darkGrayColor];
    self.triangleStrokeColor = [UIColor blackColor];
    self.triangleShadowColor = [UIColor lightGrayColor];
}

- (void)drawRect:(CGRect)rect
{
    /*
     * from the PaintCode document in ./Assets
     */
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    //// Shadow Declarations
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 2;
    
    //// Frames
    CGRect frame = self.bounds;
    
    //// Polygon Drawing
    UIBezierPath* polygonPath = [UIBezierPath bezierPath];
    [polygonPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 17, CGRectGetMinY(frame) + 14)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 2, CGRectGetMinY(frame) + 2)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 2, CGRectGetMinY(frame) + 26)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 17, CGRectGetMinY(frame) + 14)];
    [polygonPath closePath];
    polygonPath.lineJoinStyle = kCGLineJoinRound;
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, [self.triangleShadowColor CGColor]);
    [self.triangleFillColor setFill];
    [polygonPath fill];
    CGContextRestoreGState(context);
    
    [self.triangleStrokeColor setStroke];
    polygonPath.lineWidth = 1;
    [polygonPath stroke];
}

@end
