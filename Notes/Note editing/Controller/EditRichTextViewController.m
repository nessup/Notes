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
#import "NoteManager.h"
#import "RTEGestureRecognizer.h"

#define ToolbarHeight       44.f

NSString *const WebViewEventCategoryChanged = @"categoryChanged";
NSString *const WebViewEventTitleChanged = @"titleChanged";

@interface EditRichTextViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIToolbar *editingToolbar;
@property (nonatomic) KeyboardNotificationUserInfo lastKeyboardInfo;
@property (nonatomic, weak) UIWindow *keyboardWindow;
@property (nonatomic) BOOL keyboardAppearing;

@property (nonatomic, strong) UISegmentedControl *textStyleControl;
@property (nonatomic, strong) UIBarButtonItem *textColorButton;
@property (nonatomic, strong) UISegmentedControl *alignmentControl;
@end

@implementation EditRichTextViewController {
    BOOL currentBoldStatus, currentItalicStatus, currentUnderlineStatus, currentUndoStatus, currentRedoStatus;
    //    NSString *currentFontName;
    NSString *currentForeColor;
    NSTimer *_selectionTimer;
    NSMutableArray *_afterDOMLoadsBlocks;
    BOOL _DOMLoaded;
    UIPopoverController *_imagePickerPopover;
}

- (id)init {
    return [self initWithLocalPageNamed:@"NoteTemplate" subdirectory:@"WebApp/NoteEditor"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    [self checkSelection:self];
    
    RTEGestureRecognizer *tapInterceptor = [[RTEGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet *touches, UIEvent *event) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchPoint = [touch locationInView:self.view];
        
        NSString *javascript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).toString()", touchPoint.x, touchPoint.y];
        NSString *elementAtPoint = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
        
        if( [elementAtPoint rangeOfString:@"canvas"].location != NSNotFound ) {
//            initialPointOfImage = touchPoint;
            self.webView.scrollView.scrollEnabled = NO;
        }
        else {
//            initialPointOfImage = CGPointZero;
        }
    };
    tapInterceptor.touchesEndedCallback = ^(NSSet *touches, UIEvent *event) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // And move that image!
        //        NSString *javascript = [NSString stringWithFormat:@"moveImageAtTo(%f, %f, %f, %f)", initialPointOfImage.x, initialPointOfImage.y, touchPoint.x, touchPoint.y];
        //        [self.webView stringByEvaluatingJavaScriptFromString:javascript];
        
        // All done, lets re-enable scrolling
        self.webView.scrollView.scrollEnabled = YES;
    };
    [self.webView.scrollView addGestureRecognizer:tapInterceptor];
    
    [self.view addSubview:self.editingToolbar];
    [self.view bringSubviewToFront:self.editingToolbar];
}

- (BOOL)handleWebViewEvent:(NSDictionary *)event {
    if( [event[WebViewEventName] isEqualToString:WebViewEventCategoryChanged] ) {
        [self categoryChanged:event];
    }
    else if( [event[WebViewEventName] isEqualToString:WebViewEventTitleChanged] ) {
        [self titleChanged:event];
    }
    else {
        return NO;
    }
    
    return YES;
}

#pragma mark - Web view callbacks

- (void)categoryChanged:(NSDictionary *)event {
    self.note.category = event[WebViewEventValue];
}

- (void)titleChanged:(NSDictionary *)event {
    self.note.title = event[WebViewEventValue];
}

#pragma mark - Properties

- (UIToolbar *)editingToolbar {
    if( _editingToolbar ) {
        return _editingToolbar;
    }
    
    _editingToolbar = [UIToolbar new];
    _editingToolbar.barStyle = UIBarStyleBlackOpaque;
    
    return _editingToolbar;
}

- (void)setNote:(Note *)note {
    if( _note == note ) {
        return;
    }
    
    _note = note;
    
    [self doAfterDOMLoads:^{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        dictionary[@"title"] = note.title ? note.title : @"";
        
        dictionary[@"placeholderString"] = [note titlePlaceholder];
        
        dictionary[@"content"] = note.content ? note.content : @"";
        
        dictionary[@"categories"] = @[NoteCategoryClassNotes, NoteCategoryAssignment];
        
        dictionary[@"selectedCategory"] = note.category ? note.category : NoteCategoryClassNotes;
        
        dictionary[@"topRightLines"] = note.topRightLines ? note.topRightLines : @"";
        
        dictionary[@"editingMode"] = @(EditingModeWriting);
        
        [self.bridge send:dictionary];
    }];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat keyboardOffset = self.keyboardAppearing ? self.lastKeyboardInfo.frameEnd.size.height : ToolbarHeight;
    self.webView.frame = (CGRect) {
        CGPointZero,
        self.view.frame.size.width,
        self.view.frame.size.height - keyboardOffset
    };
    self.editingToolbar.frame = (CGRect) {
        0.f,
        CGRectGetMaxY(self.webView.frame),
        self.view.frame.size.width,
        ToolbarHeight
    };
}

#pragma mark - Keyboard management

- (void)keyboardWillAppear:(NSNotification *)notification {
    self.lastKeyboardInfo = [notification keyboardUserInfo];
    self.keyboardAppearing = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeDefaultKeyboardAccessory];
    });
        
    [UIView animateWithDuration:self.lastKeyboardInfo.animationDuration
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self viewWillLayoutSubviews];
                     }
                     completion:nil];
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    self.lastKeyboardInfo = [notification keyboardUserInfo];
    self.keyboardAppearing = NO;
    
    [UIView animateWithDuration:self.lastKeyboardInfo.animationDuration
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self viewWillLayoutSubviews];
                     }
                     completion:nil];
}


- (void)removeDefaultKeyboardAccessory {
    // Locate UIWebFormView.
    for( UIView *possibleFormView in [self.keyboardWindow subviews] ) {
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if( [[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound ) {
            for( UIView *subview in [possibleFormView subviews] ) {
                if( [[subview description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound ) {
                    [subview removeFromSuperview];
                }
            }
        }
    }
}

- (UIWindow *)keyboardWindow {
    if( _keyboardWindow ) {
        return _keyboardWindow;
    }
    
    for( UIWindow *testWindow in [[UIApplication sharedApplication] windows] ) {
        if( ![[testWindow class] isEqual:[UIWindow class]] ) {
            _keyboardWindow = testWindow;
            break;
        }
    }
    
    return _keyboardWindow;
}

- (void)checkSelection:(id)sender {
    BOOL boldEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Bold')"] boolValue];
    BOOL italicEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Italic')"] boolValue];
    BOOL underlineEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Underline')"] boolValue];
    
    NSMutableArray *items = [NSMutableArray new];
    
    NSArray *segItemsArray = [NSArray arrayWithObjects:
                              (boldEnabled) ? @"[B]"   :@"B",
                              italicEnabled ? @"[I]"   :@"I",
                              underlineEnabled ? @"[U]":@"U", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    
    [segmentedControl addTarget:self action:@selector(textStyleSelected:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 150.f, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [items addObject:flexibleSpace];
    [items addObject:segmentedControlButtonItem];
    
    if( currentBoldStatus != boldEnabled || currentItalicStatus != italicEnabled || currentUnderlineStatus != underlineEnabled || sender == self ) {
        self.navigationItem.rightBarButtonItems = items;
        currentBoldStatus = boldEnabled;
        currentItalicStatus = italicEnabled;
        currentUnderlineStatus = underlineEnabled;
    }
    
    // Font Color Picker
    UIBarButtonItem *fontColorPicker = [[UIBarButtonItem alloc] initWithTitle:@"Color" style:UIBarButtonItemStyleBordered target:self action:@selector(displayFontColorPicker:)];
    
    NSString *foreColor = [self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('foreColor')"];
    UIColor *color = [self colorFromRGBValue:foreColor];
    
    if( color ) {
        [fontColorPicker setTintColor:color];
    }
    
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
    
    UIBarButtonItem *insertPhoto = [[UIBarButtonItem alloc] initWithTitle:@"Photo+" style:UIBarButtonItemStyleBordered target:self action:@selector(insertPhoto:)];
    [items addObject:insertPhoto];
    
    segItemsArray = @[@"Write", @"Draw"];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(modeSelected:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 150.f, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    [items addObject:segmentedControlButtonItem];
    
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
    
    if( ![currentForeColor isEqualToString:foreColor] /*|| ![currentFontName isEqualToString:fontName] || currentUndoStatus != undoAvailable || currentRedoStatus != redoAvailable*/ || sender == self ) {
        self.editingToolbar.items = items;
        currentForeColor = foreColor;
        //        currentFontName = fontName;
        //        currentUndoStatus = undoAvailable;
        //        currentRedoStatus = redoAvailable;
    }
}

#pragma mark - Actions

- (void)modeSelected:(UISegmentedControl *)sender {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"App.setEditingMode(%d)", sender.selectedSegmentIndex]];
}

- (void)textStyleSelected:(UISegmentedControl *)control {
    switch( control.selectedSegmentIndex ) {
        case TextStyleBold :
            [self bold];
            break;
            
        case TextStyleItalic :
            [self italic];
            break;
            
        case TextStyleUnderline :
            [self underline];
            break;
            
        default:
            break;
    }
}

- (void)textAlignmentSelected:(UISegmentedControl *)control {
    switch( control.selectedSegmentIndex ) {
        case TextAlignmentLeft:
            [self.webView stringByEvaluatingJavaScriptFromString:@"App.alignLeft()"];
            break;
            
        case TextAlignmentCenter:
            [self.webView stringByEvaluatingJavaScriptFromString:@"App.alignCenter()"];
            break;
            
        case TextAlignmentRight:
            [self.webView stringByEvaluatingJavaScriptFromString:@"App.alignRight()"];
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

- (void)commitChangesToNote {
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"App.getTitle()"];
    NSString *content = [self.webView stringByEvaluatingJavaScriptFromString:@"App.getContent();"];
    NSString *plainTextContent = [self.webView stringByEvaluatingJavaScriptFromString:@"App.getPlainTextContent()"];
    NSString *topRightLines = [self.webView stringByEvaluatingJavaScriptFromString:@"App.getTopRightLines();"];
    NSString *category = [self.webView stringByEvaluatingJavaScriptFromString:@"App.getSelectedCategory();"];
    
    self.note.title = title;
    self.note.content = content;
    self.note.plainTextContent = plainTextContent;
    self.note.topRightLines = topRightLines;
    self.note.category = category;
    
    [[NoteManager sharedInstance] saveToDisk];
    
    [[[NoteManager sharedInstance] context] refreshObject:self.note mergeChanges:YES];
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
    
    if( [actionSheet.title isEqualToString:@"Select a font"] ) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontName', false, '%@')", selectedButtonTitle]];
    }
    else { [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", selectedButtonTitle]]; }
}

#pragma mark Inserting photos

- (void)insertPhoto:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    [popover presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _imagePickerPopover = popover;
}

static int i = 0;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Obtain the path to save to
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"photo%i.png", i]];
    
    // Extract image from the picker and save it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = nil;
    
    if( [mediaType isEqualToString:@"public.image"] ) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:imagePath atomically:YES];
    }
    
//    NSLog(@"lol = %@", [NSString stringWithFormat:@"insertImageWithBase64('%@')", imagePath]);
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"App.insertImageWithBase64('%@',%f,%f)", imagePath, image.size.width, image.size.height]];
    
    [_imagePickerPopover dismissPopoverAnimated:YES];
    i++;
}

#pragma mark - Utility

- (UIColor *)colorFromRGBValue:(NSString *)rgb { // General format is 'rgb(red, green, blue)'
    if( [rgb rangeOfString:@"rgb"].location == NSNotFound ) {
        return nil;
    }
    
    NSMutableString *mutableCopy = [rgb mutableCopy];
    [mutableCopy replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
    [mutableCopy replaceCharactersInRange:NSMakeRange(mutableCopy.length - 1, 1) withString:@""];
    
    NSArray *components = [mutableCopy componentsSeparatedByString:@","];
    int red = [[components objectAtIndex:0] intValue];
    int green = [[components objectAtIndex:1] intValue];
    int blue = [[components objectAtIndex:2] intValue];
    
    UIColor *retVal = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
    return retVal;
}

- (NSString *)plainTextContent {
    return [self.webView stringByEvaluatingJavaScriptFromString:@"App.getPlainTextContent()"];
}

- (void)setSearchTerm:(NSString *)searchTerm {
    _searchTerm = searchTerm;
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"App.doSearch('%@')", searchTerm]];
}

- (void)focusAndSelectTitle {
    [self.webView stringByEvaluatingJavaScriptFromString:@"App.focusAndSelectTitle()"];
}

@end
