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

@interface EditRichTextViewController : UIViewController

@property (nonatomic, weak, readonly) UIWebView *webView;

@end
