//
//  EditRichTextViewController.m
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditRichTextViewController.h"

#import "UIViewController+KeyboardNotifications.h"

@interface EditRichTextViewController ()
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) UIToolbar *editingToolbar;
@property (nonatomic, weak) UIWindow *keyboardWindow;
@end

@implementation EditRichTextViewController {
    BOOL currentBoldStatus, currentItalicStatus, currentUnderlineStatus;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

        self.view.backgroundColor = [UIColor redColor];
    
    [self registerForKeyboardNotifications];
    [self checkSelection:self];
}

#pragma mark - Properties

- (UIWebView *)webView
{
    if( _webView )
        return _webView;
    
    UIWebView *webView = [UIWebView new];
    [webView loadData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NoteTemplate" ofType:@"html"]]
             MIMEType:@"text/html"
     textEncodingName:@"utf-8"
              baseURL:[[NSBundle mainBundle] bundleURL]];
    [self.view addSubview:webView];
    _webView = webView;
    
    return _webView;
}

- (UIToolbar *)editingToolbar
{
    if( _editingToolbar )
        return _editingToolbar;
    
    _editingToolbar = [UIToolbar new];
    _editingToolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.view layoutSubviews];
    
    return _editingToolbar;
}

- (UIWindow *)keyboardWindow
{
    if( _keyboardWindow )
        return _keyboardWindow;
    
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            _keyboardWindow = testWindow;
            break;
        }
    }
    
    return _keyboardWindow;
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    self.webView.frame = self.view.bounds;
    
    self.editingToolbar.frame = (CGRect) {
        0.f,
        -44.f,
        self.view.frame.size.width,
        44.f
    };
}

#pragma mark - Keyboard management

- (void)keyboardWillAppear:(NSNotification *)notification
{
    KeyboardNotificationUserInfo keyboardInfo = [notification keyboardUserInfo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeDefaultKeyboardAccessory];
    });
    
    self.editingToolbar.frame = (CGRect) {
        0.f,
        CGRectGetMaxY(self.view.frame),
        self.editingToolbar.frame.size
    };
    
    [self.keyboardWindow addSubview:self.editingToolbar];
    
    [UIView animateWithDuration:keyboardInfo.animationDuration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.editingToolbar.frame = CGRectMake(0.0f, CGRectGetMinY([notification keyboardUserInfo].frameEnd), self.view.frame.size.width, 44.f);
    } completion:nil];
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.editingToolbar.frame = (CGRect) {
            0.0f,
            self.view.frame.size.height,
            self.editingToolbar.frame.size
        };
    }];
}

- (void)keyboardDidDisappear:(NSNotification *)notification
{
    self.keyboardWindow = nil;
}

- (void)removeDefaultKeyboardAccessory {
    // Locate UIWebFormView.
    for (UIView *possibleFormView in [self.keyboardWindow subviews]) {
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if ([[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
            for (UIView *subview in [possibleFormView subviews]) {
                if ([[subview description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
                    [subview removeFromSuperview];
                }
            }
        }
    }
}

- (void)checkSelection:(id)sender {
    BOOL boldEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Bold')"] boolValue];
    BOOL italicEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Italic')"] boolValue];
    BOOL underlineEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Underline')"] boolValue];
    
    NSArray *segItemsArray = [NSArray arrayWithObjects:
                              (boldEnabled) ? @"[B]" : @"B",
                              italicEnabled ? @"[I]" : @"I",
                              underlineEnabled ? @"[U]" : @"U", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(textStyleSelected:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 150.f, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 2;
    segmentedControl.momentary = YES;
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, nil];
    
    if (currentBoldStatus != boldEnabled || currentItalicStatus != italicEnabled || currentUnderlineStatus != underlineEnabled || sender == self) {
        self.editingToolbar.items = barArray;
        currentBoldStatus = boldEnabled;
        currentItalicStatus = italicEnabled;
        currentUnderlineStatus = underlineEnabled;
    }
}

#pragma mark - Actions

- (void)textStyleSelected:(UISegmentedControl *)control
{
    switch (control.selectedSegmentIndex) {
        case TextStyleBold:
            [self bold];
            break;
            
        case TextStyleItalic:
            [self italic];
            break;
            
        case TextStyleUnderline:
            [self underline];
            break;
            
        default:
            break;
    }
}

- (void)bold {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
}

- (void)italic {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
}

- (void)underline {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
}

@end
