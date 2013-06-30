//
//  NotesCell.m
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotesCell.h"

#import "TTTAttributedLabel.h"
#import "Utility.h"

#define ColorLayerWidth         5.f
#define SideMargin              10.f
#define VerticalMargin          10.f
#define LeftDeletionMargin      30.f
#define RightDeletionMargin     100.f
#define DefaultAccessoryWidth   20.f

@interface NotesCell ()
@property (nonatomic, strong) CALayer *colorLayer;
@property (nonatomic, strong) TTTAttributedLabel *textLabel;
@property (nonatomic, strong) TTTAttributedLabel *detailTextLabel;
@end

@implementation NotesCell
@synthesize textLabel = __textLabel;
@synthesize detailTextLabel = __detailTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if( self ) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        _colorLayer = [CALayer new];
        [self.layer addSublayer:_colorLayer];
        
        [self.contentView addSubview:self.textLabel];
        [self.contentView addSubview:self.detailTextLabel];
        [self.contentView addSubview:self.topRightTextLabel];
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.textLabel.textColor = selected ? [UIColor whiteColor] : [[self class] defaultTextLabelColor];
    self.textLabel.text = self.textLabel.text;
    self.detailTextLabel.textColor = selected ? [UIColor whiteColor] : [[self class] defaultDetailTextLabelColor];
    self.detailTextLabel.text = self.detailTextLabel.text;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.colorLayer.frame = [self colorLayerRectForBounds:self.bounds];
    self.contentView.frame = [self contentRectForBounds:self.bounds];
    self.textLabel.frame = [self textRectForContentBounds:self.contentView.bounds];
    self.topRightTextLabel.frame = [self topRightTextRectForContentBounds:self.contentView.bounds];
    self.detailTextLabel.frame = [self detailTextRectForContentBounds:self.contentView.bounds];
}

- (CGRect)colorLayerRectForBounds:(CGRect)bounds {
    return (CGRect) {
        CGPointZero,
        ColorLayerWidth,
        bounds.size.height
    };
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
    return (CGRect) {
        ColorLayerWidth + SideMargin + self.editing * LeftDeletionMargin,
        VerticalMargin,
        bounds.size.width - 2.f * SideMargin - self.showingDeleteConfirmation * RightDeletionMargin - DefaultAccessoryWidth,
        bounds.size.height - 2.f * VerticalMargin
    };
}

- (CGRect)textRectForContentBounds:(CGRect)contentBounds {
    CGSize size = [self.textLabel sizeThatFits: (CGSize) {
        contentBounds.size.width,
        CGFLOAT_MAX
    }];
    return (CGRect) {
        CGPointZero,
        size
    };
}

- (CGRect)topRightTextRectForContentBounds:(CGRect)contentBounds {
    CGRect textRect = [self textRectForContentBounds:contentBounds];
    CGSize size = [self.topRightTextLabel sizeThatFits: (CGSize) {
        contentBounds.size.width - textRect.size.width,
        CGFLOAT_MAX
    }];
    return (CGRect) {
        contentBounds.size.width - size.width,
        0.f,
        size
    };
}

- (CGRect)detailTextRectForContentBounds:(CGRect)contentBounds {
    CGRect textRect = [self textRectForContentBounds:contentBounds];
    CGSize size = [self.detailTextLabel sizeThatFits: (CGSize) {
        contentBounds.size.width,
        CGFLOAT_MAX
    }];
    return (CGRect) {
        0.f,
        CGRectGetMaxY(textRect),
        size
    };
}

- (CGFloat)cellHeightForWidth:(CGFloat)width {
    CGFloat height = 0.f;
    [self layoutIfNeeded];
    CGRect partialContentBounds = (CGRect) {
        CGPointZero,
        width,
        0.f
    };
    height += VerticalMargin;
    height += [self textRectForContentBounds:partialContentBounds].size.height;
    height += [self detailTextRectForContentBounds:partialContentBounds].size.height;
    height += VerticalMargin;
    return height;
}

#pragma mark - Properties

- (TTTAttributedLabel *)createLabel {
    TTTAttributedLabel *label = [TTTAttributedLabel new];
    label.numberOfLines = 0;
    return label;
}

+ (UIColor *)defaultTextLabelColor {
    return [UIColor blackColor];
}

- (UILabel *)textLabel
{
    if( __textLabel )
        return __textLabel;

    [[super textLabel] removeFromSuperview];
    __textLabel = [self createLabel];
    __textLabel.font = [FontManager helveticaNeueWithSize:16.f];
    __textLabel.textColor = [[self class] defaultTextLabelColor];

    return __textLabel;
}

+ (UIColor *)defaultDetailTextLabelColor {
    return [UIColor colorWithWhite:0.7f alpha:1.f];
}

- (UILabel *)detailTextLabel
{
    if( __detailTextLabel )
        return __detailTextLabel;
    
    [[super detailTextLabel] removeFromSuperview];
    __detailTextLabel = [self createLabel];
    __detailTextLabel.font = [FontManager helveticaNeueWithSize:12.f];
    __detailTextLabel.textColor = [[self class] defaultDetailTextLabelColor];
    
    return __detailTextLabel;
}

+ (UIColor *)defaultTopRightTextLabelColor {
    return [UIColor colorWithWhite:0.7f alpha:1.f];
}

- (TTTAttributedLabel *)topRightTextLabel {
    if( _topRightTextLabel )
        return _topRightTextLabel;
    
    _topRightTextLabel = [self createLabel];
    _topRightTextLabel.textColor = [[self class] defaultTopRightTextLabelColor];
    
    return _topRightTextLabel;
}

//- (void)drawRect:(CGRect)rect {
//    draw1PxBottomBorder(UIGraphicsGetCurrentContext(), rect);
//}


@end
