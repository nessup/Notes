//
//  ARMoreContactsView.m
//  AROverlayExample
//
//  Created by Abdallah Elguindy on 8/30/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//

#import "ARMoreContactsView.h"

#import <UIKit/UIKit.h>


@implementation ARMoreContactsView {
    UIImageView *background_;
    UILabel *contactCount_;
    CALayer *_arrowsLayer;
    NSTimer *_animationTimer;
    BOOL _left;
}

- (id)initWithFrame:(CGRect)frame left:(BOOL)left
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _left = left;
        
        // BG
        contactCount_ = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 30.0, 30.0)];
        contactCount_.backgroundColor = [UIColor clearColor];
        contactCount_.textColor = [UIColor whiteColor];
        contactCount_.font = FONT_Aller(14.0);
        contactCount_.textAlignment = UITextAlignmentCenter;
        [self addSubview:contactCount_];
        
        if( left ) {
            self.layer.contents = (id)[UIImage imageNamed:@"ar_notif_arrow-left"].CGImage;
            contactCount_.center = CGPointMake(23.0, 17.0);
        }
        else {
            self.layer.contents = (id)[UIImage imageNamed:@"ar_notif_arrow-right"].CGImage;
            contactCount_.center = CGPointMake(17.0, 17.0);
        }
        
        // Arrows layer
        {
            CGFloat xOffset = (left ? 1 : -1)*35.f + (left ? 12.f : 0.f);
            
            CALayer *layer = [CALayer layer];
            layer.frame = CGRectMake( xOffset, 0.f, 30.f, 30.f);
            layer.backgroundColor = [UIColor clearColor].CGColor;
            [self.layer addSublayer:layer];
            _arrowsLayer = layer;
            
            UIImage *image = (left ? [UIImage imageNamed:@"ar_arrow-left"] : [UIImage imageNamed:@"ar_arrow-right"]);
            for( int i = 0; i < 3; i++ )
            {
                CALayer *layer = [CALayer layer];
                layer.frame = (CGRect){6.f*i, 0.f, image.size};
                layer.contents = (id)image.CGImage;
                layer.opacity = 0.f;
                [_arrowsLayer addSublayer:layer];
            }
            
        }
    }
    return self;
}

- (void) setCount: (int) count {
    if( count == _count )
        return;
    
    _count = count;
    if (count == 0) {
        self.hidden = true;
    } else {
        self.hidden = false;
        contactCount_.text = [NSString stringWithFormat:@"+%d", count];
    }
}

- (void)setAnimating:(BOOL)animating
{
    if( _animating == animating )
        return;
    
    _animating = animating;
    
    if( _animating ) {
        if( _animationTimer )
            return;
        
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(enqueueAnimations:) userInfo:nil repeats:YES];
    }
    else {
        
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}

- (void)enqueueAnimations:(NSTimer *)timer
{
    CAKeyframeAnimation *a;
    int i = (_left ? 2 : 0);
    for( CALayer *layer in _arrowsLayer.sublayers ) {
        a = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        a.values = @[@0.f, @1.f, @0.f];
        a.keyTimes = @[@0.f, @0.5f, @1.f];
        a.beginTime = CACurrentMediaTime() + 0.35f*i;
        a.duration = 1.f;
        [layer addAnimation:a forKey:@"fade"];
        
        if( _left )
            i--;
        else
            i++;
    }
}

@end
