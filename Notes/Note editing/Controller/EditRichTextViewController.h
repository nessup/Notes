//
//  EditRichTextViewController.h
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    TextStyleBold,
    TextStyleItalic,
    TextStyleUnderline
};

enum {
    TextAlignmentLeft,
    TextAlignmentCenter,
    TextAlignmentRight
};

enum {
    EditingModeWriting,
    EditingModeDrawing
};

@class Note;

@interface EditRichTextViewController : UIViewController

@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, strong) Note *note;
@property (nonatomic, copy) NSString *searchTerm;

- (void)loadLocalPageNamed:(NSString *)pageName;
- (void)commitChangesToNote;
- (void)doAfterDOMLoads:(void(^) ())completion;
- (NSString *)plainTextContent;
- (void)focusAndSelectTitle;
- (void)resignFirstResponder;

@end
