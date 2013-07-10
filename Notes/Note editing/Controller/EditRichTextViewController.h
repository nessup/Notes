//
//  EditRichTextViewController.h
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "WebViewController.h"

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

@interface EditRichTextViewController : WebViewController

@property (nonatomic, strong) Note *note;
@property (nonatomic, copy) NSString *searchTerm;

- (void)commitChangesToNote;
- (NSString *)plainTextContent;
- (void)focusAndSelectTitle;

@end
