//
//  Utility.m
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//



NSURL *
ApplicationDocumentsDirectory() {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

CGFloat
CenterCoordinateHorizontallyInView(UIView *parentView, CGFloat length) {
    return roundf(parentView.frame.size.width/2.f - length/2.f);
}

CGFloat
CenterCoordinateVerticallyInView(UIView *parentView, CGFloat length) {
    return roundf(parentView.frame.size.height/2.f - length/2.f);
}

UIColor *
ChangeBrightnessOfColorByAmount(UIColor *color, CGFloat amount) {
    CGFloat hue, saturation, brightness, alpha;

    if( [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha] ) {
        brightness += (amount - 1.0);
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }

    CGFloat white;

    if( [color getWhite:&white alpha:&alpha] ) {
        white += (amount - 1.0);
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }

    return nil;
}

void
draw1PxBottomBorder(CGContextRef context, CGRect rect) {
    
    CGPoint startPoint = CGPointMake(0.0 ,rect.size.height - 1.f);
    CGPoint endPoint = CGPointMake(rect.size.width, rect.size.height - 1.f);
    
    draw1PxBorder(context, startPoint, endPoint, @"cccccc");
}

void
draw1PxBorder(CGContextRef context, CGPoint startPoint, CGPoint endPoint, NSString *color) {
    
    if ( context == nil )
        return;
    
    CGFloat offset = 1.f/2.f;
    
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:color].CGColor);
    CGContextSetLineWidth(context, 1.f);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y + offset);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y + offset);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}
