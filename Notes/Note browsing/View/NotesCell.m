
//  NotesCell.m
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotesCell.h"

#import "TTTAttributedLabel.h"


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
    //    self.detailTextLabel.textColor = selected ? [UIColor whiteColor] : [[self class] defaultDetailTextLabelColor];
    self.detailTextLabel.text = self.detailTextLabel.text;
    
}

- (void)setLeftView:(UIView *)leftView {
    [_leftView removeFromSuperview];
    _leftView = leftView;
    [self addSubview:leftView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.colorLayer.frame = [self colorLayerRectForBounds:self.bounds];
    self.leftView.frame = [self leftViewRectForBounds:self.bounds];
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

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    if( self.leftView.frame.size.height ) {
        return (CGRect) {
            ColorLayerWidth + SideMargin + self.editing * LeftDeletionMargin,
            VerticalMargin,
            self.leftView.frame.size
        };
    }
    else {
        return CGRectZero;
    }
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
    CGRect leftViewRect = [self leftViewRectForBounds:bounds];
    CGFloat width = bounds.size.width - 2.f * SideMargin - self.showingDeleteConfirmation * RightDeletionMargin - DefaultAccessoryWidth;
    CGSize constraintSize = (CGSize) {
        width,
        0.f
    };
    CGSize textSize = [self.textLabel sizeThatFits:constraintSize];
    CGSize detailTextSize = [self.detailTextLabel sizeThatFits:constraintSize];
    CGFloat height = textSize.height + detailTextSize.height;
    return (CGRect) {
        CGRectGetMaxX(leftViewRect) + SideMargin,
        CenterCoordinateVerticallyInView(self, height),
        width,
        textSize.height
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
    height += [self textRectForContentBounds:partialContentBounds].size.height;
    height += [self detailTextRectForContentBounds:partialContentBounds].size.height;
    height = MAX(height, self.leftView.frame.size.height);
    height += 2.f*VerticalMargin;
    return height;
}

#pragma mark - Properties

- (TTTAttributedLabel *)createLabel {
    TTTAttributedLabel *label = [TTTAttributedLabel new];
    //    label.numberOfLines = 0;
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
    //    __detailTextLabel.textColor = [[self class] defaultDetailTextLabelColor];
    
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

#pragma mark - Highlighting

- (void)setHighlightText:(NSString *)highlightText {
    _highlightText = [highlightText copy];
    [self updateHighlighting];
}

- (void)updateHighlighting {
    //    NSString *detailText = self.detailTextLabel.text;
    //    NSString *highlightText = self.highlightText;
    NSMutableAttributedString * (^formatForHighlighting)(NSMutableAttributedString *mutableAttributedString, NSString *text, NSString *highlightText, UIFont *highlightFont) = ^NSMutableAttributedString * (NSMutableAttributedString *mutableAttributedString, NSString *text, NSString *highlightText, UIFont *highlightFont) {
        if( highlightText.length ) {
            NSRange range = [text rangeOfString:highlightText options:NSCaseInsensitiveSearch];
            
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)highlightFont.fontName, highlightFont.pointSize, NULL);
            if( range.location != NSNotFound ) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:range];
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[[UIColor colorWithHexString:@"ffc963"] CGColor] range:range];
                CFRelease(font);
            }
        }
        return mutableAttributedString;
    };
    
    dispatch_async(dispatch_get_current_queue(), ^{
        NSString *text = self.detailTextLabel.text;
        NSString *highlightText = self.highlightText;
        UIFont *highlightFont = [FontManager boldHelveticaNeueWithSize:12.f];
        [self.detailTextLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            return formatForHighlighting(mutableAttributedString, text, highlightText, highlightFont);
        }];
        
        text = self.textLabel.text;
        highlightFont = [FontManager boldHelveticaNeueWithSize:16.f];
        [self.textLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            return formatForHighlighting(mutableAttributedString, text, highlightText, highlightFont);
        }];
        [self setNeedsLayout];
    });
}

@end
