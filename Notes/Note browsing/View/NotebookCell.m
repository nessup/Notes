//
//  NotebookView.m
//  Notes
//
//  Created by Dany on 6/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotebookCell.h"

#import "NotebookIconView.h"

#define VerticalMargin 10.f

@interface NotebookCell ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic) BOOL placeholding;
@end

@implementation NotebookCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if( self ) {
        self.backgroundColor = [UIColor clearColor];

        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [FontManager helveticaNeueWithSize:16.f];
        _titleLabel.shadowColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        _titleLabel.shadowOffset = (CGSize) {0.f, 1.f };
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];

        _iconView = [NotebookIconView new];
        [self addSubview:_iconView];
        
        _placeholding = YES;
    }

    return self;
}

#pragma mark - Layout

- (CGFloat)minimumHeight {
    return self.iconView.frame.size.height + VerticalMargin + self.titleLabel.font.lineHeight*self.titleLabel.numberOfLines;
}

- (void)layoutSubviews {
    [self.iconView sizeToFit];
    CGSize titleSize = [self.titleLabel sizeThatFits:(CGSize) {NotebookCellMaxWidth, CGFLOAT_MAX }];
    self.titleLabel.frame = (CGRect) {
        0.f,
        CGRectGetMaxY(self.iconView.frame) + VerticalMargin,
        titleSize
    };
    [self.iconView centerHorizontally];
    [self.titleLabel centerHorizontally];
}

- (CGSize)sizeThatFits:(CGSize)size {
    [self layoutSubviews];
    return (CGSize) {
        NotebookCellMaxWidth,
        MAX(CGRectGetMaxY(self.titleLabel.frame), self.minimumHeight)
    };
}

#pragma mark - Properties

- (void)setPlaceholding:(BOOL)placeholding {
    _placeholding = placeholding;
    UIColor *textColor = nil;
    if( _placeholding ) {
        textColor = [UIColor grayColor];
        self.titleLabel.text = @"Your New Notebook";
    }
    else {
        textColor = [UIColor blackColor];
    }
    self.titleLabel.textColor = textColor;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    self.placeholding = (title.length == 0);
    [self setNeedsLayout];
}

- (NSString *)title {
    if( self.placeholding )
        return @"";
    
    return self.titleLabel.text;
}

@end
