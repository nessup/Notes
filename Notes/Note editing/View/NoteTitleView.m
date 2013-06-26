//
//  NoteTitleView.m
//  Notes
//
//  Created by Dany on 6/19/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NoteTitleView.h"

@interface NoteTitleView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@end

@implementation NoteTitleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        UILabel *(^createLabel)(UIFont *) = ^UILabel *(UIFont *font) {
            UILabel *label = [UILabel new];
            label.font = font;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithWhite:0.3f alpha:1.f];
            label.shadowColor = [UIColor whiteColor];
            label.shadowOffset = (CGSize) {0.f, 1.f };
            [self addSubview:label];
            return label;
        };
        _titleLabel = createLabel([FontManager boldHelveticaNeueWithSize:16.f]);
        _subtitleLabel = createLabel([FontManager helveticaNeueWithSize:11.f]);
    }

    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
    [self updateView];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
    [self updateView];
}

- (void)updateView {
    self.titleLabel.text = self.title;
    self.subtitleLabel.text = self.subtitle;
    [self sizeToFit];
}

- (void)layoutSubviews {
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect) {
        roundf(self.frame.size.width / 2.f - self.titleLabel.frame.size.width / 2.f),
        0.f,
        self.titleLabel.frame.size
    };
    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.frame = (CGRect) {
        roundf(self.frame.size.width / 2.f - self.subtitleLabel.frame.size.width / 2.f),
        CGRectGetMaxY(self.titleLabel.frame),
        self.subtitleLabel.frame.size
    };
}

- (CGSize)sizeThatFits:(CGSize)size {
    [self layoutSubviews];
    return (CGSize) {
               MAX(self.titleLabel.frame.size.width, self.subtitleLabel.frame.size.width),
               CGRectGetMaxY(self.subtitleLabel.frame)
    };
}

@end
