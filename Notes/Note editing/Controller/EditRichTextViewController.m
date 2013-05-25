//
//  EditRichTextViewController.m
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditRichTextViewController.h"

#import "Model.h"
#import "WebViewJavascriptBridge_iOS.h"
#import "AppDelegate.h"

NSString * const WebViewEventName = @"eventName";
NSString * const WebViewEventCategoryChanged = @"categoryChanged";

NSString * const WebViewEventValue = @"value";

@interface EditRichTextViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIToolbar *editingToolbar;
@property (nonatomic, weak) UIWindow *keyboardWindow;

@property (nonatomic, strong) UISegmentedControl *textStyleControl;
@property (nonatomic, strong) UIBarButtonItem *textColorButton;
@property (nonatomic, strong) UISegmentedControl *alignmentControl;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

@end

@implementation EditRichTextViewController {
    BOOL currentBoldStatus, currentItalicStatus, currentUnderlineStatus, currentUndoStatus, currentRedoStatus;
    //    NSString *currentFontName;
    NSString *currentForeColor;
    NSTimer *_selectionTimer;
    NSMutableArray *_afterDOMLoadsBlocks;
    BOOL _DOMLoaded;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self ) {
        _afterDOMLoadsBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self registerForKeyboardNotifications];
    
    [self checkSelection:self];
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView handler:^(id data, WVJBResponseCallback responseCallback) {
        if( [data isKindOfClass:[NSString class]] && [data isEqualToString:@"DOMDidLoad"] ) {
            _DOMLoaded = YES;
            for( void (^block)() in _afterDOMLoadsBlocks ) {
                block();
            }
            [_afterDOMLoadsBlocks removeAllObjects];
            
            _selectionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f repeats:YES usingBlock:^(NSTimer *timer) {
                static int count = 0;
                
                [self checkSelection:nil];
                
                if( count % 50 == 0 ) {
                    [self save];
                }
                
                count++;
            }];
        }
        else if( [data isKindOfClass:[NSDictionary class]] ) {
            NSDictionary *dictionary = (NSDictionary *)data;
            
            if( [dictionary[WebViewEventName] isEqualToString:WebViewEventCategoryChanged] ) {
                [self categoryChanged:dictionary];
            }
        }
    }];
}

- (void)loadLocalPageNamed:(NSString *)pageName
{
    _DOMLoaded = NO;
    [_afterDOMLoadsBlocks removeAllObjects];
    
    [self.webView loadData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:pageName ofType:@"html"]]
                  MIMEType:@"text/html"
          textEncodingName:@"utf-8"
                   baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark - Web view callbacks

- (void)categoryChanged:(NSDictionary *)event {
    self.note.category = event[WebViewEventValue];
}

#pragma mark - Properties

- (UIWebView *)webView
{
    if( _webView )
        return _webView;
    
    _webView = [UIWebView new];
    _webView.keyboardDisplayRequiresUserAction = NO;
    [_webView loadData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NoteTemplate" ofType:@"html"]]
             MIMEType:@"text/html"
     textEncodingName:@"utf-8"
              baseURL:[[NSBundle mainBundle] bundleURL]];
    [self.view addSubview:_webView];
    
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

- (void)setNote:(Note *)note
{
    _note = note;
    
    [self doAfterDOMLoads:^{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        dictionary[@"title"] = note.title ? note.title : @"";
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        dictionary[@"placeholderString"] = [NSString stringWithFormat:@"Untitled Note on %@", [formatter stringFromDate:note.dateCreated]];
        
        dictionary[@"content"] = note.content ? note.content : @"";
     
        dictionary[@"categories"] = @[NoteCategoryClassNotes, NoteCategoryAssignment];

        dictionary[@"selectedCategory"] = note.category ? note.category : NoteCategoryClassNotes;
        
        dictionary[@"topRightLines"] = note.topRightLines ? note.topRightLines : @"";
     
        [self.bridge send:dictionary];
     }];
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
    
    NSMutableArray *items = [NSMutableArray new];
    
    NSArray *segItemsArray = [NSArray arrayWithObjects:
                              (boldEnabled) ? @"[B]" : @"B",
                              italicEnabled ? @"[I]" : @"I",
                              underlineEnabled ? @"[U]" : @"U", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(textStyleSelected:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 150.f, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [items addObject:flexibleSpace];
    [items addObject:segmentedControlButtonItem];
    
    if (currentBoldStatus != boldEnabled || currentItalicStatus != italicEnabled || currentUnderlineStatus != underlineEnabled || sender == self) {
        self.navigationItem.rightBarButtonItems = items;
        currentBoldStatus = boldEnabled;
        currentItalicStatus = italicEnabled;
        currentUnderlineStatus = underlineEnabled;
    }
    
    // Font Color Picker
    UIBarButtonItem *fontColorPicker = [[UIBarButtonItem alloc] initWithTitle:@"Color" style:UIBarButtonItemStyleBordered target:self action:@selector(displayFontColorPicker:)];
    
    NSString *foreColor = [self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('foreColor')"];
    UIColor *color = [self colorFromRGBValue:foreColor];
    if (color)
        [fontColorPicker setTintColor:color];
    
    [items addObject:fontColorPicker];
    
    //    // Font Picker
    //    UIBarButtonItem *fontPicker = [[UIBarButtonItem alloc] initWithTitle:@"Font" style:UIBarButtonItemStyleBordered target:self action:@selector(displayFontPicker:)];
    //
    //    NSString *fontName = [self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontName')"];
    //    UIFont *font = [UIFont fontWithName:fontName size:[UIFont systemFontSize]];
    //    if (font)
    //        [fontPicker setTitleTextAttributes:[NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont] forState:UIControlStateNormal];
    //
    //    [items addObject:fontPicker];
    
    UISegmentedControl *alignmentControl = [[UISegmentedControl alloc] initWithItems:@[@"L", @"C", @"R"]];
    [alignmentControl addTarget:self action:@selector(textAlignmentSelected:) forControlEvents:UIControlEventValueChanged];
    alignmentControl.frame = CGRectMake(0, 0, 150.f, 30);
    alignmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    alignmentControl.momentary = YES;
    UIBarButtonItem *alignmentButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)alignmentControl];
    
    [items addObject:alignmentButtonItem];
    
    //    UIBarButtonItem *undo = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undo)];
    //    UIBarButtonItem *redo = [[UIBarButtonItem alloc] initWithTitle:@"Redo" style:UIBarButtonItemStyleBordered target:self action:@selector(redo)];
    //
    //    BOOL undoAvailable = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('undo')"] boolValue];
    //    BOOL redoAvailable = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('redo')"] boolValue];
    //
    //    if (!undoAvailable)
    //        [undo setEnabled:NO];
    //
    //    if (!redoAvailable)
    //        [redo setEnabled:NO];
    //
    //    [items addObject:undo];
    //    [items addObject:redo];
    
    if (![currentForeColor isEqualToString:foreColor] /*|| ![currentFontName isEqualToString:fontName] || currentUndoStatus != undoAvailable || currentRedoStatus != redoAvailable*/ || sender == self) {
        self.editingToolbar.items = items;
        currentForeColor = foreColor;
        //        currentFontName = fontName;
        //        currentUndoStatus = undoAvailable;
        //        currentRedoStatus = redoAvailable;
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

- (void)textAlignmentSelected:(UISegmentedControl *)control
{
    switch (control.selectedSegmentIndex) {
        case TextAlignmentLeft:
            [self.webView stringByEvaluatingJavaScriptFromString:@"alignLeft()"];
            break;
            
        case TextAlignmentCenter:
            [self.webView stringByEvaluatingJavaScriptFromString:@"alignCenter()"];
            break;
            
        case TextAlignmentRight:
            [self.webView stringByEvaluatingJavaScriptFromString:@"alignRight()"];
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

//- (void)undo {
//    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
//}
//
//- (void)redo {
//    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
//}

- (void)save {
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"getTitle()"];
    NSString *content = [self.webView stringByEvaluatingJavaScriptFromString:@"getContent();"];
    NSString *topRightLines = [self.webView stringByEvaluatingJavaScriptFromString:@"getTopRightLines();"];
    NSString *category = [self.webView stringByEvaluatingJavaScriptFromString:@"getSelectedCategory();"];
    
    self.note.title = title;
    self.note.content = content;
    self.note.topRightLines = topRightLines;
    self.note.category = category;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

- (void)displayFontColorPicker:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Blue", @"Yellow", @"Green", @"Red", @"Orange", nil];
    [actionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
}

//- (void)displayFontPicker:(id)sender {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Helvetica", @"Courier", @"Arial", @"Zapfino", @"Verdana", nil];
//    [actionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
//}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    selectedButtonTitle = [selectedButtonTitle lowercaseString];
    
    if ([actionSheet.title isEqualToString:@"Select a font"])
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontName', false, '%@')", selectedButtonTitle]];
    else
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", selectedButtonTitle]];
}

#pragma mark - Utility

- (UIColor *)colorFromRGBValue:(NSString *)rgb { // General format is 'rgb(red, green, blue)'
    if ([rgb rangeOfString:@"rgb"].location == NSNotFound)
        return nil;
    
    NSMutableString *mutableCopy = [rgb mutableCopy];
    [mutableCopy replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
    [mutableCopy replaceCharactersInRange:NSMakeRange(mutableCopy.length-1, 1) withString:@""];
    
    NSArray *components = [mutableCopy componentsSeparatedByString:@","];
    int red = [[components objectAtIndex:0] intValue];
    int green = [[components objectAtIndex:1] intValue];
    int blue = [[components objectAtIndex:2] intValue];
    
    UIColor *retVal = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return retVal;
}

- (void)doAfterDOMLoads:(void (^)())completion
{
    if( _DOMLoaded ) {
        if( completion ) {
            completion();
        }
    }
    else {
        [_afterDOMLoadsBlocks addObject:[completion copy]];
    }
}

@end
