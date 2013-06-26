//
//  NotebookIconView.m
//  Notes
//
//  Created by Dany on 6/24/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotebookIconView.h"

#import "Utility.h"

#define Width  88.f
#define Height 114.f

@interface NotebookIconView ()
@property (nonatomic, strong) CAGradientLayer *layer;
@end

@implementation NotebookIconView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.layer.shadowColor = [UIColor colorWithWhite:0.f alpha:0.5f].CGColor;
        self.layer.shadowOffset = (CGSize) {0.f, 5.f };
        self.layer.shadowRadius = 5.f;

        _firstLetterLabel = [UILabel new];
        _firstLetterLabel.alpha = 0.6f;
        _firstLetterLabel.backgroundColor = [UIColor clearColor];
        _firstLetterLabel.shadowColor = [UIColor colorWithWhite:0.f alpha:0.2f];
        _firstLetterLabel.shadowOffset = (CGSize) {0.f, 1.f };
        _firstLetterLabel.font = [FontManager boldAmericanTypewriter:48.f];
        [self addSubview:_firstLetterLabel];
    }

    return self;
}

#pragma mark - Layout

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
//    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)layoutSubviews {
    [self.firstLetterLabel sizeToFit];
    [self.firstLetterLabel centerMiddle];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return (CGSize) {
               Width,
               Height
    };
}

#pragma mark - Gradient

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    UIColor *darkenedColor = ChangeBrightnessOfColorByAmount(_color, 0.75f);
    self.layer.colors = @[(id)_color.CGColor, (id)darkenedColor.CGColor];
}

@end
