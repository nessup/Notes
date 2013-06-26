//
//  ColorPickerView.m
//  Notes
//
//  Created by Dany on 6/16/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "ColorPickerView.h"

#import "Utility.h"

#define ColorDiameter             44.f
#define DefaultInterColorDistance 10.f

static NSArray *DefaultColors = nil;

@interface ColorPickerView ()

@property (nonatomic, strong) NSArray *colorViews;
@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic) NSUInteger selectedColorIndex;

@end

@implementation ColorPickerView

+ (void)initialize {
    DefaultColors = @[
            [UIColor whiteColor],
            [UIColor redColor],
            [UIColor magentaColor],
            [UIColor orangeColor],
            [UIColor yellowColor],
            [UIColor greenColor],
            [UIColor cyanColor],
            [UIColor blueColor],
            [UIColor purpleColor]
        ];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if( self ) {
        self.backgroundColor = [UIColor whiteColor];
        _selectedColor = DefaultColors[0];
        [self updateView];
    }

    return self;
}

- (void)updateView {
    if( !self.colorViews ) {
        NSMutableArray *colorViews = [NSMutableArray new];
        int i = 0;

        for( UIColor *color in DefaultColors ) {
            UIView *view = [self createColorViewWithColor:color];
            view.tag = i;
            [self addSubview:view];
            [colorViews addObject:view];
            i++;
        }

        self.colorViews = colorViews;
    }

    if( !self.selectionView ) {
        self.selectionView = [self createSelectionView];
        [self addSubview:self.selectionView];
    }

    [self setNeedsLayout];
}

- (void)layoutSubviews {
    CGFloat distanceBetweenLayers = (self.frame.size.width - self.colorViews.count * ColorDiameter) / (self.colorViews.count - 1) + ColorDiameter;
    
    int i = 0;
    
    for( UIView *colorView in self.colorViews ) {
        colorView.frame = (CGRect) {
            i *distanceBetweenLayers,
            0.f,
            ColorDiameter,
            ColorDiameter
        };
        
        if( colorView.tag == self.selectedColorIndex ) {
            self.selectionView.center = colorView.center;
        }
        
        i++;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return (CGSize) {
        self.colorViews.count *ColorDiameter + (self.colorViews.count - 1) * DefaultInterColorDistance,
        ColorDiameter
    };
}

#pragma mark - Color views

- (UIView *)createColorViewWithColor:(UIColor *)color {
    UIColor *darkenedColor = ChangeBrightnessOfColorByAmount(color, 0.9f);
    CAGradientLayer *layer = [CAGradientLayer layer];

    layer.colors = @[(id)color.CGColor, (id)darkenedColor.CGColor];
    layer.cornerRadius = 3.f;
    CGRect frame = (CGRect) {
        CGPointZero,
        ColorDiameter,
        ColorDiameter
    };
    layer.frame = frame;
    UIControl *view = [UIControl new];
    [view.layer addSublayer:layer];
    [view addTarget:self action:@selector(colorViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    view.frame = frame;
    return view;
}

- (void)colorViewTapped:(UIView *)sender {
    self.selectedColorIndex = sender.tag;
    self.selectedColor = DefaultColors[self.selectedColorIndex];
    [self updateView];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Selection

- (UIView *)createSelectionView {
    UIView *view = [UIView new];

    view.frame = (CGRect) {
        CGPointZero,
        ColorDiameter + 10.f,
        ColorDiameter + 10.f
    };
    view.backgroundColor = [UIColor clearColor];
    view.layer.borderColor = [UIColor colorWithWhite:0.7f alpha:1.f].CGColor;
    view.layer.borderWidth = 3.f;
    view.layer.cornerRadius = 5.f;
    return view;
}

@end
