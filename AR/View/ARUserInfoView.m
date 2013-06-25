//
//  ARUserInfoView.m
//  AROverlayExample
//
//  Created by Abdallah Elguindy on 8/28/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//

#import "ARUserInfoView.h"

#import "ProfileContext.h"
#import "ARContact+Distance.h"
#import "Profile+RelationshipStatus.h"

@implementation ARUserInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.layer.shouldRasterize = YES;
        //        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        // Initialization code
        self.layer.contents = (id)[UIImage imageNamed: @"ar_top-bar"].CGImage;
        
        UIFont *font = FONT_Aller(2*[UIFont systemFontSize]);
        nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, font.lineHeight)];
        nameLabel_.text = @"Gandalf";
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textAlignment = UITextAlignmentCenter;
        nameLabel_.textColor = [UIColor whiteColor];
        nameLabel_.font = font;
        [self addSubview:nameLabel_];
        
        font = FONT_Aller([UIFont systemFontSize]);
        distanceLabel_= [[UILabel alloc] initWithFrame:CGRectMake(0, 32.f, frame.size.width, font.lineHeight)];
        distanceLabel_.text = @"within 1 mile";
        distanceLabel_.backgroundColor = [UIColor clearColor];
        distanceLabel_.textAlignment = UITextAlignmentCenter;
        distanceLabel_.textColor = [UIColor whiteColor];
        distanceLabel_.font = font;
        distanceLabel_.alpha = 0.75;
        [self addSubview:distanceLabel_];
        
        font = FONT_Aller(2*[UIFont systemFontSize]/1.9);
//        relationshipLabel_= [[UILabel alloc] initWithFrame:CGRectMake(0, 52, frame.size.width, font.lineHeight)];
//        relationshipLabel_.text = @"3 mutual friends";
//        relationshipLabel_.backgroundColor = [UIColor redColor];
//        relationshipLabel_.textAlignment = UITextAlignmentCenter;
//        relationshipLabel_.textColor = [UIColor colorWithRed:196/255.0 green:239/255.0 blue:67/255.0 alpha:1];
//        relationshipLabel_.font = font;
//        [self addSubview:relationshipLabel_];
        
        circlesLabel_= [[UILabel alloc] initWithFrame:CGRectMake(0, 72, frame.size.width, font.lineHeight)];
        circlesLabel_.backgroundColor = [UIColor clearColor];
        circlesLabel_.textAlignment = UITextAlignmentCenter;
        circlesLabel_.textColor = [UIColor colorWithRed:255/255.0 green:170/255.0 blue:36/255.0 alpha:1];
        circlesLabel_.font = font;
        circlesLabel_.numberOfLines = 1;
        circlesLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:circlesLabel_];
        
        self.hidden = true;
    }
    return self;
}


- (void)set: (ARContact *) contact {
    if (contact == nil) {
        [self setHidden:YES animated:YES];
    } else {
        [self setHidden:NO animated:YES];
        
        Profile *p = contact.profileContext.profile;
        nameLabel_.text = p.firstName;
        distanceLabel_.text = contact.profileContext.lastSeenString;
        circlesLabel_.text = contact.profileContext.commonString;
        if( !circlesLabel_.text.length ) {
            circlesLabel_.text = @"Other";
        }
    }
}

BOOL animationHisteresis = NO;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    
    if( self.hidden == hidden || animationHisteresis == YES )
        return;
    
    animationHisteresis = YES;
    
    if( animated ) {
        CGFloat destinationY = hidden ? -floorf(self.frame.size.height/2.0) : floorf(self.frame.size.height/2.0);
        
        CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"position"];
        if( hidden ) {
            a.fromValue = [NSValue valueWithCGPoint:((CALayer *)self.layer.presentationLayer).position];
        }
        else {
            a.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, -floorf(self.frame.size.height/2.0))];
            [super setHidden:NO];
        }
        a.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, destinationY)];
        a.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        a.duration = 0.5;
        a.fillMode = kCAFillModeBoth;
        a.removedOnCompletion = NO;
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if( hidden )
                [super setHidden:YES];
            [self.layer removeAllAnimations];
            animationHisteresis = NO;
        }];
        [self.layer addAnimation:a forKey:@"hidden"];
        [CATransaction commit];
    }
    else {
        [super setHidden:hidden];
    }
}


@end
