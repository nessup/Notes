//
//  ARDrawingManager.m
//  AROverlayExample
//
//  Created by Abdallah Elguindy on 8/17/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//

#import "AvatarView.h"
#import "ARDrawingManager.h"
#import "ARMoreContactsView.h"
#import "UrlNavigator.h"

#import "ARContact+Distance.h"
#import "ProfileContext.h"
#import "Profile.h"

#define KEY_Contact         @"ARContact"

@implementation ARDrawingManager {
    //  Distance circles are drawn as arcs with offscreen centers.
    //  These are the center coordinates and radii.
    //  The x coordinate of all centers is the same and in the middle
    //  of the screen.
    double circleCentersX_, circleCentersYs_, circleRadii_[3];
    
    //  Keep track of previous circle constants for the purpose
    //  of animation.
    double prevCircleCenterYs_[3], prevCircleRadii_[3];
    
    // Layers where line animations take place.
    
    // ARContacts separated by their circles.
    NSMutableArray *circleARContacts_[3];
    
    // The dimensions of the avatars on the different circles.
    int dims_[3];
    
    // Indicates if the phone is pointing up. All calculations
    // are done with the assumption that the phone is pointing
    // down, this is used for correction at the end.
    bool invert_;
    
    // Box to display highlighted ARContact information.
    ARUserInfoView *ARUserInfoView_;
    
    // 2D array of Avatar objects the [i][j] holds the
    // UIView to display the jth ARContact on the ith circle.
    NSMutableArray *iconImageViews_[3];
    
    // Maintain a history of the phone heading. The final heading
    // is determined as a weighted average. This is done to smooth
    // out the animation and eliminate glitches.
    double prevHeadings_[10];
    
    // The roll angle of the phone, this determines the shape
    // of the lines and the corresponding avatar vertical positions.
    double angle_;
    
    // This holds a multiplier for the alpha of the avatars. The more
    // the phone rolls the clearer the avatars in the further circles
    // become.
    double circleAlphas_[3];
    
    // Labels with the distancs on the circles.
    UILabel *circleDistanceLabels_[3];
    
    ARMoreContactsView *leftARContactCount_;
    ARMoreContactsView *rightARContactCount_;
    
    double newAngle_, angle_2;
    CATransform3D transform_;
    double width_, height_;
    CALayer *_lineLayerContainer;
    CALayer *_lastVisibleHighlightLayer;
}

- (id)initWithView:(UIView *)view {
    //self = [super initWithFrame:frame];
    self = [super init];
    if (self) {
        _view = view;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        width_ = screenRect.size.height;
        height_ = screenRect.size.width;
        
        // Circle centers are always in the middle of the screen
        // (horizontally).
        circleCentersX_ = width_/2;
        circleCentersYs_ = 1.5 * height_ + 30;
        
        {
            CALayer *layer = [CALayer layer];
            layer.frame = (CGRect){CGPointZero, width_, height_};
            layer.contents = (id)[UIImage imageNamed:@"orbit"].CGImage;
            [_view.layer addSublayer:layer];
            _lineLayerContainer = layer;
        }
        
        _lineLayerContainer.zPosition = 500;
//        _lineLayerContainer.shouldRasterize = YES;
        
        // Avatar dimensions. Experimentally determined.
        dims_[0] = 50;
        dims_[1] = 70;
        dims_[2] = 100;
        
        // Dimensions here are also experimentally determined.
        ARUserInfoView_ = [[ARUserInfoView alloc] initWithFrame:CGRectMake(0.0, 0, 164.0, 107.0)];
        ARUserInfoView_.center = CGPointMake(CGRectGetMidX(self.view.frame), ARUserInfoView_.center.y) ;
        [_view addSubview:ARUserInfoView_];
        
        // Initialize the labels with the distances. This should
        // be changed to dynamic behaviour.
        NSString *distanceLabelTexts[3] = {@"100 miles", @"10 miles", @"2 miles"};
        for (int i = 0; i < 3; ++i) {
            circleDistanceLabels_[i] = [[UILabel alloc] initWithFrame:CGRectMake(width_/2 - 50, height_/2, 35.f, 20)];
            circleDistanceLabels_[i].text = distanceLabelTexts[i];
            circleDistanceLabels_[i].backgroundColor = [UIColor clearColor];
            circleDistanceLabels_[i].textColor = [UIColor whiteColor];
            circleDistanceLabels_[i].font = [UIFont systemFontOfSize:[UIFont systemFontSize]/2];
            circleDistanceLabels_[i].textAlignment = UITextAlignmentCenter;
//            circleDistanceLabels_[i].layer.shouldRasterize = YES;
            circleDistanceLabels_[i].layer.rasterizationScale = [UIScreen mainScreen].scale;
            [self.view addSubview:circleDistanceLabels_[i]];
        }
        
        // Initialize the "more ARContacts on this side"
        // labels.
        leftARContactCount_ = [[ARMoreContactsView alloc] initWithFrame: CGRectMake(10, height_/2 - 22, 40.0, 36.0) left:YES];
        rightARContactCount_ = [[ARMoreContactsView alloc] initWithFrame: CGRectMake(width_ - 50, height_/2 - 22, 40.0, 36.0) left:NO];

        [_view addSubview: leftARContactCount_];
        [_view addSubview: rightARContactCount_];
        
        [leftARContactCount_ setCount:0];
        [rightARContactCount_ setCount:0];
        
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                           [NSNull null], @"onOrderOut",
                                           [NSNull null], @"sublayers",
                                           [NSNull null], @"contents",
                                           [NSNull null], @"bounds",
                                           [NSNull null], @"transform",
                                           nil];
        circleRadii_[0] = 1.2 * height_;
        circleRadii_[1] = 1.05 * height_;
        circleRadii_[2] = 0.85 * height_;
        
        _lineLayerContainer.actions = newActions;
        
        [self updateLines:0.37];
        
    }
    
    return self;
}

- (void)updateLines:(double) roll {
    // The roll angle is thresholded in both directions.
    // Values here are arbitrary and experimentally determined.
    //NSLog(@"Roll: %f", roll);
    angle_2 = angle_ = MIN(MAX(fabs(roll), 37.0/100), 63.0/100);
    newAngle_ = (angle_ - 0.37) / 0.26;
    //NSLog(@"Angle: %f", angle_);
    //angle_ = 0.37;
    
    
    // Do all calculations assuming phone is rolled down.
    // Indicate a roll up by the invert_ bool.
    invert_ = false;
    if (angle_ > 0.5) {
        angle_ = 1 - angle_;
        invert_ = true;
    }
    
    // Calculating the y value of the circles.
    // It is calculated to be inversly proportional
    // to the phone angle.

    // Ad-hoc formulas for the multiplier of the alpha of
    // avatars on different circles.
    circleAlphas_[2] = 1 - (angle_ - 0.5) * 2;
    circleAlphas_[1] = fabs(angle_ - 0.5) * 6;
    circleAlphas_[0] = fabs(angle_ - 0.5) * 5;
    
    transform_ = CATransform3DIdentity;
    transform_.m34 = 1.0 / -500.0;
    transform_ = CATransform3DRotate(transform_, newAngle_ * M_PI, 1.0, 0.0, 0.0);
    transform_ = CATransform3DScale(transform_, 1.4, 1, 1);
    
    [self animateLines];
}

- (void)animateLines {
    
    _lineLayerContainer.transform = transform_;
    
    // Animate the labels as well.
    for (int i = 0; i < 3; ++i) {
        
        double y = [self getY: circleCentersX_ circle: i] + 15;
        circleDistanceLabels_[i].center = CGPointMake(circleCentersX_,  y);
        circleDistanceLabels_[i].alpha = circleAlphas_[i];
        
    }
    
    // Animate the ARContact counts. Keep them on the middle circle.
    
    double x = leftARContactCount_.center.x;
    double y = [self getY:x circle:1];
    leftARContactCount_.center = CGPointMake(leftARContactCount_.center.x, y + 20);
    
    
    x = rightARContactCount_.center.x;
    y = [self getY:x circle:1];
    rightARContactCount_.center = CGPointMake(rightARContactCount_.center.x, y + 20);
    
    for (int i = 0; i < 3; ++i) {
        prevCircleCenterYs_[i] = circleCentersYs_;
        prevCircleRadii_[i] = circleRadii_[i];
    }
}

- (double) getY: (double) x circle: (int) circle {
    double angle = (newAngle_ - 0.5) * M_PI;
    x = (x - circleCentersX_) / 1.4 + circleCentersX_;
    double dY = circleCentersYs_ - sqrt(circleRadii_[circle] * circleRadii_[circle] - (x - circleCentersX_)*(x - circleCentersX_)) - height_ / 2;
    return height_ / 2 - dY * sin(angle);
}

- (void) animateAvatars {
    double avgHeading = [self getHeading];
    int minI = 0;
    int minJ = 0;
    double minV = 1000;
    int left = 0;
    int right = 0;
    BOOL hideAvatar = NO;
    BOOL someoneIsOnScreen = NO;
    for (int j = 0; j < 3; ++j) {
        int n = [iconImageViews_[j] count];
        for (int i = 0; i < n; ++i) {
            ARContact* contact = [circleARContacts_[j] objectAtIndex:i];
            double angle = fmod(contact.direction - avgHeading + 360, 360) - 180;
            
            // Maintain the ARContact closest to center.
            if (fabs(angle) < minV) {
                minV = fabs(angle);
                minI = i;
                minJ = j;
            }
            
            if (angle > 30) {
                right++;
                hideAvatar = YES;
            } else if (angle < -30) {
                left++;
                hideAvatar = YES;
            }
            else {
                hideAvatar = NO;
                someoneIsOnScreen = YES;
            }
            
            AvatarView *avatar = [iconImageViews_[j] objectAtIndex:i];
            
            if( hideAvatar ) {
                avatar.hidden = YES;
            }
            else {
                
                // Unhighlight everyone.
//                [self highlightAvatarView:nil];
                
                avatar.hidden = NO;
                
                [self moveImage:j index:i angle:angle ];
            }
            
        }
    }
    
    // Highlight the ARContact closest to the center if they are close enough.
    // Set the information box to match the highlighted person or hide it
    // if no ARContact is highlighted.
    if (minV < 15 && minI < iconImageViews_[minJ].count) {
        AvatarView *view = [iconImageViews_[minJ] objectAtIndex:minI];
        [self highlightAvatarView:view];
        [ARUserInfoView_ set:[view.layer valueForKey:KEY_Contact]];

    } else {
        [ARUserInfoView_ set:nil];
    }
    
    [leftARContactCount_ setCount:left];
    [rightARContactCount_ setCount:right];
    leftARContactCount_.animating = !someoneIsOnScreen;
    rightARContactCount_.animating = !someoneIsOnScreen;
}


//  Convenience method to run an animation on the avatars.
//  The animation is a translation and change in alpha.
- (void)moveImage:(AvatarView *)image x:(CGFloat)x y:(CGFloat)y alpha:(CGFloat)alpha
{
    
        CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
        image.transform = transform;
        image.alpha = alpha;
}

- (void)updateAvatars: (double)heading {
    int sz = 10;
    // Kickout the oldest value of heading.
    for (int i = 0; i < sz - 1; ++i) prevHeadings_[i] = prevHeadings_[i + 1];
    // Add the new heading.
    prevHeadings_[sz - 1] = fmod(heading + 360, 360);
    
    [self animateAvatars];
}

#define KEY_HighlightLayer  @"HighlightLayer"
- (void)addHighlightLayerToAvatarView:(AvatarView *)avatarView
{
    CALayer *layer = [CALayer layer];
    
    double delta = 3.0 / 8.0 * avatarView.frame.size.width;
    layer.frame = CGRectMake(avatarView.bounds.origin.x - delta/2, avatarView.bounds.origin.y - delta/2, avatarView.frame.size.width + delta, avatarView.frame.size.height + delta);
    layer.contents = (id)[UIImage imageNamed:@"ar_avatar_highlighted"].CGImage;
    layer.opacity = 0.f;
    [avatarView.layer addSublayer:layer];
}

- (void)setIcons: (NSMutableArray*) ARContacts circle: (int) circle {
    int n = [ARContacts count];
    circleARContacts_[circle] = ARContacts;

    iconImageViews_[circle] = [[NSMutableArray alloc] init];
    double avgHeading = [self getHeading];
    for (int i = 0; i < n; ++i) {
        ARContact *contact = [ARContacts objectAtIndex:i];
        AvatarView *avatar = [[AvatarView alloc] initWithFrame:CGRectMake(0, 0, dims_[circle], dims_[circle])];
        avatar.layer.zPosition = 1000;
        avatar.borderImage = [UIImage imageNamed:@"profile_hole"];
        [avatar setAvatar:contact.profileContext.profile.avatar];
        [self addHighlightLayerToAvatarView:avatar];
        [avatar.layer setValue:contact forKey:KEY_Contact];
        [avatar addTarget:self action:@selector(avatarViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        [iconImageViews_[circle] addObject: avatar];
        
        double angle = fmod(contact.direction - avgHeading + 360, 360) - 180;
        [self moveImage:circle index:i angle:angle];
        
        [_view addSubview:avatar];
    }
    
}

- (void)avatarViewTapped:(AvatarView *)avatarView
{
    if( [self.delegate respondsToSelector:@selector(avatarViewTapped:contact:)] ) {
        [self.delegate avatarViewTapped:avatarView contact:[avatarView.layer valueForKey:KEY_Contact]];
    }
}

// Returns the weighted average of headings.
- (double) getHeading {
    
    // Heading i gets weight i.
    int sz = 10;
    double avgHeading = 0;
    for (int i = 0; i < sz; ++i) avgHeading += i * prevHeadings_[i];
    // Divide by sum of weights.
    avgHeading /= sz * (sz - 1) / 2;
    
    // The code below handles the case when some of the headings
    // wrap around 360. The solution is to simply offset all values
    // by 180, take the average and bring it back.
    bool wrapped = false;
    for (int i = 0; i < sz - 1; ++i)
        if (fabs(prevHeadings_[i] - prevHeadings_[i + 1]) > 30)
            wrapped = true;
    if (wrapped) {
        for (int i = 0; i < sz; ++i) prevHeadings_[i] = fmod(prevHeadings_[i] + 180, 360);
        avgHeading = 0;
        for (int i = 0; i < sz; ++i) avgHeading += i * prevHeadings_[i];
        avgHeading /= sz * (sz - 1) / 2;
        for (int i = 0; i < sz; ++i) prevHeadings_[i] = fmod(prevHeadings_[i] + 180, 360);
        avgHeading = fmod(avgHeading + 180, 360);
    }
    return avgHeading;
}


// Convenience method to move avatar of a ARContact based
// on the angle with the current heading.
- (void) moveImage: (int) circle index: (int) i angle: (double) angle{
    // Horizontal position is determined by the difference in angle.
    // The coefficient of angle is experimentally determined.
    if (i >= iconImageViews_[circle].count) {
        SafeAssert(NO, @"ARDrawingManager bad call to moveImage");
        return;
    }
    
    double x = circleCentersX_ + angle * 10;
    
    // The vertical position is adjusted for the avatar to lie on the circle.
    //double y = (invert_ ? 1 : -1) * sqrt(circleRadii_[circle]*circleRadii_[circle] - (x - circleCentersX_)*(x - circleCentersX_)) + circleCentersYs_;// + arc4random() % 20 - 10;
    double y = [self getY:x circle:circle];
    
    // Calculate the alpha value based on the angle.
    // The formula is ad-hoc and experimentally determined.
    double alpha = 1;
    if (fabs(angle) > 20 && fabs(angle) < 30) {
        alpha = (30 - fabs(angle)) / 10;
        alpha *= alpha;
    } else if (fabs(angle) > 30) {
        alpha = 0;
    }
    // This plays down the effect of the circle alpha multiplier.
    alpha *= sqrt(circleAlphas_[circle]);
    
    AvatarView *avatar = [iconImageViews_[circle] objectAtIndex:i];
    [self moveImage:avatar x:x-dims_[circle] / 2 y:y - dims_[circle] / 2 alpha:alpha];
}

- (void)highlightAvatarView:(AvatarView *)avatarView
{
    
    if( avatarView ) {
        CALayer *newHighlightLayer = [avatarView.layer.sublayers objectAtIndex:0];

        [CATransaction begin];
        if( UsingHardwareFasterThanIPhone4() )
            [CATransaction setAnimationDuration:0.5];
        else
            [CATransaction setDisableActions:YES];
        _lastVisibleHighlightLayer.opacity = 0.f;
        newHighlightLayer.opacity = 1.f;
        [CATransaction commit];
        
        _lastVisibleHighlightLayer = newHighlightLayer;
    }
}

@end
